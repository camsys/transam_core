class UpdateEquipmentManufacturers < ActiveRecord::DataMigration
  def up

    other_manufacturer = Manufacturer.find_or_create_by(filter: 'Equipment', name: 'Other (Describe)', code: 'ZZZ', active: true)

    Equipment.where('manufacturer_id IS NOT NULL').each do |asset|

      if(!asset.manufacturer.nil?)
        unless asset.manufacturer.name.include? 'Other'
          asset.other_manufacturer = asset.manufacturer.try(:name)
        end
        asset.manufacturer = other_manufacturer
      else
        asset.manufacturer = other_manufacturer
        asset.other_manufacturer = 'UNKNOWN'
      end


      asset.save!
    end

    Manufacturer.where(filter: 'Equipment').where.not(id: other_manufacturer.id).delete_all

  end
end