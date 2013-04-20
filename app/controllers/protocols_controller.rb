class ProtocolsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_admin
  load_and_authorize_resource
  
  def index
    @protocols = Protocol.all
  end
  
  def show
    @protocol = Protocol.find(params[:id])  
  end
  
  def new
    @protocol = Protocol.new
  end
  
  def edit
    @protocol = Protocol.find(params[:id])
  end
  
  def create
    if @protocol.save
      redirect_to @protocol, :notice => I18n.t('protocol_created')
    else
      render 'new'
    end
  end

  def update
    @protocol = Protocol.find(params[:id])

    if @protocol.update_attributes(params[:protocol])
      redirect_to @protocol, :notice => I18n.t('protocol_updated')
    else
      render 'edit'
    end
  end
  
  def destroy
    @protocol = Protocol.find(params[:id])
    @protocol.destroy

    redirect_to protocols_path, :notice => I18n.t('protocol_deleted') 
  end  
private
   def ensure_admin
    if !current_user.has_role?(Role::SUPER_ADMIN)
      redirect_to root_path, :alert => I18n.t('admins_only')
    end
  end
end
