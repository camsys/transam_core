module Delayed
  module Plugins
    class SetPriorityPlugin < Plugin
      callbacks do |lifecycle|
        lifecycle.before(:enqueue) do |job, *args, &block|
          if (DelayedJobPriority rescue false)
            # setting priority based on configuration...
            job_class_name = YAML.load(job.handler).try(:class).try(:name)
            if job_class_name.present?
              priority = DelayedJobPriority.find_by_class_name(job_class_name).try(:priority)
              if priority.present? && priority != job.priority
                job.priority = priority
              end
            end
          end
        end
      end
    end
  end
end

Delayed::Worker.plugins << Delayed::Plugins::SetPriorityPlugin