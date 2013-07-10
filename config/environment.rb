# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Conflict::Application.initialize!
Conflict::Application.config.resourcemapLink = "http://localhost:3000/"
