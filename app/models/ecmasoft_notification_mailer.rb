require 'ostruct'

class EcmasoftNotificationMailer < Mailer

  def self.ecmasoft_group
    @@ecmasoft_group ||= Group.find_by_lastname EcmasoftConsts::ECMASOFT_GROUP
  end

  def self.calculate_developers_worktime
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
              :expected_month_worktime => expected_month_worktime,
              :show_warning =>  week_worktime / expected_week_worktime < 0.7 || month_worktime / expected_month_worktime < 0.7
      )
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
    current_hrs = TimeEntry.sum("hours", :conditions => ["user_id = ? AND spent_on BETWEEN ? AND ?", user.id, from, to])
    expected_hrs = 8 * CalendarStatusItem.workdays_count(from, to, user.id)

    [current_hrs, expected_hrs]
  end

  def self.get_managers
    manager_role = Role.find_by_name("Manager")
    user_ids = manager_role.members.map(&:user_id).uniq

    User.all(:conditions => ["users.id IN (?) AND users.status = 1 AND groups_users_join.group_id = ?", user_ids, ecmasoft_group.id],
             :joins => [:groups])
  end

  def self.get_subordinates(manager)
    manager_projects = Project.all(:joins => :users, :conditions => ["users.id = ?", manager.id])
    projects_users_ids = Member.all(:select => "DISTINCT user_id", :conditions => ["project_id in (?) AND user_id != ?", manager_projects.map(&:id), manager.id])
    User.all(:conditions => ["users.id IN (?) AND users.status = 1 AND groups_users_join.group_id = ?", projects_users_ids.map(&:user_id), ecmasoft_group.id], :joins => [:groups])
  end

  def self.get_managers_and_subordinates
    result = {}

    managers = get_managers
    managers.each do |manager|
      result[manager] = get_subordinates(manager) 
    end

    result
  end

  def self.prepare_and_send_notification
    managers = get_managers_and_subordinates
    worktimes = calculate_developers_worktime

    managers.each do |manager, subordinates|
      subordinate_ids = subordinates.map(&:id)

      if [52].include?(manager.id)
        selected_worktimes = worktimes.select {|w| subordinate_ids.include?(w.user_id) }.sort_by(&:week_worktime) 
        deliver_notification(manager, selected_worktimes)
      end
    end
    nil
  end

  def notification(manager, subordinates)
    title = (subordinates.any?{|s| s.show_warning } ? "[NEED ATTENTION] " : "") + "Timesheet notification"

    from "blog4m@yandex.ru" #"no-reply@ecmasoft.com"
    recipients manager.mail
    subject title
    body :subordinates => subordinates
    content_type "text/html"
  end

end