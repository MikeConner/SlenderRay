describe "Add user" do
  let(:facility) { FactoryGirl.create(:treatment_facility) }
  before do
    Role.create(:name => Role::SUPER_ADMIN)
    Role.create(:name => Role::TECHNICIAN)
    Warden.test_mode!
  end
  
  subject { page }
  
  describe "Admin user" do
    before do
      sign_in_as_admin(facility)
      login_as(@user, :scope => :user)
      visit treatment_facilities_path
    end
    
    it "should show the facility" do
      page.should have_selector('h2', :text => 'Treatment Facilities')
      page.should have_content(facility.facility_name)
      page.should have_link('Show', :href => treatment_facility_path(facility))
      page.should have_link('Edit', :href => edit_treatment_facility_path(facility))
      page.should have_link('Assign', :href => edit_assignments_treatment_facility_path(facility))
      page.should have_link('Delete', :href => treatment_facility_path(facility))
      page.should have_link('Create Treatment Facility', :href => new_treatment_facility_path)
      page.should have_link('Static view of all active machines', :href => static_dashboard_treatment_facilities_path)
    end
    
    describe "Edit facility" do
      before { visit edit_treatment_facility_path(facility) }
      
      it "should have a link to add a user" do
        find_by_id('add_user').should_not be_nil
      end
      
      describe "add user (errors)", :js => true do
        before do
          find_by_id('add_user').click
          fill_in 'treatment_facility_users_attributes_1_email', :with => 'jkb@claritech.com'
          click_button 'Update Facility'
        end
        
        it "should not have added a user" do
          User.count.should be == 1
          facility.technicians.count.should be == 0
          facility.users.count.should be == 1
          page.should have_css('#error_explanation')
          page.should have_content("Users password can't be blank")
        end
      end
      
      describe "add user", :js => true do
        before do
          find_by_id('add_user').click
          fill_in 'treatment_facility_users_attributes_1_email', :with => 'jkb@claritech.com'
          fill_in 'treatment_facility_users_attributes_1_password', :with => 'fishyFishy'
          fill_in 'treatment_facility_users_attributes_1_password_confirmation', :with => 'fishyFishy'
          click_button 'Update Facility'
        end
        
        it "should have added a user" do
          User.count.should be == 2
          facility.users.count.should be == 2
          facility.technicians.count.should be == 1
          user = User.last
          user.email.should be == 'jkb@claritech.com'
          current_path.should be == treatment_facility_path(facility)
          page.should have_content(I18n.t('facility_updated'))
        end
        
        describe "Delete it again", :js => true do
          before do
            visit edit_treatment_facility_path(facility)
            find('a[class="close"]').click
            page.driver.browser.switch_to.alert.accept
            click_button 'Update Facility'
          end
          
          it "should be gone" do
            User.count.should be == 1
            facility.reload.users.count.should be == 1
            facility.reload.technicians.count.should be == 0
          end
        end
      end
    end
  end
end
