class CalendarStatusItem < ActiveRecord::Base

  WEEKEND = 0
  WORKDAY = 1
  VACATION = 2
  SICK_LEAVE = 4

  DAYNAMES = %w(Monday Tuesday Wednesday Thursday Friday Saturday Sunday)

  named_scope :for_user, lambda { |user_id| { :conditions => { :user_id => [0, user_id] } } } 

  def self.get_assigned_statuses(year, month, user_id = 0)
    start_month_date = Date.new(year, month, 1)
    end_month_date = start_month_date.end_of_month

    scope = CalendarStatusItem.for_user(user_id)
    scope.all(:conditions => ["date BETWEEN ? AND ?", start_month_date, end_month_date])
  end

  def self.get_month_statuses(year, month, user_id = 0)
    days = []

    statuses = CalendarStatusItem.get_assigned_statuses(year, month, user_id)

    start_month_date = Date.new(year, month, 1)
    end_month_date = start_month_date.end_of_month

    (start_month_date.cwday - 1).times { days << nil }

    date = start_month_date
    while date <= end_month_date do
      date_statuses = statuses.select {|e| e.date == date }
      days << { :status => calculate_status(date, date_statuses), :date => date }

      date = date.next
    end

    (7 - end_month_date.cwday).times { days << nil }

    days
  end

  def self.grouped_month_statuses(year, month, user_id = 0)
    statuses = CalendarStatusItem.get_month_statuses(year, month, user_id)
    weeks = []
    statuses.in_groups_of(7) {|g| weeks << g }
    weeks
  end

  def self.get_day_statuses(date, user_id = 0)
    CalendarStatusItem.for_user(user_id).all(:conditions => ["date = ?", date])
  end

  def self.set_day_status(date, user_id, status)
    if user_id == 0
      return unless [WEEKEND, WORKDAY].include?(status) # reject unrestricted statuses
    else
      return if [WEEKEND, WORKDAY].include?(status) # reject unrestricted statuses 
    end

    item = CalendarStatusItem.first(:conditions => ["date = ? AND user_id = ?", date, user_id])
    item = CalendarStatusItem.create({ :date => date, :user_id => user_id }) unless item
    item.status = status
    item.save!
  end

  def self.undo_day_status(date, user_id)
    CalendarStatusItem.delete_all ["date = ? AND user_id = ?", date, user_id]
  end

  def self.get_day(date, user_id = 0)
    date_statuses = get_day_statuses(date, user_id)
    status = calculate_status(date, date_statuses)
    { :status => status, :date => date }
  end

private

  def self.calculate_status(date, date_statuses)
    date_statuses = date_statuses || []

    status_lvl1 = [6, 7].include?(date.cwday) ? WEEKEND : WORKDAY # default status
    status_lvl1 = WEEKEND if date_statuses.any? { |s| s.status == WEEKEND }
    status_lvl1 = WORKDAY if date_statuses.any? { |s| s.status == WORKDAY }

    status_lvl2 = 0
    status_lvl2 = SICK_LEAVE if date_statuses.any? { |s| s.status == SICK_LEAVE }
    status_lvl2 = VACATION if date_statuses.any? { |s| s.status == VACATION }

    status_lvl1 | status_lvl2
  end

end