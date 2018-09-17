class CreateTransamAssets < ActiveRecord::Migration[5.2]
  def change
    create_table :transam_assets do |t|
      t.references  :transam_assetible, polymorphic: true, index: {name: :transam_assetible_idx}
      t.string      :object_key, limit: 12, null: false
      t.references  :organization, index: true, null: false
      t.references  :asset_subtype, index: true
      t.string      :asset_tag, null: false
      t.date        :disposition_date
      t.string      :external_id
      t.text        :description
      t.references  :manufacturer
      t.string      :other_manufacturer
      t.references  :manufacturer_model
      t.string      :other_manufacturer_model
      t.integer     :manufacture_year
      t.integer     :quantity
      t.string      :quantity_unit
      t.integer     :purchase_cost
      t.date        :purchase_date
      t.boolean     :purchased_new
      t.date        :in_service_date
      t.references  :vendor
      t.string      :other_vendor
      t.references  :operator
      t.string      :other_operator
      t.string      :title_number
      t.references  :title_ownership_organization
      t.string      :other_title_ownership_organization
      t.references  :lienholder
      t.string      :other_lienholder

      t.timestamps
    end
  end
end
