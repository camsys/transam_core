class AddViewToGetUserRole < ActiveRecord::Migration[5.2]
  def change
    
    #Yes, this is a view, within a view, within a view.
    #TODO: this only works if the table is relatively small. Dozens (maybe hundreds) of users.

    # Create a view that matches each user with their roles
    # user_id, role_weight, role_label
    all_user_roles_view = <<-SQL
      CREATE OR REPLACE VIEW all_user_roles AS
        SELECT
          ur.user_id AS user_id,
          r.weight AS role_weight,
          r.label AS role_label
        FROM users_roles AS ur
        LEFT JOIN roles AS r ON r.id = ur.role_id
        LEFT JOIN users AS u  ON u.id = ur.user_id;
    SQL
    ActiveRecord::Base.connection.execute all_user_roles_view

    # Create a view that looks like
    # user_id, max_role_weight
    highest_weight_user_roles_view = <<-SQL
      CREATE OR REPLACE VIEW max_user_roles AS
        SELECT user_id,max(role_weight) max_weight
        FROM all_user_roles
        GROUP BY user_id;
      SQL
    ActiveRecord::Base.connection.execute highest_weight_user_roles_view


    # Create a view matching each user with their highest weighted role
    # create a view that looks like
    # user_id, role_label
    highest_weight_user_roles_view_with_labels = <<-SQL
      CREATE OR REPLACE VIEW max_user_roles_and_labels AS
        SELECT 
          all_user_roles.role_label,
          all_user_roles.user_id,
          all_user_roles.role_weight
        FROM all_user_roles
        INNER JOIN max_user_roles as mur 
        ON all_user_roles.user_id = mur.user_id
        AND all_user_roles.role_weight = mur.max_weight;
    SQL
    ActiveRecord::Base.connection.execute highest_weight_user_roles_view_with_labels

  end
end
