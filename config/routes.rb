ActionController::Routing::Routes.draw do |map|
  map.resources :mobros
  map.new_mobros_column 'mobros/new_column', :controller => 'mobros', :action => 'new_column'
  map.create_mobros_column 'mobros/create_column', :controller => 'mobros', :action => 'create_column'
  map.new_mobros_model 'mobros/new_model', :controller => 'mobros', :action => 'new_model'
  map.create_mobros_model 'mobros/create_model', :controller => 'mobros', :action => 'create_model'
end