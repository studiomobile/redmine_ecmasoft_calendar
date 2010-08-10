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

end
