class AddViewToGetUserRole < ActiveRecord::Migration[5.2]
  def change
    
    # Create a view that matches each user with their roles
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

    # Create a view matching each user with their highest weighted role
    highest_weight_user_roles_view = <<-SQL
      CREATE OR REPLACE VIEW max_user_roles AS
        SELECT 
          all_user_roles.role_label,
          all_user_roles.user_id,
          all_user_roles.role_weight
        FROM all_user_roles
        INNER JOIN
        (
          SELECT user_id,max(role_weight) max_weight
          FROM all_user_roles
          GROUP BY user_id ) u 
        ON all_user_roles.user_id = u.user_id
        AND all_user_roles.role_weight = u.max_weight;
    SQL
    ActiveRecord::Base.connection.execute highest_weight_user_roles_view

  end
end
