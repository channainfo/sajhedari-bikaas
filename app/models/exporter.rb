require 'geo_ruby'
require 'geo_ruby/shp'
require 'geo_ruby/shp4r/shp'
require 'geo_ruby/shp4r/dbf'
require 'dbf'

require 'nokogiri'
require 'open-uri'

require 'zip/zip'

class Exporter

  COL1   = 'Type'
  COL2   = 'Intensity'
  COL3   = 'State'
  COL4   = 'Location'
  COL5   = 'Reporter'
  COL6   = 'Phone'
  COL7   = 'DateSent'	

  def initialize data
  	@data_sources = data
  end	

  def to_shp_file sh_file_name
  	fields = []
  	headers = [
		    [COL1, "C", 20 ],	
		    [COL2 ,"C", 10 ],
		    [COL3, "C", 20 ],	
		    [COL4, "C", 50 ],
		    [COL5, "C", 30 ],	
		    [COL6, "C", 20 ],	
		    [COL7, "C", 50 ]
	]

	headers.each do |column|
	  field = GeoRuby::Shp4r::Dbf::Field.new(*column)
	  fields << field
	end

  	shpfile = GeoRuby::Shp4r::ShpFile.create(sh_file_name, GeoRuby::Shp4r::ShpType::POINT, fields )
  	shpfile = GeoRuby::Shp4r::ShpFile.open(sh_file_name)

  	shpfile.transaction do |tr|
  	  @data_sources.each do |row|
  		data = convert_to_shp_data(row)
  		latln = convert_to_shp_point(row)

  		point = GeoRuby::SimpleFeatures::Point.from_x_y(latln[0].to_f, latln[1].to_f)
  		tr.add(GeoRuby::Shp4r::ShpRecord.new(point, data))
  	  end
    end
    shpfile.close
  end

  def to_sh_zip zip_file
    file    = File.basename(zip_file, '.zip')
    sh_file = File.expand_path( file + '.shp' , File.dirname(zip_file) )
    to_shp_file sh_file
    files_list  = shp_distributed_files sh_file
    create_zip zip_file, files_list
  end

  def shp_distributed_files shp_file
     file     = File.basename(shp_file, '.shp')
     dirname  = File.dirname(shp_file) 

     shx_file = File.expand_path( file + ".shx", dirname)
     dbf_file = File.expand_path( file + ".dbf", dirname)

     [shp_file, shx_file, dbf_file ]
  end

  def create_zip zip_file_name, files_list
    files_list.each do |file|
      raise 'File: ' + file + " does not exist " unless File.exist? file
    end

    Zip::ZipFile.open(zip_file_name, Zip::ZipFile::CREATE) do |zip|
      files_list.each do |file|
        zip.add File.basename(file), file
      end
    end
  end

  def to_kml_file kml_file_name
    builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml.kml(:xmlns => "http://earth.google.com/kml/2.1"){
        xml.Document {
          xml.name 'Sajhedari Bikaas'
          xml.open "1"

          xml.Style(:id => "defaultstyle") do

            xml.IconStyle {
              xml.Icon {
                xml.href "http://maps.google.com/mapfiles/kml/pushpin/red-pushpin.png"
              }
              xml.scale '1.4'
            }

            xml.LabelStyle{
              xml.color 'a1ff00ff'
              xml.scale '1.4'
            }

          end


          # xml.Folder do
          #   xml.name 'Sajhedari Bikaas'
              @data_sources.each do |row|
                xml.Placemark {
                  xml.name "case"
                  # xml.Snippet(:maxLines => 0)
                  # ßßßxml.description description_kml(row)
                  xml.styleUrl "#defaultstyle"

                  latlng = convert_to_kml_point row

                  xml.LookAt {
                    xml.longitude latlng[1]
                    xml.latitude latlng[0]
                    xml.altitude 
                    xml.range 32185
                    xml.tilt 0
                    xml.heading 0
                  }

                  xml.ExtendedData {
                    xml.Data(:name => COL1) {
                      xml.value row[0]
                    }

                    xml.Data(:name => COL2) {
                      xml.value row[1]
                    }

                    xml.Data(:name => COL3) {
                      xml.value row[2]
                    }

                    xml.Data(:name => COL4) {
                      xml.value row[3]
                    }

                    xml.Data(:name => COL5) {
                      xml.value row[4]
                    }

                    xml.Data(:name => COL6) {
                      xml.value row[5]
                    }

                    xml.Data(:name => COL7) {
                      xml.value row[6]
                    }
                  }

                  xml.Point {
                    xml.coordinates "#{row[3]},0"
                  }
                }
              end
           # end  
        }
      }
    end
    builder.to_xml
    File.open( kml_file_name , 'w') { |file| file.write(builder.to_xml) }
  end

  def description_kml row
    str = <<-EOD
        <table>
          <tr>
            <td> #{COL1} </td>
            <td> </td>
          </tr>
        </table>
    EOD

    str
  end

  def convert_to_kml_point row
    convert_to_shp_point row
  end

  def convert_to_shp_point row
  	 row[3].split(",")
  end

  def convert_to_shp_data row
	{
		COL1 => row[0],
		COL2 => row[1],
		COL3 => row[2],
		COL4 => row[3],
		COL5 => row[4],
		COL6 => row[5],
		COL7 => row[6]
	}
  end



end