class TreatmentSessionsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  
  # Need to check for active session and not create another one over top of it!
  def new
    @facility = current_user.treatment_facility
    @patients = Patient.where('treatment_facility_id = ?', @facility.id).order('updated_at desc').select { |p| p.in_treatment? }
    if @patients.empty?
      redirect_to root_path, :alert => 'Sorry; no patients in treatment'
    else  
      @treatment_session = TreatmentSession.new
    end
  end
  
  def create
    @patient = Patient.find(params[:patient_id])
    @treatment_session.treatment_plan = @patient.current_treatment_plan
    
    if @treatment_session.save
      redirect_to @treatment_session
    else
      render 'new'
    end    
  end
  
  def show
    @treatment_session = TreatmentSession.find(params[:id])      
  end
end