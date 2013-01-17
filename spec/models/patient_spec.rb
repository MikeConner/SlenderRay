# == Schema Information
#
# Table name: patients
#
#  id         :integer         not null, primary key
#  id_key     :string(40)      not null
#  name       :string(40)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

describe 'Patient' do
  let(:patient) { FactoryGirl.create(:patient) }
  
  subject { patient }
  
  it "should respond to everything" do
    patient.should respond_to(:id_key)
    patient.should respond_to(:name)
    patient.should respond_to(:display_name)
  end
  
  it { should be_valid }
  
  it "should set the display name" do
    patient.display_name.should be == patient.name
  end
  
  describe "key" do
    context "missing" do
      before { patient.id_key = ' ' }
      
      it { should_not be_valid }
    end
    
    context "too long" do
      before { patient.id_key = 'k'*(Patient::MAX_ID_LEN + 1) }
      
      it { should_not be_valid }
    end
  end
  
  describe "name" do
    context "missing" do
      before { patient.name = ' ' }
      
      it { should be_valid }
    end
    
    context "display with no name" do
      before { patient.name = ' ' }
      
      it "should display the key" do
        patient.display_name.should be == patient.id_key
      end
    end
  end
  
  describe "testimonials" do
    let(:patient) { FactoryGirl.create(:patient_with_testimonials) }
    
    it "should have testimonials" do
      patient.testimonials.count.should be == 2
    end
    
    context "destroy" do
      before { patient.destroy }
      
      it "should have no testimonials" do
        Testimonial.count.should be == 0
      end
    end
  end

  describe "treatment plans" do
    let(:patient) { FactoryGirl.create(:patient_with_plans) }
    
    it "should have plans" do
      patient.treatment_plans.count.should be == 2
    end

    it "should not be able to destroy" do
      expect { patient.destroy }.to raise_exception(ActiveRecord::DeleteRestrictionError)
    end
    
    context "destroy plans first" do
      before { patient.treatment_plans.destroy_all }
      
      it "should allow it now" do
        expect { patient.reload.destroy }.to_not raise_exception
      end
    end
  end
end
