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
    treatment_timer.should respond_to(:startable?)
    treatment_timer.should respond_to(:start)
    treatment_timer.should respond_to(:pausable?)
    treatment_timer.should respond_to(:pause)
    treatment_timer.should respond_to(:resumable?)
    treatment_timer.should respond_to(:resume)
    treatment_timer.should respond_to(:expireable?)
    treatment_timer.should respond_to(:expire)
    treatment_timer.should respond_to(:completeable?)
    treatment_timer.should respond_to(:complete)
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
  
  it "should have correct statuses" do
    treatment_timer.startable?.should be_true
    treatment_timer.pausable?.should be_false
    treatment_timer.resumable?.should be_false
    treatment_timer.expireable?.should be_false
    treatment_timer.completeable?.should be_false
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
        treatment_timer.startable?.should be_false
        treatment_timer.pausable?.should be_false
        treatment_timer.resumable?.should be_false
        treatment_timer.expireable?.should be_false
        treatment_timer.completeable?.should be_true
      end
    end
    
    describe "No time when completed" do
      before { treatment_timer.process_state = ProcessTimer::COMPLETED }
      
      it "should not have remaining time" do
        treatment_timer.seconds_remaining.should be_nil
        treatment_timer.startable?.should be_false
        treatment_timer.pausable?.should be_false
        treatment_timer.resumable?.should be_false
        treatment_timer.expireable?.should be_false
        treatment_timer.completeable?.should be_false
      end
      
      describe "reset" do
        before { treatment_timer.reset }
        
        it "should have correct status" do
          treatment_timer.startable?.should be_true
          treatment_timer.pausable?.should be_false
          treatment_timer.resumable?.should be_false
          treatment_timer.expireable?.should be_false
          treatment_timer.completeable?.should be_false          
        end
      end
    end
    
    describe "start timer" do
      before do
        treatment_timer.start
        sleep 5
      end
      
      it "should show correct remaining time" do
        treatment_timer.process_state.should be == ProcessTimer::STARTED
        treatment_timer.seconds_remaining.should be == treatment_timer.duration_seconds - 5
      end
    end
    
    describe "pause" do
      before do
        treatment_timer.start
        treatment_timer.startable?.should be_false
        treatment_timer.pausable?.should be_true
        treatment_timer.resumable?.should be_false
        treatment_timer.expireable?.should be_true
        treatment_timer.completeable?.should be_false
        sleep 5
        treatment_timer.pause
        treatment_timer.startable?.should be_false
        treatment_timer.pausable?.should be_false
        treatment_timer.resumable?.should be_true
        treatment_timer.expireable?.should be_false
        treatment_timer.completeable?.should be_false
        sleep 5
      end
      
      it "should still show the same time" do
        treatment_timer.process_state.should be == ProcessTimer::PAUSED
        treatment_timer.seconds_remaining.should be == treatment_timer.duration_seconds - 5          
      end
    end
      
    describe "resume" do
      before do
        treatment_timer.start
        sleep 5
        treatment_timer.pause
        sleep 5
        treatment_timer.resume
        treatment_timer.startable?.should be_false
        treatment_timer.pausable?.should be_true
        treatment_timer.resumable?.should be_false
        treatment_timer.expireable?.should be_true
        treatment_timer.completeable?.should be_false
        sleep 5
      end
      
      it "should show the right remaining time" do
        treatment_timer.process_state.should be == ProcessTimer::RESUMED
        treatment_timer.seconds_remaining.should be == treatment_timer.duration_seconds - 10                    
      end
    end
  end
end
