# == Schema Information
#
# Table name: machines
#
#  id                    :integer         not null, primary key
#  model                 :string(64)      not null
#  serial_number         :string(64)      not null
#  date_installed        :date
#  treatment_facility_id :integer
#  created_at            :datetime        not null
#  updated_at            :datetime        not null
#  display_name          :string(64)      default(""), not null
#

describe "Machine" do
  let(:facility) { FactoryGirl.create(:treatment_facility) }
  let(:machine) { FactoryGirl.create(:machine, :treatment_facility => facility) }
  let(:user) { FactoryGirl.create(:user_with_role, :role => Role.create(:name => Role::TECHNICIAN)) }
  before { machine.users << user }
  
  subject { machine }
  
  it { should be_valid }
  
  it "should respond to everything" do
    machine.should respond_to(:model)
    machine.should respond_to(:serial_number)
    machine.should respond_to(:date_installed)
    machine.should respond_to(:treatment_facility)
    machine.should respond_to(:display_name)
    machine.should respond_to(:treatment_sessions)
    machine.should respond_to(:users)
  end
  
  its(:treatment_facility) { should == facility }
  
  it "should have a user" do
    machine.users.count.should be == 1
    machine.users.should be == [user]
    user.machines.count.should be == 1
    user.machines.should be == [machine]
  end
  
  it "should allow deletion" do
    expect { machine.destroy }.to_not raise_exception
  end
  
  describe "sessions" do
    let(:machine) { FactoryGirl.create(:machine_with_sessions, :treatment_facility => facility) }
    
    it "should have sessions" do
      machine.treatment_sessions.count.should be == 4
      machine.treatment_sessions.each do |session|
        session.machine.should be == machine
      end
    end
    
    it "should not allow delete" do
      expect { machine.destroy }.to raise_exception(ActiveRecord::DeleteRestrictionError)
    end
  end
  
  describe "Missing display name" do
    before { machine.display_name = ' ' }
    
    it { should_not be_valid }
  end
  
  describe "Name too long" do 
    before { machine.display_name = 'n'*(Machine::MAX_FIELD_LEN + 1) }
    
    it { should_not be_valid }
  end
  
  describe "model" do
    context "missing" do
      before { machine.model = ' ' }
      
      it { should_not be_valid }
    end

    context "too long" do
      before { machine.model = 'm'*(Machine::MAX_FIELD_LEN + 1) }
      
      it { should_not be_valid }
    end
  end

  describe "serial number" do
    context "missing" do
      before { machine.serial_number = ' ' }
      
      it { should_not be_valid }
    end

    context "too long" do
      before { machine.serial_number = 'm'*(Machine::MAX_FIELD_LEN + 1) }
      
      it { should_not be_valid }
    end
  end

  describe "missing date installed" do
    before { machine.date_installed = ' ' }
    
    it { should_not be_valid }
  end
  
  it "should be paired" do
    facility.machines.should be == [machine]
  end
  
  describe "destroy" do
    before { machine.destroy }
    
    it "should not have a machine" do
      facility.machines.count.should be == 0
    end
  end
end
