
# Configure common acronym's used `#humanize`, etc

ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym 'ID'
  inflect.acronym 'IP'
  inflect.acronym 'PID'
end
