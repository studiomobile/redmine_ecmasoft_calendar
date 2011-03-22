class StudiomobileNotificationMailer < Mailer

  def self.prepare_and_send_notification
    calculator = WorktimeCalculator.new
    managers = calculator.managers_and_subordinates
    worktimes = calculator.calculate_developers_worktime

    managers.each do |manager, subordinates|
      subordinate_ids = subordinates.map(&:id)
      selected_worktimes = worktimes.select {|w| subordinate_ids.include?(w.user_id) }.sort_by(&:week_worktime)
      deliver_notification(manager, selected_worktimes)
    end
  end

  def notification(manager, subordinates)
    title = (subordinates.any?{|s| s.show_warning } ? "[NEED ATTENTION] " : "") + "Timesheet notification"

    from "no-reply@studiomobile.ru"
    recipients manager.mail
    subject title
    body :subordinates => subordinates
    content_type "text/html"
  end

end