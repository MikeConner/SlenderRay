class PatientsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def index
    @patients = Patient.all
  end
  
  def show
    @patient = Patient.find(params[:id])  
  end
  
  def new
    @patient = Patient.new
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
end
