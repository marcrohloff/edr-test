# Load everything in lib/command

# These need to be loaded first
require_relative 'command/base'

dir = File.dirname(__FILE__)
commands = Dir[File.join(dir, 'command', '**', '*.rb')]

commands.each do |filename|
  require filename
end
