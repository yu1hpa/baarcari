class CreateApplicant < ActiveRecord::Migration[7.0]
  def change
    create_table :applicants do |t|
      t.string :applicantion_id
      t.string :user_id
      t.string :purchaser_name
      t.string :purchaser_email
      t.string :exobj_item_id
      t.string :is_application_closed
      t.timestamps
    end
  end
end
