require 'tempfile'

module SpecHelperMethods
  extend ActiveSupport::Concern

  def temp_file_name
    Dir::Tmpname.create('') { it }
  end

end
