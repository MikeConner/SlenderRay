# == Schema Information
#
# Table name: treatment_plans
#
#  id                     :integer         not null, primary key
#  patient_id             :integer
#  num_sessions           :integer         not null
#  treatments_per_session :integer         not null
#  description            :text            not null
#  created_at             :datetime        not null
#  updated_at             :datetime        not null
#

describe 'TreatmentPlan' do
  let(:patient) { FactoryGirl.create(:patient) }
  let(:plan) { FactoryGirl.create(:treatment_plan, :patient => patient) }
 
  subject { plan }
 
  it " should respond to everything" do
    plan.should respond_to(:description)
    plan.should respond_to(:num_sessions)
    plan.should respond_to(:treatments_per_session)
    plan.should respond_to(:patient)
    plan.should respond_to(:treatments)
  end
  
  its(:patient) { should == patient}
  
  it { should be_valid }
  
  describe "no description" do
    before { plan.description = ' ' }
    
    it { should_not be_valid }
  end
  
  describe "num sessions" do
    context "missing" do
      before { plan.num_sessions = ' ' }
      
      it { should_not be_valid }
    end
    
    context "invalid" do
      [-2, 0, 3.5].each do |num|
        before { plan.num_sessions = num }
        
        it { should_not be_valid }
      end
    end
  end

  describe "treatments per session" do
    context "missing" do
      before { plan.treatments_per_session = ' ' }
      
      it { should_not be_valid }
    end
    
    context "invalid" do
      [-2, 0, 3.5].each do |num|
        before { plan.treatments_per_session = num }
        
        it { should_not be_valid }
      end
    end
  end
  
  describe "orphan" do
    before { plan.patient_id = nil }
    
    it { should_not be_valid }
  end
  
  describe "plan with treatments" do
    let(:plan) { FactoryGirl.create(:plan_with_treatments) }
    
    it "should have treatments" do
      plan.treatments.count.should be == 2
      
      plan.treatments.each do |treatment|
        treatment.treatment_plan.should be == plan
      end
    end
    
    it "should not be able to delete" do
      expect { plan.destroy }.to raise_exception(ActiveRecord::DeleteRestrictionError)
    end
    
    context "delete treatments first" do
      before { plan.treatments.destroy_all }
  
      it "should allow destroy" do
        expect { plan.reload.destroy }.to_not raise_exception
      end
    end
  end
end
