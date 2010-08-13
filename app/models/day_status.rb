class DayStatus
  WEEKEND = 0
  WORKDAY = 1
  VACATION = 2
  SICK_LEAVE = 4

  attr_accessor :date
  attr_accessor :status
  attr_accessor :worktime

  def initialize(date, status, worktime)
    self.date = date
    self.status = status
    self.worktime = worktime.to_f
  end

  def weekend?
    self.status & WEEKEND == WEEKEND
  end

  def workday?(without_vacations_and_sick_leaves = true)
    res = self.status & WORKDAY == WORKDAY
    without_vacations_and_sick_leaves && (vacation? || sick_leave?) ? false : res
  end

  def vacation?
    self.status & VACATION == VACATION
  end

  def sick_leave?
    self.status & SICK_LEAVE == SICK_LEAVE
  end

end