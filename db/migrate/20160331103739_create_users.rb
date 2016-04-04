class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.integer :points
      t.string :password_hash

      t.timestamps null: false
    end
  end
end
