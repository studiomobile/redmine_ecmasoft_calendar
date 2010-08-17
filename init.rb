require 'redmine'

Redmine::Plugin.register :ecmasoft_calendar do
  name 'Redmine Ecmasoft Calendar plugin'
  author 'Maxim Dobriakov'
  description 'Show calendar of work and week days'
  version '0.0.1'
  url 'http://github.com/martynovs/redmine_ecmasoft_calendar'
  author_url 'http://ecmasoft.com'

  permission :ecmasoft_calendar, { :ecmasoft_calendar => [ :index ] }, :require => :member

  settings :default => {'group_name' => 'EcmaSoft', 'manager_role' => 'Manager'}, :partial => 'settings/calendar_settings'

  menu :top_menu, :schedules_page, { :controller => 'ecmasoft_calendar', :action => 'index' },
       :after => :my_page, :caption => "EcmaSoft Calendar",
       :if => Proc.new { User.current.groups.include?(Ecmasoft::Settings.group) }

end
