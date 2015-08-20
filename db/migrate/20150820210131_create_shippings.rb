class CreateShippings < ActiveRecord::Migration
  def change
    create_table :shippings do |t|
      t.string :carrier
      t.integer :price
      t.datetime :est_date
      t.string :service_name
      t.integer :order_id
      t.string :store

      t.timestamps null: false
    end
  end
end
