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

  def tt_data
    if params[:user_id].to_i != User.current.id
      render :text => "User not allowed", :status => 403
    else
      @projects = Project.active
      @my_projects = User.current.memberships.map {|m| m.project}.sort_by(&:lft)
      @other_projects = @projects.reject {|p| @my_projects.include? p}.sort_by(&:lft)
      @date = Date.strptime(params[:date], "%Y-%m-%d")
      @tt = TimeEntry.sum("hours", :group => :project_id, :conditions => ["user_id=? and spent_on=?", User.current.id, @date])
      @tt = @tt.inject({}) {|h, (k, v)| h[k] = v; h}
      render :partial => "tt", :layout => false
    end
  end

  def submit_tt
    projects = Project.active
    date = Date.strptime(params[:date], "%Y-%m-%d")
    projects.each do |p|
      tt = params["tt_#{p.id}"] || 0
      comment = params["tt_comment_#{p.id}"] || ""
      if tt.to_i > 0 and !comment.empty?
        te = TimeEntry.new(:project => p, :user => User.current, :spent_on => date, :hours => tt.to_i, :comments => comment)
        if !te.save
          errors = te.errors.full_messages
          error_text = p.name + "<br />" + (errors.collect { |error| '-' + error }.join("<br />")) + "<br />"
          flash[:error] = "" if flash[:error].nil?
          flash[:error] += error_text
        end
      end
    end
    redirect_to :action => :index, :year => date.year, :month => date.month
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
