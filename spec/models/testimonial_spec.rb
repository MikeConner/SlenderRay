# == Schema Information
#
# Table name: testimonials
#
#  id           :integer         not null, primary key
#  comment      :text            not null
#  date_entered :date
#  displayable  :boolean         default(TRUE)
#  patient_id   :integer
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#

describe 'Testimonial' do
  let(:patient) { FactoryGirl.create(:patient) }
  let(:testimonial) { FactoryGirl.create(:testimonial, :patient => patient) }
  
  subject { testimonial }
  
  its(:patient) { should be == patient }
  
  it "should respond to everything" do
    testimonial.should respond_to(:comment)
    testimonial.should respond_to(:date_entered)
    testimonial.should respond_to(:displayable)
    testimonial.should respond_to(:patient)
    testimonial.should respond_to(:display_date)
  end
  
  it { should be_valid }
  
  it "should have display date" do
    testimonial.display_date.should be == testimonial.date_entered
  end
  
  describe "missing comment" do
    before { testimonial.comment = ' ' }
    
    it { should_not be_valid }
  end
  
  describe "missing displayable" do
    before { testimonial.displayable = nil }
    
    it { should_not be_valid }
  end
  
  describe "missing date" do
    before { testimonial.date_entered = ' ' }
    
    it { should be_valid }
    
    it "should still have display date" do
      testimonial.display_date.should be == testimonial.updated_at
    end  
  end
end
