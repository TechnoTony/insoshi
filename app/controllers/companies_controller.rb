class CompaniesController < ApplicationController

  def index
    @companies = Company.find
  end

  def show
    @company = Company.find(params[:id])
  end

  def new
    @company = Company.new
  end

  def edit
    @company = Company.find(params[:id])
	flash[:ticker] = @company.ticker
  end
  
  def create
    @company = Company.new(params[:company])
    respond_to do |format|
      if @company.save
  	    flash[:notice] = "Thanks for entering the details!!"
	    format.html { render :action => 'show' }
	  else
	    format.html { render :action => 'new' }
	  end
    end
  end

  def update
	@company = Company.find(params[:id])
    @company.ticker = flash[:ticker] 
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

end
