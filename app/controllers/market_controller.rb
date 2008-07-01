class MarketController < ApplicationController
# Add the code to require admin access, otherwise password can be compromised
# Don't add admin to the trade functions
before_filter :login_required
# before_filter :admin_required, :except => [:trade, :errors]

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
   
  def errors
  # This just loads a static page
  end
  
  def trade
    if params[:trade_type] == "Buy" 
	  @type = 'B' 
	else 
	  @type = "S" 
	end
	@fxtp_cmd = "orders #{current_person.trader_id},#{current_person.mkt_pwd},new #{params[:ticker]} #{@type}#{params[:quantity]}@market"
	@response = $market.post({'cmd' => @fxtp_cmd}, :accept => 'html')
	flash[:notice] = split_response(@response)[2]
	redirect_to :controller => 'home', :action => 'index'
  end
  
end
