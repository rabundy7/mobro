module Mobro #:nodoc:
  module Routing #:nodoc:
    module MapperExtensions
      def mobros
        @set.add_route("/mobros", {:controller => "mobros", :action => "index"})
        @set.add_route("/mobros/add_column", {:controller => "mobros", :action => "add_column"})
        @set.add_route("/mobros/add_model", {:controller => "mobros", :action => "add_model"})
      end
    end
  end
end

ActionController::Routing::RouteSet::Mapper.send :include, Mobro::Routing::MapperExtensions