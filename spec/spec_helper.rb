require './environment'
require_all '../spec/support'

RSpec.configure do |config|
  config.include SpecHelperMethods
end
