module LocalizableRoutes
  class Railtie < Rails::Railtie

    initializer 'localizable_routes.action_dispatch' do
      ::ActionDispatch::Routing::RouteSet::NamedRouteCollection.include(
        LocalizableRoutes::Extensions::ActionDispatch::NamedRouteCollection
      )
      ::ActionDispatch::Routing::Mapper.prepend(
        LocalizableRoutes::Extensions::ActionDispatch::Mapper
      )
    end

  end
end
