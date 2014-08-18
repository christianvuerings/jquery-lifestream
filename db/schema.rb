# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140815155903) do

  create_table "canvas_synchronization", force: true do |t|
    t.datetime "last_guest_user_sync"
    t.datetime "latest_term_enrollment_csv_set"
  end

  create_table "class_calendar_jobs", force: true do |t|
    t.datetime "process_start_time"
    t.datetime "process_end_time"
    t.integer  "total_entry_count"
    t.integer  "error_count"
  end

  create_table "class_calendar_log", force: true do |t|
    t.integer  "year"
    t.string   "term_cd"
    t.integer  "ccn"
    t.string   "multi_entry_cd"
    t.integer  "job_id"
    t.text     "event_data"
    t.string   "event_id"
    t.datetime "processed_at"
    t.string   "response_status"
    t.text     "response_body"
    t.boolean  "has_error"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "transaction_type", default: "C"
  end

  add_index "class_calendar_log", ["event_id"], name: "index_class_calendar_log_on_event_id"
  add_index "class_calendar_log", ["year", "term_cd", "ccn", "multi_entry_cd", "job_id"], name: "class_calendar_log_unique_index", unique: true, using: :btree

  create_table "class_calendar_queue", force: true do |t|
    t.integer  "year"
    t.string   "term_cd"
    t.integer  "ccn"
    t.string   "multi_entry_cd"
    t.text     "event_data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "event_id"
    t.string   "transaction_type", default: "C"
  end

  add_index "class_calendar_queue", ["year", "term_cd", "ccn", "multi_entry_cd"], name: "class_calendar_queue_unique_index", unique: true, using: :btree

  create_table "class_calendar_users", force: true do |t|
    t.string "uid"
    t.string "alternate_email"
  end

  create_table "fin_aid_years", force: true do |t|
    t.integer  "current_year",        null: false
    t.date     "upcoming_start_date", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fin_aid_years", ["current_year"], name: "index_fin_aid_years_on_current_year", unique: true

  create_table "link_categories", force: true do |t|
    t.string   "name",                       null: false
    t.string   "slug",                       null: false
    t.boolean  "root_level", default: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "link_categories_link_sections", id: false, force: true do |t|
    t.integer "link_category_id"
    t.integer "link_section_id"
  end

  create_table "link_sections", force: true do |t|
    t.integer  "link_root_cat_id"
    t.integer  "link_top_cat_id"
    t.integer  "link_sub_cat_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "link_sections_links", id: false, force: true do |t|
    t.integer "link_section_id"
    t.integer "link_id"
  end

  create_table "links", force: true do |t|
    t.string   "name"
    t.string   "url"
    t.string   "description"
    t.boolean  "published",   default: true
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "links_user_roles", id: false, force: true do |t|
    t.integer "link_id"
    t.integer "user_role_id"
  end

  create_table "notifications", force: true do |t|
    t.string   "uid"
    t.text     "data"
    t.text     "translator"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.datetime "occurred_at"
  end

  add_index "notifications", ["occurred_at"], name: "index_notifications_on_occurred_at"
  add_index "notifications", ["uid"], name: "index_notifications_on_uid"

  create_table "oauth2_data", force: true do |t|
    t.string  "uid"
    t.string  "app_id"
    t.text    "access_token"
    t.text    "refresh_token"
    t.integer "expiration_time", limit: 8
    t.text    "app_data"
  end

  add_index "oauth2_data", ["uid", "app_id"], name: "index_oauth2_data_on_uid_app_id", unique: true

  create_table "user_auths", force: true do |t|
    t.string   "uid",                          null: false
    t.boolean  "is_superuser", default: false, null: false
    t.boolean  "is_test_user", default: false, null: false
    t.boolean  "active",       default: false, null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "is_author",    default: false, null: false
    t.boolean  "is_viewer",    default: false, null: false
  end

  add_index "user_auths", ["uid"], name: "index_user_auths_on_uid", unique: true

  create_table "user_data", force: true do |t|
    t.string   "uid"
    t.string   "preferred_name"
    t.datetime "first_login_at"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "user_data", ["uid"], name: "index_user_data_on_uid", unique: true

  create_table "user_roles", force: true do |t|
    t.string "name"
    t.string "slug"
  end

  create_table "user_visits", id: false, force: true do |t|
    t.string   "uid",           null: false
    t.datetime "last_visit_at", null: false
  end

  add_index "user_visits", ["last_visit_at"], name: "index_user_visits_on_last_visit_at"
  add_index "user_visits", ["uid"], name: "index_user_visits_on_uid", unique: true

  create_table "user_whitelists", force: true do |t|
    t.string   "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "user_whitelists", ["uid"], name: "index_user_whitelists_on_uid", unique: true

end
