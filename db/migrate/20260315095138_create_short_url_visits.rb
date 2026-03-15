class CreateShortUrlVisits < ActiveRecord::Migration[8.1]
  def change
    create_table :short_url_visits do |t|
      t.references :short_url, null: false, foreign_key: true
      t.inet :ip_address
      t.string :referrer
      t.string :user_agent
      t.string :country_code, limit: 2
      t.string :country_name
      t.string :region_code, limit: 10
      t.string :region_name
      t.string :city
      t.timestamps
    end

    add_index :short_url_visits, [ :short_url_id, :created_at ]
    add_index :short_url_visits, [ :short_url_id, :country_code ]
  end
end
