module EcmasoftCalendarHelper

  DAY_STATUS_CLASS = {
    nil => "empty",
    CalendarStatusItem::STATUSES[:workday] => "workday",
    CalendarStatusItem::STATUSES[:weekend] => "weekend",
    CalendarStatusItem::STATUSES[:vacation] => "vacation",
    CalendarStatusItem::STATUSES[:sick_leave] => "sick-leave"
  }

  def day_status(day)
    status = day.nil? ? nil : day[:status]
    DAY_STATUS_CLASS[status]
  end

  def format_month(date)
    date.strftime('%b %Y')
  end

  def dropdown_with_users(users, current_user)
    list = users.collect {|u| [u.name, u.id] }
    list.insert(0, ["All users", 0])
    select_tag :user_id, options_for_select(list, current_user.id)
  end

end
