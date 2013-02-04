# == Schema Information
#
# Table name: treatment_facilities
#
#  id            :integer         not null, primary key
#  facility_name :string(50)      not null
#  facility_url  :string(255)
#  first_name    :string(24)
#  last_name     :string(48)
#  email         :string(255)     not null
#  phone         :string(14)
#  fax           :string(14)
#  address_1     :string(50)
#  address_2     :string(50)
#  city          :string(50)
#  state         :string(2)
#  zipcode       :string(10)
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#

describe "TreatmentFacility" do
  let(:facility) { FactoryGirl.create(:treatment_facility) }
  before do
    Role.create(:name => Role::SUPER_ADMIN)
    Role.create(:name => Role::TECHNICIAN)
  end
  
  subject { facility }
  
  it "should respond to everything" do
    facility.should respond_to(:facility_name)
    facility.should respond_to(:facility_url)
    facility.should respond_to(:first_name)
    facility.should respond_to(:last_name)
    facility.should respond_to(:email)
    facility.should respond_to(:phone)
    facility.should respond_to(:fax)
    facility.should respond_to(:address_1)
    facility.should respond_to(:address_2)
    facility.should respond_to(:city)
    facility.should respond_to(:state)
    facility.should respond_to(:zipcode)
    facility.should respond_to(:machines)
    facility.should respond_to(:treatment_sessions)
    facility.should respond_to(:users)
  end
  
  it { should be_valid }
  
  describe "users" do
    let(:user) { FactoryGirl.create(:user_with_role, :treatment_facility => facility, :role => Role.find_by_name(Role::SUPER_ADMIN)) }
    let(:user1) { FactoryGirl.create(:user_with_role, :treatment_facility => facility, :role => Role.find_by_name(Role::TECHNICIAN)) }
    let(:user2) { FactoryGirl.create(:user_with_role, :treatment_facility => facility, :role => Role.find_by_name(Role::TECHNICIAN)) }
    let(:user3) { FactoryGirl.create(:user_with_role, :treatment_facility => facility, :role => Role.find_by_name(Role::TECHNICIAN)) }
    before do
      user
      m1 = FactoryGirl.create(:machine, :treatment_facility => facility)
      m2 = FactoryGirl.create(:machine, :treatment_facility => facility)
      
      m1.users << user1
      m1.users << user2
      m1.users << user3
      m2.users << user2
    end
    
    it "should find unique users" do
      facility.technicians.count.should be == 3
      facility.technicians.should be == [user1, user2, user3]
      facility.users.count.should be == 4
      facility.users.should be == [user, user1, user2, user3]
    end
    
    describe "delete" do
      before do
        facility.machines.destroy_all
        facility.destroy
      end
      
      it "should have no users" do
        User.count.should be == 0
      end
    end
  end
  
  describe "Facility name" do
    context "missing" do
      before { facility.facility_name = ' ' }
      
      it { should_not be_valid }
    end
    
    context "too long" do
      before { facility.facility_name = 'f'*(ApplicationHelper::MAX_ADDRESS_LEN + 1) }
      
      it { should_not be_valid }
    end
    
    context "email case" do
      before do
        @old_email = facility.email
        facility.email.upcase!
      end
      
      it "should be upper case" do
        facility.email.should be == @old_email.upcase
      end  
      
      context "downcase it" do
        before { facility.save! }
          
        it "should be lower case" do
          facility.reload.email.should be == @old_email
        end
      end
    end
    
    context "uniqueness" do
      it "should not allow exact duplicates" do
        expect { facility.dup.save! }.to raise_exception(ActiveRecord::RecordInvalid)
      end
      
      context "facility name" do
        before do
          @facility2 = facility.dup
          @facility2.email = FactoryGirl.generate(:random_email)
          @facility2.facility_name.upcase!
        end
        
        it "should not allow case-insensitive duplicates" do
          expect { @facility2.save! }.to raise_exception(ActiveRecord::RecordInvalid)
        end
      end
      
      context "facility email" do
        before do
          @facility2 = facility.dup
          @facility2.facility_name = FactoryGirl.generate(:random_vendor_name)
          @facility2.email.upcase!
        end
        
        it "should not allow case-insensitive duplicates" do
          expect { @facility2.save! }.to raise_exception(ActiveRecord::RecordInvalid)
        end
      end
    end
  end
  
  describe "first name" do
    context "missing" do
      before { facility.first_name = ' ' }
      
      it { should_not be_valid }
    end
    
    context "Too long" do
      before { facility.first_name = 'n'*(ApplicationHelper::MAX_FIRST_NAME_LEN + 1) }
      
      it { should_not be_valid }
    end
  end
  
  describe "last name" do
    context "missing" do
      before { facility.last_name = ' ' }
      
      it { should_not be_valid }
    end
    
    context "Too long" do
      before { facility.last_name = 'n'*(ApplicationHelper::MAX_LAST_NAME_LEN + 1) }
      
      it { should_not be_valid }
    end
  end
  
  describe "email" do
    context "missing" do
      before { facility.email = ' ' }
      
      it { should_not be_valid }
    end
    
    context "valid" do
      ApplicationHelper::VALID_EMAILS.each do |email|
        before { facility.email = email }
        
        it { should be_valid }
      end
    end

    context "invalid" do
      ApplicationHelper::INVALID_EMAILS.each do |email|
        before { facility.email = email }
        
        it { should_not be_valid }
      end
    end
  end
  
  describe "address_1" do
    context "missing" do
      before { facility.address_1 = ' ' }
      
      it { should_not be_valid }
    end
    
    context "too long" do
      before { facility.address_1 = 'a'*(ApplicationHelper::MAX_ADDRESS_LEN + 1) }
      
      it { should_not be_valid }
    end
  end
  
  describe "address_2" do
    context "valid (factory creates it nil)" do
      before { facility.address_2 = '123 Maple Terrace' }
      
      it { should be_valid }
    end
    
    context "too long" do
      before { facility.address_2 = 'a'*(ApplicationHelper::MAX_ADDRESS_LEN + 1) }
      
      it { should_not be_valid }
    end
  end
  
  describe "city" do
    context "missing" do
      before { facility.city = ' ' }
      
      it { should_not be_valid }
    end
    
    context "too long" do
      before { facility.city = 'a'*(ApplicationHelper::MAX_ADDRESS_LEN + 1) }
      
      it { should_not be_valid }
    end
  end

  describe "state" do 
    before { facility.state = " " }
    
    it { should_not be_valid }
    
    context "validate against list" do
      ApplicationHelper::US_STATES.each do |state|
        before { facility.state = state }
        
        it { should be_valid }
      end
      
      context "invalid state" do
        before { facility.state = "Not a state" }
        
        it { should_not be_valid }
      end
    end
  end

  describe "no zip code" do
    before { facility.zipcode = nil }
    
    it { should_not be_valid }
  end
  
  describe "zip code (valid)" do
    ["13416", "15237", "15237-2339"].each do |code|
      before { facility.zipcode = code }
      
      it { should be_valid }
    end
  end

  describe "zip code (invalid)" do  
    ["xyz", "1343", "1343k", "134163423", "13432-", "13432-232", "13432-232x", "34234-32432", "32432_3423"].each do |code|
      before { facility.zipcode = code }
     
      it { should_not be_valid }
    end
  end  

  describe "phone (valid)" do
    ["(412) 441-4378", "(724) 342-3423", "(605) 342-3242"].each do |phone|
      before { facility.phone = phone }
      
      it { should be_valid }
    end
  end

  # Should actually introduce phone normalization if we want people to type them in
  # Many of these should be valid after normalization 
  describe "phone (invalid)" do  
    ["xyz", "412-441-4378", "441-4378", "1-800-342-3423", "(412) 343-34232", "(412) 343-342x"].each do |phone|
      before { facility.phone = phone }
     
      it { should_not be_valid }
    end
  end  

  describe "missing phone" do
    before { facility.phone = nil }
    
    it { should_not be_valid }
  end
  
  describe "fax (valid)" do
    ["(412) 441-4378", "(724) 342-3423", "(605) 342-3242"].each do |phone|
      before { facility.fax = phone }
      
      it { should be_valid }
    end
  end

  # Should actually introduce phone normalization if we want people to type them in
  # Many of these should be valid after normalization 
  describe "fax (invalid)" do  
    ["xyz", "412-441-4378", "441-4378", "1-800-342-3423", "(412) 343-34232", "(412) 343-342x"].each do |phone|
      before { facility.fax = phone }
     
      it { should_not be_valid }
    end
  end  

  describe "missing fax" do
    before { facility.fax = nil }
    
    it { should be_valid }
  end
  
  describe "url (valid)" do
    ["https://cryptic-ravine-3423.herokuapp.com", "microsoft.com", "http://www.google.com", "www.bitbucket.org", "google.com/index.html"].each do |url|
      before { facility.facility_url = url }
      
      it { should be_valid }
    end
  end

  # Should actually introduce phone normalization if we want people to type them in
  # Many of these should be valid after normalization 
  describe "url (invalid)" do  
    ["xyz", ".com", "google", "www.google", "ftp://microsoft.com/fish", "www.google."].each do |url|
      before { facility.facility_url = url }
     
      it { should_not be_valid }
    end
  end  
  
  describe "machines" do
    let(:machine) { FactoryGirl.create(:machine, :treatment_facility => facility) }
    
    it "can destroy if no machines" do
      expect { facility.destroy }.to_not raise_exception
    end
    
    it "should have a machine" do
      machine.treatment_facility.should be == facility
      facility.reload.machines.should be == [machine]
      
      expect { facility.reload.destroy }.to raise_exception(ActiveRecord::DeleteRestrictionError)
    end  
      
    context "destroy machine allows destruction of facility" do
      it "should have a machine" do
        machine.treatment_facility.should be == facility
        facility.reload.machines.should be == [machine]
      end
      
      context "destroy machine" do
        before { machine.destroy }
        
        it "should allow destroy" do
          expect { facility.reload.destroy }.to_not raise_exception
        end
      end
    end
  end
  
  it "should delete" do
    expect { facility.destroy }.to_not raise_exception
  end
  
  describe "areas" do
    let(:facility) { FactoryGirl.create(:facility_with_areas) }
    
    it "should have all relationships" do
      facility.treatment_areas.count.should be == 3
      facility.treatment_areas.each do |area|
        area.treatment_facility.should == facility
      end
    end
    
    it "should delete" do
      expect { facility.destroy }.to_not raise_exception
    end
  end
end
