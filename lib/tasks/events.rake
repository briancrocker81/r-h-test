## Send event mailer before 24 hours
## rails events:notify
namespace :events do
  desc 'Send confirmation mail'
  task notify: :environment do
    Event.where(mail_sent: false).each { |event| event.send_event_email }
  end

  # lib/tasks/delete_old_records.rake

  desc 'Delete records older than 40 days'
  task :delete_old_events => :environment do
    Event.where('"end" < ?', 40.days.ago).each do |event|
      event.destroy
    end
  end

end
