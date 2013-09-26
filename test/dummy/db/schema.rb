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

ActiveRecord::Schema.define(:version => 20130926103349) do

  create_table "results", :force => true do |t|
    t.string   "name"
    t.integer  "depth"
    t.integer  "run_id"
    t.string   "filetype"
    t.string   "filepath"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "runs", :force => true do |t|
    t.string   "run_identification"
    t.string   "state"
    t.datetime "creation"
    t.datetime "start"
    t.datetime "end"
    t.datetime "expiry"
    t.integer  "workflow_id"
    t.string   "description"
    t.integer  "user_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "taverna_lite_alternative_components", :force => true do |t|
    t.integer  "component_id"
    t.integer  "alternative_id"
    t.string   "note"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "taverna_lite_port_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "taverna_lite_workflow_components", :force => true do |t|
    t.integer  "workflow_id"
    t.integer  "license_id"
    t.integer  "version"
    t.string   "family"
    t.string   "name"
    t.string   "registry"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "taverna_lite_workflow_errors", :force => true do |t|
    t.integer  "workflow_id"
    t.string   "error_code"
    t.string   "name"
    t.string   "pattern"
    t.string   "message"
    t.integer  "run_count"
    t.integer  "port_count"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "taverna_lite_workflow_ports", :force => true do |t|
    t.integer  "workflow_id"
    t.integer  "port_type_id"
    t.string   "name"
    t.string   "display_name"
    t.text     "description"
    t.text     "display_description"
    t.integer  "order"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.integer  "display_control_id"
    t.string   "sample_value"
    t.string   "sample_file"
    t.string   "sample_file_type"
    t.boolean  "show"
  end

  create_table "taverna_lite_workflow_profiles", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created"
    t.datetime "modified"
    t.integer  "license_id"
    t.integer  "author_id"
    t.integer  "version"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "workflow_id"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "workflows", :force => true do |t|
    t.string   "title"
    t.string   "author"
    t.text     "description"
    t.string   "name"
    t.string   "workflow_file"
    t.integer  "my_experiment_id"
    t.integer  "user_id"
    t.boolean  "is_shared"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

end
