class ChangeAllowedEmailDomainsText < ActiveRecord::Migration[5.2]
  def change
    if Organization.column_names.include? 'allowed_email_domains'
      change_column :organizations, :allowed_email_domains, :text, limit: 255
    end
  end
end
