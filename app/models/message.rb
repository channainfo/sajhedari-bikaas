class Message < ActiveRecord::Base
	validates_presence_of :guid, :body, :from

	INVALID_COMMAND = "Invalid command"
	INVALID_USER = "This phone number is not belong to any reporter. Please contact administrator."
	attr_accessible :guid
  	attr_accessible :body
  	attr_accessible :from

	def process!
		reporter_number = from
		rm_codes = ConflictCase.get_field_codes
		self.is_success = false
		self.reply = INVALID_USER unless validate_sender
		self.reply = self.validate_message(rm_codes)
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

	def validate_message(rm_codes)
		
		fields = body.split(" ")
		list = {}
		fields.each do |f|
			# data = f.split(".")
			# if message not require . so people send a1 b2 ...
			data = f.split(/(?<=[a-zA-Z])(?=\d)/)
			key = data[0]
			value = data[1]
			if(rm_codes.include?(key.downcase) or f.downcase.start_with? "#{Setting.first.conflict_location_code.downcase}")
				unless self.is_i? value
					return "Error #{f}." + Setting.first.message_unknown
				else
					if f.downcase.start_with? "#{Setting.first.conflict_location_code.downcase}"
						l = Location.find_by_code(value)
						if l
							list["#{f[0]}".downcase] = value
						else
							return "Error #{f}." + Setting.first.message_unknown
						end
					else
						list["#{f[0]}".downcase] = value
					end
				end
			else
				return "Error #{f}." + Setting.first.message_unknown
			end
		end
		return Setting.first.message_invalid unless fields.size == (rm_codes.size + 1)
		return Setting.first.message_duplicate if list.size != (rm_codes.size + 1)
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
		all_fields = ConflictCase.get_fields
		conflict = {}
		data = {}
		fields.each do |f|
			# obj = f.split(".")
			# if message not require . so people send a1 b2 ...
			obj = f.split(/(?<=[a-zA-Z])(?=\d)/)
			key = obj[0]
			value = obj[1]
			if f.downcase.start_with? "#{Setting.first.conflict_location_code.downcase}"
				l = Location.find_by_code(value)
				if l
					conflict[:location_id] = l.id 
				else
					return false
				end
			else
				property_id = ConflictCase.get_property_id(all_fields, key.to_s)
				data[property_id] = value.to_i unless property_id.nil?
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