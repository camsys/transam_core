ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.irregular 'foot', 'feet'
  inflect.irregular 'chassis', 'chasses' # English not-withstanding
  inflect.irregular 'autonomous', 'autonomous' # not a noun
end