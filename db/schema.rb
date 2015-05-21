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

ActiveRecord::Schema.define(version: 20150521163404) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "canvas_site_mailing_lists", force: true do |t|
    t.string   "canvas_site_id"
    t.string   "list_name"
    t.string   "state"
    t.datetime "populated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "members_count"
    t.integer  "populate_add_errors"
    t.integer  "populate_remove_errors"
  end

  add_index "canvas_site_mailing_lists", ["canvas_site_id"], name: "index_canvas_site_mailing_lists_on_canvas_site_id", unique: true, using: :btree

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
    t.string   "transaction_type"
  end

  add_index "class_calendar_log", ["event_id"], name: "index_class_calendar_log_on_event_id", using: :btree
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
    t.string   "transaction_type"
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

  add_index "fin_aid_years", ["current_year"], name: "index_fin_aid_years_on_current_year", unique: true, using: :btree

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

  add_index "notifications", ["occurred_at"], name: "index_notifications_on_occurred_at", using: :btree
  add_index "notifications", ["uid"], name: "index_notifications_on_uid", using: :btree

  create_table "oauth2_data", force: true do |t|
    t.string  "uid"
    t.string  "app_id"
    t.text    "access_token"
    t.text    "refresh_token"
    t.integer "expiration_time", limit: 8
    t.text    "app_data"
  end

  add_index "oauth2_data", ["uid", "app_id"], name: "index_oauth2_data_on_uid_app_id", unique: true, using: :btree

  create_table "recent_uids", force: true do |t|
    t.string   "owner_id"
    t.string   "stored_uid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "recent_uids", ["owner_id"], name: "recent_uids_index", using: :btree

  create_table "saved_uids", force: true do |t|
    t.string   "owner_id"
    t.string   "stored_uid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "saved_uids", ["owner_id"], name: "saved_uids_index", using: :btree

  create_table "schema_migrations_backup", id: false, force: true do |t|
    t.string "version"
  end

  create_table "schema_migrations_fixed_backup", id: false, force: true do |t|
    t.string "version"
  end

  create_table "summer_sub_terms", force: true do |t|
    t.integer  "year",          null: false
    t.integer  "sub_term_code", null: false
    t.date     "start",         null: false
    t.date     "end",           null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "summer_sub_terms", ["year", "sub_term_code"], name: "index_summer_sub_terms_on_year_and_sub_term_code", using: :btree

  create_table "user_auths", force: true do |t|
    t.string   "uid",                          null: false
    t.boolean  "is_superuser", default: false, null: false
    t.boolean  "active",       default: false, null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "is_author",    default: false, null: false
    t.boolean  "is_viewer",    default: false, null: false
  end

  add_index "user_auths", ["uid"], name: "index_user_auths_on_uid", unique: true, using: :btree

  create_table "user_data", force: true do |t|
    t.string   "uid"
    t.string   "preferred_name"
    t.datetime "first_login_at"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "user_data", ["uid"], name: "index_user_data_on_uid", unique: true, using: :btree

  create_table "user_roles", force: true do |t|
    t.string "name"
    t.string "slug"
  end

  create_table "user_visits", id: false, force: true do |t|
    t.string   "uid",           null: false
    t.datetime "last_visit_at", null: false
  end

  add_index "user_visits", ["last_visit_at"], name: "index_user_visits_on_last_visit_at", using: :btree
  add_index "user_visits", ["uid"], name: "index_user_visits_on_uid", unique: true, using: :btree

  create_table "webcast_course_site_log", force: true do |t|
    t.integer  "canvas_course_site_id",    null: false
    t.datetime "webcast_tool_unhidden_at", null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "webcast_course_site_log", ["canvas_course_site_id"], name: "webcast_course_site_log_unique_index", unique: true, using: :btree

end
