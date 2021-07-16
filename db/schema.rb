# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_07_15_074856) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "allocation_subjects", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_allocation_subjects_on_name", unique: true
  end

  create_table "apply_application_sync_requests", force: :cascade do |t|
    t.integer "response_code"
    t.boolean "successful"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "apply_applications", force: :cascade do |t|
    t.integer "apply_id", null: false
    t.jsonb "application"
    t.bigint "provider_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.jsonb "invalid_data"
    t.index ["apply_id"], name: "index_apply_applications_on_apply_id", unique: true
    t.index ["provider_id"], name: "index_apply_applications_on_provider_id"
  end

  create_table "audits", force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.jsonb "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "bursaries", force: :cascade do |t|
    t.string "training_route", null: false
    t.integer "amount", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "bursary_subjects", force: :cascade do |t|
    t.bigint "bursary_id"
    t.bigint "allocation_subject_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["allocation_subject_id", "bursary_id"], name: "index_bursary_subjects_on_allocation_subject_id_and_bursary_id", unique: true
    t.index ["allocation_subject_id"], name: "index_bursary_subjects_on_allocation_subject_id"
    t.index ["bursary_id"], name: "index_bursary_subjects_on_bursary_id"
  end

  create_table "consistency_checks", force: :cascade do |t|
    t.integer "trainee_id"
    t.datetime "contact_last_updated_at"
    t.datetime "placement_assignment_last_updated_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "course_subjects", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.bigint "subject_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["course_id", "subject_id"], name: "index_course_subjects_on_course_id_and_subject_id", unique: true
    t.index ["course_id"], name: "index_course_subjects_on_course_id"
    t.index ["subject_id"], name: "index_course_subjects_on_subject_id"
  end

  create_table "courses", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.date "start_date", null: false
    t.integer "duration_in_years", null: false
    t.string "course_length"
    t.integer "qualification", null: false
    t.integer "route", null: false
    t.string "summary", null: false
    t.integer "level", null: false
    t.string "accredited_body_code", null: false
    t.integer "min_age", null: false
    t.integer "max_age", null: false
    t.index ["code"], name: "index_courses_on_code", unique: true
  end

  create_table "degrees", force: :cascade do |t|
    t.integer "locale_code", null: false
    t.string "uk_degree"
    t.string "non_uk_degree"
    t.bigint "trainee_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "subject"
    t.string "institution"
    t.integer "graduation_year"
    t.string "grade"
    t.string "country"
    t.text "other_grade"
    t.string "slug", null: false
    t.uuid "dttp_id"
    t.index ["dttp_id"], name: "index_degrees_on_dttp_id"
    t.index ["locale_code"], name: "index_degrees_on_locale_code"
    t.index ["slug"], name: "index_degrees_on_slug", unique: true
    t.index ["trainee_id"], name: "index_degrees_on_trainee_id"
  end

  create_table "disabilities", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_disabilities_on_name", unique: true
  end

  create_table "dttp_providers", force: :cascade do |t|
    t.string "name"
    t.uuid "dttp_id"
    t.string "ukprn"
    t.datetime "created_at", precision: 6, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: 6, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["dttp_id"], name: "index_dttp_providers_on_dttp_id", unique: true
  end

  create_table "dttp_schools", force: :cascade do |t|
    t.string "name"
    t.string "dttp_id"
    t.string "urn"
    t.datetime "created_at", precision: 6, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: 6, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["dttp_id"], name: "index_dttp_schools_on_dttp_id", unique: true
  end

  create_table "dttp_users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "dttp_id"
    t.string "provider_dttp_id"
    t.datetime "created_at", precision: 6, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", precision: 6, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["dttp_id"], name: "index_dttp_users_on_dttp_id", unique: true
  end

  create_table "nationalisations", force: :cascade do |t|
    t.bigint "trainee_id", null: false
    t.bigint "nationality_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["nationality_id"], name: "index_nationalisations_on_nationality_id"
    t.index ["trainee_id"], name: "index_nationalisations_on_trainee_id"
  end

  create_table "nationalities", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_nationalities_on_name", unique: true
  end

  create_table "providers", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "dttp_id"
    t.string "code"
    t.boolean "apply_sync_enabled", default: false
    t.string "ukprn"
    t.index ["dttp_id"], name: "index_providers_on_dttp_id", unique: true
  end

  create_table "schools", force: :cascade do |t|
    t.string "urn", null: false
    t.string "name", null: false
    t.string "postcode"
    t.string "town"
    t.date "open_date"
    t.date "close_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "lead_school", null: false
    t.tsvector "searchable"
    t.index ["close_date"], name: "index_schools_on_close_date", where: "(close_date IS NULL)"
    t.index ["lead_school"], name: "index_schools_on_lead_school", where: "(lead_school IS TRUE)"
    t.index ["searchable"], name: "index_schools_on_searchable", using: :gin
    t.index ["urn"], name: "index_schools_on_urn", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "subject_specialisms", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "allocation_subject_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index "lower((name)::text)", name: "index_subject_specialisms_on_lower_name", unique: true
    t.index ["allocation_subject_id"], name: "index_subject_specialisms_on_allocation_subject_id"
  end

  create_table "subjects", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["code"], name: "index_subjects_on_code", unique: true
  end

  create_table "trainee_disabilities", force: :cascade do |t|
    t.bigint "trainee_id", null: false
    t.bigint "disability_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "additional_disability"
    t.index ["disability_id"], name: "index_trainee_disabilities_on_disability_id"
    t.index ["trainee_id"], name: "index_trainee_disabilities_on_trainee_id"
  end

  create_table "trainees", force: :cascade do |t|
    t.text "trainee_id"
    t.text "first_names"
    t.text "last_name"
    t.date "date_of_birth"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "address_line_one"
    t.text "address_line_two"
    t.text "town_city"
    t.text "postcode"
    t.text "email"
    t.uuid "dttp_id"
    t.text "middle_names"
    t.integer "training_route"
    t.text "international_address"
    t.integer "locale_code"
    t.integer "gender"
    t.integer "diversity_disclosure"
    t.integer "ethnic_group"
    t.text "ethnic_background"
    t.text "additional_ethnic_background"
    t.integer "disability_disclosure"
    t.text "course_subject_one"
    t.date "course_start_date"
    t.jsonb "progress", default: {}
    t.bigint "provider_id", null: false
    t.date "outcome_date"
    t.date "course_end_date"
    t.uuid "placement_assignment_dttp_id"
    t.string "trn"
    t.datetime "submitted_for_trn_at"
    t.integer "state", default: 0
    t.integer "withdraw_reason"
    t.datetime "withdraw_date"
    t.string "additional_withdraw_reason"
    t.date "defer_date"
    t.string "slug", null: false
    t.datetime "recommended_for_award_at"
    t.string "dttp_update_sha"
    t.date "commencement_date"
    t.date "reinstate_date"
    t.uuid "dormancy_dttp_id"
    t.bigint "lead_school_id"
    t.bigint "employing_school_id"
    t.bigint "apply_application_id"
    t.integer "course_min_age"
    t.integer "course_max_age"
    t.string "course_code"
    t.text "course_subject_two"
    t.text "course_subject_three"
    t.datetime "awarded_at"
    t.boolean "applying_for_bursary"
    t.integer "training_initiative"
    t.integer "bursary_tier"
    t.index ["apply_application_id"], name: "index_trainees_on_apply_application_id"
    t.index ["disability_disclosure"], name: "index_trainees_on_disability_disclosure"
    t.index ["diversity_disclosure"], name: "index_trainees_on_diversity_disclosure"
    t.index ["dttp_id"], name: "index_trainees_on_dttp_id"
    t.index ["employing_school_id"], name: "index_trainees_on_employing_school_id"
    t.index ["ethnic_group"], name: "index_trainees_on_ethnic_group"
    t.index ["gender"], name: "index_trainees_on_gender"
    t.index ["lead_school_id"], name: "index_trainees_on_lead_school_id"
    t.index ["locale_code"], name: "index_trainees_on_locale_code"
    t.index ["progress"], name: "index_trainees_on_progress", using: :gin
    t.index ["provider_id"], name: "index_trainees_on_provider_id"
    t.index ["slug"], name: "index_trainees_on_slug", unique: true
    t.index ["state"], name: "index_trainees_on_state"
    t.index ["training_route"], name: "index_trainees_on_training_route"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email", null: false
    t.bigint "provider_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "dfe_sign_in_uid"
    t.datetime "last_signed_in_at"
    t.uuid "dttp_id"
    t.boolean "system_admin", default: false
    t.datetime "welcome_email_sent_at"
    t.index ["dfe_sign_in_uid"], name: "index_users_on_dfe_sign_in_uid", unique: true
    t.index ["dttp_id"], name: "index_users_on_dttp_id", unique: true
    t.index ["email"], name: "index_users_on_email"
    t.index ["provider_id"], name: "index_users_on_provider_id"
  end

  create_table "validation_errors", force: :cascade do |t|
    t.bigint "user_id"
    t.string "form_object"
    t.jsonb "details"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_validation_errors_on_user_id"
  end

  add_foreign_key "apply_applications", "providers"
  add_foreign_key "course_subjects", "courses"
  add_foreign_key "course_subjects", "subjects"
  add_foreign_key "degrees", "trainees"
  add_foreign_key "nationalisations", "nationalities"
  add_foreign_key "nationalisations", "trainees"
  add_foreign_key "subject_specialisms", "allocation_subjects"
  add_foreign_key "trainee_disabilities", "disabilities"
  add_foreign_key "trainee_disabilities", "trainees"
  add_foreign_key "trainees", "apply_applications"
  add_foreign_key "trainees", "providers"
  add_foreign_key "trainees", "schools", column: "employing_school_id"
  add_foreign_key "trainees", "schools", column: "lead_school_id"
  add_foreign_key "users", "providers"
end
