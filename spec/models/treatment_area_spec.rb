# == Schema Information
#
# Table name: treatment_areas
#
#  id                    :integer         not null, primary key
#  area_name             :string(64)      not null
#  process_name          :string(64)
#  treatment_facility_id :integer
#  created_at            :datetime        not null
#  updated_at            :datetime        not null
#

describe "TreatmentArea" do
  let(:facility) { FactoryGirl.create(:treatment_facility) }
  let(:area) { FactoryGirl.create(:treatment_area, :treatment_facility => facility) }
  
  subject { area }
  
  it "should respond to everything" do
    area.should respond_to(:area_name)
    area.should respond_to(:process_name)
    area.should respond_to(:process_timer)
    area.should respond_to(:treatment_facility)
  end
  
  its(:treatment_facility) { should == facility }
  
  it { should be_valid }
  
  it "should enforce unique display names" do 
    expect { FactoryGirl.create(:treatment_area, :treatment_facility => facility, :area_name => area.area_name) }.to raise_exception(ActiveRecord::RecordNotUnique)
  end
  
  it "should have no process name" do
    area.process_name.should be_nil
  end
  
  describe "missing area name" do
    before { area.area_name = ' ' }
    
    it { should_not be_valid }
  end

  describe "area name too long" do
    before { area.area_name = 'n'*(TreatmentArea::MAX_FIELD_LEN + 1) }
    
    it { should_not be_valid }
  end

  describe "process name too long" do
    before { area.process_name = 'n'*(TreatmentArea::MAX_FIELD_LEN + 1) }
    
    it { should_not be_valid }
  end
end
