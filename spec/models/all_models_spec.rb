require 'rails_helper'

RSpec.describe do

  # checks that the default of boolean `active` of all models does not overwrite input
  # a user input of false would be overridden by `self.active ||= true`. test prevents such a code snippet
  # TODO: extend test to check defaults on all boolean fields

  Dir[TransamCore::Engine.root.join("app/models/*.rb")].map{|m| m.chomp('.rb').camelize.split("::").last}.each do |model|
    if ActiveRecord::Base.connection.table_exists? model.tableize # model is WIP so skip as db table does not exist
      if model.constantize.new.respond_to? :active
        it "inactive instance #{model} doesnt initialize as active" do
          expect(model.constantize.new(:active => false).active).to be false
        end
      else
        puts "Model #{model} does not have an `active` boolean field"
      end
    else
      puts "Table #{model.tableize} does not exist in DB"
    end
  end

end
