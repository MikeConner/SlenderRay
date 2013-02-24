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
#  protocol_id       :integer
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
    session.should respond_to(:labels)
    session.should respond_to(:labeled_measurements)
    session.should respond_to(:date_completed)
  end
  
  its(:treatment_plan) { should == plan }
  its(:machine) { should == machine }
  
  it { should be_valid }
  
  it "should have no date completed" do
    session.date_completed.should be_nil
  end
  
  describe "no navel" do
    let(:measurement) { FactoryGirl.create(:measurement, :location => 'blah', :treatment_session => session) }
    
    before { measurement }
    
    it "should have a measurement" do
      session.measurements.count.should be == 1
      session.reload.valid?.should be_false
    end
  end
  
  describe "completed session" do
    let(:session) { FactoryGirl.create(:completed_session, :treatment_plan => plan) }
    
    it "should be complete" do
      session.complete?.should be_true
      session.date_completed.should be == session.process_timer.updated_at
    end
  end
  
  describe "first session" do
    let(:session) { FactoryGirl.create(:first_session_with_measurements, :treatment_plan => plan) }   
    
    it "should have 8 measurements" do
      session.measurements.count.should be == 8
      session.reload.labels.should be == [Measurement::AFTER_LABEL, Measurement::BEFORE_LABEL]
      session.labeled_measurements(Measurement::BEFORE_LABEL).count.should be == 4
      session.labeled_measurements(Measurement::AFTER_LABEL).count.should be == 4
      session.labeled_measurements('Invalid').count.should be == 0
      session.labeled_measurements('').count.should be == 0
      session.labeled_measurements(nil).count.should be == 0
    end
  end
  
  describe "orphan" do
    before { session.treatment_plan_id = nil }
    
    it { should_not be_valid }
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
    
    describe "remove required measurement" do
      let(:session) { FactoryGirl.create(:session_with_fixed_measurements, :treatment_plan => plan) }
      
      it "should have 3 measurements" do
        session.measurements.count.should be == 3
        session.should be_valid
      end
      
      describe "now remove it" do
        before { session.measurements.where('location = ?', TreatmentSession::REQUIRED_MEASUREMENT).destroy_all }
        
        it "should have 2 measurements" do
          session.reload.measurements.count.should be == 2
          session.reload.should_not be_valid
        end
      end
    end
    
    describe "destroy should work" do
      before { session.reload.destroy }
      
      it "should be gone" do
        Measurement.count.should be == 0
      end
    end
  end
end
