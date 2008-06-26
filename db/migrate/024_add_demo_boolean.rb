class AddDemoBoolean < ActiveRecord::Migration
  def self.up
    add_column :preferences, :demo, :boolean, :default => false
	add_column :people, :trader_id, :integer, :null => false, :default =>0
	add_column :people, :mkt_pwd, :string
	create_table "companies", :force => true do |t|
      t.string   :name, :ticker, :sector, :claim_id, :creator, :website, :location, :funding
      t.text     :description
      t.datetime :date_founded
      t.integer  :employees, :null => false, :default => 0
      t.timestamps
    end
  end

  def self.down
    remove_column :preferences, :demo
	remove_column :people, :trader_id
	remove_column :people, :mkt_pwd
	drop_table "companies"	
  end
end
