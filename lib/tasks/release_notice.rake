namespace :transam_core do
  desc "Create Notice of New Release"
  task release_notice: :environment do
    puts 'Checking for existing update notice'
    updated_version = Rails.application.config.version

    unless Notice.find_by(subject: "New release: #{updated_version}")
      update_notice = Notice.new
      update_notice.assign_attributes(
        subject: "New release: #{updated_version}",
        summary: "Release date: #{Date.today}, Release notes: https://camsys.github.io/transam_user_guide/user_guide/Release%20notes%20(#{updated_version})_All.pdf",
        details: nil,
        display_date: Date.today,
        display_hour: Time.now.hour,
        end_date: Date.today + 3.months + 1.day,
        end_hour: 23,
        notice_type: NoticeType.find_by(name: "Informational Notice")
      )
      if update_notice.save
        puts 'New release update notice created.'
      else
        puts 'Error creating new update notice.'
      end
    end
  end
end