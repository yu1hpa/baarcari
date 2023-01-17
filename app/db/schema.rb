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

ActiveRecord::Schema[7.0].define(version: 2023_01_14_170843) do
  create_table "applicants", force: :cascade do |t|
    t.string "applicantion_id"
    t.string "user_id"
    t.string "purchaser_name"
    t.string "purchaser_email"
    t.string "exobj_item_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "exhibition_objs", force: :cascade do |t|
    t.string "user_id"
    t.string "item_id"
    t.string "item_name"
    t.string "item_info"
    t.string "item_image_fname"
    t.string "remarks"
    t.string "joutosaki"
    t.datetime "deadline"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "user_id"
    t.string "username"
    t.string "passwd"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
