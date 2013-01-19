# == Schema Information
#
# Table name: users
#
#  id                     :integer         not null, primary key
#  email                  :string(255)     default(""), not null
#  encrypted_password     :string(255)     default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer         default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  role_id                :integer
#  machine_id             :integer
#  created_at             :datetime        not null
#  updated_at             :datetime        not null
#

describe 'User' do
  let(:user) { FactoryGirl.create(:user) }
  before do
    Role.create(:name => Role::SUPER_ADMIN)
    Role.create(:name => Role::INSTRUMENT_ADMIN)
  end
  
  subject { user }

  it "should respond to everything" do
    user.should respond_to(:email)
    user.should respond_to(:password)
    user.should respond_to(:password_confirmation)
    user.should respond_to(:remember_me)
    user.should respond_to(:role)
  end
      
  it { should be_valid }
  
  describe "duplicate email" do
    before { @user2 = user.dup }
    
    it "shouldn't allow exact duplicates" do
      @user2.should_not be_valid
    end
    
    context "case sensitivity" do
      before do
        @user2 = user.dup
        @user2.email = user.email.upcase
      end
      
      it "shouldn't allow case variant duplicates" do
        @user2.should_not be_valid
      end
    end
    
    describe "missing email" do
      before { user.email = " " }
      
      it { should_not be_valid }
      
      describe "email format (valid)" do
        ApplicationHelper::VALID_EMAILS.each do |address|
          before { user.email = address }
          
          it { should be_valid }
        end
      end
  
      describe "email format (invalid)" do
        ApplicationHelper::INVALID_EMAILS.each do |address|
          before { user.email = address }
          
          it { should_not be_valid }
        end
      end
    end
  end
  
  it "should have no role by default" do
    user.role.should be_nil
  end
  
  describe "super admin" do
    let(:user) { FactoryGirl.create(:user_with_role, :role => Role.find_by_name(Role::SUPER_ADMIN)) }
    
    it "should have the role" do
      user.has_role?(Role::SUPER_ADMIN).should be_true
    end
  end

  describe "instrument admin" do
    let(:user) { FactoryGirl.create(:instrument_admin, :role => Role.find_by_name(Role::INSTRUMENT_ADMIN)) }
    
    it "should have the role" do
      user.has_role?(Role::INSTRUMENT_ADMIN).should be_true
    end
    
    context "without machine should be invalid" do
      before { user.machine_id = nil }
      
      it { should_not be_valid }
    end
  end
end
