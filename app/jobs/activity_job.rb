#------------------------------------------------------------------------------
#
# ActivityJob
#
# Special type of job that is run from the acticity scheduler. These jobs
# reference the activity context and can load parameters from the activity
# table
#
#------------------------------------------------------------------------------
class ActivityJob < Job

  attr_reader :context
  attr_reader :start_time

  def initialize(args = {})
    super(args)
    args.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end

  # Make sure that the due date/time expression can be parsed
  def check
    super
    # Save the start time for the job
    @start_time = Time.now
    raise ArgumentError, "Missing execution context" if @context.blank?
    true
  end

  # Perform post-processing
  def clean_up
    super
    # Update the last run time and save
    @context.last_run = @start_time
    @context.save(:validate => false)
  end

  def prepare
    super
  end

  protected

  # Write to activity log
  def write_to_activity_log org, message
    ActivityLog.create({
      :item_type => self.class.name,
      :organization => org,
      :activity => message,
      :activity_time => Time.now
      })
  end

  # Get the system user
  def get_system_user
    User.where('first_name = ? AND last_name = ?', 'system', 'user').first
  end

end
