ActionController::Routing::Routes.draw do |map|
  map.resources :mobros
  map.mobro_update_model 'mobros/update_model', :controller => 'mobros', :action => 'update_model'
  map.new_mobros_model 'mobros/new_model', :controller => 'mobros', :action => 'new_model'
  map.create_mobros_model 'mobros/create_model', :controller => 'mobros', :action => 'create_model'
end