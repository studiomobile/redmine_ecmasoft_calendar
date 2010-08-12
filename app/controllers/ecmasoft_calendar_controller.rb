class EcmasoftCalendarController < ApplicationController
  unloadable

  before_filter :require_ecmasoft_user

  def index
    ecmasoft_group = Group.find_by_lastname EcmasoftConsts::ECMASOFT_GROUP
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

private

  def require_ecmasoft_user
    return unless require_login
    unless User.current.groups.any? {|g| g.lastname == EcmasoftConsts::ECMASOFT_GROUP}
      render_403
      return false
    end
    true
  end


end
