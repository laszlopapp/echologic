# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110228183745) do

  create_table "about_item_translations", :force => true do |t|
    t.integer "about_item_id"
    t.string  "locale"
    t.string  "responsibility"
    t.text    "description"
    t.string  "name"
  end

  create_table "about_items", :force => true do |t|
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.string   "name"
    t.string   "responsibility"
    t.text     "description"
    t.integer  "about_category_id"
    t.integer  "index"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "admin_mailers", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "drafting_infos", :force => true do |t|
    t.integer  "statement_node_id"
    t.datetime "state_since",       :default => '2010-08-26 18:50:17'
    t.integer  "times_passed",      :default => 0
  end

  create_table "echos", :force => true do |t|
    t.integer "visitor_count",   :default => 0
    t.integer "supporter_count", :default => 0
  end

  create_table "enum_keys", :force => true do |t|
    t.string  "code"
    t.string  "type"
    t.string  "description"
    t.integer "key"
  end

  add_index "enum_keys", ["code", "id"], :name => "index_enum_keys_on_code_and_id"
  add_index "enum_keys", ["code", "type", "id"], :name => "index_enum_keys_on_code_and_enum_name_and_id"
  add_index "enum_keys", ["type", "id"], :name => "index_enum_keys_on_enum_name_and_id"

  create_table "enum_values", :force => true do |t|
    t.integer "enum_key_id"
    t.string  "context"
    t.string  "value"
    t.string  "code"
  end

  add_index "enum_values", ["enum_key_id", "code", "id"], :name => "idx_enum_values_enum_key_code_pk"

  create_table "events", :force => true do |t|
    t.text     "event"
    t.integer  "subscribeable_id"
    t.string   "subscribeable_type"
    t.string   "operation"
    t.datetime "created_at"
  end

  add_index "events", ["subscribeable_id", "subscribeable_type", "created_at"], :name => "events_index"

  create_table "feedbacks", :force => true do |t|
    t.string "name"
    t.string "email"
    t.string "message"
  end

  create_table "locales", :force => true do |t|
    t.string "code"
    t.string "name"
  end

  add_index "locales", ["code"], :name => "index_locales_on_code"

  create_table "memberships", :force => true do |t|
    t.integer  "user_id"
    t.string   "organisation"
    t.string   "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "memberships", ["user_id", "id"], :name => "index_memberships_on_user_id_and_id"

  create_table "newsletter_translations", :force => true do |t|
    t.integer "newsletter_id"
    t.string  "locale"
    t.string  "subject"
    t.text    "text"
  end

  create_table "newsletters", :force => true do |t|
    t.string   "subject"
    t.text     "text"
    t.boolean  "default_greeting", :default => true
    t.boolean  "default_goodbye",  :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pending_actions", :id => false, :force => true do |t|
    t.string   "uuid",       :limit => 36
    t.text     "action"
    t.boolean  "status",                   :default => false, :null => false
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "profiles", :force => true do |t|
    t.boolean  "female"
    t.string   "city"
    t.string   "country"
    t.text     "about_me"
    t.text     "motivation"
    t.date     "birthday"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.float    "completeness",        :default => 0.01
    t.string   "avatar_remote_url"
    t.string   "full_name"
  end

  add_index "profiles", ["user_id", "id"], :name => "index_profiles_on_user_id_and_id"

  create_table "reports", :force => true do |t|
    t.integer  "reporter_id"
    t.integer  "suspect_id"
    t.text     "reason"
    t.boolean  "done",        :default => false
    t.text     "decision"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "name",              :limit => 40
    t.string   "authorizable_type", :limit => 40
    t.integer  "authorizable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "social_identifiers", :force => true do |t|
    t.string   "identifier",    :null => false
    t.string   "provider_name"
    t.text     "profile_info"
    t.integer  "user_id",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "social_identifiers", ["identifier"], :name => "index_social_identifiers_on_identifier", :unique => true
  add_index "social_identifiers", ["user_id"], :name => "index_social_identifiers_on_user_id"

  create_table "spoken_languages", :force => true do |t|
    t.integer "user_id"
    t.integer "language_id"
    t.integer "level_id"
  end

  add_index "spoken_languages", ["user_id", "level_id"], :name => "index_spoken_languages_on_user_id_and_level_id"

  create_table "statement_documents", :force => true do |t|
    t.string   "title"
    t.text     "text"
    t.integer  "language_id"
    t.integer  "statement_id"
    t.integer  "current"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "locked_by"
    t.datetime "locked_at"
  end

  add_index "statement_documents", ["language_id"], :name => "index_statement_documents_on_language_id"
  add_index "statement_documents", ["statement_id", "id"], :name => "index_statement_documents_on_statement_id_and_id"

  create_table "statement_histories", :force => true do |t|
    t.integer  "statement_document_id"
    t.integer  "statement_id"
    t.integer  "author_id"
    t.integer  "action_id"
    t.integer  "old_document_id"
    t.integer  "incorporated_node_id"
    t.string   "comment"
    t.datetime "created_at"
  end

  create_table "statement_images", :force => true do |t|
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  create_table "statement_nodes", :force => true do |t|
    t.string   "type"
    t.integer  "parent_id"
    t.integer  "root_id"
    t.integer  "creator_id"
    t.integer  "echo_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "statement_id"
    t.string   "drafting_state", :limit => 20
    t.integer  "lft"
    t.integer  "rgt"
    t.integer  "question_id"
  end

  add_index "statement_nodes", ["creator_id"], :name => "index_statement_nodes_on_creator_id"
  add_index "statement_nodes", ["echo_id", "id"], :name => "index_statement_nodes_on_echo_id_and_id"
  add_index "statement_nodes", ["id", "statement_id"], :name => "index_statement_nodes_on_id_and_statement_id"
  add_index "statement_nodes", ["type"], :name => "index_statement_nodes_on_type"

  create_table "statements", :force => true do |t|
    t.integer "original_language_id"
    t.integer "statement_image_id"
    t.integer "editorial_state_id"
  end

  create_table "subscriptions", :force => true do |t|
    t.integer  "subscriber_id"
    t.string   "subscriber_type"
    t.integer  "subscribeable_id"
    t.string   "subscribeable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subscriptions", ["subscribeable_id", "subscriber_id", "subscribeable_type"], :name => "subscriptions_index"

  create_table "tags", :force => true do |t|
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "language_id"
  end

  create_table "tao_tags", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "tao_id"
    t.string   "tao_type"
    t.string   "context_id"
    t.datetime "created_at"
  end

  add_index "tao_tags", ["tag_id"], :name => "index_tao_tags_on_tag_id"
  add_index "tao_tags", ["tao_id", "tao_type", "context_id"], :name => "index_tao_tags_on_tao_id_and_tao_type_and_context_id"

  create_table "translations", :force => true do |t|
    t.string  "key"
    t.string  "raw_key"
    t.text    "value"
    t.integer "pluralization_index", :default => 1
    t.integer "locale_id"
  end

  add_index "translations", ["locale_id", "key", "pluralization_index"], :name => "index_translations_on_locale_id_and_key_and_pluralization_index"
  add_index "translations", ["locale_id", "raw_key"], :name => "index_translations_on_locale_id_and_raw_key"

  create_table "user_echos", :force => true do |t|
    t.integer "echo_id"
    t.integer "user_id"
    t.boolean "visited",   :default => false
    t.boolean "supported", :default => false
  end

  add_index "user_echos", ["echo_id"], :name => "index_echo_details_on_echo_id"
  add_index "user_echos", ["user_id"], :name => "index_echo_details_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token",                          :null => false
    t.string   "perishable_token",                           :null => false
    t.integer  "login_count",             :default => 0,     :null => false
    t.integer  "failed_login_count",      :default => 0,     :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",                  :default => false, :null => false
    t.integer  "last_login_language_id"
    t.integer  "activity_notification",   :default => 1
    t.integer  "drafting_notification",   :default => 1
    t.integer  "newsletter_notification", :default => 1
    t.integer  "authorship_permission",   :default => 1
  end

  add_index "users", ["email"], :name => "index_users_on_email"

  create_table "valid_contexts", :force => true do |t|
    t.integer "context_id"
    t.string  "tao_type"
  end

  create_table "web_addresses", :force => true do |t|
    t.integer  "user_id"
    t.string   "address"
    t.integer  "sort"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "type_id"
  end

  add_index "web_addresses", ["user_id"], :name => "index_web_profiles_on_user_id"

end
