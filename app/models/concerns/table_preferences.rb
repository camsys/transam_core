module TablePreferences

  DEFAULT_PREFERENCES = 
    {
      users: [:last_name, :organization_name]      
    }

  def table_preferences table_code=nil
    if table_code
      table_prefs[table_code] || DEFAULT_TABLE_PREFERENCES[table_code.to_sym]
    else
      table_prefs
    end
  end

end