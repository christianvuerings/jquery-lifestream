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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 2013042909416600) do

  create_table "notifications", :force => true do |t|
    t.string   "uid"
    t.text     "data"
    t.text     "translator"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.datetime "occurred_at"
  end

  add_index "notifications", ["occurred_at"], :name => "index_notifications_on_occurred_at"
  add_index "notifications", ["uid"], :name => "index_notifications_on_uid"

  create_table "oauth2_data", :force => true do |t|
    t.string  "uid"
    t.string  "app_id"
    t.text    "access_token"
    t.text    "refresh_token"
    t.integer "expiration_time", :limit => 8
    t.text    "app_data"
  end

  add_index "oauth2_data", ["uid", "app_id"], :name => "index_oauth2_data_on_uid_app_id", :unique => true

  create_table "user_auths", :force => true do |t|
    t.string   "uid",                             :null => false
    t.boolean  "is_superuser", :default => false, :null => false
    t.boolean  "is_test_user", :default => false, :null => false
    t.boolean  "active",       :default => false, :null => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "user_auths", ["uid"], :name => "index_user_auths_on_uid", :unique => true

  create_table "user_data", :force => true do |t|
    t.string   "uid"
    t.string   "preferred_name"
    t.datetime "first_login_at"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "user_data", ["uid"], :name => "index_user_data_on_uid", :unique => true

  create_table "user_visits", :id => false, :force => true do |t|
    t.string   "uid",           :null => false
    t.datetime "last_visit_at", :null => false
  end

  add_index "user_visits", ["last_visit_at"], :name => "index_user_visits_on_last_visit_at"
  add_index "user_visits", ["uid"], :name => "index_user_visits_on_uid", :unique => true

end
