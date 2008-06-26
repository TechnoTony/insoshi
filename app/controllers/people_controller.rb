class PeopleController < ApplicationController
  
  skip_before_filter :require_activation, :only => :verify
  skip_before_filter :admin_warning, :only => [ :show, :update ]
  before_filter :login_required, :only => [ :show, :edit, :update ]
  before_filter :correct_user_required, :only => [ :edit, :update ]
  before_filter :setup
  
  def index
    @people = Person.mostly_active(params[:page])

    respond_to do |format|
      format.html
    end
  end
  
  def show
    @person = Person.find(params[:id], :include => :activities)
    unless @person.active? or current_person.admin?
      flash[:error] = "That person is not active"
      redirect_to home_url and return
    end
    if logged_in?
      @some_contacts = @person.some_contacts
      @common_connections = current_person.common_connections_with(@person)
    end
    respond_to do |format|
      format.html
    end
  end
  
  def new
    @body = "register single-col"
    @person = Person.new

    respond_to do |format|
      format.html
    end
  end

  def create
    cookies.delete :auth_token
    @person = Person.new(params[:person])
    respond_to do |format|
      @person.email_verified = false if global_prefs.email_verifications?
      @response = create_investor(@person)
	  puts @response[1][0,1]
	  if @response[1][0,1] == '2'
	    @person.trader_id = @response[2][5..-1]
		@person.mkt_pwd = @response[4][10..-1]
	    @person.save
        if @person.errors.empty?
          if global_prefs.email_verifications?
            @person.email_verifications.create
            flash[:notice] = %(Thanks for signing up! A verification email has 
                             been sent to #{@person.email}.)
            format.html { redirect_to(home_url) }
          else
            self.current_person = @person
            flash[:notice] = "Thanks for signing up!"
            format.html { redirect_back_or_default(home_url) }
          end
        else
#Warning: this delete is not currently working correctly as just creates random trader, needs editing
          @response = delete_investor(@person.trader_id = @response[2][5..-1])
		  if @response != '2'
		    flash[:notice] = 'Warning: possibly duplicate entry created.  Contact administrator'
		  end
		  @body = "register single-col"
          format.html { render :action => 'new' }
        end
	  else
        @body = "register single-col"
		flash[:notice] = @response[0]
        format.html { render :action => 'new' }	    
	  end
    end
  rescue ActiveRecord::StatementInvalid
    # Handle duplicate email addresses gracefully by redirecting.
    redirect_to home_url
  end

  def verify
    verification = EmailVerification.find_by_code(params[:id])
    if verification.nil?
      flash[:error] = "Invalid email verification code"
      redirect_to home_url
    else
      cookies.delete :auth_token
      person = verification.person
      person.email_verified = true; person.save!
      self.current_person = person
      flash[:success] = "Email verified. Your profile is active!"
      redirect_to person
    end
  end

  def edit
    @person = Person.find(params[:id])

    respond_to do |format|
      format.html
    end
  end

  def update
    @person = Person.find(params[:id])
    respond_to do |format|
      case params[:type]
      when 'info_edit'
        if !preview? and @person.update_attributes(params[:person])
          flash[:success] = 'Profile updated!'
          format.html { redirect_to(@person) }
        else
          if preview?
            @preview = @person.description = params[:person][:description]
          end
          format.html { render :action => "edit" }
        end
      when 'password_edit'
        if global_prefs.demo?
          flash[:error] = "Passwords can't be changed in demo mode."
          redirect_to @person and return
        end
        if @person.change_password?(params[:person])
          flash[:success] = 'Password changed.'
          format.html { redirect_to(@person) }
        else
          format.html { render :action => "edit" }
        end
      end
    end
  end
  
  def common_contacts
    @person = Person.find(params[:id])
    @common_connections = @person.common_connections_with(current_person,
                                                          params[:page])
    respond_to do |format|
      format.html
    end
  end
  
  private

    def setup
      @body = "person"
    end
  
    def correct_user_required
      redirect_to home_url unless Person.find(params[:id]) == current_person
    end
    
    def preview?
      params["commit"] == "Preview"
    end


#Market methods start below
#Testing requires:
#Can a new account be created
#What happens if account already exists
#What happens if server isn't working
#What happens if user enters wrong information  
  def delete_investor(trader_id)
  	@fxtp_cmd = 'admin_user ' + FORESIGHT_PWD + ",set,#{trader_id},,,#{String.random_alphanumeric}@blah.com,1,#{String.random_alphanumeric},0,0,0,0,,2,1,0,0"
#	puts @fxtp_cmd
	@response = $market.post({'cmd' => @fxtp_cmd}, :accept => 'html')
#	puts @response
#	puts @response[0,1]
	return @response[0,1]
  end	

  def create_investor(investor)
  	@fxtp_cmd = 'admin_user ' + FORESIGHT_PWD + ",new,,,#{investor.email},1,#{investor.name},0,0,0,0,,2,1,0,0"
#	puts @fxtp_cmd
	@response = $market.post({'cmd' => @fxtp_cmd}, :accept => 'html')
#	puts @response
	return split_response(@response)
  end
	   
end
