# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_15_095138) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "short_url_visits", force: :cascade do |t|
    t.string "city"
    t.string "country_code", limit: 2
    t.string "country_name"
    t.datetime "created_at", null: false
    t.inet "ip_address"
    t.string "referrer"
    t.string "region_code", limit: 10
    t.string "region_name"
    t.bigint "short_url_id", null: false
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.index ["short_url_id", "country_code"], name: "index_short_url_visits_on_short_url_id_and_country_code"
    t.index ["short_url_id", "created_at"], name: "index_short_url_visits_on_short_url_id_and_created_at"
    t.index ["short_url_id"], name: "index_short_url_visits_on_short_url_id"
  end

  create_table "short_urls", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.json "metadata"
    t.string "short_code", limit: 15, null: false
    t.text "target_url", null: false
    t.datetime "updated_at", null: false
    t.index ["short_code"], name: "index_short_urls_on_short_code", unique: true
  end

  add_foreign_key "short_url_visits", "short_urls"
end
