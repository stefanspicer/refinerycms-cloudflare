require 'http'
require 'refinerycms-core'

module Refinery
  autoload :CloudflareGenerator, 'generators/refinery/cloudflare_generator'

  module Cloudflare
    require 'refinery/cloudflare/engine'

    class << self
      attr_writer :root

      def root
        @root ||= Pathname.new(File.expand_path('../../../', __FILE__))
      end

      def factory_paths
        @factory_paths ||= [ root.join('spec', 'factories').to_s ]
      end

      def in_production?
        return Rails.env.production?
      end

      def purge_cache(files, files_extra = nil, context = nil)
        domain  = Refinery::Setting.get(:cloudflare_domain)
        zone    = Refinery::Setting.get(:cloudflare_zone)
        email   = Refinery::Setting.get(:cloudflare_auth_email)
        api_key = Refinery::Setting.get(:cloudflare_auth_api_key)

        if zone.blank? && in_production? && domain.present? && email.present? && api_key.present?
          result = JSON.parse(HTTP[
            :"X-Auth-Email" => email,
            :"X-Auth-Key"   => api_key,
            :"Content-Type" => "application/json",
          ].get("https://api.cloudflare.com/client/v4/zones?name=#{domain.gsub(/https?:\/\//, '')}").to_s)

          zone = result['result'][0]['id']
          Refinery::Setting.set(:cloudflare_zone, zone)
        end

        if in_production? && domain.present? && zone.present? && email.present? && api_key.present?
          batch_size = 30 # API MAX
          last_purge = nil
          last_purge = Refinery::Cloudflare::Purge.where(:context => context).last if context.present?
          # only purge extra if we haven't in a while
          purge_extra = files_extra.present? && (last_purge.blank? || last_purge.created_at < 5.minutes.ago)

          if purge_extra
            all_files = files + files_extra
            purge_record = Refinery::Cloudflare::Purge.new(:context => context)
            purge_record.save
          else
            all_files = files
          end

          all_files.map! {|f| "#{domain}#{f}"}

          all_files.each_slice(batch_size).to_a.each do |batch|
            # Rails.logger.warn "DEBUG: DELETE #{zone}/purge(#{batch.length})"
            # Rails.logger.warn "DEBUG: files=[#{batch.join(', ')}]"
            result = JSON.parse(HTTP[
              :"X-Auth-Email" => email,
              :"X-Auth-Key"   => api_key,
              :"Content-Type" => "application/json",
            ].delete("https://api.cloudflare.com/client/v4/zones/#{zone}/purge_cache", :json => {:files => batch}).to_s)
          end
        end
      end
    end
  end
end
