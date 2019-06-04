class AddPasswordChangedAtIfDoesntExist < ActiveRecord::Migration[5.2]
  def change
    unless column_exists? :users, :password_changed_at
      add_column    :users, :password_changed_at, :datetime, :after => :locked_at
    end
  end
end
