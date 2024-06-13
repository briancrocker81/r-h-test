# cronotab.rb — Crono configuration file
#
# Here you can specify periodic jobs and schedule.
# You can use ActiveJob's jobs from `app/jobs/`
# You can use any class. The only requirement is that
# class should have a method `perform` without arguments.

require 'rake'

Rails.app_class.load_tasks

class Sendmail
  def perform
    Rake::Task['crono:send_mail'].invoke
  end
end

Crono.perform(Sendmail).every 1.day, at: {hour: 8, min: 00}