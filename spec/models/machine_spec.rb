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
#

describe "Machine" do
  let(:facility) { FactoryGirl.create(:treatment_facility) }
  let(:machine) { FactoryGirl.create(:machine, :treatment_facility => facility) }
  
  subject { machine }
  
  it { should be_valid }
  
  it "should respond to everything" do
    machine.should respond_to(:model)
    machine.should respond_to(:serial_number)
    machine.should respond_to(:date_installed)
    machine.should respond_to(:treatment_facility)
  end
  
  its(:treatment_facility) { should == facility }
  
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
