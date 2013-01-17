# == Schema Information
#
# Table name: treatments
#
#  id                :integer         not null, primary key
#  treatment_plan_id :integer
#  protocol_id       :integer
#  patient_image     :string(255)
#  notes             :text
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#

describe 'Treatment' do
  let(:protocol) { FactoryGirl.create(:protocol) }
  let(:plan) { FactoryGirl.create(:treatment_plan) }
  let(:treatment) { FactoryGirl.create(:treatment, :treatment_plan => plan, :protocol => protocol) }
  
  subject { treatment }
  
  it "should respond to everything" do
    treatment.should respond_to(:notes)
    treatment.should respond_to(:patient_image)
    treatment.should respond_to(:treatment_plan)
    treatment.should respond_to(:protocol)
    treatment.should respond_to(:measurements)
  end
  
  its(:protocol) { should == protocol }
  its(:treatment_plan) { should == plan }
  
  it { should be_valid }
  
  describe "missing protocol" do
    before { treatment.protocol = nil }
    
    it { should_not be_valid }
  end

  describe "missing plan" do
    before { treatment.treatment_plan = nil }
    
    it { should_not be_valid }
  end
  
  describe "measurements" do
    let(:treatment) { FactoryGirl.create(:treatment_with_measurements, :treatment_plan => plan, :protocol => protocol) }
    
    it "should have measurements" do
      treatment.measurements.count.should be == 6
      
      treatment.measurements.each do |measurement|
        measurement.treatment.should be == treatment
      end
    end  
    
    context "can destroy" do
      before { treatment.destroy }
      
      it "should have destroyed the measurements" do
        Measurement.count.should be == 0
      end
    end
  end
end
