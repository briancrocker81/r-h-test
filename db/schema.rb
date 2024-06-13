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

ActiveRecord::Schema.define(version: 2024_04_29_130617) do

  create_table "active_storage_attachments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "additional_tenants", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.string "first_name"
    t.string "surname"
    t.string "phone_number"
    t.text "address"
    t.string "email"
    t.string "signature"
    t.date "signed_date"
    t.boolean "accept_agreement"
    t.bigint "tenancy_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenancy_id"], name: "index_additional_tenants_on_tenancy_id"
  end

  create_table "admin_variables", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.boolean "rightmove", default: false
    t.boolean "zoopla", default: false
    t.boolean "onthemarket", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["onthemarket"], name: "index_admin_variables_on_onthemarket"
    t.index ["rightmove"], name: "index_admin_variables_on_rightmove"
    t.index ["zoopla"], name: "index_admin_variables_on_zoopla"
  end

  create_table "attachments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.string "title"
    t.integer "attached_item_id"
    t.string "attached_item_type"
    t.string "attachment", null: false
    t.string "original_filename"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "alt_tag"
    t.index ["alt_tag"], name: "index_attachments_on_alt_tag"
    t.index ["attached_item_type", "attached_item_id"], name: "index_attachments_on_attached_item_type_and_attached_item_id"
  end

  create_table "companies", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.string "name"
    t.text "address"
    t.string "phone_number"
    t.string "main_email"
    t.string "bank_account_name"
    t.string "bank_name"
    t.text "bank_address"
    t.string "bank_sort_code"
    t.string "bank_account_number"
    t.string "bank_iban"
    t.string "bank_bic"
    t.string "vat_number"
    t.string "registration_number"
    t.string "main_contact"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "bank_payment_reference"
  end

  create_table "company_details", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.string "phone_number"
    t.string "email"
    t.string "main_contact_name"
    t.string "vat_number"
    t.string "registration_number"
    t.string "bank"
    t.string "bank_account_number"
    t.string "bank_sort_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "compliance_documents", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.string "document_name"
    t.string "document_file"
    t.date "document_expiry"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "property_id"
    t.integer "generic_document_id"
    t.index ["generic_document_id"], name: "index_compliance_documents_on_generic_document_id"
    t.index ["property_id"], name: "index_compliance_documents_on_property_id"
  end

  create_table "conversations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.bigint "property_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["property_id"], name: "index_conversations_on_property_id"
  end

  create_table "criminal_records", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.string "conviction_status"
    t.string "offence"
    t.date "date"
    t.string "judgement"
    t.bigint "tenancy_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenancy_id"], name: "index_criminal_records_on_tenancy_id"
  end

  create_table "crono_jobs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.string "job_id", null: false
    t.text "log", limit: 4294967295
    t.datetime "last_performed_at"
    t.boolean "healthy"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_crono_jobs_on_job_id", unique: true
  end

  create_table "custom_property_reports", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.date "start_date"
    t.date "end_date"
    t.integer "run_by_id"
    t.string "year"
    t.integer "month"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["run_by_id"], name: "index_custom_property_reports_on_run_by_id"
  end

  create_table "email_templates", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.string "template_name"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "event_users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "event_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_event_users_on_event_id"
    t.index ["user_id"], name: "index_event_users_on_user_id"
  end

  create_table "events", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.datetime "start"
    t.datetime "end"
    t.integer "event_type"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "client_name"
    t.string "client_contact_number"
    t.string "budget_per_week"
    t.string "client_email"
    t.string "client_required_bedrooms"
    t.integer "viewing_type", limit: 2
    t.boolean "client_confirmation", default: false
    t.boolean "mail_sent", default: false
    t.datetime "mail_sent_at"
    t.string "budget_per_month"
    t.boolean "confirmed", default: false
    t.text "tenancy_ids"
    t.string "event_title"
    t.string "appointment_info"
  end

  create_table "events_properties", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.bigint "property_id", null: false
    t.index ["event_id", "property_id"], name: "index_events_properties_on_event_id_and_property_id"
  end

  create_table "features", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.string "feature"
    t.bigint "property_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["property_id"], name: "index_features_on_property_id"
  end

  create_table "generic_documents", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.string "document_name"
    t.string "document_file"
    t.date "document_expiry"
    t.boolean "active"
    t.bigint "admin_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_generic_documents_on_active"
    t.index ["admin_id"], name: "index_generic_documents_on_admin_id"
  end

  create_table "guarantors", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.string "guarantor_name"
    t.text "guarantor_address"
    t.string "guarantor_post_code"
    t.string "guarantor_email"
    t.string "guarantor_mobile"
    t.string "guarantor_relationship"
    t.bigint "tenancy_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "own_property", default: false
    t.string "national_insurance_number"
    t.string "contact_number"
    t.date "date_of_birth"
    t.string "tenant_relationship"
    t.integer "employment_status"
    t.string "employer_name"
    t.string "employer_manager"
    t.string "employer_contact"
    t.text "employer_address"
    t.string "employer_email"
    t.string "job_title"
    t.string "net_salary"
    t.string "guarantor_signature"
    t.date "guarantor_signature_date"
    t.string "photo_id"
    t.string "utility_bill"
    t.text "uri_string"
    t.boolean "confirm_guarantor", default: false
    t.boolean "confirm_signed_tenancy", default: false
    t.boolean "complete_guarantor_agreement", default: false
    t.index ["tenancy_id"], name: "index_guarantors_on_tenancy_id"
  end

  create_table "landlord_documents", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.string "document_name"
    t.string "document_file"
    t.boolean "active", default: true
    t.bigint "landlord_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["landlord_id"], name: "index_landlord_documents_on_landlord_id"
  end

  create_table "landlord_staff_conversations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.bigint "landlord_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["landlord_id"], name: "index_landlord_staff_conversations_on_landlord_id"
  end

  create_table "landlord_staff_messages", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.text "body"
    t.text "subject"
    t.string "from"
    t.bigint "landlord_staff_conversation_id"
    t.integer "sender_id"
    t.integer "receiver_id"
    t.boolean "read", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "sender_type"
    t.string "receiver_type"
    t.index ["landlord_staff_conversation_id"], name: "index_landlord_staff_messages_on_landlord_staff_conversation_id"
  end

  create_table "landlord_statement_reports", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.integer "landlord_id"
    t.integer "property_id"
    t.boolean "mail_sent", default: false
    t.string "statement_report"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "mail_sent_at"
    t.string "year"
    t.integer "statement_type", default: 0
    t.index ["landlord_id"], name: "index_landlord_statement_reports_on_landlord_id"
    t.index ["mail_sent"], name: "index_landlord_statement_reports_on_mail_sent"
    t.index ["mail_sent_at"], name: "index_landlord_statement_reports_on_mail_sent_at"
    t.index ["property_id"], name: "index_landlord_statement_reports_on_property_id"
    t.index ["statement_type"], name: "index_landlord_statement_reports_on_statement_type"
    t.index ["year"], name: "index_landlord_statement_reports_on_year"
  end

  create_table "landlords", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.string "contact_number"
    t.string "alternate_number"
    t.string "email"
    t.text "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "contact_name"
    t.boolean "landlord_type"
    t.string "company_name"
    t.text "notes"
    t.integer "partnership_format"
    t.string "rate"
    t.string "account_name"
    t.string "bank_name"
    t.text "bank_address"
    t.string "bank_sort_code"
    t.string "bank_account_number"
    t.string "fee"
    t.string "alternate_name"
    t.string "alternate_email"
    t.string "bic"
    t.string "iban"
    t.boolean "pay_direct"
    t.string "landlord_signature"
    t.date "landlord_signature_date"
    t.boolean "send_report"
  end

  create_table "manage_automation_mails", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.string "mail_type"
    t.text "mail_methods"
    t.boolean "automation", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["automation"], name: "index_manage_automation_mails_on_automation"
    t.index ["mail_type"], name: "index_manage_automation_mails_on_mail_type"
  end

  create_table "messages", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.text "body"
    t.bigint "conversation_id"
    t.integer "sender_id"
    t.integer "receiver_id"
    t.boolean "read", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
  end

  create_table "professional_details", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.string "working_at"
    t.string "job_title"
    t.integer "tenancy_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "salary"
    t.integer "salary_type"
    t.integer "employment_type"
    t.boolean "receive_benefits"
    t.text "benefit_details"
    t.index ["tenancy_id"], name: "index_professional_details_on_tenancy_id"
  end

  create_table "properties", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.string "number"
    t.string "street"
    t.string "address_line_2"
    t.string "city"
    t.string "county"
    t.string "postcode", limit: 8
    t.integer "number_of_bedrooms"
    t.string "property_type"
    t.string "listing_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "rental_type"
    t.integer "number_of_bathrooms"
    t.boolean "pets"
    t.decimal "home_rental_price", precision: 10, default: "0"
    t.bigint "landlord_id"
    t.string "style"
    t.boolean "list_on_website"
    t.integer "number_of_kitchens"
    t.integer "number_of_gardens"
    t.integer "number_of_lounges"
    t.integer "number_of_studies"
    t.integer "number_of_dining_rooms"
    t.integer "number_of_utility_rooms"
    t.integer "number_of_toilets"
    t.integer "number_of_studio_apartments"
    t.integer "number_of_showers"
    t.text "other"
    t.integer "parking"
    t.integer "outside_space"
    t.integer "ensuite"
    t.decimal "room_rental_price", precision: 10, default: "0"
    t.boolean "right_move", default: false
    t.boolean "on_the_market", default: false
    t.boolean "zoopla", default: false
    t.string "listing_etag"
    t.string "council_tax_band", limit: 1
    t.boolean "list_on_3rd_party_websites"
    t.string "epc_rating", limit: 1
    t.integer "furnished", default: 2
    t.integer "status", default: 0
    t.integer "property_status_type"
    t.index ["landlord_id"], name: "index_properties_on_landlord_id"
    t.index ["on_the_market"], name: "index_properties_on_on_the_market"
    t.index ["right_move"], name: "index_properties_on_right_move"
    t.index ["zoopla"], name: "index_properties_on_zoopla"
  end

  create_table "property_expenses", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.integer "property_id"
    t.integer "number_of_months"
    t.integer "category"
    t.string "year"
    t.string "name"
    t.string "file"
    t.decimal "amount", precision: 10, default: "0"
    t.boolean "recurring", default: false
    t.date "expense_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0
    t.index ["expense_date"], name: "index_property_expenses_on_expense_date"
    t.index ["property_id"], name: "index_property_expenses_on_property_id"
    t.index ["status"], name: "index_property_expenses_on_status"
    t.index ["year"], name: "index_property_expenses_on_year"
  end

  create_table "property_list_families", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.bigint "property_id"
    t.text "description"
    t.string "location"
    t.string "school"
    t.text "nearest_park_and_play_area"
    t.text "area_family_location"
    t.string "front_photo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "additional_features_1"
    t.string "additional_features_2"
    t.string "additional_features_3"
    t.string "additional_features_4"
    t.string "additional_features_5"
    t.string "additional_features_6"
    t.decimal "list_price", precision: 8, scale: 2
    t.date "let_available_date"
    t.decimal "deposit", precision: 6, scale: 2
    t.integer "minimum_term"
    t.boolean "list_weekly"
    t.boolean "list_monthly", default: true, null: false
    t.index ["property_id"], name: "index_property_list_families_on_property_id"
  end

  create_table "property_list_graduates", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.bigint "property_id"
    t.text "description"
    t.string "location"
    t.boolean "student_allowed", default: true
    t.string "front_photo"
    t.text "bus_route"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "additional_features_1"
    t.string "additional_features_2"
    t.string "additional_features_3"
    t.string "additional_features_4"
    t.string "additional_features_5"
    t.string "additional_features_6"
    t.decimal "list_price", precision: 8, scale: 2
    t.date "let_available_date"
    t.decimal "deposit", precision: 6, scale: 2
    t.integer "minimum_term"
    t.boolean "list_weekly"
    t.boolean "list_monthly", default: true, null: false
    t.index ["property_id"], name: "index_property_list_graduates_on_property_id"
  end

  create_table "property_list_professionals", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.bigint "property_id"
    t.text "description"
    t.string "location"
    t.text "bus_route"
    t.string "front_photo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "additional_features_1"
    t.string "additional_features_2"
    t.string "additional_features_3"
    t.string "additional_features_4"
    t.string "additional_features_5"
    t.string "additional_features_6"
    t.boolean "council_tax_included"
    t.decimal "list_price", precision: 8, scale: 2
    t.date "let_available_date"
    t.decimal "deposit", precision: 6, scale: 2
    t.integer "minimum_term"
    t.boolean "list_weekly"
    t.boolean "list_monthly", default: true, null: false
    t.index ["property_id"], name: "index_property_list_professionals_on_property_id"
  end

  create_table "property_list_students", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.bigint "property_id"
    t.text "description"
    t.string "location"
    t.string "college"
    t.string "style"
    t.boolean "pet_passport_allowed"
    t.integer "walk_to_city_campus"
    t.string "front_photo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "additional_features_1"
    t.string "additional_features_2"
    t.string "additional_features_3"
    t.string "additional_features_4"
    t.string "additional_features_5"
    t.string "additional_features_6"
    t.decimal "list_price", precision: 8, scale: 2
    t.date "let_available_date"
    t.decimal "deposit", precision: 6, scale: 2
    t.integer "minimum_term"
    t.boolean "list_weekly", default: true, null: false
    t.boolean "list_monthly"
    t.index ["property_id"], name: "index_property_list_students_on_property_id"
  end

  create_table "property_listing_locations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.integer "listing_type"
    t.string "year"
    t.bigint "property_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["property_id"], name: "index_property_listing_locations_on_property_id"
    t.index ["user_id"], name: "index_property_listing_locations_on_user_id"
  end

  create_table "property_reports", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.integer "report_type", default: 0
    t.integer "run_by"
    t.string "year"
    t.string "report"
    t.boolean "mail_sent", default: false
    t.datetime "mail_sent_at"
    t.datetime "start_run_at"
    t.datetime "end_run_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["end_run_at"], name: "index_property_reports_on_end_run_at"
    t.index ["mail_sent"], name: "index_property_reports_on_mail_sent"
    t.index ["report_type"], name: "index_property_reports_on_report_type"
    t.index ["run_by"], name: "index_property_reports_on_run_by"
    t.index ["start_run_at"], name: "index_property_reports_on_start_run_at"
    t.index ["year"], name: "index_property_reports_on_year"
  end

  create_table "property_utilities", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.string "utility_name"
    t.boolean "included"
    t.decimal "landlord_contribution", precision: 6, scale: 2
    t.string "frequency"
    t.bigint "property_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["property_id"], name: "index_property_utilities_on_property_id"
  end

  create_table "reports", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.integer "landlord_id"
    t.integer "property_id"
    t.integer "term_type"
    t.integer "report_type"
    t.integer "month"
    t.string "report"
    t.string "year"
    t.datetime "mail_sent_at"
    t.boolean "mail_sent", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["landlord_id"], name: "index_reports_on_landlord_id"
    t.index ["mail_sent"], name: "index_reports_on_mail_sent"
    t.index ["month"], name: "index_reports_on_month"
    t.index ["property_id"], name: "index_reports_on_property_id"
    t.index ["report_type"], name: "index_reports_on_report_type"
    t.index ["term_type"], name: "index_reports_on_term_type"
    t.index ["year"], name: "index_reports_on_year"
  end

  create_table "rooms", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.string "number"
    t.text "description"
    t.decimal "list_price", precision: 10
    t.string "dimensions"
    t.bigint "property_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "ensuite"
    t.boolean "availability", default: true
    t.string "agent_ref"
    t.text "rightmove_response"
    t.text "zoopla_response"
    t.text "on_the_market_response"
    t.index ["property_id"], name: "index_rooms_on_property_id"
  end

  create_table "student_course_details", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.string "studying_at"
    t.string "student_id_number"
    t.string "course"
    t.bigint "tenancy_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "course_start"
    t.date "course_end"
    t.index ["tenancy_id"], name: "index_student_course_details_on_tenancy_id"
  end

  create_table "system_content_data_categories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.string "category"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tenancies", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.date "tenancy_start"
    t.date "tenancy_end"
    t.string "first_name"
    t.string "surname"
    t.date "dob"
    t.string "mobile"
    t.string "email"
    t.string "nationality"
    t.boolean "criminal_record"
    t.boolean "accept_agreement"
    t.string "year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "uri_string"
    t.boolean "form_submitted", default: false
    t.boolean "signed_tenancy_agreement", default: false
    t.boolean "read_doc", default: false
    t.text "address"
    t.string "state"
    t.string "city"
    t.string "post_code"
    t.string "signature"
    t.datetime "signed_date_time"
    t.boolean "final_submission", default: false
    t.integer "tenant_type"
    t.bigint "room_id"
    t.boolean "is_guarantor_available"
    t.string "deposit_term"
    t.boolean "dashboard_link_mail", default: false
    t.boolean "dashboard_link_visited", default: false
    t.datetime "dashboard_link_mail_at"
    t.integer "dashboard_link_mail_number_of_time"
    t.string "emergency_contact_name"
    t.string "emergency_contact_number"
    t.decimal "advanced_rent_payment_amount", precision: 10
    t.date "advanced_rent_payment_date"
    t.string "payment_card_pan"
    t.date "payment_card_expiry"
    t.string "payment_card_cvc"
    t.string "payment_status", default: "unpaid"
    t.integer "number_of_weeks"
    t.integer "number_of_months"
    t.decimal "weekly_price", precision: 10
    t.decimal "monthly_price", precision: 10
    t.text "emergency_contact_address"
    t.string "emergency_contact_postcode"
    t.string "rent_payment_option"
    t.text "special_conditions"
    t.date "deposit_date"
    t.decimal "deposit_guarantor_amount", precision: 10
    t.boolean "confirm_tenancy"
    t.boolean "archived", default: false
    t.boolean "roll_into_next_year", default: false
    t.integer "booking_status", default: 0
    t.date "rent_due_date"
    t.integer "rent_installment_term", default: 0
    t.string "total_tenancy_value"
    t.integer "number_of_payments"
    t.decimal "payment_amount", precision: 10
    t.boolean "deposit_paid"
    t.boolean "deposit_protected"
    t.boolean "prescribed_info_sent"
    t.datetime "failed_to_book_at"
    t.string "tenancy_agreement_signature"
    t.datetime "final_submission_at"
    t.date "signed_date"
    t.boolean "confirmed_video_viewed"
    t.decimal "initial_payment", precision: 8, scale: 2
    t.date "initial_payment_date"
    t.boolean "initial_payment_paid"
    t.integer "tenancy_is"
    t.index ["booking_status"], name: "index_tenancies_on_booking_status"
    t.index ["roll_into_next_year"], name: "index_tenancies_on_roll_into_next_year"
    t.index ["room_id"], name: "index_tenancies_on_room_id"
  end

  create_table "tenancy_complete_email_notifications", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tenancy_documents", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.string "document_name"
    t.string "document_file"
    t.bigint "tenancy_id"
    t.boolean "verified", default: false
    t.timestamp "verified_at"
    t.integer "staff_id"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenancy_id"], name: "index_tenancy_documents_on_tenancy_id"
  end

  create_table "tenancy_histories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.bigint "tenancy_id"
    t.integer "original_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenancy_id"], name: "index_tenancy_histories_on_tenancy_id"
  end

  create_table "tenancy_identifications", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.bigint "tenancy_id"
    t.integer "staff_id"
    t.string "id_proof_name"
    t.string "id_proof_doc"
    t.boolean "verified", default: false
    t.timestamp "verified_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenancy_id"], name: "index_tenancy_identifications_on_tenancy_id"
  end

  create_table "tenancy_payment_items", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.bigint "tenancy_id"
    t.string "item"
    t.string "item_type"
    t.date "due_date"
    t.decimal "amount_due", precision: 10, scale: 2
    t.decimal "amount_paid", precision: 10, scale: 2
    t.string "arrears"
    t.string "payment_method"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "item_year"
    t.date "date_paid"
    t.bigint "tenancy_id_id"
    t.index ["tenancy_id"], name: "index_tenancy_payment_items_on_tenancy_id"
    t.index ["tenancy_id_id"], name: "index_tenancy_payment_items_on_tenancy_id_id"
  end

  create_table "tenancy_staff_conversations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.bigint "tenancy_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenancy_id"], name: "index_tenancy_staff_conversations_on_tenancy_id"
  end

  create_table "tenancy_staff_messages", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.text "body"
    t.text "subject"
    t.string "from"
    t.bigint "tenancy_staff_conversation_id"
    t.integer "sender_id"
    t.integer "receiver_id"
    t.boolean "read", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "sender_type"
    t.string "receiver_type"
    t.index ["tenancy_staff_conversation_id"], name: "index_tenancy_staff_messages_on_tenancy_staff_conversation_id"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "surname"
    t.string "username"
    t.string "mobile"
    t.boolean "admin"
    t.string "colour"
    t.string "role", limit: 50
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "additional_tenants", "tenancies"
  add_foreign_key "conversations", "properties"
  add_foreign_key "criminal_records", "tenancies"
  add_foreign_key "features", "properties"
  add_foreign_key "guarantors", "tenancies"
  add_foreign_key "landlord_documents", "landlords"
  add_foreign_key "landlord_staff_conversations", "landlords"
  add_foreign_key "landlord_staff_messages", "landlord_staff_conversations"
  add_foreign_key "messages", "conversations"
  add_foreign_key "properties", "landlords"
  add_foreign_key "property_list_families", "properties"
  add_foreign_key "property_list_graduates", "properties"
  add_foreign_key "property_list_professionals", "properties"
  add_foreign_key "property_list_students", "properties"
  add_foreign_key "property_listing_locations", "properties"
  add_foreign_key "property_listing_locations", "users"
  add_foreign_key "property_utilities", "properties"
  add_foreign_key "rooms", "properties"
  add_foreign_key "student_course_details", "tenancies"
  add_foreign_key "tenancy_documents", "tenancies"
  add_foreign_key "tenancy_histories", "tenancies"
  add_foreign_key "tenancy_identifications", "tenancies"
  add_foreign_key "tenancy_payment_items", "tenancies"
  add_foreign_key "tenancy_staff_conversations", "tenancies"
  add_foreign_key "tenancy_staff_messages", "tenancy_staff_conversations"
end
