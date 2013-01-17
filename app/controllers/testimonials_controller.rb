class TestimonialsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def index
    @testimonials = Testimonial.all
  end
  
  def show
    @testimonial = Testimonial.find(params[:id])  
  end
  
  def new
    @testimonial = Testimonial.new
  end
  
  def edit
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

    redirect_to patients_path, :notice => I18n.t('testimonial_deleted') 
  end  
end
