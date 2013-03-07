class StaticPagesController < ApplicationController
  before_filter :authenticate_user!, :except => [:home]
  before_filter :ensure_admin, :only => [:select_report, :generate_report]
  
  def home
  end
  
  def training_videos
  end
  
  def select_report
    @reports = ['Overview']
  end
  
  def generate_report
    @start_date = DateTime.new(params[:report]['start_date(1i)'].to_i, params[:report]['start_date(2i)'].to_i, params[:report]['start_date(3i)'].to_i)
    @end_date = DateTime.new(params[:report]['end_date(1i)'].to_i, params[:report]['end_date(2i)'].to_i, params[:report]['end_date(3i)'].to_i)
    
    if @end_date < @start_date
      redirect_to select_report_path, :alert => 'Invalid date range'
    end
    
    # Ensure it's at least 1, to avoid division by zero
    days_in_range = [1, (@end_date - @start_date).to_i].max

    case params[:report_name]
    when 'Overview'
      @report_data = Hash.new
      TreatmentFacility.all.each do |facility|
        n = facility.facility_name
        @report_data[n] = Hash.new
        @report_data[n][:patients] = facility.patients.count
        @report_data[n][:machines] = Hash.new
        patient_ids = Set.new
        facility.machines.each do |machine|
          cnt = 0
          machine.treatment_sessions.each do |session|
            patient_ids.add(session.treatment_plan.patient.id)
            if session.complete? and (session.date_completed >= @start_date) and (session.date_completed <= @end_date)
              cnt += 1
            end
          end
          @report_data[n][:machines][machine.display_name] = cnt
        end       
        
        @patients_per_day = (patient_ids.length.to_f / days_in_range.to_f).round(2)
      end
      
      render 'overview_report' and return
    else
      redirect_to root_path, :alert => 'Report not found'
    end
  end
  
private
  def ensure_admin
    if !current_user.has_role?(Role::SUPER_ADMIN)
      redirect_to root_path, :alert => I18n.t('admins_only')
    end
  end
end
