class PutMetricDataService

  def initialize
    @cw = Fog::AWS::CloudWatch.new({:aws_secret_access_key => ENV['AWS_SECRET_KEY'],
                                    :aws_access_key_id => ENV['AWS_ACCESS_KEY']
                                   }) unless ENV['AWS_SECRET_KEY'].blank? && ENV['AWS_ACCESS_KEY'].blank?
    @env = ENV['RAILS_ENV']
    @namespace = "#{Rails.application.class.parent}:#{@env}"

  end

  def put_metric(name, unit, value, dimensions=[])
    #puts [{'MetricName' => name, 'Unit' => unit, 'Value' => value, 'Dimensions' => dimensions}.select { |k, v| v!=[] }]
    put_metrics_prepared([{'MetricName' => name, 'Unit' => unit, 'Value' => value, 'Dimensions' => dimensions}.select { |k, v| v!=[] }]) if @cw && @env != 'development'
  end

  def put_metrics_prepared metrics
    metrics.each_slice(20).each do |slice|
      while true
        begin
          log "Sent #{slice.size} prepared metrics to CW for namespace #{@namespace} #{slice.collect{|s| s['MetricName']}.sort.uniq.join(',')}"
          debug slice.inspect
          @cw.put_metric_data(@namespace, slice)
          break
        rescue Exception => e
#          if e.response.body =~ %r{<Message>Rate exceeded</Message>}
#            sleep 1
#          else
          log "Exception: #{e}"
          log_exception_to_cw
          raise e
#          end
        end
      end
    end
  end

  def log_exception_to_cw
    @cw.put_metric_data(@namespace, [{'MetricName' => 'MonitoringException', 'Unit' => 'None', 'Value' => 1}]) unless @env=='development'
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