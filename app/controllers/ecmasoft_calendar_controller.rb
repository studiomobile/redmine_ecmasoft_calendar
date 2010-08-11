class EcmasoftCalendarController < ApplicationController
  unloadable

  def index
    ecmasoft_group = Group.find_by_lastname "EcmaSoft"
    @users = ecmasoft_group.present? ? ecmasoft_group.users : []
    @current_user_id =  (params[:user_id] || User.current.id).to_i

    year = params[:year].to_i
    month = params[:month].to_i

    @date = Date.new(year, month, 1)
    @weeks = CalendarStatusItem.grouped_month_statuses(year, month, @current_user_id)

    render :partial => "calendar", :layout => false if request.post?
  end

  def set_status
    date = Date.parse(params[:date])
    user_id = params[:user_id].to_i
    status = params[:status].to_i

    CalendarStatusItem.set_day_status(date, user_id, status)

    day = CalendarStatusItem.get_day(date, user_id)
    render :partial => "cell", :layout => false, :locals => { :day => day, :user_id => user_id }
  end

  def undo
    date = Date.parse(params[:date])
    user_id = params[:user_id].to_i

    CalendarStatusItem.undo_day_status(date, user_id)

    day = CalendarStatusItem.get_day(date, user_id)
    render :partial => "cell", :layout => false, :locals => { :day => day, :user_id => user_id }
  end

end
