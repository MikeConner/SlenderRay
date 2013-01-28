# == Schema Information
#
# Table name: process_timers
#
#  id               :integer         not null, primary key
#  process_state    :string(16)      default("Idle"), not null
#  start_time       :datetime
#  elapsed_seconds  :integer
#  process_id       :integer
#  process_type     :string(255)
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#  duration_seconds :integer
#

describe "ProcessTimer" do
  let(:treatment_timer) { FactoryGirl.create(:treatment_timer) }
  let(:area_timer) { FactoryGirl.create(:area_timer) }
  
  subject { treatment_timer }
  
  it "should respond to everything" do
    treatment_timer.should respond_to(:process_state)
    treatment_timer.should respond_to(:start_time)
    treatment_timer.should respond_to(:elapsed_seconds)
    treatment_timer.should respond_to(:duration_seconds)
    treatment_timer.should respond_to(:process)
    treatment_timer.should respond_to(:seconds_remaining)
  end
  
  it { should be_valid }
  
  describe "missing duration" do
    before { treatment_timer.duration_seconds = ' ' }
    
    it { should_not be_valid }
  end
  
  it "should have the right types" do
    treatment_timer.process.class.should be == Treatment
    area_timer.process.class.should be == TreatmentArea
  end
  
  describe "valid states" do
    ProcessTimer::PROCESS_STATES.each do |state|
      before { treatment_timer.process_state = state }
      
      it { should be_valid }
    end
  end
  
  describe "Invalid state" do 
    before { treatment_timer.process_state = 'Not in List' }
    
    it { should_not be_valid }
  end
  
  describe "timing" do
    it "should not have remaining time" do
      treatment_timer.seconds_remaining.should be_nil
    end
    
    describe "No time when expired" do
      before { treatment_timer.process_state = ProcessTimer::EXPIRED }
      
      it "should not have remaining time" do
        treatment_timer.seconds_remaining.should be_nil
      end
    end
    
    describe "No time when completed" do
      before { treatment_timer.process_state = ProcessTimer::COMPLETED }
      
      it "should not have remaining time" do
        treatment_timer.seconds_remaining.should be_nil
      end
    end
    
    describe "start timer" do
      before do
        treatment_timer.process_state = ProcessTimer::STARTED
        treatment_timer.start_time = Time.now
        sleep 5
      end
      
      it "should show correct remaining time" do
        treatment_timer.process_state.should be == ProcessTimer::STARTED
        treatment_timer.seconds_remaining.should be == treatment_timer.duration_seconds - 5
      end
    end
    
    describe "pause" do
      before do
        treatment_timer.process_state = ProcessTimer::STARTED
        sleep 5
        treatment_timer.process_state = ProcessTimer::PAUSED
        treatment_timer.elapsed_seconds = 5
        sleep 5
      end
      
      it "should still show the same time" do
        treatment_timer.process_state.should be == ProcessTimer::PAUSED
        treatment_timer.seconds_remaining.should be == treatment_timer.duration_seconds - 5          
      end
    end
      
    describe "resume" do
      before do
        treatment_timer.process_state = ProcessTimer::STARTED
        sleep 5
        treatment_timer.process_state = ProcessTimer::PAUSED
        treatment_timer.elapsed_seconds = 5
        sleep 5
        treatment_timer.process_state = ProcessTimer::RESUMED
        treatment_timer.start_time = Time.now
        sleep 5
      end
      
      it "should show the right remaining time" do
        treatment_timer.process_state.should be == ProcessTimer::RESUMED
        treatment_timer.seconds_remaining.should be == treatment_timer.duration_seconds - 10                    
      end
    end
  end
end
