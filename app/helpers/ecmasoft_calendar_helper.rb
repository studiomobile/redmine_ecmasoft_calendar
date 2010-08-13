module EcmasoftCalendarHelper

  DAY_STATUS_CLASS = {
    nil => "empty",
    CalendarStatusItem::WEEKEND => "weekend",
    CalendarStatusItem::WORKDAY => "workday",
    CalendarStatusItem::WEEKEND | CalendarStatusItem::VACATION => "vacation",
    CalendarStatusItem::WEEKEND | CalendarStatusItem::SICK_LEAVE => "sick-leave",
    CalendarStatusItem::WORKDAY | CalendarStatusItem::VACATION => "vacation",
    CalendarStatusItem::WORKDAY | CalendarStatusItem::SICK_LEAVE => "sick-leave"
  }

  def day_status(day, month)
    status = day[:status]
    classes = []
    classes << DAY_STATUS_CLASS[status]
    classes << "other-month" if day[:date].month != month
    classes
  end

  def format_month(date)
    date.strftime('%b %Y')
  end

  def dropdown_with_users(users, user_id)
    list = users.collect {|u| [u.name, u.id] }
    list.insert(0, ["All users", 0])
    select_tag :user_id, options_for_select(list, user_id)
  end

  def weekend?(day)
    day[:status] & CalendarStatusItem::WEEKEND == CalendarStatusItem::WEEKEND
  end

  def workday?(day)
    day[:status] & CalendarStatusItem::WORKDAY == CalendarStatusItem::WORKDAY
  end

  def vacation?(day)
    day[:status] & CalendarStatusItem::VACATION == CalendarStatusItem::VACATION
  end

  def sick_leave?(day)
    day[:status] & CalendarStatusItem::SICK_LEAVE == CalendarStatusItem::SICK_LEAVE
  end

  def worktime_attribute(day)
    worktime = day[:worktime].to_f
    "data-worktime=\"#{worktime}\" title=\"Worktime: #{worktime}\"" if worktime > 0
  end


  def worktime_progress(day)
    worktime = day[:worktime].to_f
    "style=\"background-position: 0 #{80 - 10 * worktime}px\"" if worktime > 0
  end

end
