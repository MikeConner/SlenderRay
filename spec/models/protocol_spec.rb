# == Schema Information
#
# Table name: protocols
#
#  id         :integer         not null, primary key
#  frequency  :integer         not null
#  name       :string(32)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

describe 'Protocol' do
  let(:protocol) { FactoryGirl.create(:protocol) }
  
  subject { protocol }
  
  it "should respond to everything" do
    protocol.should respond_to(:name)
    protocol.should respond_to(:frequency)
    protocol.should respond_to(:display_name)
  end
  
  it "should show the correct display name" do
    protocol.display_name.should be == "#{protocol.id}) #{protocol.name}"
  end
  
  it { should be_valid }
  
  describe "missing name" do
    before { protocol.name = nil }
    
    it { should be_valid }
    
    it "should show the default display name" do
      protocol.display_name.should be == "Protocol #{protocol.id}"
    end
  end
  
  describe "missing frequency" do
    before { protocol.frequency = ' ' }
    
    it { should_not be_valid }
    
    context "invalid" do
      [-2, 0, 3.5].each do |f|
        before { protocol.frequency = f }
        
        it { should_not be_valid }
      end
    end
  end
end
