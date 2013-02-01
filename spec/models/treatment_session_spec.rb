# == Schema Information
#
# Table name: treatment_sessions
#
#  id                :integer         not null, primary key
#  treatment_plan_id :integer
#  patient_image     :string(255)
#  notes             :text
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#  machine_id        :integer
#

describe 'TreatmentSession' do
  let(:plan) { FactoryGirl.create(:treatment_plan) }
  let(:machine) { FactoryGirl.create(:machine) }
  let(:session) { FactoryGirl.create(:treatment_session, :treatment_plan => plan, :machine => machine) }
  
  subject { session }
  
  it "should respond to everything" do
    session.should respond_to(:notes)
    session.should respond_to(:patient_image)
    session.should respond_to(:treatment_plan)
    session.should respond_to(:machine)
    session.should respond_to(:measurements)
    session.should respond_to(:treatments)
    session.should respond_to(:labels)
    session.should respond_to(:labeled_measurements)
  end
  
  its(:treatment_plan) { should == plan }
  its(:machine) { should == machine }
  
  it { should be_valid }
  
  describe "first session" do
    let(:session) { FactoryGirl.create(:first_session_with_measurements, :treatment_plan => plan) }   

    it "should have 8 measurements" do
      session.measurements.count.should be == 8
      session.labels.should be == ['After', 'Before']
      session.labeled_measurements('Before').count.should be == 4
      session.labeled_measurements('After').count.should be == 4
      session.labeled_measurements('Invalid').count.should be == 0
      session.labeled_measurements('').count.should be == 0
      session.labeled_measurements(nil).count.should be == 0
    end
  end
  
  describe "orphan" do
    before { session.treatment_plan_id = nil }
    
    it { should_not be_valid }
  end
  
  describe "with treatments" do
    let(:session) { FactoryGirl.create(:session_with_treatments, :treatment_plan => plan) }
    
    it "should have treatments" do
      session.treatments.count.should be == 2
      session.treatments.each do |treatment|
        treatment.treatment_session.should == session
      end
    end
    
    describe "destroy should work" do
      before { session.destroy }
      
      it "should be gone" do
        Treatment.count.should be == 0
      end
    end
  end

  describe "with measurements" do
    let(:session) { FactoryGirl.create(:session_with_measurements, :treatment_plan => plan) }
    
    it "should have measurements" do
      session.measurements.count.should be == 6
      session.labels.should be == []
      
      session.measurements.each do |measurement|
        measurement.treatment_session.should == session
      end
    end
    
    describe "destroy should work" do
      before { session.destroy }
      
      it "should be gone" do
        Measurement.count.should be == 0
      end
    end
  end
end
