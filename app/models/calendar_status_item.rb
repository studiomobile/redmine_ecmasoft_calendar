class CalendarStatusItem < ActiveRecord::Base

  STATUSES = { :workday => 0, :weekend => 1, :vacation => 2, :sick_leave => 3 }
  DAYNAMES = %w(Monday Tuesday Wednesday Thursday Friday Saturday Sunday)

  named_scope :for_user, lambda { |user_id| { :conditions => { :user_id => user_id } } } 

  def self.get_assigned_statuses(year, month, user_id = nil)
    start_month_date = Date.new(year, month, 1)
    end_month_date = start_month_date.end_of_month

    scope = CalendarStatusItem.all(:conditions => ["date BETWEEN ? AND ?", start_month_date, end_month_date])
    scope = scope.for_user(user_id) if user_id
    scope
  end

  def self.get_month_statuses(year, month, user_id = nil)
    days = []

    statuses = CalendarStatusItem.get_assigned_statuses(year, month, user_id)

    start_month_date = Date.new(year, month, 1)
    end_month_date = start_month_date.end_of_month

    (start_month_date.cwday - 1).times { days << nil }

    date = start_month_date
    while date <= end_month_date do
      calendar_status_item = statuses.select {|e| e.date == date }.first

      status = [6, 7].include?(date.cwday) ? STATUSES[:weekend] : STATUSES[:workday] # default status
      status = calendar_status_item.status if calendar_status_item # assigned status 

      days << { :status => status, :date => date }

      date = date.next
    end

    (7 - end_month_date.cwday).times { days << nil }

    days
  end

  def self.grouped_month_statuses(year, month, user_id = nil)
    statuses = CalendarStatusItem.get_month_statuses(year, month, user_id)
    weeks = []
    statuses.in_groups_of(7) {|g| weeks << g }
    weeks
  end

end