module TranslatableRoutes
  module ActionDispatch
    module Mapper
      extend ActiveSupport::Concern

      def localized
        @locales = I18n.available_locales
        scope(':locale') { yield }
        @locales = nil
      end

      def add_route(action, options)
        if @locales
          @locales.each do |locale|
            if @scope[:scope_level_resource]
              original_scope_level_resource = @scope[:scope_level_resource].dup
            end
            if @scope[:path]
              original_path = @scope[:path].dup
            end
            original_path_names = @scope[:path_names].dup
            original_options = options.dup
            @scope[:path] = i18n_path(@scope[:path], locale)
            @scope[:path_names].each { |key, value| value = i18n_path(value, locale) }
            options[:path] = i18n_path(options[:path], locale)
            options[:constraints] = { locale: locale.to_s }
            options[:defaults] = { locale: locale.to_s }
            if @scope[:scope_level_resource]
              %w(collection_name member_name).each do |method|
                @scope[:scope_level_resource].class_eval do
                  define_method method do
                    "#{super()}_#{locale}"
                  end
                end
              end
            else
              options[:as] = "#{options[:as] || action}_#{locale}"
            end
            super i18n_path(action, locale), options
            if @scope[:scope_level_resource]
              @scope[:scope_level_resource] = original_scope_level_resource
            end
            if @scope[:path]
              @scope[:path] = original_path
            end
            @scope[:path_names] = original_path_names
            options = original_options
          end
          if @scope[:scope_level_resource]
            helper = name_for_action(options[:as], action)
          else
            helper = "#{options[:as] || action}"
            helper = "#{@scope[:as]}_#{helper}" if @scope[:as]
          end
          @set.named_routes.define_i18n_url_helper helper
        else
          super
        end
      end

      protected

      def i18n_path(path, locale)
        case path
        when String
          i18n_path = []
          path.split('/').each do |part|
            next if part == ''
            if part[0] == ':' or part[0] == '*'
              i18n_path << part
            else
              i18n_path << I18n.t("routes.#{part}", locale: locale, default: part.gsub(/_/, '-'))
            end
          end
          i18n_path.join('/')
        when Symbol
          path
        end
      end

    end
  end
end
