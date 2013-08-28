class ConflictCase < ActiveRecord::Base
  belongs_to :location
  belongs_to :reporter

  attr_accessible :location_id
  attr_accessible :case_message
  attr_accessible :site_id
  attr_accessible :conflict_intensity
  attr_accessible :conflict_state
  attr_accessible :conflict_type

  attr_accessible :is_deleted
  attr_accessible :is_updated
  attr_accessible :reporter_id

  def save_case_to_resource_map option
    yml = self.class.load_resource_map
    request = Typhoeus::Request.new(
       yml["url"] + "api/collections/" + yml["collection_id"].to_s + "/sites",
       method: :post,
       body: "this is a request body",
       params: { lat: self.location.lat, 
                 lng: self.location.lng, 
                 name: self.location.name, 
                 phone_number: self.reporter.phone_number,
                 conflict_type: option[:conflict_type],
                 conflict_intensity: option[:conflict_intensity],
                 conflict_state: option[:conflict_state] },
       headers: { Accept: "text/html" }
     )
     request.run
     response = request.response
     if(response.code == 200)
       result = JSON.parse response.response_body
       return result["site"]
     end
  end

  def update_to_resource_map
    yml = self.class.load_resource_map
    site_id = self.site_id.to_s
    request = Typhoeus::Request.new(
       yml["url"] + "api/collections/" + yml["collection_id"].to_s + "/sites/" + site_id,
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

  def update_to_resource_map_with_form params
    yml = self.class.load_resource_map
    site_id = self.site_id.to_s
    request = Typhoeus::Request.new(
       yml["url"] + "api/collections/" + yml["collection_id"].to_s + "/sites/" + site_id,
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
    yml = self.class.load_resource_map
    site_id = self.site_id.to_s
    request = Typhoeus::Request.new(
    yml["url"] + "api/collections/" + yml["collection_id"].to_s + "/sites/" + site_id,
      method: :delete,
      body: "this is a request body",
      params: {},
      headers: { Accept: "text/html" }
    )
    request.run
    response = request.response.code
    return response == 200
  end

  def self.get_all_sites_from_resource_map(limit, offset)
    yml = load_resource_map
    request = Typhoeus::Request.new(
    yml["url"] + "api/collections/" + yml["collection_id"].to_s + "/sites",
      method: :get,
      body: "this is a request body",
      params: {:limit => limit, :offset => offset},
      headers: { Accept: "text/html" }
    )
    request.run
    response = request.response.response_body
    return JSON.parse(response)
  end

  def get_conflict_from_resource_map
    yml = self.class.load_resource_map
    request = Typhoeus::Request.new(
    yml["url"] + "api/collections/" + yml["collection_id"].to_s + "/sites/" + self.site_id.to_s,
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

  def self.load_resource_map
    YAML.load_file File.expand_path(Rails.root + "config/resourcemap.yml", __FILE__)
  end

  def self.get_fields
    yml = load_resource_map
    request = Typhoeus::Request.new(
    yml["url"] + "api/collections/" + yml["collection_id"].to_s + "/get_fields.json",
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

  def self.transform sites, field
    conflict_cases = []
    sites.each do |site|
      conflict_cases.push(convertToConflictCase(site, field))
    end
    conflict_cases
  end

  def self.get_sites_bases_on_conflict_type_from_resourcemap params
    yml = load_resource_map
    request = Typhoeus::Request.new(
    yml["url"] + "api/collections/" + yml["collection_id"].to_s + "/sites",
      method: :get,
      body: "this is a request body",
      params: {:con_type => params[:data], :from => params[:from], :to => params[:to]},
      headers: { Accept: "text/html" }
    )
    request.run
    response = request.response.response_body
    return JSON.parse(response)
  end

  def self.convertToConflictCase site, field
    conflict = ConflictCase.find_by_site_id(site["id"])
    properties = site["properties"]
    properties.each do |key, value|
      conflict = assign_value conflict, key, value, field
    end
    conflict
  end

  def self.generate_weekly_graph conflict_case, params
    graph_data = {}
    k = 0
    con_type = params[:data].split(",")
    if con_type.count > 0
      arr = generate_weekly_array params[:from], params[:to]
      con_type.each do |con|
        k = k + 1
        conflict_case.each do |c|
            for w in 1..arr.count
              week = arr[w-1][0].split("/")[0]
              if week == "W1"
                if (1..7).member?(c.created_at.mday) && c.conflict_type == con.to_i
                  arr[w-1][k] = arr[w-1][k].nil? ? 1 : arr[w-1][k] + 1
                else
                  arr[w-1][k] = arr[w-1][k].nil? ? 0 : arr[w-1][k]
                end
              elsif week == "W2"
                if (8..14).member?(c.created_at.mday) && c.conflict_type == con.to_i
                  arr[w-1][k] = arr[w-1][k].nil? ? 1 : arr[w-1][k] + 1
                else
                  arr[w-1][k] = arr[w-1][k].nil? ? 0 : arr[w-1][k]
                end
              elsif week == "W3"
                if (15..21).member?(c.created_at.mday) && c.conflict_type == con.to_i
                  arr[w-1][k] = arr[w-1][k].nil? ? 1 : arr[w-1][k] + 1
                else
                  arr[w-1][k] = arr[w-1][k].nil? ? 0 : arr[w-1][k]
                end
              elsif week == "W4"
                if (22..31).member?(c.created_at.mday) && c.conflict_type == con.to_i
                  arr[w-1][k] = arr[w-1][k].nil? ? 1 : arr[w-1][k] + 1
                else
                  arr[w-1][k] = arr[w-1][k].nil? ? 0 : arr[w-1][k]
                end
              end

            end
        end
      end
    else
      arr = [['', 0]]
    end
    return arr
  end

  def self.generate_daily_graph conflict_case, params
    graph_data = {}
    k = 0
    con_type = params[:data].split(",")
    if con_type.count > 0
      arr = generate_daily_array params[:from], params[:to]
      con_type.each do |con|
        k = k + 1
        conflict_case.each do |c|
            for day in 1..arr.count
              tmp_day = arr[day-1][0].split("/")[1].to_i
              if c.created_at.mday == tmp_day && c.conflict_type == con.to_i
                arr[day-1][k] = arr[day-1][k].nil? ? 1 : arr[day-1][k] + 1
              else
                arr[day-1][k] = arr[day-1][k].nil? ? 0 : arr[day-1][k]
              end
            end
        end
      end
    else
      arr = [['', 0]]
    end
    return arr
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
    to = to.blank? ? "#{Time.now.mon}/31/#{Time.now.year}" : to
    from = parse_date_format from
    to = parse_date_format to
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
    con_type = params[:data].split(",")
    if con_type.count > 0
      arr = generate_montly_array params[:from], params[:to]
      con_type.each do |con|
        k = k + 1
        conflict_case.each do |c|
            for mon in 1..arr.count
              month = arr[mon-1][0].split("/")[0].to_i
              if c.created_at.mon == month && c.conflict_type == con.to_i
                arr[mon-1][k] = arr[mon-1][k].nil? ? 1 : arr[mon-1][k] + 1
              else
                arr[mon-1][k] = arr[mon-1][k].nil? ? 0 : arr[mon-1][k]
              end
            end
        end
      end
    else
      arr = [['', 0]]
    end
    return arr
  end

  def self.generate_yearly_graph conflict_case, params
    graph_data = {}
    k = 0
    con_type = params[:data].split(",")
    if con_type.count > 0
      arr = generate_yearly_array params[:from], params[:to]
      con_type.each do |con|
        k = k + 1
        conflict_case.each do |c|
            for y in 1..arr.count
              year = arr[y-1][0].split("/")[0].to_i
              if c.created_at.year == year && c.conflict_type == con.to_i
                arr[y-1][k] = arr[y-1][k].nil? ? 1 : arr[y-1][k] + 1
              else
                arr[y-1][k] = arr[y-1][k].nil? ? 0 : arr[y-1][k]
              end
            end
        end
      end
    else
      arr = [['', 0]]
    end
    return arr
  end

  def self.generate_yearly_array from, to
    arr = []
    from = from.blank? ? "#{Time.now.mon}/01/#{Time.now.year}" : from
    to = to.blank? ? "#{Time.now.mon}/31/#{Time.now.year}" : to
    from = parse_date_format from
    to = parse_date_format to
    for i in from..to
      arr << ["#{i.year}"] unless arr.include?(["#{i.year}"])
    end
    return arr
  end

  def self.generate_semi_annual_graph conflict_case, params
    graph_data = {}
    k = 0
    con_type = params[:data].split(",")
    if con_type.count > 0
      arr = generate_semi_annual_array params[:from], params[:to]
      con_type.each do |con|
        k = k + 1
        conflict_case.each do |c|
            for q in 1..arr.count
              quarter = arr[q-1][0].split("/")[0]
              if quarter == "S1"
                if (1..6).member?(c.created_at.mon) && c.conflict_type == con.to_i
                  arr[q-1][k] = arr[q-1][k].nil? ? 1 : arr[q-1][k] + 1
                else
                  arr[q-1][k] = arr[q-1][k].nil? ? 0 : arr[q-1][k]
                end
              elsif quarter == "S2"
                if (7..12).member?(c.created_at.mon) && c.conflict_type == con.to_i
                  arr[q-1][k] = arr[q-1][k].nil? ? 1 : arr[q-1][k] + 1
                else
                  arr[q-1][k] = arr[q-1][k].nil? ? 0 : arr[q-1][k]
                end
              end

            end
        end
      end
    else
      arr = [['', 0]]
    end
    return arr
  end

  def self.generate_semi_annual_array from, to
    arr = []
    from = from.blank? ? "#{Time.now.mon}/01/#{Time.now.year}" : from
    to = to.blank? ? "#{Time.now.mon}/31/#{Time.now.year}" : to
    from = parse_date_format from
    to = parse_date_format to
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
    con_type = params[:data].split(",")
    if con_type.count > 0
      arr = generate_quarterly_array params[:from], params[:to]

      con_type.each do |con|
        k = k + 1
        conflict_case.each do |c|
            for q in 1..arr.count
              quarter = arr[q-1][0].split("/")[0]
              if quarter == "Q1"
                if (1..3).member?(c.created_at.mon) && c.conflict_type == con.to_i
                  arr[q-1][k] = arr[q-1][k].nil? ? 1 : arr[q-1][k] + 1
                else
                  arr[q-1][k] = arr[q-1][k].nil? ? 0 : arr[q-1][k]
                end
              elsif quarter == "Q2"
                if (4..6).member?(c.created_at.mon) && c.conflict_type == con.to_i
                  arr[q-1][k] = arr[q-1][k].nil? ? 1 : arr[q-1][k] + 1
                else
                  arr[q-1][k] = arr[q-1][k].nil? ? 0 : arr[q-1][k]
                end
              elsif quarter == "Q3"
                if (7..9).member?(c.created_at.mon) && c.conflict_type == con.to_i
                  arr[q-1][k] = arr[q-1][k].nil? ? 1 : arr[q-1][k] + 1
                else
                  arr[q-1][k] = arr[q-1][k].nil? ? 0 : arr[q-1][k]
                end
              elsif quarter == "Q4"
                if (10..12).member?(c.created_at.mon) && c.conflict_type == con.to_i
                  arr[q-1][k] = arr[q-1][k].nil? ? 1 : arr[q-1][k] + 1
                else
                  arr[q-1][k] = arr[q-1][k].nil? ? 0 : arr[q-1][k]
                end
              end

            end
        end
      end
    else
      arr = [['', 0]]
    end
    return arr
  end

  def self.generate_quarterly_array from, to
    arr = []
    from = from.blank? ? "#{Time.now.mon}/01/#{Time.now.year}" : from
    to = to.blank? ? "#{Time.now.mon}/31/#{Time.now.year}" : to
    from = parse_date_format from
    to = parse_date_format to
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
    to = to.blank? ? "#{Time.now.mon}/31/#{Time.now.year}" : to
    from = parse_date_format from
    to = parse_date_format to
    for i in from..to
      arr << ["#{i.mon}/#{i.year}"] unless arr.include?(["#{i.mon}/#{i.year}"])
    end
    return arr
  end

  def self.generate_daily_array from, to
    arr = []
    from = from.blank? ? "#{Time.now.mon}/01/#{Time.now.year}" : from
    to = to.blank? ? "#{Time.now.mon}/31/#{Time.now.year}" : to
    from = parse_date_format from
    to = parse_date_format to
    for i in from..to
      arr << [reverse_date_format(i)]
    end
    return arr
  end

  def self.parse_date_format date 
    array_date = date.split("/")
    return Date.new(array_date[2].to_i, array_date[0].to_i, array_date[1].to_i)
  end

  def self.reverse_date_format date
    return "#{date.mon}/#{date.mday}/#{date.year}"
  end

  def self.assign_value conflict, key, value, field
    field.each do |f|
      if f["id"] == key.to_i
        case f["code"]
          when "con_state"
            conflict.conflict_state = value
          when "con_type"
            conflict.conflict_type = value
          when "con_intensity"
            conflict.conflict_intensity = value
        end
      end
    end
    conflict
  end
end
