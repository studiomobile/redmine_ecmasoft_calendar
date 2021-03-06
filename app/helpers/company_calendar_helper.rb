module CompanyCalendarHelper

  DAY_STATUS_CLASS = {
    nil => "empty",
    DayStatus::WEEKEND => "weekend",
    DayStatus::WORKDAY => "workday",
    DayStatus::WEEKEND | DayStatus::VACATION => "vacation",
    DayStatus::WEEKEND | DayStatus::SICK_LEAVE => "sick-leave",
    DayStatus::WEEKEND | DayStatus::LEAVE_WITHOUT_PAY => "leave-without-pay",
    DayStatus::WORKDAY | DayStatus::VACATION => "vacation",
    DayStatus::WORKDAY | DayStatus::SICK_LEAVE => "sick-leave",
    DayStatus::WORKDAY | DayStatus::LEAVE_WITHOUT_PAY => "leave-without-pay"
  }

  def day_status(day, month)
    classes = []
    classes << DAY_STATUS_CLASS[day.status]
    classes << "other-month" if day.date.month != month
    classes << "today" if day.date == Date.today
    classes
  end

  def format_month(date)
    date.strftime('%b %Y')
  end

  def dropdown_with_users(users, user_id)
    list = users.sort{|x, y| x.name <=> y.name }.collect {|u| [u.name, u.id] }
    list.insert(0, ["All users", 0])
    select_tag :user_id, options_for_select(list, user_id)
  end

  def worktime_attribute(day)
    worktime = day.worktime
    "data-worktime=\"#{worktime}\"" if worktime > 0
  end
  
  def date_attribute(date)
    "data-date=\"#{date.strftime('%Y-%m-%d')}\""
  end

  def worktime_progress(day)
    worktime = day.worktime
    "style=\"background-position: 0 #{80 - 10 * worktime}px\"" if worktime > 0
  end

  def cell_title_attribute(day)
    worktime = day.worktime

    lines = []
    lines << "Vacation" if day.vacation?
    lines << "Sick leave" if day.sick_leave?
    lines << "Leave without pay" if day.leave_without_pay?
    lines << "Worktime: #{worktime}" if worktime > 0

    "title=\"#{lines.join("\n")}\"" unless lines.empty?
  end

end
