require '../spec_helper'

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

    describe "generate graph" do
      before(:each) do
        @params = {:data => "1", :from => "08/01/2013", :to => "09/30/2013"}
        ConflictCase.create!(:conflict_intensity => 1, :conflict_state => 1, :conflict_type => 1)
        ConflictCase.create!(:conflict_intensity => 1, :conflict_state => 1, :conflict_type => 1)
        @conflict_case = ConflictCase.where(:conflict_type => 1)
      end

      it "should generate array format for display daily report on google chart" do
        expected_result = [[["8/1/2013", 0], ["8/2/2013", 0], ["8/3/2013", 0], ["8/4/2013", 0], ["8/5/2013", 0], ["8/6/2013", 0],
                  ["8/7/2013", 0], ["8/8/2013", 0], ["8/9/2013", 0], ["8/10/2013", 0], ["8/11/2013", 0], ["8/12/2013", 0],
                  ["8/13/2013", 0], ["8/14/2013", 0], ["8/15/2013", 0], ["8/16/2013", 0], ["8/17/2013", 0], ["8/18/2013", 0],
                  ["8/19/2013", 0], ["8/20/2013", 0], ["8/21/2013", 0], ["8/22/2013", 0], ["8/23/2013", 0], ["8/24/2013", 0],
                  ["8/25/2013", 0], ["8/26/2013", 0], ["8/27/2013", 0], ["8/28/2013", 0], ["8/29/2013", 0], ["8/30/2013", 0], ["8/31/2013", 0],
                  ["9/1/2013", 0], ["9/2/2013", 0], ["9/3/2013", 2], ["9/4/2013", 0], ["9/5/2013", 0], ["9/6/2013", 0],
                  ["9/7/2013", 0], ["9/8/2013", 0], ["9/9/2013", 0], ["9/10/2013", 0], ["9/11/2013", 0], ["9/12/2013", 0],
                  ["9/13/2013", 0], ["9/14/2013", 0], ["9/15/2013", 0], ["9/16/2013", 0], ["9/17/2013", 0], ["9/18/2013", 0],
                  ["9/19/2013", 0], ["9/20/2013", 0], ["9/21/2013", 0], ["9/22/2013", 0], ["9/23/2013", 0], ["9/24/2013", 0],
                  ["9/25/2013", 0], ["9/26/2013", 0], ["9/27/2013", 0], ["9/28/2013", 0], ["9/29/2013", 0], ["9/30/2013", 0]], ["4"]]

        ConflictCase.generate_daily_graph(@conflict_case, @params).should eq expected_result
      end

      it "should generate array format for display weekly report on google chart" do
        expected_result = [[["W1/8/2013", 0], ["W2/8/2013", 0], ["W3/8/2013", 0], ["W4/8/2013", 0],
                          ["W1/9/2013", 2], ["W2/9/2013", 0], ["W3/9/2013", 0], ["W4/9/2013", 0]],["4"]]

        ConflictCase.generate_weekly_graph(@conflict_case, @params).should eq expected_result
      end

      it "should generate array format for disply montly report on google chart" do
        expected_result = [[["8/2013", 0], ["9/2013", 2]], ["4"]]
        ConflictCase.generate_montly_graph(@conflict_case, @params).should eq expected_result
      end

      it "should generate array format for display quarterly report on google chart" do
        expected_result = [[["Q3/2013", 2]], ["4"]]
        ConflictCase.generate_quarterly_graph(@conflict_case, @params).should eq expected_result
      end

      it "should generate array format for display semi-annualy report on google chart" do
        expected_result = [[["S2/2013", 2]], ["4"]]
        ConflictCase.generate_semi_annual_graph(@conflict_case, @params).should eq expected_result
      end

      it "should generate array format for display yearly report on google chart" do
        expected_result = [[["2013", 2]], ["4"]]
        ConflictCase.generate_yearly_graph(@conflict_case, @params).should eq expected_result
      end
    end

    describe "manualy set the max high of google chart" do

      it "should return 4 when the array is empty" do
        array_value = []
        max_value = ConflictCase.calculate_max_vAxis(array_value)
        max_value.should eq 4
      end

      it "should return 4 when the max value in array less than 4" do
        array_value = [1, 2, 3]
        max_value = ConflictCase.calculate_max_vAxis(array_value)
        max_value.should eq 4
      end

      it "should return the max value if it is devided by 4" do
        array_value = [1, 2, 3, 4]
        max_value = ConflictCase.calculate_max_vAxis(array_value)
        max_value.should eq 4
      end

      it "should return the value division of 4 if it is not devided by 4" do
        array_value = [1, 2, 3, 4, 5, 6, 7]
        max_value = ConflictCase.calculate_max_vAxis(array_value)
        max_value.should eq 8
      end
    end

  end
end
