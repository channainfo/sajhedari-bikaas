class Message < ActiveRecord::Base
	validates_presence_of :guid, :body, :from

	INVALID_COMMAND = "Invalid command"
	INVALID_USER = "This phone number is not belong to any reporter. Please contact administrator."
	attr_accessible :guid
  	attr_accessible :body
  	attr_accessible :from

	def process!
		reporter_number = from
		self.is_success = false
		self.reply = INVALID_USER unless validate_sender
		self.reply = self.validate_message
		self.reply = Setting.first.message_invalid_sender unless sender
		if(self.reply == nil)
			fields = body.split(" ")
			if self.save_to_case(fields, sender)
				self.is_success = true
				self.reply = Setting.first.message_success
			else
				self.reply = Setting.first.message_failed
			end
		end
	end

	def validate_message
		fields = body.split(" ")
		list = {}
		fields.each do |f|
			if((f.downcase.start_with? "t.") or (f.downcase.start_with? "s.") or (f.downcase.start_with? "c.") or (f.downcase.start_with? "i."))
				unless self.is_i? f[2..-1]
					return "Error #{f}." + Setting.first.message_unknown
				else
					if f.downcase.start_with? "c."
						l = Location.find_by_code(f[2..-1])
						if l
							list["#{f[0]}".downcase] = f[2..-1]
						else
							return "Error #{f}." + Setting.first.message_unknown
						end
					else
						list["#{f[0]}".downcase] = f[2..-1]
					end
				end
			else
				return "Error #{f}." + Setting.first.message_unknown
			end
		end
		return Setting.first.message_invalid unless fields.size == 4
		return Setting.first.message_duplicate if list.size != 4
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
		data = {}
		fields.each do |f|
			if f.downcase.start_with? "c."
				l = Location.find_by_code(f[2..-1])
				if l
					conflict[:location_id] = l.id 
				else
					return false
				end
			end
			if f.downcase.start_with? "t."
				data[:conflict_type] = f[2..-1].to_i
			end
			if f.downcase.start_with? "i."
				data[:conflict_intensity] = f[2..-1].to_i
			end
			if f.downcase.start_with? "s."
				data[:conflict_state] = f[2..-1].to_i
			end
		end
		conflict[:reporter_id] = sender.id
		conflict[:message_id] = self.id
		@conflict_case = ConflictCase.new(conflict)
		site = @conflict_case.save_case_to_resource_map data
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