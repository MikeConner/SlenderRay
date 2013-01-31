class PatientsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_technician
  load_and_authorize_resource

  def index
    @facility = current_user.treatment_facility
    @patients = Patient.where('treatment_facility_id = ?', @facility.id).order('updated_at desc').paginate(:page => params[:page])
  end
  
  def show
    @patient = Patient.find(params[:id])  
  end
  
  def new
    @patient = current_user.treatment_facility.patients.build
  end
  
  def edit
    @patient = Patient.find(params[:id])
  end
  
  def create
    if @patient.save
      redirect_to @patient, :notice => I18n.t('patient_created')
    else
      render 'new'
    end
  end

  def update
    @patient = Patient.find(params[:id])

    if @patient.update_attributes(params[:patient])
      redirect_to @patient, :notice => I18n.t('patient_updated')
    else
      render 'edit'
    end
  end
  
  def destroy
    @patient = Patient.find(params[:id])
    @patient.destroy

    redirect_to patients_path, :notice => I18n.t('patient_deleted') 
  end  
  
private
  def ensure_technician
    if !current_user.has_role?(Role::TECHNICIAN)
      redirect_to root_path, :alert => I18n.t('technicians_only')
    end
  end
end

