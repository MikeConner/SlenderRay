class UsersController < ApplicationController
  def index
    @facilities = TreatmentFacility.order(:last_name)
  end
end
