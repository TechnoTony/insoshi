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

end
