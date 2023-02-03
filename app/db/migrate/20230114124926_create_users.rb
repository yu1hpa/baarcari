class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :user_id, :null => false
      t.string :username, :null => false
      t.string :passwd, :null => false
      t.string :email
      t.boolean :is_admin, :null => false, :default => false
      t.timestamps
    end
  end
end
