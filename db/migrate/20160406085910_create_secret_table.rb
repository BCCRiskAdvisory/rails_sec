class CreateSecretTable < ActiveRecord::Migration
  def change
    create_table :secret_table do |t|
      t.string :cc_number
      t.string :pps_number
      t.string :full_name
    end
  end
end
