# == Schema Information
#
# Table name: roles
#
#  id         :integer         not null, primary key
#  name       :string(16)      not null
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

describe 'Role' do
  let(:role) { FactoryGirl.create(:role) }

  subject { role }
  
  it { should respond_to(:name) }
  
  it { should be_valid }
  
  describe "duplicate names" do
    before { @role2 = role.dup }
    
    it "shouldn't allow exact duplicates" do
      @role2.should_not be_valid
    end
    
    describe "case sensitivity" do
      before do
        @role2 = role.dup
        @role2.name = role.name.upcase
      end
      
      it "shouldn't allow case variant duplicates" do
        @role2.should_not be_valid
      end
    end
  end  
end
