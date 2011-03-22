class CompanyCalendarController < ApplicationController
  unloadable

  before_filter :require_company_user

  def index
    company_group = StudioMobile::Settings.group
    @users = company_group.present? ? company_group.users : []
    @current_user_id =  (params[:user_id] || User.current.id).to_i

    year = params[:year].to_i
    month = params[:month].to_i

    @date = Date.new(year, month, 1)
    @weeks = CalendarStatusItem.grouped_month_statuses(year, month, @current_user_id)

    render :partial => "calendar", :layout => false if request.post?
  end

  def set_status
    date = Date.parse(params[:date])
    month = params[:month].to_i
    user_id = params[:user_id].to_i
    status = params[:status].to_i

    if status == -1
      CalendarStatusItem.undo_day_status(date, user_id)
    else
      CalendarStatusItem.set_day_status(date, user_id, status)
    end

    day = CalendarStatusItem.get_day(date, user_id)
    render :partial => "cell", :layout => false, :locals => { :day => day, :month => month, :user_id => user_id }
  end

private

  def require_company_user
    return unless require_login
    unless User.current.groups.include?(StudioMobile::Settings.group)
      render_403
      return false
    end
    true
  end


end
