# == Schema Information
#
# Table name: measurements
#
#  id                   :integer         not null, primary key
#  location             :string(16)      not null
#  circumference        :decimal(, )     not null
#  treatment_session_id :integer
#  created_at           :datetime        not null
#  updated_at           :datetime        not null
#

describe 'Measurement' do
  let(:session) { FactoryGirl.create(:treatment_session) }
  let(:measurement) { FactoryGirl.create(:measurement, :treatment_session => session) }
  
  subject { measurement }
  
  it "should respond to everything" do
    measurement.should respond_to(:location)
    measurement.should respond_to(:circumference)
    measurement.should respond_to(:treatment_session)
  end
  
  its(:treatment_session) { should == session }
  
  it { should be_valid }
  
  describe "missing location" do
    before { measurement.location = ' ' }
    
    it { should_not be_valid }
  end

  describe "location too long" do
    before { measurement.location = 'l'*(Measurement::MAX_LOCATION_LEN + 1) }
    
    it { should_not be_valid }
  end
  
  describe "circumference (invalid)" do
    [-1.5, -1, 0].each do |inches|
      before { measurement.circumference = inches }
      
      it { should_not be_valid }
    end
  end

  describe "circumference (valid)" do
    [0.5, 12, 15.5, 38.75].each do |inches|
      before { measurement.circumference = inches }
      
      it { should be_valid }
    end
  end
end
