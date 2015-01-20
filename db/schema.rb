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

ActiveRecord::Schema.define(version: 20150120153118) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "appointment_feedbacks", force: true do |t|
    t.integer  "appointment_id",       null: false
    t.integer  "feedback_giver_id",    null: false
    t.integer  "feedback_receiver_id", null: false
    t.text     "text",                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "appointment_requests", force: true do |t|
    t.integer  "availability_id"
    t.integer  "mentee_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "appointments", force: true do |t|
    t.integer  "mentor_id"
    t.integer  "mentee_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "timezone"
    t.string   "location"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "city"
    t.boolean  "feedback_sent", default: false
  end

  create_table "availabilities", force: true do |t|
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "mentor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "timezone"
    t.string   "location"
    t.string   "city"
    t.integer  "appointment_id"
  end

  add_index "availabilities", ["appointment_id"], name: "index_availabilities_on_appointment_id", using: :btree

  create_table "kudos", force: true do |t|
    t.integer  "appointment_id"
    t.integer  "mentor_id"
    t.integer  "mentee_id"
    t.integer  "points"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "activation_code"
    t.boolean  "activated"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "twitter_handle"
    t.text     "bio"
    t.string   "interests"
    t.string   "gravatar_url"
    t.integer  "total_kudos",       default: 0
    t.integer  "total_given_kudos", default: 0
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

end
