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
#  minutes_per_treatment :integer         default(8), not null
#  hostname              :string(32)
#  web_enabled           :boolean         default(FALSE), not null
#  license_active        :boolean         default(TRUE), not null
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
    machine.should respond_to(:minutes_per_treatment)
    machine.should respond_to(:hostname)
    machine.should respond_to(:web_enabled)
    machine.should respond_to(:license_active)
    machine.should respond_to(:is_machine_running?)
    machine.should respond_to(:turn_on)
    machine.should respond_to(:turn_off)
  end
  
  its(:treatment_facility) { should == facility }
  
  it { should be_valid }
  
  it "should not allow machine running calls" do
    expect { machine.is_machine_running? }.to raise_exception  
    expect { machine.turn_on }.to raise_exception  
    expect { machine.turn_off }.to raise_exception  
  end

  describe "Hostname too long" do
    let(:machine) { FactoryGirl.create(:pi_machine) }
    
    it { should be_valid }
    
    it "should be web-enabled" do
      machine.web_enabled.should be_true
    end
    
    describe "Too long" do
      before { machine.hostname = '1'*(Machine::MAX_HOSTNAME_LEN + 1) }
      
      it { should_not be_valid }
    end
  end
  
  it "should allow no hostname on local machine" do
    machine.hostname.should be_nil
    machine.web_enabled.should be_false
    machine.should be_valid
  end
  
  describe "Missing hostname on pi machine" do
    before { machine.web_enabled = true }
    
    it "should not have a hostname" do
      machine.hostname.should be_nil
      machine.web_enabled.should be_true
    end
    
    it { should_not be_valid }
    
    describe "Add hostname" do
      before { machine.hostname = "microsoft.com" }
      
      it { should be_valid }
    end
  end
  
  describe "Invalid web flag" do
    before { machine.web_enabled = nil }
    
    it { should_not be_valid }
  end
  
  describe "Invalid license flag" do
    before { machine.license_active = nil }
    
    it { should_not be_valid }
  end
  
  it "should have default flags" do
    machine.web_enabled.should be_false
    machine.license_active.should be_true
  end
  
  describe "add port" do
    before { machine.hostname = '192.0.0.1' }
    
    it "should add the port" do
      machine.should be_valid
      machine.hostname.should be == "192.0.0.1:#{Machine::DEFAULT_PORT}"
    end
    
    describe "save it" do
      before { machine.save! }
      
      it "should have the port" do
        Machine.first.hostname.should be == "192.0.0.1:#{Machine::DEFAULT_PORT}"
      end
    end
  end
  
  describe "invalid minutes" do
    [-5, 0, 2.5, 'abc', nil].each do |mins|
      before { machine.minutes_per_treatment = mins }
      
      it { should_not be_valid }
    end
  end
  
  it "should enforce unique display names" do 
    expect { FactoryGirl.create(:machine, :treatment_facility => facility, :display_name => machine.display_name) }.to raise_exception(ActiveRecord::RecordNotUnique)
  end

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
