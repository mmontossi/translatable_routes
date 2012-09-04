module RailsI18nRoutes
  module ActionController
    module BaseMethods
      
      def self.included(base)
        base.send :prepend_before_filter, :select_locale
      end
      
      def select_locale
        if Rails.application.config.i18n_routes.selection == :subdomain
          Rails.application.config.i18n_routes.mapping.each_pair do |key, value|
            if value.include? request.subdomain
              I18n.locale = "#{key}_#{request.subdomain}" 
              break
            end
          end
        else
          unless params[:locale].nil?
            I18n.locale = params[:locale]
          end
        end        
      end
      
    end
  end
end

ActionController::Base.send :include, RailsI18nRoutes::ActionController::BaseMethods