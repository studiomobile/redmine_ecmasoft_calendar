ActionController::Routing::Routes.draw do |map|
  map.ecmasoft_calendar "ecmasoft_calendar/:year/:month", :controller => "ecmasoft_calendar", :action => "index",
    :requirements => { :year => /\d{4}/, :month => /\d{1,2}/ }
end
