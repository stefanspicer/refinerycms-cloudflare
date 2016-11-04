Refinery::Page.class_eval do
  after_save :purge_cache

  private
    def purge_cache
      Refinery::Cloudflare::purge_cache([self.nested_path])
    end
end
