namespace :transam_core do
  desc "Email Successful Server Update Alert"
  task server_updated: :environment do
    puts 'Updated'
    UserMailer.updated.deliver!
  end
end