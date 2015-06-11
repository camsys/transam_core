class ServiceLifeConsumedReport < AbstractReport

  BUCKET_SIZE = 10
  MAX_PCNT = 200

  def initialize(attributes = {})
    super(attributes)
  end

  def get_data(organization_id_list, params)

    # Check to see if we got an asset type to sub select on
    if params[:report_filter_type]
      report_filter_type = params[:report_filter_type].to_i
    else
      report_filter_type = 0
    end

    a = []

    # Set up the labels one for each asset class
    labels = ['% Service Life Used']
    # asset_cols is the index into the column array a[][x] for each asset type
    asset_cols = []
    if report_filter_type > 0
      asset_type = AssetType.find_by_id(report_filter_type)
      labels << asset_type.name
    else
      AssetType.all.each do |type|
        asset_count = Asset.where("assets.organization_id IN (?) AND assets.asset_type_id = ?", organization_id_list, type.id).count
        if asset_count > 0
          # push this asset type into the a matrix
          labels << type.name
          asset_cols << labels.size - 1 # account for the row label
        else
          asset_cols << -1
        end
      end
    end
    # this is the number of asset types with assets
    num_asset_types = labels.size - 1

    #puts asset_cols.inspect
    #puts labels.inspect

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

    puts "num buckets = #{num_buckets}"
    puts "a num rows = #{a.size}, a num cols = #{a[0].size}"

    # Process the assets and increament the bucket counters based on the %age useful life consumed for
    # each asset
    if report_filter_type > 0
      assets = Asset.where("assets.organization_id IN (?) AND asset_type_id = ?", organization_id_list, report_filter_type)
    else
      assets = Asset.where("assets.organization_id IN (?)", organization_id_list)
    end
    # count the number of assets so we can normalize the report
    num_assets = 0
    assets.each do |asset|
      # Only on age right now
      pcnt_consumed = (asset.age / asset.expected_useful_life * 12) * 100.0
      # Get the column for this asset type, if we only have one it is the first column
      col = report_filter_type > 0 ? 1 : asset_cols[asset.asset_type_id - 1]
      row = [(pcnt_consumed / BUCKET_SIZE).to_i - 1, num_buckets].min
      #puts "row = #{row}, col = #{col}"
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
