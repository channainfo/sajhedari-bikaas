
require 'spec_helper'

describe Message do

	describe "check message channel and sender" do
		before(:each) do
			@message =  Message.new
		end

		it "should not be an sms" do
			@message.should_not be_channel(:sms)
		end

		it "should not have a sender" do
			@message.sender.should be_nil
		end

		it "should check message is and sms" do
			@message.from = "sms://1"
			@message.should be_channel(:sms)
		end

		it "should find sender by phone number" do
			reporter = Reporter.make :phone_number => "1"
			@message.from = "sms://1"
			@message.sender.should eq(reporter)
		end
	end

	describe "#process!" do
		before(:each) do
			location = Location.make :code => 20, :name => 'Samrong', :lat => 12.33434, :lng => 123.12334
			reporter = Reporter.make :id => 1, :phone_number => "85516222172"
			@message = Message.new :guid => '999', :from => 'sms://85516222172', :body => 'c.20 t.2 s.1 i.5'
		end

		it "should save reply" do
			@message.process!
			@message.reply.should == "Successfully submit report to the system."
		end

		context "when command is invalid" do
			it "should not save reply and return unknow field" do
				@message.body = "g.10 t.89 c.20 s.10"
				@message.save
				@message.process!
				@message.reply.should == "g.10 is unknown."
			end

			it "should not save reply and return not valid data" do
				@message.body = "i.23 t.8.9 c.20 s.10"
				@message.save
				@message.process!
				@message.reply.should == "t.8.9 is not valid."
			end

			it "should not save reply and return duplicated field" do
				@message.body = "c.20 i.2 s.1 i.5"
				@message.save
				@message.process!
				@message.reply.should == "Duplicate information reported."
			end

			it "should not save reply and return missing some field" do
				@message.body = "c.20 i.2"
				@message.save
				@message.process!
				@message.reply.should == "Message missing some field. Please follow the message template."
			end
		end
	end  
end 
