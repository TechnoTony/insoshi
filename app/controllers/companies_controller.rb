class CompaniesController < ApplicationController

  def index
    @companies = Company.find(:all)
  end

  def show
    @company = Company.find(params[:id])
  end

  def new
    @company = Company.new
	@sectors = show_sectors
  end

  def edit
    @company = Company.find(params[:id])
	@sectors = show_sectors
#	flash[:ticker] = @company.ticker
  end
  
  def create
    @company = Company.new(params[:company])
	@sectors = show_sectors
    respond_to do |format|
	  if check_ticker(@company.ticker) == '2'
	    flash[:notice] = "Company ticker has already been taken"
		format.html { render :action => 'new' }
      else
        @response = create_stock(@company)
	    if @response[1][0,1] == '2'
	    #Stock successfully created
	      if @company.save
  	        flash[:notice] = "Thanks for entering the details!!"
	        format.html { render :action => 'show' }
	      else
	        #may get an error here, as duplicate ticker created
			#currently don't know how to undo ticker		  
		    format.html { render :action => 'new' }
	      end
	    else
	      #something prevented the stock from being saved properly in the market
		  flash[:notice] = @response[0]
		  puts @response[0]
		  format.html { render :action => 'new' }
	    end
	  end
    end
  end

  def update
	@company = Company.find(params[:id])
#    @company.ticker = flash[:ticker] 
	@company.update_attributes(params[:company])
	
	respond_to do |format|
      if @company.save
  	    flash[:notice] = "Thanks for updating the details!!"
	    format.html { render :action => 'show' }
	  else
	    format.html { render :action => 'edit' }
	  end
    end
  end

  private
  
  def check_ticker(ticker)
    @fxtp_cmd = 'admin_claim ' + FORESIGHT_PWD + ",get,#{ticker}"
	@response = $market.post({'cmd' => @fxtp_cmd}, :accept => 'html')
	return split_response(@response)[1][0,1]
  end
  
  
  def create_stock(company)
    @fxtp_cmd = 'admin_claim ' + FORESIGHT_PWD + ",set,#{company.ticker},,#{company.name},#{company.description},1,,2009/12/31,,0,0,CAT_SYM:#{company.sector}"
	@response = $market.post({'cmd' => @fxtp_cmd}, :accept => 'html')
	return split_response(@response)
  end
  
end
