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
    plan.should respond_to(:treatments)
    plan.should respond_to(:complete?)
  end
  
  its(:patient) { should == patient}
  
  it { should be_valid }
  
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
    let(:plan) { FactoryGirl.create(:plan_with_treatments) }
    
    it "should have sessions" do
      plan.treatment_sessions.count.should be == 2
      plan.treatments.count.should be == 4
      
      plan.treatment_sessions.each do |session|
        session.treatment_plan.should be == plan
      end
      
      plan.complete?.should be_false
    end
    
    describe "complete one" do
      before {
        plan.treatment_sessions.first.treatments.each do |treatment|
          treatment.process_timer.process_state = ProcessTimer::COMPLETED
        end
      }
      
      it "should not be complete" do
        plan.complete?.should be_false
      end
    end
    
    describe "complete all" do
      before {
        plan.treatments.each do |treatment|
          treatment.process_timer.process_state = ProcessTimer::COMPLETED
        end
      }
      
      it "should be complete" do
        plan.treatments.each do |treatment|
          treatment.complete?.should be_true
        end
        
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
        session.treatments.each do |treatment|
          treatment.treatment_session.should be == session
        end
      end
    end
    
    it "should not be able to delete" do
      expect { plan.destroy }.to raise_exception(ActiveRecord::DeleteRestrictionError)
    end
    
    context "delete sessions first" do
      before { plan.treatment_sessions.destroy_all }
  
      it "should allow destroy" do
        expect { plan.reload.destroy }.to_not raise_exception
      end
    end
  end
end
