require 'phone_utils'

class TreatmentFacilitiesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :transform_phones, only: [:create, :update]
  before_filter :ensure_admin, :only => [:static_dashboard]
  before_filter :ensure_technician, :only => [:treatment_areas]
  load_and_authorize_resource
  
  include ActionView::Helpers::TextHelper

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
  
  def edit_assignments
    @facility = TreatmentFacility.find(params[:id])    
  end

  # Users created this way are Technicians
  def create
    @facility = TreatmentFacility.new(params[:treatment_facility])
    
    if @facility.save
      # Set roles for new users
      @facility.users.each do |user|
        if user.role.nil?
          user.role = Role.find_by_name(Role::TECHNICIAN)
          user.save!
        end
      end
      # Create timers for new treatment areas
      @facility.treatment_areas.each do |area|
        if area.process_timer.nil?
          area.build_process_timer(:duration_seconds => area.duration_minutes * 60)
          area.save!
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
    
    total_before = @facility.machines.count + @facility.technicians.count
    if @facility.update_attributes(params[:treatment_facility])
      # Set roles for new users
      @facility.users.each do |user|
        if user.role.nil?
          user.role = Role.find_by_name(Role::TECHNICIAN)
          user.save!
        end
      end
      # Create timers for new treatment areas
      @facility.treatment_areas.each do |area|
        if area.process_timer.nil?
          area.build_process_timer(:duration_seconds => area.duration_minutes * 60)
          area.save!
        end
      end
      
      total_after = @facility.machines.count + @facility.technicians.count
      if (total_after == total_before) or (0 == @facility.machines.count) or (0 == @facility.technicians.count)
        redirect_to @facility, :notice => I18n.t('facility_updated')
      else
        redirect_to edit_assignments_treatment_facility_path(@facility)
      end
    else
      render 'edit'
    end
  end
  
  def update_assignments
    @facility = TreatmentFacility.find(params[:id])    
    
    if @facility.update_attributes(params[:treatment_facility])
      redirect_to @facility, :notice => I18n.t('facility_updated')
    else
      render 'edit_assignments'
    end
  end
  
  def destroy
    @facility = TreatmentFacility.find(params[:id])
    @facility.destroy

    redirect_to treatment_facilities_path, :notice => I18n.t('facility_deleted') 
  end  

  def dashboard
    if current_user.has_role?(Role::SUPER_ADMIN)
      @facilities = TreatmentFacility.order(:facility_name)
      # Look for expired timers, since JS does not have individual ones for all of them
      @facilities.each do |facility|
        facility.treatment_areas.each do |area|
          if area.process_timer.pausable? and (0 == area.process_timer.seconds_remaining)
            area.process_timer.expire
          end
        end
      end
      
      render 'admin_dashboard'
    else
      @facility = current_user.treatment_facility
    end    
  end

  def static_dashboard
    @facilities = TreatmentFacility.order(:facility_name)    
  end
    
  def update_dashboard
    @facility = TreatmentFacility.find(params[:id])
    
    if @facility.update_attributes(params[:treatment_facility])
      @area = TreatmentArea.find(params[:treatment_facility][:treatment_areas_attributes]['0'][:id])
      if 'Start Timer' == params[:commit]
        # Did we override the timer?
        @area.process_timer.update_attributes(:duration_seconds => params[:minutes_override].to_i * 60)
        @area.process_timer.start
      elsif 'Pause Timer' == params[:commit]
        @area.process_timer.pause
      elsif 'Resume Timer' == params[:commit]
        @area.process_timer.resume
      elsif 'Reset Session' == params[:commit]
        @area.process_timer.reset
      elsif 'Expire Timer' == params[:commit]
        @area.process_timer.expire
      elsif 'Complete Session' == params[:commit]
        @area.process_timer.complete
      end
      
      redirect_to dashboard_treatment_facilities_path
    end   
  end
  
  def treatment_areas
    facility = TreatmentFacility.find(params[:id])
    data = Hash.new
    # Send the client a hash of treatment areas and their statuses for this facility
    facility.treatment_areas.each do |area|
      status = area.process_timer.display_status
      # If 10 seconds left, append BEEP, which tells client to beep
      if 10 == area.process_timer.seconds_remaining
        status += 'BEEP'
      elsif area.process_timer.pausable? and (0 == area.process_timer.seconds_remaining)
        # Make sure it expires - append RELOAD, which tells the client to reload the page
        area.process_timer.expire
        status += "RELOAD"
      end
      data[area.id] = "#{pluralize(area.process_timer.duration_seconds / 60, 'minute')} :  #{status}"
    end
    
    respond_to do |format|
      format.js { render :json => data, :content_type => Mime::JSON }
    end
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
  
  def ensure_admin
    if !current_user.has_role?(Role::SUPER_ADMIN)
      redirect_to root_path, :alert => I18n.t('admins_only')
    end
  end

  def ensure_technician
    if !current_user.has_role?(Role::TECHNICIAN)
      redirect_to root_path, :alert => I18n.t('technicians_only')
    end
  end
end
