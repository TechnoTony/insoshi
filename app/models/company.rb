# Created in migration 24
#	create_table "companies", :force => true do |t|
#      t.string   :name, :ticker, :sector, :claim_id, :creator, :website, :location, :funding
#      t.text     :description
#      t.datetime :date_founded
#      t.integer  :employees, :null => false, :default => 0
#      t.timestamps
#    end
#	add_column	  :companies,  :last_price, :float
#	add_column	  :companies,  :last7, :float	
#	add_column	  :companies,  :week_change, :float	
#	add_column	  :companies,  :vol_today, :float
#	add_column	  :companies,  :vol_average, :float	

class Company < ActiveRecord::Base
  MAX_NAME = MAX_SECTOR = MAX_STRING = SMALL_STRING_LENGTH
  MAX_WEBSITE = MEDIUM_STRING_LENGTH
  MAX_DESCRIPTION = MAX_TEXT_LENGTH
  MAX_TICKER = 8
  
  validates_presence_of     :ticker, :name  
  validates_uniqueness_of   :ticker
  
end