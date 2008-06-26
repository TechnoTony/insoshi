class MarketController < ApplicationController
# Add the code to require admin access, otherwise password can be compromised
#  before_filter :login_required, :admin_required

  def index
#    @fxtp_cmd = 'list_keywords'
#    @testdoc = $market.post({'cmd' => @fxtp_cmd}, :accept => 'html') 
  end
  
  def test_mkt
    if params[:admin]
	#this first line should probably be removed before deployment for security of password
	  @fxtp_cmd = params[:cmd] +' '+ FORESIGHT_PWD + params[:args]	
	else
	  @fxtp_cmd = params[:cmd] +' '+ params[:args]
	end
    @testdoc = $market.post({'cmd' => @fxtp_cmd}, :accept => 'html')
  end
  
end
