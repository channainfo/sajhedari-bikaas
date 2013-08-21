require 'spec_helper'

describe Exporter do 
  before(:each) do
  	@data = [
  	   [ 'Identity-based Violence', 'High', 'At the conflict'    , '9.177,104.0844', 'Ilab Channa-Ly', '855975553553' , '2013-08-16 08:39:41 UTC'], 	
	     [ 'Gender Based Violence'  , 'Low' , 'Before the conflict', '8.277,104.1844', 'Ilab Kakada'   , '855975553554' , '2013-08-16 08:41:07 UTC' ] ,	
	     [ 'X Based Violence'       , 'Low' , 'Before the conflict', '7.377,104.2844', 'Ilab Mann'     , '855975553555' , '2013-08-16 08:41:07 UTC' 	] ,
	     [ 'Y Based Violence'       , 'Low' , 'Before the conflict', '11.477,104.3844', 'Ilab Mesa'    , '855975553556' , '2013-08-16 08:41:07 UTC' 	]
  	]
  	@exporter = Exporter.new(@data)
  end

  describe '#as_shp_file' do
  	it "should create a shp file" do

  	  shp_file_name = File.expand_path('data/export.shp', File.dirname(__FILE__)	)
  	  shx_file_name = File.expand_path('data/export.shx', File.dirname(__FILE__)	)
  	  dbf_file_name = File.expand_path('data/export.dbf', File.dirname(__FILE__)	)

  	  File.delete shp_file_name	 if File.exist?(shp_file_name)
  	  File.delete shx_file_name	 if File.exist?(shx_file_name)
  	  File.delete dbf_file_name	 if File.exist?(dbf_file_name)

  	  @exporter.to_shp_file shp_file_name

  	  File.exist?(shp_file_name).should be_true
  	  File.exist?(shx_file_name).should be_true
  	  File.exist?(dbf_file_name).should be_true

  	end
  end

  it "should return list of shp distributed file names with #shp_distributed_files" do
    file = "/x/y/export.shp.shp"
    files = @exporter.shp_distributed_files file
    files.should =~ ["/x/y/export.shp.shp", "/x/y/export.shp.shx", "/x/y/export.shp.dbf"]
  end

  describe '#create_zip' do
    it "should create zip file" do
      zip_file = File.expand_path("data/zip/case_shp.zip", File.dirname(__FILE__))
      File.delete zip_file if File.exist? zip_file

      file1 = File.expand_path("data/zip/protected/file1.shp", File.dirname(__FILE__))
      file2 = File.expand_path("data/zip/protected/file1.shx", File.dirname(__FILE__))
      file3 = File.expand_path("data/zip/protected/file1.dbf", File.dirname(__FILE__))

      files_to_zip = [ file1, file2, file3 ]
      @exporter.create_zip zip_file, files_to_zip
      File.exist?(zip_file).should be_true
    end

    it "should raise exception" do
      zip_file = File.expand_path("data/zip/case_shp.zip", File.dirname(__FILE__))
      File.delete zip_file if File.exist? zip_file

      file1 = File.expand_path("data/zip/non-xx.shp", File.dirname(__FILE__))
      file2 = File.expand_path("data/zip/non-xy.shx", File.dirname(__FILE__))
      file3 = File.expand_path("data/zip/nox-xu.dbf", File.dirname(__FILE__))

      files_to_zip = [ file1, file2, file3 ]
      expect{@exporter.create_zip(zip_file, files_to_zip)}.to raise_error(RuntimeError, /does not exist/) 
      File.exist?(zip_file).should be_false
    end
  end

  describe '#to_sh_zip' do
    it "should create zip file" do
      zip_file = File.expand_path('data/zip/to_zip_file.zip', File.dirname(__FILE__))
      File.delete(zip_file) if File.exist? zip_file
      @exporter.to_sh_zip zip_file
    end
  end

  describe '#as_kml_file' do
    it "should create kml file" do
      kml_file = File.expand_path('../data/export.kml', __FILE__)
      File.delete kml_file if File.exist?(kml_file)
      @exporter.to_kml_file kml_file
      File.exist?(kml_file).should be_true
    end
  end

end