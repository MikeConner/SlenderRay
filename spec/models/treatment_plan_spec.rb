# == Schema Information
#
# Table name: treatment_plan_templates
#
#  id                     :integer         not null, primary key
#  patient_id             :integer
#  num_sessions           :integer         not null
#  treatments_per_session :integer         not null
#  description            :text            not null
#  price                  :decimal(, )
#  type                   :string(255)
#  created_at             :datetime        not null
#  updated_at             :datetime        not null
#  treatment_facility_id  :integer
#

describe 'TreatmentPlan' do
  let(:patient) { FactoryGirl.create(:patient) }
  let(:plan) { FactoryGirl.create(:treatment_plan, :patient => patient) }
 
  subject { plan }
 
  it " should respond to everything" do
    plan.should respond_to(:description)
    plan.should respond_to(:num_sessions)
    plan.should respond_to(:treatments_per_session)
    plan.should respond_to(:price)
    plan.should respond_to(:type)
    plan.should respond_to(:patient)
    plan.should respond_to(:treatment_sessions)
    plan.should respond_to(:complete?)
    plan.should respond_to(:first_session?)
    plan.should respond_to(:last_session?)
  end
  
  its(:patient) { should == patient}
  
  it { should be_valid }
  
  describe "first/last sessions (complete)" do
    let(:plan) { FactoryGirl.create(:plan_with_sessions, :num_sessions => 4, :num_treatment_sessions => 4) }
    before { plan }
    
    it "should calculate first/last correctly" do    
      for i in 0..3 do
        if 0 == i
          plan.reload.first_session?(plan.reload.treatment_sessions[i]).should be_true
        else
          plan.reload.first_session?(plan.reload.treatment_sessions[i]).should be_false
        end
        
        if 3 == i
          plan.reload.last_session?(plan.reload.treatment_sessions[i]).should be_true
        else
          plan.reload.last_session?(plan.reload.treatment_sessions[i]).should be_false
        end
      end
    end
  end

  describe "first/last sessions (incomplete)" do
    # 4 of 6 -- last one isn't the last *planned*, so last_session? should be false
    let(:plan) { FactoryGirl.create(:plan_with_sessions, :num_sessions => 6, :num_treatment_sessions => 4) }
    before { plan }
    
    it "should calculate first/last correctly" do    
      for i in 0..3 do
        if 0 == i
          plan.reload.first_session?(plan.reload.treatment_sessions[i]).should be_true
        else
          plan.reload.first_session?(plan.reload.treatment_sessions[i]).should be_false
        end
        
        plan.reload.last_session?(plan.reload.treatment_sessions[i]).should be_false
      end
    end
  end
  
  describe "create from template" do
    let(:template) { FactoryGirl.create(:plan1) }
    before { @plan = TreatmentPlan.create_from_template(template, patient) }
    
    it "should have the correct data" do
      template.type.should be == 'TreatmentPlanTemplate'
      @plan.type.should be == 'TreatmentPlan'
      
      @plan.description.should be == template.description
      @plan.num_sessions.should be == template.num_sessions
      @plan.treatments_per_session.should be == template.treatments_per_session
      @plan.price.should be == template.price
      @plan.patient.should be == patient
    end
    
    context "create with overrides" do
      before { @plan = TreatmentPlan.create_from_template(template, patient, :price => template.price * 2, :num_sessions => template.num_sessions * 3) }
      
      it "should have the correct data" do
        template.type.should be == 'TreatmentPlanTemplate'
        @plan.type.should be == 'TreatmentPlan'
        
        @plan.description.should be == template.description
        @plan.num_sessions.should be == template.num_sessions * 3
        @plan.treatments_per_session.should be == template.treatments_per_session
        @plan.price.should be == template.price * 2
        @plan.patient.should be == patient      
      end
    end
  end
  
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
  
  describe "missing type" do
    before { plan.type = ' '}
    
    it { should_not be_valid }
  end
  
  describe "missing price" do
    before { plan.price = nil }
    
    it { should be_valid }
  end

  describe "invalid price" do
    before { plan.price = -2.5 }
    
    it { should_not be_valid }
  end

  describe "plan with treatments" do
    let(:plan) { FactoryGirl.create(:plan_with_sessions) }
    
    it "should have sessions" do
      plan.treatment_sessions.count.should be == 2
      
      plan.treatment_sessions.each do |session|
        session.treatment_plan.should be == plan
      end
      
      plan.complete?.should be_false
    end
    
    describe "complete one" do
      before { plan.reload.treatment_sessions.first.process_timer.process_state = ProcessTimer::COMPLETED }
      
      it "should not be complete" do
        plan.complete?.should be_false
      end
    end
    
    describe "complete all" do
      before do
        plan.reload.treatment_sessions.each do |session|
          session.process_timer.process_state = ProcessTimer::COMPLETED
          session.process_timer.save!
        end
      end
      
      it "should be complete" do
        plan.treatment_sessions.count.should be == 2
        
        plan.complete?.should be_true
      end
    end
  end

  describe "plan with sessions" do
    let(:plan) { FactoryGirl.create(:plan_with_sessions) }
    
    it "should have sessions" do
      plan.treatment_sessions.count.should be == 2
      
      plan.treatment_sessions.each do |session|
        session.treatment_plan.should be == plan
      end
    end
    
    it "should not be able to delete" do
      expect { plan.reload.destroy }.to raise_exception(ActiveRecord::DeleteRestrictionError)
    end
    
    context "delete sessions first" do
      before { plan.reload.treatment_sessions.destroy_all }
  
      it "should allow destroy" do
        expect { plan.reload.destroy }.to_not raise_exception
      end
    end
  end
end
