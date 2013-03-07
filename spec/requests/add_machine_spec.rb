describe "Add machine" do
  let(:facility) { FactoryGirl.create(:treatment_facility) }
  before do
    Role.create(:name => Role::SUPER_ADMIN)
    Role.create(:name => Role::TECHNICIAN)
    Warden.test_mode!
  end
  
  subject { page }
  
  describe "Invalid user" do
    before do
      @user = FactoryGirl.create(:user, :treatment_facility => nil)
      login_as(@user, :scope => :user)
      visit treatment_facilities_path
    end
    
    it "should not have a valid treatment facility" do
      @user.treatment_facility.should be_nil
    end
    
    it { should have_content(I18n.t('user_not_set_up')) }
  end
  
  describe "Technician user" do
    before do
      sign_in_as_technician(facility)
      login_as(@user, :scope => :user)
      visit treatment_facilities_path
    end
    
    it "should have links" do
      page.should have_selector('h2', :text => 'Treatment Facilities')
      page.should have_content(facility.facility_name)
      page.should have_link('Show', treatment_facility_path(facility))
      page.should have_link('Edit', edit_treatment_facility_path(facility))
      page.should_not have_link('Static view of all active machines', :href => static_dashboard_treatment_facilities_path)
    end
  end
  
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
      
      it "should have a link to add a machine" do
        find_by_id('add_machine').should_not be_nil
      end
      
      describe "add machine (errors)", :js => true do
        before do
          find_by_id('add_machine').click
          fill_in 'Model', :with => '342-D'
          fill_in 'Display name', :with => 'FatBlaster 3000'
          click_button 'Update Facility'
        end
        
        it "should not have added a machine" do
          Machine.count.should be == 0
          facility.machines.count.should be == 0
          page.should have_css('#error_explanation')
          page.should have_content("Machines serial number can't be blank")
        end
      end
      
      describe "add machine", :js => true do
        before do
          find_by_id('add_machine').click
          fill_in 'Model', :with => '342-D'
          fill_in 'Serial number', :with => '3242342'
          fill_in 'Display name', :with => 'FatBlaster 3000'
          fill_in 'Minutes per treatment', :with => 10
          click_button 'Update Facility'
          save_page
        end
        
        it "should have added a machine" do
          Machine.count.should be == 1
          facility.machines.count.should be == 1
          machine = Machine.first
          machine.model.should be == '342-D'
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
            Machine.count.should be == 0
            facility.reload.machines.count.should be == 0
          end
        end
      end
    end
  end
end
