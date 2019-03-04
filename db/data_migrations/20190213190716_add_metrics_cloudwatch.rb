class AddMetricsCloudwatch < ActiveRecord::DataMigration
  def up

    # this sends a metric (of 0 so no errors) to Cloudwatch for the prod environment so we can set up alarms

    @pmd_service = PutMetricDataService.new
    @pmd_service.instance_variable_set(:@namespace, "#{Rails.application.class.parent}:production")

    @pmd_service.put_metric('ClockworkErrorResponse', 'Count', 0)
    @pmd_service.put_metric('DelayedJobErrorResponse', 'Count', 0)
  end
end