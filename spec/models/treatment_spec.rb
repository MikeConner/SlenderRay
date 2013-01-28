# == Schema Information
#
# Table name: treatments
#
#  id                   :integer         not null, primary key
#  protocol_id          :integer
#  created_at           :datetime        not null
#  updated_at           :datetime        not null
#  duration             :integer
#  treatment_session_id :integer
#

describe 'Treatment' do
  let(:protocol) { FactoryGirl.create(:protocol) }
  let(:plan) { FactoryGirl.create(:treatment_plan) }
  let(:session) { FactoryGirl.create(:treatment_session, :treatment_plan => plan) }
  let(:treatment) { FactoryGirl.create(:treatment, :treatment_session => session, :protocol => protocol) }
  
  subject { treatment }
  
  it "should respond to everything" do
    treatment.should respond_to(:treatment_session)
    treatment.should respond_to(:protocol)
    treatment.should respond_to(:duration)
    treatment.should respond_to(:process_timer)
  end
  
  its(:protocol) { should == protocol }
  its(:treatment_session) { should == session }
  
  it { should be_valid }
  
  it "should be idle" do
    treatment.process_timer.process_state.should be == ProcessTimer::IDLE
  end
  
  describe "missing protocol" do
    before { treatment.protocol = nil }
    
    it { should_not be_valid }
  end

  describe "missing session" do
    before { treatment.treatment_session = nil }
    
    it { should_not be_valid }
  end  

  describe "missing duration" do
    before { treatment.duration = nil }
    
    it { should_not be_valid }
  end    
end
