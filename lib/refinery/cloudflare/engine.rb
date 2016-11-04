module Refinery
  module Cloudflare
    class Engine < Rails::Engine
      extend Refinery::Engine
      isolate_namespace Refinery::Cloudflare

      engine_name :refinery_cloudflare

      before_inclusion do
        Refinery::Plugin.register do |plugin|
          plugin.name = "purges"
          plugin.url = proc { Refinery::Core::Engine.routes.url_helpers.cloudflare_admin_purges_path }
          plugin.pathname = root
          plugin.menu_match = %r{refinery/cloudflare/purges(/.*)?$}
          plugin.icon = 'icon icon-cloud icon-fe'
        end
      end

      config.after_initialize do
        Refinery.register_extension(Refinery::Cloudflare)
      end
    end
  end
end
