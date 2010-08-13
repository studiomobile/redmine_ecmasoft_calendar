namespace :ecmasoft_calendar do

  desc 'Task to send notification about changes in calendar.'
  task :notification => :environment do
    EcmasoftNotificationMailer.prepare_and_send_notification
  end
  
end