class PutMetricDataService

  def initialize
    @cw = Aws::CloudWatch::Client.new
    @env = ENV['RAILS_ENV']
    @namespace = "#{Rails.application.class.parent}:#{@env}"
  end

  def put_metric(name, unit, value, dimensions=[])
    put_metrics_prepared([{metric_name: name, unit: unit, value: value, dimensions: dimensions}.select { |k, v| v!=[] }]) if @cw && @env != 'test'
  end

  def put_metrics_prepared metrics
    metrics.each_slice(20).each do |slice|
     
      ## Log to CloudWatch
      begin
        Timeout::timeout(5) do #If this takes more than 5 seconds, just move on.
          log "Sent #{slice.size} prepared metrics to CW for namespace #{@namespace} #{slice.collect{|s| s['MetricName']}.sort.uniq.join(',')}"
          debug slice.inspect
          @cw.put_metric_data(namespace: @namespace, metric_data: slice)
        end
      rescue Exception => e
        log "Exception: #{e}"
        log_exception_to_cw
      end
    
    end
  end

  def log_exception_to_cw
    @cw.put_metric_data(namespace: @namespace, metric_data: [{metric_name: 'MonitoringException', unit: 'None', value: 1}]) if @env != 'test'
  end

  def log text
    puts format_log_message(text)
  end

  def debug text
    puts(format_log_message(text)) if ENV['DEBUG']
  end

  def format_log_message(text)
    "#{Time.now.iso8601} (#{Process.pid}) #{text}"
  end

end
