class TestimonialsController < ApplicationController
  before_filter :authenticate_user!, :except => [:index]
  load_and_authorize_resource

  def index
    @testimonials = Testimonial.where("displayable = #{ActiveRecord::Base.connection.quoted_true}").order('date_entered desc').paginate(:page => params[:page])
    @can_create = !current_user.nil? and current_user.has_role?(Role::TECHNICIAN) and current_user.treatment_facility.patients.count > 0
    @can_edit = !current_user.nil? && current_user.has_role?(Role::TECHNICIAN)
  end
  
  def show
    @testimonial = Testimonial.find(params[:id])  
  end
  
  def new
    @patients = current_user.treatment_facility.patients
    @testimonial = Testimonial.new
  end
  
  def edit
    @patients = current_user.treatment_facility.patients
    @testimonial = Testimonial.find(params[:id])
  end
  
  def create
    if @testimonial.save
      redirect_to @testimonial, :notice => I18n.t('testimonial_created')
    else
      render 'new'
    end
  end

  def update
    @testimonial = Testimonial.find(params[:id])

    if @testimonial.update_attributes(params[:patient])
      redirect_to @testimonial, :notice => I18n.t('testimonial_updated')
    else
      render 'edit'
    end
  end
  
  def destroy
    @testimonial = Testimonial.find(params[:id])
    @testimonial.destroy

    redirect_to testimonials_path, :notice => I18n.t('testimonial_deleted') 
  end  
end
