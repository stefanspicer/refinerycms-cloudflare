require 'will_paginate/array'

module Refinery
  module Cloudflare
    module Admin
      class PurgesController < ::Refinery::AdminController

        crudify :'refinery/cloudflare/purge',
                :title_attribute => 'context',
                :searchable => false,
                :sortable => false

        # NOTE: when making searchable: remember to add to your model `acts_as_indexed :fields => [:title, :body]`

        def index
          unless searching?
            find_all_purges
          else
            search_all_purges
          end

          # Set domain, only if there is no setting for this
          Refinery::Setting.get_or_set(:cloudflare_domain, request.base_url, {form_value_type: 'string'}) if Refinery::Cloudflare.in_production?

          @purges = @purges.paginate(page: params[:page])

          respond_to do |format|
            format.html
          end
        end
      end
    end
  end
end
