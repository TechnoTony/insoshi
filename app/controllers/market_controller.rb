class MarketController < ApplicationController

  def index
    @fxtp_cmd = 'list_keywords'
    response = $market.post({'cmd' => @fxtp_cmd}, :accept => 'html')
    @testdoc = response
  end
  
  def test_mkt
    if params[:admin]
	  @fxtp_cmd = params[:cmd] + FORESIGHT_PWD + params[:args]	
	else
	  @fxtp_cmd = params[:cmd] + params[:args]
	end
    @testdoc = $market.post({'cmd' => @fxtp_cmd}, :accept => 'html')
  end
  
end
