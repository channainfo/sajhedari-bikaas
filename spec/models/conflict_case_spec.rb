require 'spec_helper'

describe ConflictCase do
  describe '#field_description' do
  	before(:each) do
      @fields = [ {"code"=>"con_state", "id"=>4, "name"=>"Conflict Status", "options"=>[ {"id"=>1, "code"=>"1", "label"=>"Before the conflict"}, 
  	 																				  	 {"id"=>2, "code"=>"2", "label"=>"At the conflict"}, 
  	 																				     {"id"=>3, "code"=>"3", "label"=>"After the conflict"} ] }, 


			   {"code"=>"con_type", "id"=>5, "name"=>"Conflict Type", "options"=>[ {"id"=>1, "code"=>"1", "label"=>"Gender Based Violence"}, 
																				   {"id"=>2, "code"=>"2", "label"=>"Identity-based Violence"}, 
																				   {"id"=>3, "code"=>"3", "label"=>"Caste-based Violence"}, 
																				   {"id"=>4, "code"=>"4", "label"=>"Political Violence"}, 
																				   {"id"=>5, "code"=>"5", "label"=>"Inter-Personal Violence"}, 
																				   {"id"=>6, "code"=>"6", "label"=>"Resource-based Violence"}]}, 


    			{"code"=>"con_intensity", "id"=>6, "name"=>"Conflict Intensity", "options"=>[ {"id"=>1, "code"=>"1", "label"=>"Low"}, 
    																			  			  {"id"=>2, "code"=>"2", "label"=>"Moderate"}, 
    																			  			  {"id"=>3, "code"=>"3", "label"=>"High"}]}
    		]

      @conflict = ConflictCase.new(:conflict_intensity => 3, :conflict_state => 2, :conflict_type => 4)		


  	end

  	describe "with valid property" do
	  	
	  it "should return description field for con_type property" do
	  	@conflict.field_description(@fields, 'con_type').should eq "Political Violence"
	  end

	  it "should return description field for con_state property" do
	  	@conflict.field_description(@fields, 'con_state').should eq "At the conflict"
	  end

	  it "should return description field for con_intensity property" do
	  	@conflict.field_description(@fields, 'con_intensity').should eq "High"
	  end
  	end

  	describe "with invalid property" do
  	  it "should raise exception if property does not exist" do
  	  	expect{ @conflict.field_description(@fields, 'xxx')}.to raise_error(Exception)
  	  end

  	  it "should raise exception if code is incorrect" do
  	  	@conflict.conflict_intensity = 30
  	  	expect{ @conflict.field_description(@fields, 'con_intensity')}.to raise_error(Exception)		
  	  end
  	end

  end
end
