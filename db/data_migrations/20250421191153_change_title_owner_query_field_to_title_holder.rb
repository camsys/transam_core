# frozen_string_literal: true

class ChangeTitleOwnerQueryFieldToTitleHolder < ActiveRecord::DataMigration
  def up
    title_owner_query_field = QueryField.find_by(label: "Title Owner")
    title_owner_other_query_field = QueryField.find_by(label: "Title Owner (Other)")

    if title_owner_query_field
      title_owner_query_field.update(label: "Title Holder")
    end
    if title_owner_other_query_field
      title_owner_other_query_field.update(label: "Title Holder (Other)")
    end
  end
end