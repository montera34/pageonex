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

ActiveRecord::Schema.define(:version => 20130309271421) do

  create_table "areas", :force => true do |t|
    t.integer  "x1"
    t.integer  "y1"
    t.integer  "x2"
    t.integer  "y2"
    t.integer  "highlighted_area_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.integer  "width"
    t.integer  "height"
  end

  create_table "coded_pages", :force => true do |t|
    t.integer  "threadx_id"
    t.integer  "user_id"
    t.integer  "image_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "codes", :force => true do |t|
    t.string   "code_text"
    t.integer  "threadx_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.text     "code_description"
    t.string   "color"
  end

  create_table "highlighted_areas", :force => true do |t|
    t.integer  "image_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "name"
    t.integer  "code_id"
  end

  create_table "images", :force => true do |t|
    t.date     "publication_date"
    t.string   "size"
    t.string   "local_path"
    t.integer  "media_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "image_name"
  end

  create_table "media", :force => true do |t|
    t.string   "name"
    t.string   "country"
    t.string   "country_code"
    t.string   "url"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "display_name"
  end

  create_table "media_threadxes", :force => true do |t|
    t.integer  "threadx_id"
    t.integer  "media_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "threadx_collaborators", :force => true do |t|
    t.integer  "threadx_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "threadxes", :force => true do |t|
    t.string   "thread_name"
    t.string   "thread_display_name"
    t.date     "start_date"
    t.date     "end_date"
    t.text     "description"
    t.string   "category"
    t.string   "status"
    t.integer  "owner_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "username",               :default => "", :null => false
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
