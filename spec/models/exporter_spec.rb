require 'spec_helper'

describe Exporter do 
  before(:each) do

    conflict1 = ConflictCase.new(
        :conflict_type_description => "Violence",
        :conflict_state_description => 'Middel',
        :conflict_intensity_description => 'Low',
        :created_at => Time.now,
        :location => Location.new( :name => 'Phone Penh', :code => '855', :lat => 11.550874, :lng => 104.916992 ),
        :reporter => Reporter.new( :first_name => 'Mr Ilab',  :phone_number => '8550202020')
    )

    conflict2 = ConflictCase.new(
        :conflict_type_description => "Abuse",
        :conflict_state_description => 'Begining',
        :conflict_intensity_description => 'Medium',
        :created_at => Time.now,
        :location => Location.new( :name => 'Cambodia', :code => '090', :lat => 11.580874, :lng => 104.916900 ),
        :reporter => Reporter.new( :first_name => 'Mr SEA', :phone_number => '8550202030')
    )

    conflict3 = ConflictCase.new(
        :conflict_type_description => "Dispute",
        :conflict_state_description => 'Finished',
        :conflict_intensity_description => 'High',
        :created_at => Time.now,
        :location => Location.new( :name => 'Kampong Cham', :code => '200', :lat => 11.600874, :lng => 104.91700),
        :reporter => Reporter.new( :first_name => 'Mr Ponhea krek', :phone_number => '8550202040')
    )
    
    allow(conflict1).to receive(:created_at).and_return(Time.now)
    allow(conflict2).to receive(:created_at).and_return(Time.now + 1.day)
    allow(conflict3).to receive(:created_at).and_return(Time.now + 2.days)

    @conflicts = [conflict1, conflict2, conflict3]

  	@exporter = Exporter.new(@conflicts)
  end

  describe '#as_shp_file' do
  	it "should create a shp file" do

  	  shp_file_name = File.expand_path('data/export.shp', File.dirname(__FILE__)	)
  	  shx_file_name = File.expand_path('data/export.shx', File.dirname(__FILE__)	)
  	  dbf_file_name = File.expand_path('data/export.dbf', File.dirname(__FILE__)	)

  	  @exporter.to_shp_file shp_file_name

  	  File.exist?(shp_file_name).should be_true
  	  File.exist?(shx_file_name).should be_true
  	  File.exist?(dbf_file_name).should be_true

      File.delete shp_file_name  if File.exist?(shp_file_name)
      File.delete shx_file_name  if File.exist?(shx_file_name)
      File.delete dbf_file_name  if File.exist?(dbf_file_name)

  	end
  end

  it "should return list of shp distributed file names with #shp_distributed_files" do
    file = "/x/y/export.shp.shp"
    files = @exporter.shp_distributed_files file
    files.should =~ ["/x/y/export.shp.shp", "/x/y/export.shp.shx", "/x/y/export.shp.dbf", "/x/y/export.shp.prj"]
  end

  describe '#create_zip' do
    it "should create zip file" do
      zip_file = File.expand_path("data/zip/case_shp.zip", File.dirname(__FILE__))
      
      file1 = File.expand_path("data/zip/protected/file1.shp", File.dirname(__FILE__))
      file2 = File.expand_path("data/zip/protected/file1.shx", File.dirname(__FILE__))
      file3 = File.expand_path("data/zip/protected/file1.dbf", File.dirname(__FILE__))

      files_to_zip = [ file1, file2, file3 ]
      @exporter.create_zip zip_file, files_to_zip
      File.exist?(zip_file).should be_true

      File.delete zip_file if File.exist? zip_file
    end

    it "should raise exception" do
      zip_file = File.expand_path("data/zip/case_shp.zip", File.dirname(__FILE__))
      

      file1 = File.expand_path("data/zip/non-xx.shp", File.dirname(__FILE__))
      file2 = File.expand_path("data/zip/non-xy.shx", File.dirname(__FILE__))
      file3 = File.expand_path("data/zip/nox-xu.dbf", File.dirname(__FILE__))

      files_to_zip = [ file1, file2, file3 ]
      expect{@exporter.create_zip(zip_file, files_to_zip)}.to raise_error(RuntimeError, /does not exist/) 
      File.exist?(zip_file).should be_false

      File.delete zip_file if File.exist? zip_file
    end
  end

  describe '#to_sh_zip' do
    it "should create zip file" do
      zip_file = File.expand_path('data/zip/to_zip_file.zip', File.dirname(__FILE__))
      @exporter.to_sh_zip(zip_file)
      
      File.exist?(zip_file).should be_true
      File.delete(zip_file) if File.exist? zip_file
    end
  end

  describe '#as_kml_file' do
    it "should create kml file" do
      kml_file = File.expand_path('../data/export.kml', __FILE__)
      
      @exporter.to_kml_file kml_file
      File.exist?(kml_file).should be_true
      File.delete kml_file if File.exist?(kml_file)

    end
  end

end