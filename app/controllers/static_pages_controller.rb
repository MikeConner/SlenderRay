class StaticPagesController < ApplicationController
  before_filter :authenticate_user!, :except => [:home, :public_videos]
  
  def home
  end
  
  def training_videos
  end
  
  def public_videos
  end
  
  def select_report
    clinic_reports = ['Package', 'Clinic Patient', 'Clinic Monthly']
    @reports = current_user.has_role?(Role::SUPER_ADMIN) ? ['Overall Machine', 'Overall Patient'] + clinic_reports : clinic_reports 
  end
  
  def generate_report
    @report_data = Hash.new
    
    case params[:report_name]
    when 'Overall Machine'
      TreatmentFacility.all.each do |facility|
        n = facility.facility_name
        @report_data[n] = Hash.new
        facility.machines.each do |machine|
          @report_data[n][machine.display_name] = Hash.new
          @report_data[n][machine.display_name][:serial] = machine.serial_number
          @report_data[n][machine.display_name][:count] = machine.treatment_sessions.select { |s| s.complete? }.count
        end
      end
      
      render 'admin_machine_report' and return
    when 'Package'
      @facilities = current_user.has_role?(Role::TECHNICIAN) ? [current_user.treatment_facility] : TreatmentFacility.all
      @facilities.each do |facility|
        n = facility.facility_name
        @report_data[n] = Hash.new
        facility.treatment_plan_templates.where("type = 'TreatmentPlanTemplate'").each do |template|
          @report_data[n][template.description] = Hash.new
          @report_data[n][template.description][:price] = template.price
          @report_data[n][template.description][:sessions] = template.num_sessions
          @report_data[n][template.description][:count] = 
            facility.treatment_plan_templates.where("description='#{template.description}'").select { |f| f.type == 'TreatmentPlan' }.count
        end
      end
      
      render 'package_report' and return
    when 'Overall Patient'
      TreatmentFacility.all.each do |facility|
        n = facility.facility_name
        @report_data[n] = Hash.new
        @report_data[n][:total] = facility.patients.count
        @report_data[n][:new] = facility.patients.select { |p| (1 == p.treatment_plans.count) and !p.unfinished_plan.nil? }.count
        @report_data[n][:continuing] = facility.patients.select { |p| p.treatment_plans.count > 1 }.count
      end
      
      render 'admin_patient_report' and return
    when 'Clinic Patient' 
      @facilities = current_user.has_role?(Role::TECHNICIAN) ? [current_user.treatment_facility] : TreatmentFacility.all
      @report_data = Hash.new
      @facilities.each do |facility|
        n = facility.facility_name
        @report_data[n] = Hash.new
        facility.patients.each do |patient|
          p = patient.name
          @report_data[n][p] = Hash.new
          @report_data[n][p][:status] = patient.unfinished_plan.nil? ? 'Finished' : 'Active'
          @report_data[n][p][:packages] = patient.treatment_plans.count
          @report_data[n][p][:sessions] = patient.treatment_sessions.select { |s| s.complete? }.count
        end
      end
        
      render 'clinic_patient_report' and return
    when 'Clinic Monthly' 
      @start_date = DateTime.new(params[:report]['start_date(1i)'].to_i, params[:report]['start_date(2i)'].to_i, 1)
      @end_date = DateTime.new(params[:report]['end_date(1i)'].to_i, params[:report]['end_date(2i)'].to_i, 1)
      
      if @end_date < @start_date
        redirect_to select_report_path, :alert => 'Invalid date range'
      end
            
      current_date = @start_date.beginning_of_month
      @months = [current_date]
      while current_date < @end_date do       
        current_date += 1.month
        @months.push(current_date)
      end 
         
      @facilities = current_user.has_role?(Role::TECHNICIAN) ? [current_user.treatment_facility] : TreatmentFacility.all
      @report_data = Hash.new
      @facilities.each do |facility|
        n = facility.facility_name
        @report_data[n] = Hash.new
        @months.each do |current_month|
          m = current_month.try(:strftime, ApplicationHelper::MONTH_FORMAT)
          @report_data[n][m] = Hash.new
          @report_data[n][m][:new] = 
            facility.patients.select { |p| (1 == p.treatment_plans.count) and !p.unfinished_plan.nil? and 
                                           (p.treatment_plans.first.created_at.year == current_month.year) and 
                                           (p.treatment_plans.first.created_at.month == current_month.month) }.count
          @report_data[n][m][:continuing] = 0
          @report_data[n][m][:active] = 0
          @report_data[n][m][:finished] = 0
          @report_data[n][m][:count] = 0
          # continuing if there is more than one treatment plan, and the second one was created during or before the current month
          # active if there is a plan that started during or before the current_month and is either still active or, if completed, 
          #   was completed during or after the month
          next_month = current_month + 1.month
          facility.patients.each do |patient|
            if patient.created_at < next_month
              @report_data[n][m][:count] += 1
            end
            
            if patient.treatment_plans.count > 1
              if patient.treatment_plans[1].created_at < next_month
                @report_data[n][m][:continuing] += 1                
              end 
            end
            
            active = false
            patient.treatment_plans.each do |plan|
              if plan.created_at < next_month 
                if !plan.complete? or (plan.date_completed >= current_month)
                  active = true
                  break
                end
              end
            end
            if active
              @report_data[n][m][:active] += 1
            else
              @report_data[n][m][:finished] += 1 unless patient.treatment_plans.empty? or (patient.created_at > next_month)
            end
          end
        end
      end
        
      render 'clinic_monthly_report' and return
    when 'Overview'
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
