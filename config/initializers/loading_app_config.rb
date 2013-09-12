ResourceMapConfig = YAML.load_file File.expand_path(Rails.root + "config/resourcemap.yml", __FILE__)
NuntiumConfig = YAML.load_file File.expand_path(Rails.root + "config/nuntium.yml", __FILE__)
PageSize = 15