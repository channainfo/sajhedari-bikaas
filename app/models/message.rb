class Message < ActiveRecord::Base
	validates_presence_of :guid, :body, :from

	INVALID_COMMAND = "Invalid command"
	INVALID_USER = "This phone number is not belong to any reporter. Please contact administrator."
	attr_accessible :guid
  	attr_accessible :body
  	attr_accessible :from

	def process!
		reporter_number = from
		self.reply = INVALID_USER unless validate_sender
		self.reply = self.validate_message		
		if(self.reply == nil)
			fields = body.split(" ")
			if self.save_to_case(fields, sender)
				self.reply = "Successfully submit report to the system."
			else
				self.reply = "Failed to submit report to the system. Please try again later."
			end
		end
	end

	def validate_message
		fields = body.split(" ")
		list = {}
		fields.each do |f|
			if((f.start_with? "t.") or (f.start_with? "s.") or (f.start_with? "c.") or (f.start_with? "i."))
				unless self.is_i? f[2..-1]
					return "#{f} is not valid."
				else
					list["#{f[0]}"] = f[2..-1]
				end
			else
				return "#{f} is unknown."
			end
		end
		return "Message missing some field. Please follow the message template." unless fields.size == 4
		return "Duplicate information reported." if list.size != 4
	end

	def validate_sender
		if sender
			return true
		else
			return false
		end
	end

	def sender
	    if channel?(:sms)
			Reporter.find_by_phone_number(self.from[6..-1]) || Reporter.find_by_phone_number("+" + self.from[6..-1])
		end
	end

	def channel?(protocol)
		self.from && self.from.start_with?("#{protocol.to_s}://")
	end

	def save_to_case fields, sender
		conflict = {}
		fields.each do |f|
			if f.start_with? "t."
				conflict[:conflict_type_id] = f[2..-1].to_i
			end
			if f.start_with? "c."
				l = Location.find_by_code(f[2..-1])
				conflict[:location_id] = l.id
			end
			if f.start_with? "s."
				l = Location.find_by_code(f[2..-1])
				conflict[:conflict_state_id] = f[2..-1].to_i
			end
			if f.start_with? "i."
				conflict[:conflict_intensity_id] = f[2..-1].to_i
			end
		end
		conflict[:reporter_id] = sender.id
		@conflict_case = ConflictCase.new(conflict)
		site = @conflict_case.save_case_to_resource_map
		if site
			@conflict_case.site_id = site["id"]
			if @conflict_case.save				
				return true
			else
				return false
			end
		else
			return false
		end
		return false
	end

	def is_i? text
       !!(text =~ /^[-+]?[0-9]+$/)
    end

end