# frozen_string_literal: true

ActiveRecord::Schema.define(version: 2024_05_06_152000) do
  create_table :users do |t|
    t.string 'email', default: '', null: false
    t.bigint 'default_project_id'
  end

  create_table :projects do |t|
    t.bigint 'user_id', null: false
    t.string 'name', null: false
    t.text 'description', default: ''
    t.text 'guidelines', default: ''
    t.string 'settings', default: '{}'
  end

  create_table "emails", id: :string,
               default: -> {
                 "lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || " \
                 "substr(lower(hex(randomblob(2))),2) || '-' || substr('89ab',abs(random()) % 4 + 1, 1) " \
                 "|| substr(lower(hex(randomblob(2))),2) || '-' || lower(hex(randomblob(6)))"
               },
               force: :cascade do |t|
    t.string "to"
    t.string "from"
    t.string "subject"
    t.text "mail"
  end

  create_table :email_items, force: :cascade do |t|
    t.string "email_id", null: false
    t.string "item_type"
    t.string "item_id"
    t.index %w[email_id], name: "index_email_items_on_project_id"
    t.index %w[item_type item_id], name: "index_email_items_on_item"
  end

  add_foreign_key "email_items", "emails", on_update: :cascade, on_delete: :cascade
  add_foreign_key 'projects', 'users', on_update: :cascade
  add_foreign_key 'users', 'projects', column: 'default_project_id', on_update: :cascade, on_delete: :nullify
end
