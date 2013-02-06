class TreatmentSessionsController < ApplicationController
  respond_to :js, :html
  
  before_filter :authenticate_user!
  before_filter :ensure_technician
  before_filter :ensure_own_facility, :only => [:edit, :update]
  load_and_authorize_resource
  
  # Clicking on "Treatment" before we know which patient it is
  # There are three possibilities: 
  #   1) Patient with no plan or last plan completed -- needs a new plan (not in list -- they need to edit the patient)
  #   2) Patient with an unfinished plan, but last session completed -- needs a new session within the current plan
  #   3) Patient with an unfinished session (e.g., lost connection or interruped) -- needs to resume an existing treatment session
  def new
    @facility = current_user.treatment_facility
    patients = Patient.where('treatment_facility_id = ?', @facility.id).order('updated_at desc').select { |p| !p.unfinished_plan.nil? }
    if patients.empty?
      redirect_to root_path, :alert => I18n.t('nobody_in_treatment')     
    end
      
    @resume_session = patients.select { |p| !p.unfinished_session.nil? }
    @new_session = patients - @resume_session
    @treatment_session = TreatmentSession.new
    if !@resume_session.empty?
      @resume_machine_id = @resume_session.first.unfinished_session.machine.id
    end
  end

  def create    
    if I18n.t('start_session') == params[:commit]
      @patient = Patient.find(params[:new_patient_id])
      @treatment_session.treatment_plan = @patient.unfinished_plan
      @treatment_session.machine_id = params[:new_machine_id]
      @treatment_session.build_process_timer(:duration_seconds => @treatment_session.treatment_plan.treatments_per_session * TreatmentPlan::TREATMENT_DURATION_MINUTES * 60)
      
      if @treatment_session.save
        redirect_to edit_treatment_session_path(@treatment_session) and return
      end    
    elsif I18n.t('resume_session') == params[:commit]
      @patient = Patient.find(params[:resume_patient_id])
      @patient.unfinished_session.machine_id = params[:resume_machine_id]
      if @patient.unfinished_session.save
        redirect_to edit_treatment_session_path(@patient.unfinished_session) and return
      end
    end
    
    @facility = current_user.treatment_facility
    patients = Patient.where('treatment_facility_id = ?', @facility.id).order('updated_at desc').select { |p| !p.unfinished_plan.nil? }
    @resume_session = patients.select { |p| !p.unfinished_session.nil? }
    @new_session = patients - @resume_session
    @treatment_session = TreatmentSession.new
    if !@resume_session.empty?
      @resume_machine_id = @resume_session.first.unfinished_session.machine.id
    end
    render 'new' 
  end

  def edit
    # filter sets @treatment_session
    @plan = @treatment_session.treatment_plan
    @patient = @plan.patient
    @facility = @patient.treatment_facility
    @current_session_idx = @plan.treatment_sessions.count
    @total_sessions = @plan.treatments_per_session
    @first_session = 1 == @current_session_idx
    # Fill in defaults
    @treatment_session.add_measurement_prototypes(@first_session)
    
    render :layout => 'treatment'
  end

  def timer_expired
    @treatment_session = TreatmentSession.find(params[:id])
    @treatment_session.process_timer.expire

    respond_to do |format|
      format.js { render :js => "window.location.href = \"#{edit_treatment_session_path(@treatment_session)}\"" }
    end
  end
  
  def update
    @treatment_session = TreatmentSession.find(params[:id])

    #TODO Why is this returning true when the measurements don't validate???
    notice = nil
    if @treatment_session.update_attributes(params[:treatment_session]) and @treatment_session.valid?
      if 'Start Timer' == params[:commit]
        @treatment_session.process_timer.start
      elsif 'Pause Timer' == params[:commit]
        @treatment_session.process_timer.pause
      elsif 'Resume Timer' == params[:commit]
        @treatment_session.process_timer.resume
      elsif 'Reset Session' == params[:commit]
        @treatment_session.process_timer.reset
      elsif 'Complete Session' == params[:commit]
        @treatment_session.process_timer.complete
        redirect_to root_path and return
      elsif 'Update Session Data' == params[:commit]
        notice = I18n.t('session_updated')
      end
      
      redirect_to edit_treatment_session_path(@treatment_session), :notice => notice
    else
      @plan = @treatment_session.treatment_plan
      @patient = @plan.patient
      @facility = @patient.treatment_facility
      @current_session_idx = @plan.treatment_sessions.count
      @total_sessions = @plan.treatments_per_session
      @first_session = 1 == @current_session_idx
      render 'edit'
    end    
  end

private
  def ensure_technician
    if !current_user.has_role?(Role::TECHNICIAN)
      redirect_to root_path, :alert => I18n.t('technicians_only')
    end
  end
  
  def ensure_own_facility
    @treatment_session = TreatmentSession.find(params[:id])      
    @facility = @treatment_session.treatment_plan.patient.treatment_facility    
    
    if @facility != current_user.treatment_facility
      @patient.errors.add :base, "Cannot show treatment sessions for patients at other facilities"
    end
  end
end