class CreateCloudflarePurges < ActiveRecord::Migration

  def up
    create_table :refinery_cloudflare_purges do |t|
      t.string :context
      t.integer :position
      
      t.timestamps
    end

    add_index ::Refinery::Cloudflare::Purge.table_name, :id


  end



  def down
    if defined?(::Refinery::UserPlugin)
      ::Refinery::UserPlugin.destroy_all({:name => "refinerycms-cloudflare"})
    end

    drop_table :refinery_cloudflare_purges

  end

end
