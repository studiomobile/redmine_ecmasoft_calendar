require 'redmine'
require 'studiomobile/settings'

Redmine::Plugin.register :studiomobile_calendar do
  name 'Studio Mobile Calendar plugin'
  author 'Maxim Dobryakov'
  description 'Show calendar of work and week days'
  version '0.0.2'
  url 'http://github.com/martynovs/redmine_studiomobile_calendar'
  author_url 'http://studiomobile.ru'

  permission :studiomobile_calendar, { :company_calendar => [ :index ] }, :require => :member

  settings :default => {'group_name' => 'StudioMobile', 'manager_role' => 'Manager'}, :partial => 'settings/calendar_settings'

  menu :top_menu, :schedules_page, { :controller => 'company_calendar', :action => 'index' },
       :after => :my_page, :caption => "Company Calendar",
       :if => Proc.new { User.current.groups.include?(StudioMobile::Settings.group) }

end
