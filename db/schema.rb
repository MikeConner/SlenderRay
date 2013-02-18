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

ActiveRecord::Schema.define(:version => 20130207035758) do

  create_table "machines", :force => true do |t|
    t.string   "model",                 :limit => 64,                 :null => false
    t.string   "serial_number",         :limit => 64,                 :null => false
    t.date     "date_installed"
    t.integer  "treatment_facility_id"
    t.datetime "created_at",                                          :null => false
    t.datetime "updated_at",                                          :null => false
    t.string   "display_name",          :limit => 64, :default => "", :null => false
  end

  add_index "machines", ["treatment_facility_id", "display_name"], :name => "index_machines_on_treatment_facility_id_and_display_name", :unique => true

  create_table "machines_users", :id => false, :force => true do |t|
    t.integer "machine_id"
    t.integer "user_id"
  end

  add_index "machines_users", ["machine_id", "user_id"], :name => "index_machines_users_on_machine_id_and_user_id", :unique => true

  create_table "measurements", :force => true do |t|
    t.string   "location",             :limit => 16, :null => false
    t.decimal  "circumference",                      :null => false
    t.integer  "treatment_session_id"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.string   "label",                :limit => 16
  end

  create_table "patients", :force => true do |t|
    t.string   "name",                  :limit => 40
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.integer  "treatment_facility_id"
  end

  add_index "patients", ["treatment_facility_id", "name"], :name => "index_patients_on_treatment_facility_id_and_name", :unique => true

  create_table "process_timers", :force => true do |t|
    t.string   "process_state",    :limit => 16, :default => "Idle", :null => false
    t.datetime "start_time"
    t.integer  "elapsed_seconds"
    t.integer  "process_id"
    t.string   "process_type"
    t.datetime "created_at",                                         :null => false
    t.datetime "updated_at",                                         :null => false
    t.integer  "duration_seconds"
  end

  create_table "protocols", :force => true do |t|
    t.integer  "frequency",                :null => false
    t.string   "name",       :limit => 32
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  create_table "rails_admin_histories", :force => true do |t|
    t.text     "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      :limit => 2
    t.integer  "year",       :limit => 5
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], :name => "index_rails_admin_histories"

  create_table "roles", :force => true do |t|
    t.string   "name",       :limit => 16, :null => false
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "roles", ["name"], :name => "index_roles_on_name", :unique => true

  create_table "testimonials", :force => true do |t|
    t.text     "comment",                        :null => false
    t.date     "date_entered"
    t.boolean  "displayable",  :default => true
    t.integer  "patient_id"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  create_table "treatment_areas", :force => true do |t|
    t.string   "area_name",             :limit => 64, :null => false
    t.string   "process_name",          :limit => 64
    t.integer  "treatment_facility_id"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.integer  "duration_minutes"
  end

  add_index "treatment_areas", ["treatment_facility_id", "area_name"], :name => "index_treatment_areas_on_treatment_facility_id_and_area_name", :unique => true

  create_table "treatment_facilities", :force => true do |t|
    t.string   "facility_name", :limit => 50, :null => false
    t.string   "facility_url"
    t.string   "first_name",    :limit => 24
    t.string   "last_name",     :limit => 48
    t.string   "email",                       :null => false
    t.string   "phone",         :limit => 14
    t.string   "fax",           :limit => 14
    t.string   "address_1",     :limit => 50
    t.string   "address_2",     :limit => 50
    t.string   "city",          :limit => 50
    t.string   "state",         :limit => 2
    t.string   "zipcode",       :limit => 10
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  add_index "treatment_facilities", ["email"], :name => "index_treatment_facilities_on_email", :unique => true
  add_index "treatment_facilities", ["facility_name"], :name => "index_treatment_facilities_on_facility_name", :unique => true

  create_table "treatment_plan_templates", :force => true do |t|
    t.integer  "patient_id"
    t.integer  "num_sessions",           :null => false
    t.integer  "treatments_per_session", :null => false
    t.text     "description",            :null => false
    t.decimal  "price"
    t.string   "type"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.integer  "treatment_facility_id"
  end

  create_table "treatment_sessions", :force => true do |t|
    t.integer  "treatment_plan_id"
    t.string   "patient_image"
    t.text     "notes"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "machine_id"
    t.integer  "protocol_id"
  end

  create_table "users", :force => true do |t|
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
    t.integer  "role_id"
    t.integer  "machine_id"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.integer  "treatment_facility_id"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
