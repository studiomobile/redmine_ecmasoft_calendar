class DayStatus
  WEEKEND = 0
  WORKDAY = 1
  VACATION = 2
  SICK_LEAVE = 4
  LEAVE_WITHOUT_PAY = 8

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

  def workday?
    res = self.status & WORKDAY == WORKDAY
    off_day? ? false : res
  end

  def off_day?
    vacation? || sick_leave? || leave_without_pay?
  end

  def vacation?
    self.status & VACATION == VACATION
  end

  def sick_leave?
    self.status & SICK_LEAVE == SICK_LEAVE
  end

  def leave_without_pay?
    self.status & LEAVE_WITHOUT_PAY == LEAVE_WITHOUT_PAY
  end

end