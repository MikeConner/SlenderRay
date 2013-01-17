# == Schema Information
#
# Table name: measurements
#
#  id            :integer         not null, primary key
#  location      :string(16)      not null
#  circumference :decimal(, )     not null
#  treatment_id  :integer
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#

describe 'Measurement' do
  let(:treatment) { FactoryGirl.create(:treatment) }
  let(:measurement) { FactoryGirl.create(:measurement, :treatment => treatment) }
  
  subject { measurement }
  
  it "should respond to everything" do
    measurement.should respond_to(:location)
    measurement.should respond_to(:circumference)
    measurement.should respond_to(:treatment)
  end
  
  its(:treatment) { should == treatment }
  
  it { should be_valid }
end
