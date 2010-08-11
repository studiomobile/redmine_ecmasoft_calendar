class EcmasoftCalendarController < ApplicationController
  unloadable

  def index
    ecmasoft_group = Group.find_by_lastname "EcmaSoft"
    @users = ecmasoft_group.present? ? ecmasoft_group.users : []
    @current_user_id =  params[:user_id].to_i || User.current.id

    year = params[:year].to_i
    month = params[:month].to_i

    @date = Date.new(year, month, 1)
    @weeks = CalendarStatusItem.grouped_month_statuses(year, month, @current_user_id)

    render :partial => "calendar", :layout => false if request.post?
  end

end
