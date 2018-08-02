class AddOtherManufacturerModel < ActiveRecord::DataMigration
  def up
    manufacturer_models = [
      {name: 'Other', description: 'Other', active: true}
    ]

    manufacturer_models.each do |model|
      ManufacturerModel.create!(model)
    end
  end
end