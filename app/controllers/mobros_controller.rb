class MobrosController < ApplicationController
  def index
    @models = Dir.glob(File.join(RAILS_ROOT, 'app', 'models', '*.rb')).map{|f|
      Object.const_get(File.basename(f, '.rb').titleize)
    }.select{|m| m.is_a?(Class) && m.ancestors.include?(ActiveRecord::Base)}
    @model = @models.find(Proc.new{@models.first}){|m| m.name == params[:selected_model]}
    @assocs_hash = {}
    assocs = @model.reflect_on_all_associations
    assoc_types = [:belongs_to, :has_one, :has_many, :has_and_belongs_to_many]
    assoc_types.each{|t| @assocs_hash[t] = assocs.select{|a| a.macro == t} || []}
  end
  
  def new_column
    @model = Object.const_get(params[:model_name])
#    puts "AAAAAAAAAAAAAAAAAAA"
#    render :template => 'mobros/new_column.js.rjs', :locals => {:model => Object.const_get(params[:model])}
  end
  
  def create_column
    # Generate migration
    %x[ruby script/generate migration add_#{params[:column_name]}_to_#{params[:model].underscore} #{params[:column_name]}:#{params[:column_type]}]
    # Run migration
    %x[rake db:migrate]
    render :template => 'mobros/create_column.js.rjs', :locals => {:model => Object.const_get(params[:model].titleize)}
  end
  
  def create_model
    # Generate migration
    %x[ruby script/generate model #{params[:model_name].underscore}]
    # Run migration
    %x[rake db:migrate]
    render :template => 'mobros/create_model.js.rjs', :locals => {:model => Object.const_get(params[:model_name].titleize)}
  end
  
end