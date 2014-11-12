describe Portal do
  let(:machine) { FactoryGirl.create(:machine) }
  let(:portal) { FactoryGirl.create(:portal, :machine => machine) }

  subject { portal }
  
  it "should respond to everything" do
    portal.should respond_to(:name)
    portal.should respond_to(:cik)
    portal.should respond_to(:rid)
    portal.should respond_to(:basic_auth)
    portal.should respond_to(:wifi_key)
    portal.should respond_to(:mac_address)
  end
  
  its(:machine) { should be == machine }
  
  it { should be_valid }
  
  describe "machine factory" do
    let(:machine) { FactoryGirl.create(:machine_with_portal) }
    
    it "should have a portal" do
      machine.portal.should_not be_nil
    end
  end
  
  describe "Missing cik" do
    before { portal.cik = ' ' }
    
    it { should_not be_valid }
  end

  describe "cik too long" do
    before { portal.cik = 'c'*(Portal::API_KEY_LEN + 1) }
    
    it { should_not be_valid }
  end

  describe "Missing rik" do
    before { portal.rik = ' ' }
    
    it { should_not be_valid }
  end

  describe "rik too long" do
    before { portal.rik = 'c'*(Portal::API_KEY_LEN + 1) }
    
    it { should_not be_valid }
  end
end
