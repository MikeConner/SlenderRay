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
  let(:session_timer) { FactoryGirl.create(:session_timer) }
  let(:area_timer) { FactoryGirl.create(:area_timer) }
  
  subject { session_timer }
  
  it "should respond to everything" do
    session_timer.should respond_to(:process_state)
    session_timer.should respond_to(:start_time)
    session_timer.should respond_to(:elapsed_seconds)
    session_timer.should respond_to(:duration_seconds)
    session_timer.should respond_to(:process)
    session_timer.should respond_to(:seconds_remaining)
    session_timer.should respond_to(:startable?)
    session_timer.should respond_to(:start)
    session_timer.should respond_to(:pausable?)
    session_timer.should respond_to(:pause)
    session_timer.should respond_to(:resumable?)
    session_timer.should respond_to(:resume)
    session_timer.should respond_to(:expireable?)
    session_timer.should respond_to(:expire)
    session_timer.should respond_to(:completeable?)
    session_timer.should respond_to(:complete)
  end
  
  it { should be_valid }
  
  describe "missing duration" do
    before { session_timer.duration_seconds = ' ' }
    
    it { should_not be_valid }
  end
  
  it "should have the right types" do
    session_timer.process.class.should be == TreatmentSession
    area_timer.process.class.should be == TreatmentArea
  end
  
  it "should have correct statuses" do
    session_timer.startable?.should be_true
    session_timer.pausable?.should be_false
    session_timer.resumable?.should be_false
    session_timer.expireable?.should be_false
    session_timer.completeable?.should be_false
  end
  
  describe "valid states" do
    ProcessTimer::PROCESS_STATES.each do |state|
      before { session_timer.process_state = state }
      
      it { should be_valid }
    end
  end
  
  describe "Invalid state" do 
    before { session_timer.process_state = 'Not in List' }
    
    it { should_not be_valid }
  end
  
  describe "timing" do
    it "should not have remaining time" do
      session_timer.seconds_remaining.should be_nil
    end
    
    describe "No time when expired" do
      before { session_timer.process_state = ProcessTimer::EXPIRED }
      
      it "should not have remaining time" do
        session_timer.seconds_remaining.should be_nil
        session_timer.startable?.should be_false
        session_timer.pausable?.should be_false
        session_timer.resumable?.should be_false
        session_timer.expireable?.should be_false
        session_timer.completeable?.should be_true
      end
    end
    
    describe "No time when completed" do
      before { session_timer.process_state = ProcessTimer::COMPLETED }
      
      it "should not have remaining time" do
        session_timer.seconds_remaining.should be_nil
        session_timer.startable?.should be_false
        session_timer.pausable?.should be_false
        session_timer.resumable?.should be_false
        session_timer.expireable?.should be_false
        session_timer.completeable?.should be_false
      end
      
      describe "reset" do
        before { session_timer.reset }
        
        it "should have correct status" do
          session_timer.startable?.should be_true
          session_timer.pausable?.should be_false
          session_timer.resumable?.should be_false
          session_timer.expireable?.should be_false
          session_timer.completeable?.should be_false          
        end
      end
    end
    
    describe "start timer" do
      before do
        session_timer.start
        sleep 5
      end
      
      it "should show correct remaining time" do
        session_timer.process_state.should be == ProcessTimer::STARTED
        session_timer.seconds_remaining.should be == session_timer.duration_seconds - 5
      end
    end
    
    describe "pause" do
      before do
        session_timer.start
        session_timer.startable?.should be_false
        session_timer.pausable?.should be_true
        session_timer.resumable?.should be_false
        session_timer.expireable?.should be_true
        session_timer.completeable?.should be_false
        sleep 5
        session_timer.pause
        session_timer.startable?.should be_false
        session_timer.pausable?.should be_false
        session_timer.resumable?.should be_true
        session_timer.expireable?.should be_false
        session_timer.completeable?.should be_false
        sleep 5
      end
      
      it "should still show the same time" do
        session_timer.process_state.should be == ProcessTimer::PAUSED
        session_timer.seconds_remaining.should be == session_timer.duration_seconds - 5          
      end
    end
      
    describe "resume" do
      before do
        session_timer.start
        sleep 5
        session_timer.pause
        sleep 5
        session_timer.resume
        session_timer.startable?.should be_false
        session_timer.pausable?.should be_true
        session_timer.resumable?.should be_false
        session_timer.expireable?.should be_true
        session_timer.completeable?.should be_false
        sleep 5
      end
      
      it "should show the right remaining time" do
        session_timer.process_state.should be == ProcessTimer::RESUMED
        session_timer.seconds_remaining.should be == session_timer.duration_seconds - 10                    
      end
    end
  end
end
