class AddMetadataToShortUrls < ActiveRecord::Migration[8.1]
  def change
    add_column :short_urls, :metadata, :json
  end
end
