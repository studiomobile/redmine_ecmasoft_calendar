class EcmasoftCalendarController < ApplicationController
  unloadable

  def index
    year = params[:year].to_i || Date.today.year
    month = params[:month].to_i || Date.today.month

    @date = Date.new(year, month, 1)
    @weeks = CalendarStatusItem.grouped_month_statuses(year, month)
  end
  
end
