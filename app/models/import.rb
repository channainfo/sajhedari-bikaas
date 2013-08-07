require 'csv'

class Import
  @csv_header = "" 
  @error_type = ""
  
  def self::validate_header?(file_path)
    CSV.foreach(file_path) do |row|
      if (!validate_metaData(row))
        @error_type = "File header is invalide"
        return false
      end
      return true
    end
    return false
  end
  
  def self::get_error_type
    return @error_type
  end  
 
  def self::validate_metaData(row)
    @csv_header = row
    return true if row[0] == "name" && row[1] == "code" && row[2] == "lat" && row[3] == "lng"
  	return false
  end

  def self::process_import file_path
    rows = 0
    rows_error = 0
    error_records = []
    CSV.foreach(file_path, :headers => true) do |row|
      @location = Location.new(:name => row[0], :code => row[1], :lat => row[2], :lng => row[3])
      if @location.save
        rows = rows + 1
      else
        errors = []
        @location.errors.messages.each do |key, value| 
          errors.push(key.to_s + " " + value[0])
        end
        row["error_messages"] = errors.join("<br />")
        p row
        error_records.push(row)
        rows_error = rows_error + 1
      end
    end
    return {:success => rows, :failed => rows_error, :error_records => error_records}
  end
  
end
