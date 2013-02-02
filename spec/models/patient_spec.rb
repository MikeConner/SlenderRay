# == Schema Information
#
# Table name: patients
#
#  id                    :integer         not null, primary key
#  name                  :string(40)
#  created_at            :datetime        not null
#  updated_at            :datetime        not null
#  treatment_facility_id :integer
#

describe 'Patient' do
  let(:facility) { FactoryGirl.create(:treatment_facility) }
  let(:patient) { FactoryGirl.create(:patient, :treatment_facility => facility) }
  
  subject { patient }
  
  it "should respond to everything" do
    patient.should respond_to(:name)
    patient.should respond_to(:treatment_facility)
    patient.should respond_to(:current_treatment_plan)
    patient.should respond_to(:in_treatment?)
    facility.patients.should be == [patient]
  end
  
  describe "missing facility" do
    before { patient.treatment_facility = nil }
    
    it { should_not be_valid }
  end
  
  describe "should not be destroyed" do
    before { patient }
    
    it "should have a patient" do
      facility.patients.count.should be == 1
      expect { facility.destroy }.to raise_exception(ActiveRecord::DeleteRestrictionError)
    end    
  end
  
  describe "destruction" do
    before { facility.patients.destroy_all }
    
    it "should destroy now" do
      expect { facility.reload.destroy }.to_not raise_exception
    end
  end
  
  its(:treatment_facility) { should == facility }
  
  it { should be_valid }
  
  describe "name" do
    context "missing" do
      before { patient.name = ' ' }
      
      it { should be_valid }
    end
  end
  
  describe "testimonials" do
    let(:patient) { FactoryGirl.create(:patient_with_testimonials) }
    
    it "should have testimonials" do
      patient.testimonials.count.should be == 2
    end
    
    context "destroy" do
      before { patient.destroy }
      
      it "should have no testimonials" do
        Testimonial.count.should be == 0
      end
    end
  end

  describe "treatment plans" do
    let(:patient) { FactoryGirl.create(:patient_with_plans) }
    
    it "should have plans" do
      patient.treatment_plans.count.should be == 2
      patient.in_treatment?.should be_true
      patient.current_treatment_plan.should be == patient.treatment_plans.first
    end

    it "should not be able to destroy" do
      expect { patient.destroy }.to raise_exception(ActiveRecord::DeleteRestrictionError)
    end
    
    context "destroy plans first" do
      before { patient.treatment_plans.destroy_all }
      
      it "should allow it now" do
        expect { patient.reload.destroy }.to_not raise_exception
      end
    end
  end
end
