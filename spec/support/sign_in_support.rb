module ValidUserRequestHelper
  def sign_in_as_admin(facility)
    @user ||= FactoryGirl.create(:user_with_role, :treatment_facility => facility, :role => Role.find_by_name(Role::SUPER_ADMIN))
  end

  def sign_in_as_technician(facility)
    @user ||= FactoryGirl.create(:user_with_role, :treatment_facility => facility, :role => Role.find_by_name(Role::TECHNICIAN))
  end
end