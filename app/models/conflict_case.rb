class ConflictCase < ActiveRecord::Base
  belongs_to :location
  belongs_to :reporter
  belongs_to :message

  attr_accessible :location_id
  attr_accessible :message_id
  attr_accessible :case_message
  attr_accessible :site_id
  attr_accessible :conflict_intensity
  attr_accessible :conflict_state
  attr_accessible :conflict_type

  attr_accessible :reporter, :location, :message, :conflict_type_description, :conflict_intensity_description, :conflict_state_description

  attr_accessible :is_deleted
  attr_accessible :is_updated
  attr_accessible :reporter_id

  attr_accessor :conflict_type_description, :conflict_intensity_description, :conflict_state_description

  def field_description fields, property
    property_code = self.translate(property)

    fields.each do |f|
        if(f["code"] == property)
          options = f["options"]
          options.each do |option|
            return option["label"] if(option["code"] == property_code)
          end
        end
    end
    raise "Unknow property: " + property + " with code: " + property_code
  end

  def con_type_description fields
    field_description fields, 'con_type'
  end

  def con_intensity_description fields
    field_description fields, 'con_intensity'
  end

  def con_state_description fields
    field_description fields, 'con_state'
  end

  def translate property
    if property == "con_type"
      self.conflict_type.to_s
    elsif property == "con_intensity"
      self.conflict_intensity.to_s
    else property == "con_state"
      self.conflict_state.to_s     
    end
  end

  def save_case_to_resource_map option
    params = { lat: self.location.lat, 
                 lng: self.location.lng, 
                 name: self.location.name, 
                 phone_number: self.reporter.phone_number,
                 conflict_type: option[:conflict_type],
                 conflict_intensity: option[:conflict_intensity],
                 conflict_state: option[:conflict_state] ,
                 headers: { Accept: "text/html" }
            }
    request = Typhoeus::Request.new(
       ResourceMapConfig["url"] + "api/collections/" + ResourceMapConfig["collection_id"].to_s + "/sites",
       method: :post,
       body: "this is a request body",
       params: params
     )
     request.run
     response = request.response
     if(response.code == 200)
       result = JSON.parse response.response_body
       return result["site"]
     end
  end

  def update_to_resource_map
    site_id = self.site_id.to_s
    request = Typhoeus::Request.new(
       ResourceMapConfig["url"] + "api/collections/" + ResourceMapConfig["collection_id"].to_s + "/sites/" + site_id,
       method: :put,
       body: "this is a request body",
       params: { phone_number: self.reporter.phone_number,
                 lat: Location.find_by_id(self.backup.data["location_id"].to_i).lat, 
                 lng: Location.find_by_id(self.backup.data["location_id"].to_i).lng,
                 name: Location.find_by_id(self.backup.data["location_id"].to_i).name, 
                 conflict_type: self.backup.data["conflict_type"].to_i,
                 conflict_intensity: self.backup.data["conflict_intensity"].to_i,
                 conflict_state: self.backup.data["conflict_state"].to_i 
                },
       headers: { Accept: "text/html" }
     )
    request.run
    response = request.response.code
    return response == 200
  end

  def to_csv

  end

  def update_to_resource_map_with_form params
    site_id = self.site_id.to_s
    request = Typhoeus::Request.new(
       ResourceMapConfig["url"] + "api/collections/" + ResourceMapConfig["collection_id"].to_s + "/sites/" + site_id,
       method: :put,
       body: "this is a request body",
       params: { phone_number: self.reporter.phone_number,
                 lat: Location.find_by_id(self.backup.data["location_id"].to_i).lat, 
                 lng: Location.find_by_id(self.backup.data["location_id"].to_i).lng, 
                 name: Location.find_by_id(self.backup.data["location_id"].to_i).name, 
                 conflict_type: params["conflict_type"].to_i,
                 conflict_intensity: params["conflict_intensity"].to_i,
                 conflict_state: params["conflict_state"].to_i 
                },
       headers: { Accept: "text/html" }
     )
    request.run
    response = request.response.code
    return response == 200
  end

  def destroy_case_from_resource_map
    site_id = self.site_id.to_s
    request = Typhoeus::Request.new(
    ResourceMapConfig["url"] + "api/collections/" + ResourceMapConfig["collection_id"].to_s + "/sites/" + site_id,
      method: :delete,
      body: "this is a request body",
      params: {},
      headers: { Accept: "text/html" }
    )
    request.run
    response = request.response.code
    return response == 200
  end

  def self.get_all_sites_from_resource_map()
    request = Typhoeus::Request.new(
    ResourceMapConfig["url"] + "api/collections/" + ResourceMapConfig["collection_id"].to_s + "/sites",
      method: :get,
      body: "this is a request body",
      headers: { Accept: "text/html" }
    )
    request.run
    response = request.response.response_body
    return JSON.parse(response)["sites"]
  end

  def self.get_paging_sites_from_resource_map(limit, offset, from, to)
    request = Typhoeus::Request.new(
    ResourceMapConfig["url"] + "api/collections/" + ResourceMapConfig["collection_id"].to_s + "/sites",
      method: :get,
      body: "this is a request body",
      params: {:limit => limit, :offset => offset, :from => from, :to => to}
    )
    request.run
    response = request.response.response_body
    return JSON.parse(response)
  end


  def self.all_from_resource_map
    request = Typhoeus::Request.new(
      ResourceMapConfig["url"] + "api/collections/" + ResourceMapConfig["collection_id"].to_s + "/sites",
      method: :get
    )
    request.run
    JSON.parse(request.response.body)["sites"]
  end

  def self.get_all_sites_from_resource_map_by_period(start_date, end_date)
    request = Typhoeus::Request.new(
      ResourceMapConfig["url"] + "api/collections/" + ResourceMapConfig["collection_id"].to_s + "/sites",
      method: :get,
      body: "this is a request body",
      headers: { Accept: "text/html" },
      params: {:start_date => start_date, :end_date => end_date } 
    )
    request.run
    response = request.response.response_body
    return JSON.parse(response)["sites"]
  end

  def self.get_some_sites_from_resourcemap site_ids
    request = Typhoeus::Request.new(
      ResourceMapConfig["url"] + "api/collections/" + ResourceMapConfig["collection_id"].to_s + "/get_some_sites",
      method: :get,
      body: "this is a request body",
      headers: { Accept: "text/html" },
      params: {:sites => site_ids.join(",")} 
    )
    request.run
    response = request.response.response_body
    return JSON.parse(response)
  end

  def get_conflict_from_resource_map
    request = Typhoeus::Request.new(
      ResourceMapConfig["url"] + "api/collections/" + ResourceMapConfig["collection_id"].to_s + "/sites/" + self.site_id.to_s,
      method: :get,
      body: "this is a request body",
      params: {},
      headers: { Accept: "text/html" }
    )
    request.run
    response = request.response.response_body
    return JSON.parse(response)
  end


  def self.get_category
    'conflict_case'
  end

  def backup
    backup = Backup.find_by_entity_id_and_category(self.id, ConflictCase.get_category)
    backup.data = JSON.parse backup.data if backup
    backup
  end

  def self.get_fields
    request = Typhoeus::Request.new(
    ResourceMapConfig["url"] + "api/collections/" + ResourceMapConfig["collection_id"].to_s + "/get_fields.json",
      method: :get,
      headers: { Accept: "text/html" }
    )
    request.run
    response = request.response
    if response.code == 200
      fields = JSON.parse response.response_body
      return fields
    else
      return nil
    end
  end

  def self.transform sites, fields
    conflict_cases = []
    sites.each do |site|
      conflict_cases.push(convertToConflictCase(site, fields))
    end
    conflict_cases
  end

  def self.get_sites_bases_on_conflict_type_from_resourcemap params
    request = Typhoeus::Request.new(
    ResourceMapConfig["url"] + "api/collections/" + ResourceMapConfig["collection_id"].to_s + "/get_sites_conflict.json",
      method: :get,
      body: "this is a request body",
      params: {:con_type => params[:data], :from => params[:from], :to => params[:to]},
      headers: { Accept: "text/html" }
    )
    request.run
    response = request.response.response_body
    return JSON.parse(response)
  end

  def self.convertToConflictCase site, fields
    conflict = ConflictCase.find_by_site_id(site["id"])
    properties = site["properties"]
    properties.each do |key, value|
      conflict = assign_value conflict, key, value, fields
    end
    conflict
  end

  def self.generate_weekly_graph conflict_case, params
    graph_data = {}
    k = 0
    con_type = params[:data].split(",")
    tmp_value = []
    result = []
    if con_type.count > 0
      arr = generate_weekly_array params[:from], params[:to]
      con_type.each do |con|
        k = k + 1
        if conflict_case.count > 0
          conflict_case.each do |c|
              for w in 1..arr.count
                week = arr[w-1][0].split("/")[0]
                month = arr[w-1][0].split("/")[1].to_i
                year = arr[w-1][0].split("/")[2].to_i
                if week == "W1"
                  if (1..7).member?(c.created_at.mday) && c.created_at.mon == month && c.created_at.year == year && c.conflict_type == con.to_i
                    arr[w-1][k] = arr[w-1][k].nil? ? 1 : arr[w-1][k] + 1
                  else
                    arr[w-1][k] = arr[w-1][k].nil? ? 0 : arr[w-1][k]
                  end
                elsif week == "W2"
                  if (8..14).member?(c.created_at.mday) && c.created_at.mon == month && c.created_at.year == year && c.conflict_type == con.to_i
                    arr[w-1][k] = arr[w-1][k].nil? ? 1 : arr[w-1][k] + 1
                  else
                    arr[w-1][k] = arr[w-1][k].nil? ? 0 : arr[w-1][k]
                  end
                elsif week == "W3"
                  if (15..21).member?(c.created_at.mday) && c.created_at.mon == month && c.created_at.year == year && c.conflict_type == con.to_i
                    arr[w-1][k] = arr[w-1][k].nil? ? 1 : arr[w-1][k] + 1
                  else
                    arr[w-1][k] = arr[w-1][k].nil? ? 0 : arr[w-1][k]
                  end
                elsif week == "W4"
                  if (22..31).member?(c.created_at.mday) && c.created_at.mon == month && c.created_at.year == year && c.conflict_type == con.to_i
                    arr[w-1][k] = arr[w-1][k].nil? ? 1 : arr[w-1][k] + 1
                  else
                    arr[w-1][k] = arr[w-1][k].nil? ? 0 : arr[w-1][k]
                  end
                end
                tmp_value << arr[w-1][k]
              end
          end
        else
          for w in 1..arr.count
            arr[w-1][k] = arr[w-1][k].nil? ? 0 : arr[w-1][k]
          end
        end
      end
      max_value = calculate_max_vAxis(tmp_value)
      result << arr
      result << [max_value.to_s]
    else
      result = [[["", 0]], ["4"]]
    end
    return result
  end

  def self.generate_daily_graph conflict_case, params
    graph_data = {}
    k = 0
    con_type = params[:data].split(",")
    tmp_value = []
    result = []
    if con_type.count > 0
      arr = generate_daily_array params[:from], params[:to]
      con_type.each do |con|
        k = k + 1
        if conflict_case.count > 0
          conflict_case.each do |c|
              for day in 1..arr.count
                tmp_day = arr[day-1][0].split("/")[1].to_i
                month = arr[day-1][0].split("/")[0].to_i
                year = arr[day-1][0].split("/")[2].to_i
                if c.created_at.mday == tmp_day && c.created_at.mon == month && c.created_at.year == year && c.conflict_type == con.to_i
                  arr[day-1][k] = arr[day-1][k].nil? ? 1 : arr[day-1][k] + 1
                else
                  arr[day-1][k] = arr[day-1][k].nil? ? 0 : arr[day-1][k]
                end
                tmp_value << arr[day-1][k]
              end
          end
        else
          for day in 1..arr.count
            arr[day-1][k] = arr[day-1][k].nil? ? 0 : arr[day-1][k]
          end
        end
      end
      max_value = calculate_max_vAxis(tmp_value)
      result << arr
      result << [max_value.to_s]
    else
      result = [[["", 0]], ["4"]]
    end
    return result
  end

  def self.calculate_max_vAxis tmp_value
    if tmp_value.count > 0
      if (tmp_value.max() < 4)
          max_value = 4
      else
        res = tmp_value.max() % 4
        if (res != 0)
          max_value = tmp_value.max() + (4 - res)
        else
          max_value = tmp_value.max()
        end
      end
    else
      max_value = 4
    end
    return max_value
  end

  def self.generate_header con_type
    header = ["Day"]
    con_type = con_type.split(",")
    if con_type.size == 0
      header << ""
    end
    con_type.each do |el|
      header << ""
    end
    return header
  end

  def self.generate_weekly_array from, to
    arr = []
    from = from.blank? ? "#{Time.now.mon}/01/#{Time.now.year}" : from
    to = to.blank? ? "#{Time.now.mon}/30/#{Time.now.year}" : to
    from = parse_date_format from
    to = parse_date_format(to).end_of_month
    for i in from..to
      if (1..7).member?(i.mday)
        arr << ["W1/#{i.mon}/#{i.year}"] unless arr.include?(["W1/#{i.mon}/#{i.year}"])
      elsif (7..14).member?(i.mday)
        arr << ["W2/#{i.mon}/#{i.year}"] unless arr.include?(["W2/#{i.mon}/#{i.year}"])
      elsif (15..21).member?(i.mday)
        arr << ["W3/#{i.mon}/#{i.year}"] unless arr.include?(["W3/#{i.mon}/#{i.year}"])
      elsif (22..31).member?(i.mday)
        arr << ["W4/#{i.mon}/#{i.year}"] unless arr.include?(["W4/#{i.mon}/#{i.year}"])
      end
    end
    return arr
  end

  def self.generate_montly_graph conflict_case, params
    graph_data = {}
    k = 0
    tmp_value = []
    result = []
    con_type = params[:data].split(",")
    if con_type.count > 0
      arr = generate_montly_array params[:from], params[:to]
      con_type.each do |con|
        k = k + 1
        if conflict_case.count > 0
          conflict_case.each do |c|
              for mon in 1..arr.count
                month = arr[mon-1][0].split("/")[0].to_i
                year = arr[mon-1][0].split("/")[1].to_i
                if c.created_at.mon == month && c.created_at.year == year && c.conflict_type == con.to_i
                  arr[mon-1][k] = arr[mon-1][k].nil? ? 1 : arr[mon-1][k] + 1
                else
                  arr[mon-1][k] = arr[mon-1][k].nil? ? 0 : arr[mon-1][k]
                end
                tmp_value << arr[mon-1][k]
              end
          end
        else
          for mon in 1..arr.count
            arr[mon-1][k] = arr[mon-1][k].nil? ? 0 : arr[mon-1][k]
          end
        end
      end
      max_value = calculate_max_vAxis(tmp_value)
      result << arr
      result << [max_value.to_s]
    else
      result = [[["", 0]], ["4"]]
    end
    return result
  end

  def self.generate_yearly_graph conflict_case, params
    graph_data = {}
    k = 0
    tmp_value = []
    result = []
    con_type = params[:data].split(",")
    if con_type.count > 0
      arr = generate_yearly_array params[:from], params[:to]
      con_type.each do |con|
        k = k + 1
        if conflict_case.count > 0
          conflict_case.each do |c|
              for y in 1..arr.count
                year = arr[y-1][0].split("/")[0].to_i
                if c.created_at.year == year && c.conflict_type == con.to_i
                  arr[y-1][k] = arr[y-1][k].nil? ? 1 : arr[y-1][k] + 1
                else
                  arr[y-1][k] = arr[y-1][k].nil? ? 0 : arr[y-1][k]
                end
                tmp_value << arr[y-1][k]
              end
          end
        else
          for y in 1..arr.count
            arr[y-1][k] = arr[y-1][k].nil? ? 0 : arr[y-1][k]
          end
        end
      end
      max_value = calculate_max_vAxis(tmp_value)
      result << arr
      result << [max_value.to_s]
    else
      result = [[["", 0]], ["4"]]
    end
    return result
  end

  def self.generate_yearly_array from, to
    arr = []
    from = from.blank? ? "#{Time.now.mon}/01/#{Time.now.year}" : from
    to = to.blank? ? "#{Time.now.mon}/30/#{Time.now.year}" : to
    from = parse_date_format from
    to = parse_date_format(to).end_of_month
    for i in from..to
      arr << ["#{i.year}"] unless arr.include?(["#{i.year}"])
    end
    return arr
  end

  def self.generate_semi_annual_graph conflict_case, params
    graph_data = {}
    k = 0
    tmp_value = []
    result = []
    con_type = params[:data].split(",")
    if con_type.count > 0
      arr = generate_semi_annual_array params[:from], params[:to]
      con_type.each do |con|
        k = k + 1
        if conflict_case.count > 0
          conflict_case.each do |c|
              for s in 1..arr.count
                semester = arr[s-1][0].split("/")[0]
                year = arr[s-1][0].split("/")[1].to_i
                if semester == "S1"
                  if (1..6).member?(c.created_at.mon) && c.created_at.year == year && c.conflict_type == con.to_i
                    arr[s-1][k] = arr[s-1][k].nil? ? 1 : arr[s-1][k] + 1
                  else
                    arr[s-1][k] = arr[s-1][k].nil? ? 0 : arr[s-1][k]
                  end
                elsif semester == "S2"
                  if (7..12).member?(c.created_at.mon) && c.created_at.year == year && c.conflict_type == con.to_i
                    arr[s-1][k] = arr[s-1][k].nil? ? 1 : arr[s-1][k] + 1
                  else
                    arr[s-1][k] = arr[s-1][k].nil? ? 0 : arr[s-1][k]
                  end
                end
                tmp_value << arr[s-1][k]
              end
          end
        else
          for s in 1..arr.count
            arr[s-1][k] = arr[s-1][k].nil? ? 0 : arr[s-1][k]
          end
        end
      end
      max_value = calculate_max_vAxis(tmp_value)
      result << arr
      result << [max_value.to_s]
    else
      result = [[["", 0]], ["4"]]
    end
    return result
  end

  def self.generate_semi_annual_array from, to
    arr = []
    from = from.blank? ? "#{Time.now.mon}/01/#{Time.now.year}" : from
    to = to.blank? ? "#{Time.now.mon}/30/#{Time.now.year}" : to
    from = parse_date_format from
    to = parse_date_format(to).end_of_month
    for i in from..to
      if (1..6).member?(i.mon)
        arr << ["S1/#{i.year}"] unless arr.include?(["S1/#{i.year}"])
      elsif (7..12).member?(i.mon)
        arr << ["S2/#{i.year}"] unless arr.include?(["S2/#{i.year}"])
      end
    end
    return arr
  end

  def self.generate_quarterly_graph conflict_case, params
    graph_data = {}
    k = 0
    tmp_value = []
    result = []
    con_type = params[:data].split(",")
    if con_type.count > 0
      arr = generate_quarterly_array params[:from], params[:to]

      con_type.each do |con|
        k = k + 1
        if conflict_case.count > 0
          conflict_case.each do |c|
              for q in 1..arr.count
                quarter = arr[q-1][0].split("/")[0]
                year = arr[q-1][0].split("/")[1].to_i
                if quarter == "Q1"
                  if (1..3).member?(c.created_at.mon) && c.created_at.year == year && c.conflict_type == con.to_i
                    arr[q-1][k] = arr[q-1][k].nil? ? 1 : arr[q-1][k] + 1
                  else
                    arr[q-1][k] = arr[q-1][k].nil? ? 0 : arr[q-1][k]
                  end
                elsif quarter == "Q2"
                  if (4..6).member?(c.created_at.mon) && c.created_at.year == year && c.conflict_type == con.to_i
                    arr[q-1][k] = arr[q-1][k].nil? ? 1 : arr[q-1][k] + 1
                  else
                    arr[q-1][k] = arr[q-1][k].nil? ? 0 : arr[q-1][k]
                  end
                elsif quarter == "Q3"
                  if (7..9).member?(c.created_at.mon) && c.created_at.year == year && c.conflict_type == con.to_i
                    arr[q-1][k] = arr[q-1][k].nil? ? 1 : arr[q-1][k] + 1
                  else
                    arr[q-1][k] = arr[q-1][k].nil? ? 0 : arr[q-1][k]
                  end
                elsif quarter == "Q4"
                  if (10..12).member?(c.created_at.mon) && c.created_at.year == year && c.conflict_type == con.to_i
                    arr[q-1][k] = arr[q-1][k].nil? ? 1 : arr[q-1][k] + 1
                  else
                    arr[q-1][k] = arr[q-1][k].nil? ? 0 : arr[q-1][k]
                  end
                end
                tmp_value << arr[q-1][k]
              end
          end
        else
          for q in 1..arr.count
            arr[q-1][k] = arr[q-1][k].nil? ? 0 : arr[q-1][k]
          end
        end
      end
      max_value = calculate_max_vAxis(tmp_value)
      result << arr
      result << [max_value.to_s]
    else
      result = [[["", 0]], ["4"]]
    end
    return result
  end

  def self.generate_quarterly_array from, to
    arr = []
    from = from.blank? ? "#{Time.now.mon}/01/#{Time.now.year}" : from
    to = to.blank? ? "#{Time.now.mon}/30/#{Time.now.year}" : to
    from = parse_date_format from
    to = parse_date_format(to).end_of_month
    for i in from..to
      if (1..3).member?(i.mon)
        arr << ["Q1/#{i.year}"] unless arr.include?(["Q1/#{i.year}"])
      elsif (4..6).member?(i.mon)
        arr << ["Q2/#{i.year}"] unless arr.include?(["Q2/#{i.year}"])
      elsif (7..9).member?(i.mon)
        arr << ["Q3/#{i.year}"] unless arr.include?(["Q3/#{i.year}"])
      elsif (10..12).member?(i.mon)
        arr << ["Q4/#{i.year}"] unless arr.include?(["Q4/#{i.year}"])
      end
    end
    return arr
  end

  def self.generate_montly_array from, to
    arr = []
    from = from.blank? ? "#{Time.now.mon}/01/#{Time.now.year}" : from
    to = to.blank? ? "#{Time.now.mon}/30/#{Time.now.year}" : to
    from = parse_date_format from
    to = parse_date_format(to).end_of_month
    for i in from..to
      arr << ["#{i.mon}/#{i.year}"] unless arr.include?(["#{i.mon}/#{i.year}"])
    end
    return arr
  end

  def self.generate_daily_array from, to
    arr = []
    from = from.blank? ? "#{Time.now.mon}/01/#{Time.now.year}" : from
    to = to.blank? ? "#{Time.now.mon}/30/#{Time.now.year}" : to
    from = parse_date_format from
    to = parse_date_format(to).end_of_month
    for i in from..to
      arr << [reverse_date_format(i)]
    end
    return arr
  end

  def self.parse_date_format date 
    array_date = date.split("-")
    return Date.new(array_date[2].to_i, array_date[0].to_i, array_date[1].to_i)
  end

  def self.reverse_date_format date
    return "#{date.mon}/#{date.mday}/#{date.year}"
  end

  def self.assign_value conflict, key, value, fields
    fields.each do |f|
      if f["id"] == key.to_i
        case f["code"]
          when "con_state"
            conflict.conflict_state = value
            conflict.conflict_state_description = conflict.con_state_description fields
          when "con_type"
            conflict.conflict_type = value
            conflict.conflict_type_description = conflict.con_type_description fields
          when "con_intensity"
            conflict.conflict_intensity = value
            conflict.conflict_intensity_description = conflict.con_intensity_description fields
        end
      end
    end
    conflict
  end

  def self.generate_csv_headers con_type
    arr_conflict = ["Date"]
    con_type.each do |el|
      if el == "1"
        arr_conflict << "Gender based violence"
      elsif el == "2"
        arr_conflict << "Identity-based violence"
      elsif el == "3"
        arr_conflict << "Case based violence"
      elsif el == "4"
        arr_conflict << "Political violence"
      elsif el == "5"
        arr_conflict << "Inter-personal conflict"
      elsif el == "6"
        arr_conflict << "Resource based violence"
      end
    end
    return arr_conflict
  end

  def self.generate_csv_content graph_data
    CSV.generate do |csv|
      graph_data.each do |el|
        csv << el
      end
    end
  end

  def self.generate_trends_header
    return ["Date","type1"]
  end

  def self.generate_trends_content graph_data
    graph_data.each do |el|
      return el
    end
  end

  def meet_alert?(condition)
    return false unless condition.size > 0
    condition.each do |key, value|
      case key
        when "con_state"
          return false unless self.conflict_state == value.to_i
        when "con_type"
          return false unless self.conflict_type == value.to_i
        when "con_intensity"
          return false unless self.conflict_intensity == value.to_i
      end
    end
    return true
  end
end
