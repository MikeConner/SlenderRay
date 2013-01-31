require 'phone_utils'

class TreatmentFacilitiesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :transform_phones, only: [:create, :update]

  load_and_authorize_resource

  def index
    @facilities = TreatmentFacility.all
  end
  
  def show
    @facility = TreatmentFacility.find(params[:id])  
  end
  
  def new
    @facility = TreatmentFacility.new
  end
  
  def edit
    @facility = TreatmentFacility.find(params[:id])
  end
  
  # Users created this way are Technicians
  def create
    @facility = TreatmentFacility.new(params[:treatment_facility])
    
    if @facility.save
      @facility.users.each do |user|
        if user.role.nil?
          user.role = Role.find_by_name(Role::TECHNICIAN)
          user.save!
        end
      end
      
      redirect_to @facility, :notice => I18n.t('facility_created')
    else
      render 'new'
    end
  end

  # Users created this way are technicians
  def update
    @facility = TreatmentFacility.find(params[:id])
    
    if @facility.update_attributes(params[:treatment_facility])
      @facility.users.each do |user|
        if user.role.nil?
          user.role = Role.find_by_name(Role::TECHNICIAN)
          user.save!
        end
      end
      
      redirect_to @facility, :notice => I18n.t('facility_updated')
    else
      render 'edit'
    end
  end
  
  def destroy
    @facility = TreatmentFacility.find(params[:id])
    @facility.destroy

    redirect_to treatment_facilities_path, :notice => I18n.t('facility_deleted') 
  end  

private
  def transform_phones
    if !params[:treatment_facility].nil?
      phone_number = params[:treatment_facility][:phone]
      if !phone_number.blank? and (phone_number !~ /#{ApplicationHelper::US_PHONE_REGEX}/)
        params[:treatment_facility][:phone] = PhoneUtils::normalize_phone(phone_number)
      end       
      fax_number = params[:treatment_facility][:fax]
      if !fax_number.blank? and (fax_number !~ /#{ApplicationHelper::US_PHONE_REGEX}/)
        params[:treatment_facility][:fax] = PhoneUtils::normalize_phone(fax_number)
      end       
    end
  end
end
