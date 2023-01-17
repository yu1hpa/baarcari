class CreateExhibitionObjs < ActiveRecord::Migration[7.0]
  def change
    create_table :exhibition_objs do |t|
      t.string :user_id
      t.string :item_id
      t.string :item_name
      t.string :item_info
      t.string :item_image_fname
      t.string :remarks
      t.string :joutosaki
      t.datetime :deadline
      t.timestamps
    end
  end
end
