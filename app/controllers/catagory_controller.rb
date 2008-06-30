class CatagoryController < ApplicationController
  def new
	@sectors = show_sectors
  end
  
  def update_catagory
    @fxtp_cmd = 'admin_keyword ' + FORESIGHT_PWD + ",set,#{params[:catagory]},1,0,1000,-1,-1,100,2000/12/30,2100/12/30,2000/12/30,2100/12/30,#{params[:catagory]}"
	@response = $market.post({'cmd' => @fxtp_cmd}, :accept => 'html')
	if @response[0,1] == '2'
	  flash[:notice] = "Thanks for adding the catagory!!"
	  redirect_to :controller => 'companies', :action => 'index'
	else
	  flash[:notice] = @response
	  redirect_to :action => 'new'
	end
  end

end
