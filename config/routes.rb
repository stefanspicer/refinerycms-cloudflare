Refinery::Core::Engine.routes.draw do

  # Admin routes
  namespace :cloudflare, :path => '' do
    namespace :admin, :path => "#{Refinery::Core.backend_route}/cloudflare" do
      resources :purges, :only => :index
    end
  end
end

