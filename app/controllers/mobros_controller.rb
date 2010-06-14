class MobrosController < ApplicationController
  def index
    @models = Dir.glob(File.join(RAILS_ROOT, 'app', 'models', '*.rb')).map{|f|
      Object.const_get(File.basename(f, '.rb').titleize)
    }.select{|m| m.is_a?(Class) && m.ancestors.include?(ActiveRecord::Base)}
    @model = @models.find(Proc.new{@models.first}){|m| m.name == params[:selected_model]}
    @model_columns = get_model_columns(@model)
    @assocs_hash = {}
    assocs = @model.reflect_on_all_associations
    assoc_types = [:belongs_to, :has_one, :has_many, :has_and_belongs_to_many]
    assoc_types.each{|t| @assocs_hash[t] = assocs.select{|a| a.macro == t} || []}
  end
  
  def update_model
    @model = Object.const_get(params[:model_name])
    deleted_columns = params[:deleted_columns].split(/,/).map{|c| c.sub(/_column$/, '')}
    modified_column_names = {}
    modified_column_types = {}
    new_columns = {} 
    
    get_model_columns(@model).each do |column|
      param_col_name = params["#{column.name}_column"]
      modified_column_names.merge!({column.name => param_col_name}) if param_col_name != column.name
      param_col_type = params["#{column.name}_column_type"]
      modified_column_types.merge!({column.name => param_col_type}) if param_col_type != column.type.to_s
    end
    params.keys.select{|k| k =~ /\d_new_column$/}.each do |new_column|
      new_columns.merge!({params[new_column] => params["#{new_column}_type"]}) if !params[new_column].blank? 
    end
    puts "~~~~deleted_columns = #{deleted_columns.inspect}"
    puts "~~~~modified_column_names = #{modified_column_names.inspect}"
    puts "~~~~modified_column_types = #{modified_column_types.inspect}"
    puts "~~~~new_columns = #{new_columns.inspect}"
    
    existing_migration_filenames = Dir.glob(File.join(RAILS_ROOT, 'db', 'migrate', '*.rb')).map do |f| 
      File.basename(f, '.rb').gsub(/\d+_/, '')
    end
    
    migration_base_filename = "modify_#{params[:model_name].underscore}"
    i = 1
    while existing_migration_filenames.include?(migration_base_filename)
      migration_base_filename.gsub!(/\d+$/, '')
      migration_base_filename += "#{i}"
      i += 1
    end
    
    migration_filename = "#{DateTime.now.strftime('%Y%m%d%H%M%S')}_#{migration_base_filename}.rb"
    
    migration_erb = ERB.new <<-END
      class <%= migration_base_filename.camelize %> < ActiveRecord::Migration
        def self.up
          <% new_columns.each do |nc, nt| %>
          add_column :<%= @model.table_name %>, :<%= nc %>, :<%= nt %>
          <% end %>
          <% modified_column_names.each do |ocn, ncn| %>
          rename_column :<%= @model.table_name %>, :<%= ocn %>, :<%= ncn %> 
          <% end %>
          <% modified_column_types.each do |cn, nt| %>
          change_column :<%= @model.table_name %>, :<%= cn %>, :<%= nt %>
          <% end %>
          <% deleted_columns.each do |dc| %>
          remove_column :<%= @model.table_name %>, :<%= dc %>
          <% end %>
        end
      
        def self.down
          <% new_columns.each do |nc, nt| %>
          remove_column :<%= @model.table_name %>, :<%= nc %>
          <% end %>
          <% modified_column_names.each do |ocn, ncn| %>
          rename_column :<%= @model.table_name %>, :<%= ncn %>, :<%= ocn %>
          <% end %>
          <% modified_column_types.each do |cn, nt| %>
          change_column :<%= @model.table_name %>, :<%= cn %>, :<%= @model.columns.select{|c| c.name == cn}.first.type %>
          <% end %>
          <% deleted_columns.each do |dc| %>
          add_column :<%= @model.table_name %>, :<%= dc %>, :<%= @model.columns.select{|c| c.name == dc}.first.type %>
          <% end %>
        end
      end
    END
    
    File.open(File.join(RAILS_ROOT, 'db', 'migrate', migration_filename), "w"){|f| f.write(migration_erb.result(binding))}

    # Run migration
    %x[rake db:migrate]
    
    @model.reset_column_information
    @model_columns = get_model_columns(@model)
    render :template => 'mobros/update_model.js.rjs', :locals => {:model => @model}
  end
  
  def create_model
    # Generate migration
    %x[ruby script/generate model #{params[:model_name].underscore}]
    # Run migration
    %x[rake db:migrate]
    render :template => 'mobros/create_model.js.rjs', :locals => {:model => Object.const_get(params[:model_name].titleize)}
  end
  
  private
  
  def get_model_columns(model)
    model.columns.sort{|a, b| a.name <=> b.name}
  end
end