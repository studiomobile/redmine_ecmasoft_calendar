ActionController::Routing::Routes.draw do |map|
  map.ecmasoft_calendar "ecmasoft_calendar/:year/:month",
    :controller => "ecmasoft_calendar", :action => "index", :year => Date.today.year, :month => Date.today.month,
    :requirements => { :year => /\d{4}/, :month => /\d{1,2}/ }
end
