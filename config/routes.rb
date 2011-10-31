ActionController::Routing::Routes.draw do |map|
  map.studiomobile_calendar "company_calendar/:year/:month",
    :controller => "company_calendar", :action => "index", :year => Date.today.year, :month => Date.today.month,
  :requirements => { :year => /\d{4}/, :month => /\d{1,2}/ }
  map.studiomobile_calendar "company_calendar/tt", :controller => "company_calendar", :action => "tt_data"
  map.studiomobile_calendar "company_calendar/submit_tt", :controller => "company_calendar", :action => "submit_tt"
end
