class CalendarStatusItem < ActiveRecord::Base

  WEEKEND = 0
  WORKDAY = 1
  VACATION = 2
  SICK_LEAVE = 4

  DAYNAMES = %w(Monday Tuesday Wednesday Thursday Friday Saturday Sunday)

  named_scope :for_user, lambda { |user_id| { :conditions => { :user_id => [0, user_id] } } } 

  def self.get_assigned_statuses(from, to, user_id = 0)
    scope = CalendarStatusItem.for_user(user_id)
    scope.all(:conditions => ["date BETWEEN ? AND ?", from, to])
  end

  def self.get_month_statuses(year, month, user_id = 0)
    days = []

    start_month_date = Date.new(year, month, 1)
    end_month_date = start_month_date.end_of_month

    start_date = start_month_date - (start_month_date.cwday - 1).days
    end_date = end_month_date + (7 - end_month_date.cwday).days

    statuses = CalendarStatusItem.get_assigned_statuses(start_date, end_date, user_id)

    start_date.step(end_date) do |date|
      date_statuses = statuses.select {|e| e.date == date }
      days << { :status => calculate_status(date, date_statuses), :date => date }
    end

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
      return if !User.current.admin? && User.current.id != user_id
    end

    item = CalendarStatusItem.first(:conditions => ["date = ? AND user_id = ?", date, user_id])
    item = CalendarStatusItem.create({ :date => date, :user_id => user_id }) unless item
    item.status = status
    item.save!
  end

  def self.undo_day_status(date, user_id)
    return if user_id == 0
    item = CalendarStatusItem.first(:conditions => ["date = ? AND user_id = ?", date, user_id])
    if item
      item.status = 0
      item.save
    end
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
    status_lvl1 = WEEKEND if date_statuses.any? { |s| s.status == WEEKEND && s.user_id == 0 }
    status_lvl1 = WORKDAY if date_statuses.any? { |s| s.status == WORKDAY && s.user_id == 0 }

    status_lvl2 = 0
    status_lvl2 = SICK_LEAVE if date_statuses.any? { |s| s.status == SICK_LEAVE }
    status_lvl2 = VACATION if date_statuses.any? { |s| s.status == VACATION }

    status_lvl1 | status_lvl2
  end

end