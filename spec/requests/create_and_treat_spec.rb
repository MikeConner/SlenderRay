describe "Create patient (and treat)" do
  let(:facility) { FactoryGirl.create(:treatment_facility) }
  let(:plan) { FactoryGirl.create(:plan1, :treatment_facility => facility) }
  before do
    Role.create(:name => Role::TECHNICIAN)
    Warden.test_mode!
    plan
  end
  
  subject { page }
  
  describe "create patient" do
    before do
      sign_in_as_technician(facility)
      login_as(@user, :scope => :user)
      visit new_patient_path
      save_page
      fill_in 'patient_name', :with => 'Fat Bastard'
      click_button 'Create Patient'
    end
    
    it "should have a patient" do
      Patient.count.should be == 1
      current_path.should be == edit_patient_path(Patient.first)
    end
  end

  describe "create patient and treat" do
    let(:machine) { FactoryGirl.create(:machine, :treatment_facility => facility) }
    before do
      machine
      sign_in_as_technician(facility)
      login_as(@user, :scope => :user)
      visit new_patient_path
      fill_in 'patient_name', :with => 'Fat Bastard'
      click_button I18n.t('create_and_treat')
    end
    
    it "should have a patient" do
      Patient.count.should be == 1
      current_path.should be == edit_treatment_session_path(TreatmentSession.last)
    end
  end
end