require 'geo_ruby'
require 'geo_ruby/shp'
require 'geo_ruby/shp4r/shp'
require 'geo_ruby/shp4r/dbf'
require 'dbf'

require 'nokogiri'
require 'zip/zip'

class Exporter

  COL_TYPE        = 'Type'
  COL_INTENSITY   = 'Intensity'
  COL_STATE       = 'State'
  COL_LOCATION    = 'Location'
  COL_REPORTER    = 'Reporter'
  COL_PHONE       = 'Phone'
  COL_DATE_SEND   = 'DateSent'	

  def initialize data
  	@data_sources = data
  end	

  def to_shp_file sh_file_name
  	fields = []
  	headers = [
		    [COL_TYPE,      "C", 20 ],	
		    [COL_INTENSITY ,"C", 10 ],
		    [COL_STATE,     "C", 20 ],	
		    [COL_LOCATION,  "C", 50 ],
		    [COL_REPORTER,  "C", 30 ],	
		    [COL_PHONE,     "C", 20 ],	
		    [COL_DATE_SEND, "C", 50 ]
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
  		  point = GeoRuby::SimpleFeatures::Point.from_x_y(row.location.lng, row.location.lat)
  		  tr.add(GeoRuby::Shp4r::ShpRecord.new(point, data))
  	  end

    end
    shpfile.close
    shp_prj_create sh_file_name
  end

  def to_sh_zip zip_file

    sh_file = "#{Rails.root}/tmp/sb.shp" 
    to_shp_file sh_file
    files_list  = shp_distributed_files sh_file

    create_zip(zip_file, files_list)

    # clean up the files after zipping
    files_list.each do |file|
      File.delete file
    end
  end

  def shp_prj_create shp_file
    file     = File.basename(shp_file, '.shp')
    dirname  = File.dirname(shp_file) 
    prj_file = File.expand_path( file + ".prj", dirname)

    epsg_4326_file = "#{Rails.root}/public/data/protected/EPSG-4326.prj" 
    epsg_4326_content = File.open(epsg_4326_file){|f| f.read}
    File.open(prj_file,'w'){|f| f.write(epsg_4326_content)}
    prj_file
  end

  def shp_distributed_files shp_file
     file     = File.basename(shp_file, '.shp')
     dirname  = File.dirname(shp_file) 

     shx_file = File.expand_path( file + ".shx", dirname)
     dbf_file = File.expand_path( file + ".dbf", dirname)
     prj_file = File.expand_path( file + ".prj", dirname)

     [shp_file, shx_file, dbf_file, prj_file ]
  end

  def create_zip(zip_file_name, files_list)

    files_list.each do |file|
      raise 'File: ' + file + " does not exist " unless File.exist? file
    end

    File.delete zip_file_name if File.exist? zip_file_name

    Zip::ZipFile.open(zip_file_name, Zip::ZipFile::CREATE) do |zip|
      files_list.each do |original_file|
        in_zip = File.basename(original_file)
        zip.add(in_zip, original_file)
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
                  xml.name row.location.description
                  # xml.Snippet(:maxLines => 0)
                  # ßßßxml.description description_kml(row)
                  xml.styleUrl "#defaultstyle"
                  xml.LookAt {
                    xml.longitude row.location.lng
                    xml.latitude  row.location.lat
                    xml.altitude  0
                    xml.range 32185
                    xml.tilt 0
                    xml.heading 0
                  }

                  xml.ExtendedData {
                    xml.Data(:name => COL_TYPE) {
                      xml.value row.conflict_type_description
                    }

                    xml.Data(:name => COL_INTENSITY) {
                      xml.value row.conflict_intensity_description
                    }

                    xml.Data(:name => COL_STATE) {
                      xml.value row.conflict_state_description
                    }

                    xml.Data(:name => COL_LOCATION) {
                      xml.value row.location.lnglat
                    }

                    xml.Data(:name => COL_REPORTER) {
                      xml.value row.reporter.full_name
                    }

                    xml.Data(:name => COL_PHONE) {
                      xml.value row.reporter.phone_number
                    }

                    xml.Data(:name => COL_DATE_SEND) {
                      xml.value row.created_at
                    }
                  }

                  xml.Point {
                    xml.coordinates "#{row.location.lnglat},0"
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

  def convert_to_shp_data row
  	{
  		COL_TYPE      => row.conflict_type_description,
  		COL_INTENSITY => row.conflict_intensity_description,
  		COL_STATE     => row.conflict_state_description,
  		COL_LOCATION  => row.location.lnglat,
  		COL_REPORTER  => row.reporter.full_name,
  		COL_PHONE     => row.reporter.phone_number,
  		COL_DATE_SEND => row.created_at
  	}
  end



end