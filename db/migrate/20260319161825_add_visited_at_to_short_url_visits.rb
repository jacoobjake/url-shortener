class AddVisitedAtToShortUrlVisits < ActiveRecord::Migration[8.1]
  def change
    add_column :short_url_visits, :visited_at, :datetime, null: false, default: -> { "CURRENT_TIMESTAMP" }
  end
end
