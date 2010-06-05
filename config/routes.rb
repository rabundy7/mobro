ActionController::Routing::Routes.draw do |map|
  map.resources :mobros
  map.add_model_inspectors_column 'mobros/add_column', :controller => 'model_inspectors', :action => 'add_column'
  map.add_model_inspectors_model 'mobros/add_model', :controller => 'model_inspectors', :action => 'add_model'
end