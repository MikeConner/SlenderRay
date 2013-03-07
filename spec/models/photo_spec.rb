# == Schema Information
#
# Table name: photos
#
#  id                    :integer         not null, primary key
#  title                 :string(64)
#  caption               :string(255)
#  facility_image        :string(255)
#  treatment_facility_id :integer
#  created_at            :datetime        not null
#  updated_at            :datetime        not null
#

describe "Photo" do
  let(:facility) { FactoryGirl.create(:treatment_facility) }
  let(:photo) { FactoryGirl.create(:photo, :treatment_facility => facility) }
  
  subject { photo }
  
  it "should respond to everything" do
    photo.should respond_to(:title)
    photo.should respond_to(:caption)
    photo.should respond_to(:treatment_facility)
    photo.should respond_to(:facility_image)
  end
  
  its(:treatment_facility) { should be == facility }

  it { should be_valid }
  
  describe "Missing title" do
    before { photo.title = ' ' }
    
    it { should_not be_valid }
  end

  describe "Title too long" do
    before { photo.title = 't'*(Photo::MAX_TITLE_LEN + 1) }
    
    it { should_not be_valid }
  end

  describe "Missing image" do
    before { photo.remove_facility_image! }
    
    it { should_not be_valid }
  end

  describe "Orphan" do
    before { photo.treatment_facility_id = nil }
    
    it { should_not be_valid }
  end
end

