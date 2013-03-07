class PhotosController < ApplicationController
  before_filter :authenticate_user!, :except => [:index]
  before_filter :ensure_technician, :except => [:index]
  load_and_authorize_resource

  def new
    @photo = current_user.treatment_facility.photos.build
  end
  
  def create
    if @photo.save
      redirect_to photos_path, :notice => I18n.t('photo_created')
    else
      render 'new'
    end    
  end
  
  def edit
    @photo = Photo.find(params[:id])    
  end
  
  def update
    @photo = Photo.find(params[:id])

    if @photo.update_attributes(params[:photo])
      redirect_to photos_path, :notice => I18n.t('photo_updated')
    else
      render 'edit'
    end    
  end
  
  def index
    if current_user.nil?
      @photos = Photo.where('treatment_facility_id = ? ', LOCAL_FACILITY.id).order('created_at desc')      
    elsif current_user.has_role?(Role::SUPER_ADMIN)
      @photos = Photo.order('created_at desc')
    else
      @photos = Photo.where('treatment_facility_id = ? ', current_user.treatment_facility.id).order('created_at desc')
    end
  end
  
  def destroy
    @photo = Photo.find(params[:id])
    @photo.destroy
    
    redirect_to photos_path, :notice => I18n.t('photo_deleted')    
  end
  
private
  def ensure_technician
    if !current_user.has_role?(Role::TECHNICIAN)
      redirect_to root_path, :alert => I18n.t('technicians_only')
    end
  end
end
