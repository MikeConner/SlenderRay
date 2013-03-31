# == Schema Information
#
# Table name: patients
#
#  id                    :integer         not null, primary key
#  name                  :string(40)
#  created_at            :datetime        not null
#  updated_at            :datetime        not null
#  treatment_facility_id :integer
#  contract_file         :string(255)
#

describe 'Patient' do
  let(:facility) { FactoryGirl.create(:treatment_facility) }
  let(:patient) { FactoryGirl.create(:patient, :treatment_facility => facility) }
  
  subject { patient }
  
  it "should respond to everything" do
    patient.should respond_to(:name)
    patient.should respond_to(:treatment_facility)
    patient.should respond_to(:unfinished_plan)
    patient.should respond_to(:unfinished_session)
    patient.should respond_to(:treatment_plans)
    patient.should respond_to(:treatment_sessions)
    patient.should respond_to(:testimonials)
    patient.should respond_to(:contract_file)
    patient.should respond_to(:editable_session)
    facility.patients.should be == [patient]
  end
  
  it "should not have an editable session out of the box" do
    patient.editable_session.should be_nil
  end
  
  describe "Editable session" do
    let(:plan) { FactoryGirl.create(:plan_with_sessions, :patient => patient) }
    before do
      @session = FactoryGirl.create(:completed_session, :treatment_plan => plan)
    end
    
    it "should have an editable session" do
      patient.editable_session.should be == @session
    end
  end
  
  it "Do not allow duplicates in the same facility" do
    expect { FactoryGirl.create(:patient, :name => patient.name, :treatment_facility => facility) }.to raise_exception(ActiveRecord::RecordNotUnique)
  end

  it "Allow duplicates in different facilities" do
    expect { FactoryGirl.create(:patient, :name => patient.name) }.to_not raise_exception
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
      
      it { should_not be_valid }
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
      patient.reload.unfinished_plan.should be == patient.treatment_plans.first
    end

    it "should not be able to destroy" do
      expect { patient.reload.destroy }.to raise_exception(ActiveRecord::DeleteRestrictionError)
    end
    
    context "destroy plans first" do
      before { patient.reload.treatment_plans.destroy_all }
      
      it "should allow it now" do
        expect { patient.reload.destroy }.to_not raise_exception
      end
    end
  end
end
