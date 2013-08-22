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

ActiveRecord::Schema.define(version: 20130821030632) do

  create_table "alerts", force: true do |t|
    t.text     "condition"
    t.string   "name"
    t.integer  "last_days"
    t.integer  "total"
    t.integer  "priority"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "message"
    t.text     "phone_contacts"
    t.text     "email_contacts"
  end

  create_table "backups", force: true do |t|
    t.integer  "entity_id"
    t.text     "data"
    t.string   "category"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "conflict_cases", force: true do |t|
    t.string   "case_message"
    t.integer  "location_id"
    t.integer  "site_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "reporter_id"
    t.boolean  "is_deleted",         default: false
    t.boolean  "is_updated",         default: false
    t.integer  "conflict_type"
    t.integer  "conflict_state"
    t.integer  "conflict_intensity"
  end

  add_index "conflict_cases", ["location_id"], name: "index_conflict_cases_on_location_id", using: :btree

  create_table "delayed_job_alerts", force: true do |t|
    t.integer  "delayed_job_id"
    t.integer  "alerts_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "locations", force: true do |t|
    t.string   "name"
    t.string   "code"
    t.decimal  "lat",        precision: 10, scale: 6
    t.decimal  "lng",        precision: 10, scale: 6
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_deleted",                          default: false
    t.boolean  "is_updated",                          default: false
  end

  create_table "messages", force: true do |t|
    t.string   "guid"
    t.string   "country"
    t.string   "carrier"
    t.string   "channel"
    t.string   "application"
    t.string   "from"
    t.string   "to"
    t.string   "subject"
    t.string   "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "reply"
  end

  create_table "reporters", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone_number"
    t.string   "sex"
    t.string   "address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cast_ethnicity"
    t.date     "date_of_birth"
  end

  create_table "roles", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "settings", force: true do |t|
    t.integer  "interval_alert"
    t.text     "message_success"
    t.text     "message_invalid"
    t.text     "message_unknown"
    t.text     "message_invalid_sender"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "username"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone_number"
    t.string   "sex"
    t.string   "address"
    t.string   "email"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "role_id"
    t.string   "encrypted_password"
    t.string   "cast_ethnicity"
    t.date     "date_of_birth"
  end

end
