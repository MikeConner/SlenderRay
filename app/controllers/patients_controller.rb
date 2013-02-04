class PatientsController < ApplicationController
  respond_to :js, :html
  
  before_filter :authenticate_user!
  before_filter :ensure_technician
  load_and_authorize_resource

  def index
    @facility = current_user.treatment_facility
    @patients = Patient.where('treatment_facility_id = ?', @facility.id).order('updated_at desc').paginate(:page => params[:page])
  end
  
  def show
    @patient = Patient.find(params[:id])  
    @plans = @patient.treatment_plans.order('updated_at desc')
  end
  
  def new
    @facility = current_user.treatment_facility
    if 0 == @facility.treatment_plan_templates.count
      redirect_to root_path, :alert => I18n.t('no_templates_found')
    end
    @patient = @facility.patients.build
  end
  
  def edit
    @patient = Patient.find(params[:id])
    @facility = @patient.treatment_facility
  end
=begin  
  def treat
    @patient = Patient.find(params[:patient_id])   
    @plan = @patient.current_treatment_plan
    @past_sessions = @plan.treatment_sessions.order('created_at desc')
    @session = @plan.treatment_sessions.build
    
    render :layout => 'treatment'
  end
=end  
  def create    
    if @patient.save
      template = TreatmentPlanTemplate.find_by_description(params[:plan_template])
      TreatmentPlan.create_from_template(template, @patient)
      
      redirect_to @patient, :notice => I18n.t('patient_created')
    else
      @facility = current_user.treatment_facility
      render 'new'
    end
    
    rescue
      redirect_to new_patient_path, :alert => I18n.t('cannot_create_patient')
  end

  def update
    @patient = Patient.find(params[:id])

    if @patient.update_attributes(params[:patient])
      redirect_to @patient, :notice => I18n.t('patient_updated')
    else
      @facility = @patient.treatment_facility
      render 'edit'
    end
    
    #rescue
    #  @patient.errors.add :base, "Cannot delete treatment plan with sessions"
    #  render 'edit'
  end
  
  def destroy
    @patient = Patient.find(params[:id])
    @patient.destroy

    redirect_to patients_path, :notice => I18n.t('patient_deleted') 
    
  rescue
    redirect_to root_path, :alert => I18n.t('cannot_delete_patient')
  end  
  
  def clone_treatment_plan
    @patient = Patient.find(params[:patient_id])
    template = TreatmentPlanTemplate.find_by_description(params[:name])
    TreatmentPlan.create_from_template(template, @patient)
    
    respond_to do |format|
      format.js { render :js => "window.location.href=\"#{edit_patient_path(:id => @patient.id)}\"" }
    end
  end
  
private
  def ensure_technician
    if !current_user.has_role?(Role::TECHNICIAN)
      redirect_to root_path, :alert => I18n.t('technicians_only')
    end
  end
end

