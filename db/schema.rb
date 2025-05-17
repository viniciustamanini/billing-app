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

ActiveRecord::Schema[8.0].define(version: 2025_05_17_033532) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "zip_code"
    t.string "country"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "invoice_items", force: :cascade do |t|
    t.bigint "invoice_id", null: false
    t.text "description"
    t.integer "quantity", null: false
    t.decimal "unit_price", precision: 10, scale: 2, null: false
    t.decimal "tax_rate", precision: 10, scale: 2, null: false
    t.decimal "line_total", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_invoice_items_on_invoice_id"
  end

  create_table "invoice_renegotiations", force: :cascade do |t|
    t.bigint "invoice_id", null: false
    t.bigint "renegotiation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_invoice_renegotiations_on_invoice_id"
    t.index ["renegotiation_id"], name: "index_invoice_renegotiations_on_renegotiation_id"
  end

  create_table "invoice_statuses", force: :cascade do |t|
    t.string "name", limit: 50, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_invoice_statuses_on_name", unique: true
  end

  create_table "invoices", force: :cascade do |t|
    t.date "issued_date", null: false
    t.date "due_date", null: false
    t.decimal "total_amount", precision: 10, scale: 2, null: false
    t.bigint "invoice_status_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "profile_id", null: false
    t.datetime "paid_at"
    t.date "original_due_date"
    t.index ["invoice_status_id"], name: "index_invoices_on_invoice_status_id"
    t.index ["paid_at"], name: "index_invoices_on_paid_at"
    t.index ["profile_id"], name: "index_invoices_on_profile_id"
  end

  create_table "overdue_ranges", force: :cascade do |t|
    t.string "name"
    t.integer "days_from", limit: 2
    t.integer "days_to", limit: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id", null: false
    t.index ["company_id"], name: "index_overdue_ranges_on_company_id"
  end

  create_table "payment_methods", force: :cascade do |t|
    t.string "name", limit: 30, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payment_statuses", force: :cascade do |t|
    t.string "name", limit: 30, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "invoice_id", null: false
    t.datetime "payment_date", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.bigint "payment_method_id", null: false
    t.string "transaction_reference"
    t.bigint "payment_status_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_payments_on_invoice_id"
    t.index ["payment_method_id"], name: "index_payments_on_payment_method_id"
    t.index ["payment_status_id"], name: "index_payments_on_payment_status_id"
  end

  create_table "profile_types", force: :cascade do |t|
    t.string "name", limit: 20, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_profile_types_on_name", unique: true
  end

  create_table "profiles", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "company_id", null: false
    t.bigint "profile_type_id", null: false
    t.boolean "default_profile", default: false, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "cpf", limit: 11
    t.string "first_name", limit: 50
    t.string "last_name", limit: 100
    t.index ["company_id"], name: "index_profiles_on_company_id"
    t.index ["cpf"], name: "index_profiles_on_cpf"
    t.index ["profile_type_id"], name: "index_profiles_on_profile_type_id"
    t.index ["user_id", "company_id", "profile_type_id"], name: "index_profiles_on_user_company_and_type", unique: true
    t.index ["user_id", "company_id"], name: "unique_default_profile_per_user", unique: true, where: "(default_profile = true)"
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "renegotiation_statuses", force: :cascade do |t|
    t.string "name", limit: 30, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_renegotiation_statuses_on_name", unique: true
  end

  create_table "renegotiations", force: :cascade do |t|
    t.decimal "proposed_total_amount", precision: 10, scale: 2, null: false
    t.date "proposed_due_date", null: false
    t.text "reason"
    t.bigint "renegotiation_status_id", null: false
    t.date "decision_date", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["renegotiation_status_id"], name: "index_renegotiations_on_renegotiation_status_id"
  end

  create_table "segments", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.bigint "overdue_range_id", null: false
    t.string "name"
    t.text "description"
    t.decimal "debt_min"
    t.decimal "debt_max"
    t.boolean "include_active_customer"
    t.boolean "include_inactive_customer"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_segments_on_company_id"
    t.index ["overdue_range_id"], name: "index_segments_on_overdue_range_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name", limit: 50, null: false
    t.string "last_name", limit: 100, null: false
    t.string "cpf", limit: 11, null: false
    t.uuid "account_number", default: -> { "gen_random_uuid()" }, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "invoice_items", "invoices"
  add_foreign_key "invoice_renegotiations", "invoices"
  add_foreign_key "invoice_renegotiations", "renegotiations"
  add_foreign_key "invoices", "invoice_statuses"
  add_foreign_key "invoices", "profiles"
  add_foreign_key "overdue_ranges", "companies"
  add_foreign_key "payments", "invoices"
  add_foreign_key "payments", "payment_methods"
  add_foreign_key "payments", "payment_statuses"
  add_foreign_key "profiles", "companies"
  add_foreign_key "profiles", "profile_types"
  add_foreign_key "profiles", "users"
  add_foreign_key "renegotiations", "renegotiation_statuses"
  add_foreign_key "segments", "companies"
  add_foreign_key "segments", "overdue_ranges"
end
