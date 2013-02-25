describe "Add treatment area" do
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
      
      it "should have a link to add a treatment area" do
        find_by_id('add_treatment_area').should_not be_nil
      end
      
      describe "add treatment area (errors)", :js => true do
        before do
          find_by_id('add_treatment_area').click
          fill_in 'Area name', :with => 'Massage Table'
          fill_in 'Process name', :with => 'Swedish Massage'
          click_button 'Update Facility'
        end
        
        it "should not have added a treatment area" do
          TreatmentArea.count.should be == 0
          facility.treatment_areas.count.should be == 0
          page.should have_css('#error_explanation')
          page.should have_content("Treatment areas duration minutes can't be blank")
        end
      end
      
      describe "add treatment area", :js => true do
        before do
          find_by_id('add_treatment_area').click
          fill_in 'Area name', :with => 'Massage Table'
          fill_in 'Process name', :with => 'Swedish Massage'
          fill_in 'Process Duration (mins)', :with => 30
          click_button 'Update Facility'
        end
        
        it "should have added a treatment area" do
          TreatmentArea.count.should be == 1
          facility.treatment_areas.count.should be == 1
          area = TreatmentArea.first
          area.area_name.should be == 'Massage Table'
          area.process_name.should be == 'Swedish Massage'
          area.duration_minutes.should be == 30
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
            TreatmentArea.count.should be == 0
            facility.reload.treatment_areas.count.should be == 0
          end
        end
      end
    end
  end

  describe "Technician user" do
    before do
      sign_in_as_technician(facility)
      login_as(@user, :scope => :user)
      visit treatment_facilities_path
    end
    
    it "should show the facility" do
      page.should have_selector('h2', :text => 'Treatment Facilities')
      page.should have_content(facility.facility_name)
      page.should have_link('Show', :href => treatment_facility_path(facility))
      page.should have_link('Edit', :href => edit_treatment_facility_path(facility))
    end
    
    describe "Edit facility" do
      before { visit edit_treatment_facility_path(facility) }
      
      it "should have a link to add a treatment area" do
        find_by_id('add_treatment_area').should_not be_nil
      end
      
      describe "add treatment area (errors)", :js => true do
        before do
          find_by_id('add_treatment_area').click
          fill_in 'Area name', :with => 'Massage Table'
          fill_in 'Process name', :with => 'Swedish Massage'
          click_button 'Update Facility'
        end
        
        it "should not have added a treatment area" do
          TreatmentArea.count.should be == 0
          facility.treatment_areas.count.should be == 0
          page.should have_css('#error_explanation')
          page.should have_content("Treatment areas duration minutes can't be blank")
        end
      end
      
      describe "add treatment area", :js => true do
        before do
          find_by_id('add_treatment_area').click
          fill_in 'Area name', :with => 'Massage Table'
          fill_in 'Process name', :with => 'Swedish Massage'
          fill_in 'Process Duration (mins)', :with => 30
          click_button 'Update Facility'
        end
        
        it "should have added a treatment area" do
          TreatmentArea.count.should be == 1
          facility.treatment_areas.count.should be == 1
          area = TreatmentArea.first
          area.area_name.should be == 'Massage Table'
          area.process_name.should be == 'Swedish Massage'
          area.duration_minutes.should be == 30
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
            TreatmentArea.count.should be == 0
            facility.reload.treatment_areas.count.should be == 0
          end
        end
      end
    end
  end
end
