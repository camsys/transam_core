class AddSystemConfigFieldCustomizations < ActiveRecord::DataMigration
  def up
    ['organizations.short_name', 'organizations.name'].each do |field|
      table_name = field.split('.')[0]
      field_name = field.split('.')[1]

      SystemConfigFieldCustomization.create!(table_name: table_name, field_name: field_name, is_locked: true, active: true, code_frag: '!(current_user.has_role? :admin)')
    end

    SystemConfigFieldCustomization.create!(table_name: 'policy_asset_type_rules,', field_name: 'service_life_calculation_type_id', is_locked: true, active: true, code_frag: '@policy.parent?')
  end
end