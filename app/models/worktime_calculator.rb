require 'ostruct'

class WorktimeCalculator

  def initialize(group = Ecmasoft::Settings.group)
    @group = group
  end

  def calculate_developers_worktime
    users = @group.present? ? @group.users : []

    worktimes = []
    users.each do |user|
      week_worktime, expected_week_worktime = user_worktime_for_current_week(user)
      month_worktime, expected_month_worktime = user_worktime_for_current_month(user)

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

  def user_worktime_for_current_week(user)
    from = Date.today.beginning_of_week
    to = Date.today

    calculate_user_worktime(user, from, to)
  end

  def user_worktime_for_current_month(user)
    from = Date.today.beginning_of_month
    to = Date.today

    calculate_user_worktime(user, from, to)
  end

  def calculate_user_worktime(user, from, to)
    current_hrs = TimeEntry.sum("hours", :conditions => ["user_id = ? AND spent_on BETWEEN ? AND ?", user.id, from, to])
    expected_hrs = 8 * CalendarStatusItem.workdays_count(from, to, user.id)

    [current_hrs, expected_hrs]
  end

  def managers
    user_ids = Ecmasoft::Settings.manager_role.members.map(&:user_id).uniq

    User.all(:conditions => ["users.id IN (?) AND users.status = 1 AND groups_users_join.group_id = ?", user_ids, @group.id], :joins => [:groups])
  end

  def subordinates(manager)
    manager_projects = Project.all(:joins => :users, :conditions => ["users.id = ?", manager.id])
    projects_users_ids = Member.all(:select => "DISTINCT user_id", :conditions => ["project_id in (?) AND user_id != ?", manager_projects.map(&:id), manager.id])
    User.all(:conditions => ["users.id IN (?) AND users.status = 1 AND groups_users_join.group_id = ?", projects_users_ids.map(&:user_id), @group.id], :joins => [:groups])
  end

  def managers_and_subordinates
    managers.inject({}) { |all, manager| all.merge!(manager => subordinates(manager)) }
  end

end