LIB_ROOT = './lib'
$LOAD_PATH << LIB_ROOT

require 'bundler/setup'
Bundler.require

# GEM requires
require 'active_model'
require 'active_support'

module Kernel
  # A poor man's Zeitwerk
  def require_all(path)
    files = Dir[File.join(LIB_ROOT, path, '**', '*.rb')]

    files.each do |filename|
      require filename
    end
  end
end

require     'command/base' # This need to be loaded first
require_all 'command'
require_all 'activity_log'
require_all 'runner'
