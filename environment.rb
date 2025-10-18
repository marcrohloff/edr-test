LIB_ROOT = './lib'
$LOAD_PATH << LIB_ROOT

require 'bundler/setup'
Bundler.require

# gem requires
require 'active_model'
require 'active_support'

module Kernel
  # A poor man's Zeitwerk
  def require_tree(path)
    files = Dir[File.join(LIB_ROOT, path, '**', '*.rb')]

    files.each do |filename|
      require filename
    end
  end
end

require_tree 'config'
require     'command/base' # This need to be loaded first
require_tree 'command'
require     'data_source/base' # This need to be loaded first
require_tree 'data_source'
require_tree 'activity_log'
require_tree 'runner'
require      'multiplexer'
require      'command_line_parser'

