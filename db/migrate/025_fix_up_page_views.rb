class FixUpPageViews < ActiveRecord::Migration
  def self.up
    remove_column :page_views, :user_id
    add_column    :page_views, :person_id, :integer
    add_index     :page_views, [:person_id, :created_at]
	add_column	  :companies,  :last_price, :float
	add_column	  :companies,  :last7, :float	
	add_column	  :companies,  :week_change, :float	
	add_column	  :companies,  :vol_today, :float
	add_column	  :companies,  :vol_average, :float	
	add_column	  :people,	   :net_worth, :float
	add_column    :people,	   :current_cash,  :float	
  end

  def self.down
    add_column    :page_views, :user_id, :integer
    remove_column :page_views, :person_id
    remove_index  :page_views, [:person_id, :created_at]
	remove_column :companies,  :last_price
	remove_column :companies,  :last7
	remove_column :companies,  :week_change	
	remove_column :companies,  :vol_today
	remove_column :companies,  :vol_average	
	remove_column :people,	   :net_worth 
	remove_column :people,	   :current_cash 
  end
end
