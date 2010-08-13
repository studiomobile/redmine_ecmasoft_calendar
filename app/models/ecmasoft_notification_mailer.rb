require 'ostruct'

class EcmasoftNotificationMailer < Mailer

  def self.calculate_developers_worktime
    ecmasoft_group = Group.find_by_lastname EcmasoftConsts::ECMASOFT_GROUP
    users = ecmasoft_group.present? ? ecmasoft_group.users : []

    worktimes = []
    users.each do |user|
      week_worktime, expected_week_worktime = get_user_worktime_for_current_week(user)
      month_worktime, expected_month_worktime = get_user_worktime_for_current_month(user)

      worktimes << OpenStruct.new(
              :user_id => user.id,
              :name => user.name,
              :week_worktime => week_worktime,
              :expected_week_worktime => expected_week_worktime,
              :month_worktime => month_worktime,
              :expected_month_worktime => expected_month_worktime )
    end
    worktimes
  end

  def self.get_user_worktime_for_current_week(user)
    from = Date.today.beginning_of_week
    to = Date.today

    self.calculate_user_worktime(user, from, to)
  end

  def self.get_user_worktime_for_current_month(user)
    from = Date.today.beginning_of_month
    to = Date.today

    self.calculate_user_worktime(user, from, to)
  end

  def self.calculate_user_worktime(user, from, to)
    current_hrs = TimeEntry.sum("hours", :conditions => ["user_id = ? AND spent_on BETWEEN ? AND ?", user.id, from, to]).round
    expected_hrs = 8 * CalendarStatusItem.workdays_count(from, to, user.id)

    [current_hrs, expected_hrs]
  end

  def self.get_managers_and_related_stuff
    ecmasoft_group = Group.find_by_lastname EcmasoftConsts::ECMASOFT_GROUP
    ecmasoft_user_ids = ecmasoft_group.present? ? ecmasoft_group.users.map(&:id) : []

    managers = {}
    manager_role = Role.find_by_name("Manager")
    manager_members = manager_role.members.all(:include => [:user, :project]).select {|m| m.user.active? }
    manager_members.each {|member| managers[member.user] = [] }

    manager_members.each do |member|
      manager = member.user

      member.project.members.each do |project_member|
        user = project_member.user

        if ecmasoft_user_ids.include?(user.id) && user != manager && user.active?
          managers[manager] << user unless managers[manager].include?(user)
        end
      end
    end

    managers
  end

  def self.prepare_and_send_notification
    managers = get_managers_and_related_stuff
    worktimes = calculate_developers_worktime

    managers.each do |manager, subordinates|
      subordinate_ids = subordinates.map(&:id)

      if [52].include?(manager.id)
        deliver_notification(manager, worktimes.select {|w| subordinate_ids.include?(w.user_id) } )
      end
    end
  end

  def notification(manager, subordinates)
    from "blog4m@yandex.ru" #"no-reply@ecmasoft.com"
    recipients manager.mail
    subject "Timesheet notification"
    body :subordinates => subordinates
    content_type "text/html"
  end

end