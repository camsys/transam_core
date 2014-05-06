class ServiceLifeConsumedReport < AbstractReport

  BUCKET_SIZE = 10
  MAX_PCNT = 200
  
  def initialize(attributes = {})
    super(attributes)
  end    
  
  def get_data(organization, params)

    # Check to see if we got an asset type to sub select on
    if params[:report_filter_type] 
      report_filter_type = params[:report_filter_type].to_i
    else
      report_filter_type = 0
    end
    
    a = []

    # Set up the labels one for each asset class
    labels = ['% Service Life Used']
    asset_cols = []
    if report_filter_type > 0
      asset_type = AssetType.find_by_id(report_filter_type)
      labels << asset_type.name
    else
      AssetType.all.each do |type| 
        asset_count = organization.assets.where("asset_type_id = ?", type.id).count
        asset_cols << -1
        if asset_count > 0
          labels << type.name
          asset_cols[asset_cols.size - 1] = asset_cols.size - 1
        end
      end
    end
    num_asset_types = labels.size - 1
                
    # Set up the buckets using BUCKET_SIZE buckets.The array is now an array of length num_buckets where each element
    # is an array of ints with value 0 and length num_asset_types
    num_buckets = MAX_PCNT / BUCKET_SIZE
    (0..num_buckets).each do |bucket|
      counts = []
      counts << "#{bucket * BUCKET_SIZE}%"
      (1..num_asset_types).each do |x|
        counts << 0
      end
      a << counts
    end

    # Process the assets and increament the bucket counters based on the %age useful life consumed for
    # each asset
    if report_filter_type > 0
      assets = organization.assets.where("asset_type_id = ?", report_filter_type)
    else
      assets = organization.assets
    end
    # get the current policy so we can deduce useful life
    policy = organization.get_policy
    # count the number of assets so we can normalize ther report
    num_assets = 0
    assets.each do |asset|
      # Only on age right now
      useful_life = policy.get_policy_item(asset)
      pcnt_consumed = (asset.age / useful_life.max_service_life_years.to_f) * 100.0
      # Get the column for this asset type, if we only have one it is the first column
      col = report_filter_type > 0 ? 1 : asset_cols[asset.asset_type_id]
      row = [(pcnt_consumed / BUCKET_SIZE).to_i - 1, num_buckets].min
      a[row][col] += 1
      num_assets += 1
    end

    # normalize the table
    (0..num_buckets).each do |row|
      (1..num_asset_types).each do |col|
        a[row][col] = a[row][col] / num_assets.to_f * 100
      end
    end
    
    return {:labels => labels, :data => a}

  end
  
end
