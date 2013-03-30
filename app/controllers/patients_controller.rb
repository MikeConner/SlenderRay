class PatientsController < ApplicationController
  respond_to :js, :html
  
  before_filter :authenticate_user!
  before_filter :ensure_technician
  before_filter :ensure_own_patient, :only => [:edit, :update, :treat]
  load_and_authorize_resource

  def index
    @facility = current_user.treatment_facility
    @patients = Patient.where('treatment_facility_id = ?', @facility.id).order('upper(name) asc').paginate(:page => params[:page])
  end
  
  def show
    @patient = Patient.find(params[:id])  
    @plans = @patient.treatment_plans.order('updated_at desc')
  end
  
  # Start or Resume session (shortcut from User Show or Manage patients)
  def treat
    resume_session = @patient.unfinished_session
    if resume_session.nil?
      resume_plan = @patient.unfinished_plan
      if resume_plan.nil?
        redirect_to root_path, :alert => 'No active treatment plan for this patient' # shouldn't happen
      else
        machine = Machine.first
        new_session = resume_plan.treatment_sessions.build(:machine_id => machine.id)
        new_session.build_process_timer(:duration_seconds => resume_plan.treatments_per_session * machine.minutes_per_treatment * 60)
        if new_session.save
          redirect_to edit_treatment_session_path(new_session)
        end    
      end
    else
      redirect_to edit_treatment_session_path(resume_session)
    end
  end
  
  def new
    @facility = current_user.treatment_facility
    if 0 == @facility.treatment_plan_templates.where("type = 'TreatmentPlanTemplate'").count
      redirect_to root_path, :alert => I18n.t('no_templates_found')
    end
    @patient = @facility.patients.build
  end
  
  def edit
    # Filter sets patient and facility
    if 0 == @facility.treatment_plan_templates.where("type = 'TreatmentPlanTemplate'").count
      redirect_to root_path, :alert => I18n.t('no_templates_found')
    end
  end

  def create    
    if @patient.save
      template = TreatmentPlanTemplate.find_by_description(params[:plan_template])
      @plan = TreatmentPlan.create_from_template(template, @patient)
      
      if I18n.t('create_and_treat') == params[:commit]
        @treatment_session = @plan.treatment_sessions.build
        # Just pick the first machine; they can change it later
        machine = @patient.treatment_facility.machines.first
        @treatment_session.machine_id = machine.id
        @treatment_session.build_process_timer(:duration_seconds => @treatment_session.treatment_plan.treatments_per_session * machine.minutes_per_treatment * 60)
        
        if @treatment_session.save
          redirect_to edit_treatment_session_path(@treatment_session) and return
        end    
      else
        redirect_to edit_patient_path(@patient), :notice => I18n.t('patient_created')
      end
    else
      @facility = current_user.treatment_facility
      render 'new'
    end
    
    rescue
      redirect_to new_patient_path, :alert => I18n.t('cannot_create_patient')
  end

  def update
    # Filter sets @patient and @facility
    if @patient.update_attributes(params[:patient])
      if params[:plan_template]
        template = TreatmentPlanTemplate.find_by_description(params[:plan_template])
        TreatmentPlan.create_from_template(template, @patient)        
      end
      redirect_to root_path, :notice => I18n.t('patient_updated')
    else
      render 'edit'
    end
    
    #rescue
    #  @patient.errors.add :base, "Cannot delete treatment plan with sessions"
    #  render 'edit'
  end
  
  def destroy
    @patient = Patient.find(params[:id])
    # This should only be called if it's in the original state, with 1 plan and no sessions
    #   otherwise this will fail with dependent sessions
    @patient.treatment_plans.destroy_all
    @patient.destroy

    redirect_to patients_path, :notice => I18n.t('patient_deleted') 
    
  rescue
    redirect_to root_path, :alert => I18n.t('cannot_delete_patient')
  end  
  
  # On new treatment session page, when resuming an existing session, select the current machine associated with that session
  def current_session_machine
    patient = Patient.find(params[:id])
    
    # Return something (on error, 0 should not be found, so it just won't do anything)
    machine_id = (!patient.nil? and !patient.unfinished_session.nil?) ? patient.unfinished_session.machine_id : '0'
    
    respond_to do |format|
      format.js { render :text => machine_id, :content_type => Mime::TEXT }
    end
  end

  def completed_sessions
    @patient = Patient.find(params[:id])
    unfinished_plan = @patient.unfinished_plan
   
    if unfinished_plan.nil?
      @sessions = []
      @total = 0
    else
      @sessions = unfinished_plan.treatment_sessions.select { |s| s.complete? }
      @total = unfinished_plan.num_sessions
    end
    
    render :layout => false
  end
private
  def ensure_technician
    if !current_user.has_role?(Role::TECHNICIAN)
      redirect_to root_path, :alert => I18n.t('technicians_only')
    end
  end
  
  def ensure_own_patient
    @patient = Patient.find(params[:id])
    @facility = @patient.treatment_facility    
    
    if @facility != current_user.treatment_facility
      @patient.errors.add :base, "Cannot edit patients at other facilities"
    end
  end
end

