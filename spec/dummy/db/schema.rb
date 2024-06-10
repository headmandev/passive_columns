# frozen_string_literal: true

ActiveRecord::Schema.define(version: 2024_05_06_152000) do
  create_table :users do |t|
    t.string "email", default: "", null: false
    t.bigint "default_project_id"
  end

  create_table "projects" do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.text "description", default: ""
    t.text "guidelines", default: ""
  end

  add_foreign_key "projects", "users", on_update: :cascade
  add_foreign_key "users", "projects", column: "default_project_id", on_update: :cascade, on_delete: :nullify
end