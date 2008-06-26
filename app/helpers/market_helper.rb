module MarketHelper

  def create_stock(company)
  #this helper creates a new claim in the database
	@fxtp_cmd = 'admin_claim ' + FORESIGHT_PWD + ',set,#{company.ticker},#{company.ticker},#{company.name},#{company.description},1,,2009/12/31,,0,0,Sales'
	@response = $market.post({'cmd' => @fxtp_cmd}, :accept => 'html')
  end
  
  def create_investor(investor)
  	@fxtp_cmd = 'admin_claim ' + FORESIGHT_PWD + ',new,,,#{investor.email},1,#{investor.name},0,0,0,0,,2,1,0,0'
	puts @fxtp_cmd
	@response = $market.post({'cmd' => @fxtp_cmd}, :accept => 'html')
	puts @response
  end
  
end
