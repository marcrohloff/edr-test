module Command
  class Base
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Validations

    include Command::Errors
  end


  def self.command_classes
    # Note: I intended to keep this flexible by calling `subclasses`
    #       (with some potential filtering required)
    #       However the responses are ordered in reverse alphabetical order
    #       And I wanted to stick to the order given in the document
    #       So this is just hard-coded for now

    [
      StartProcess,
      CreateFile,
      ModifyFile,
      DeleteFile,
      NetworkConnection,
      Wait
    ]

  end

end
