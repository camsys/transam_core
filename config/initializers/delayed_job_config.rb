Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.sleep_delay = 30
Delayed::Worker.max_attempts = 1
Delayed::Worker.max_run_time = 1.hour
Delayed::Worker.read_ahead = 2
Delayed::Worker.delay_jobs = !Rails.env.test?