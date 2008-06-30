# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  include AuthenticatedSystem
  include SharedHelper
  include PreferencesHelper
  
  before_filter :create_page_view, :require_activation, :tracker_vars,
                :admin_warning

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '71a8c82e6d248750397d166001c5e308'

#the following loads the code and creates the connection for the foresight server
  require 'lib/rest_client'
  require 'lib/resource'
  require 'yaml'
  
  @config = YAML::load(File.open("#{RAILS_ROOT}/config/passwords.yml"))
  FORESIGHT_URL = @config["url"]
  FORESIGHT_PWD = @config["pwd"] 

#Need to add some code to catch an error here if the market connection doesn't work
#This code is not properly working
  begin
    $market = RestClient::Resource.new(FORESIGHT_URL)
  rescue  Exception
    redirect_to :controller => :market, :action => "errors"
  end

#The following are helper functions used to interact with the market
  def split_response(response)
  #this method returns an array with the full response in [0] and each line split subsequently
    n=0
	@array = []
	@array[0] = response
	response.each_line do |line|
	  n += 1
	  @array[n] = line
	end
	return @array
  end
  
  def show_sectors
  	@fxtp_cmd = "list_keywords"
	@response = $market.post({'cmd' => @fxtp_cmd}, :accept => 'html')
    n=0
	@array = []
	@response.each_line do |line|
	  if  line[0,8] == "CAT_SYM:"
	    @array[n] = line[8..-1]
	    n += 1
	  end
	end
	return @array 
  end
  
  def String.random_alphanumeric(size=16)
  #creates a random string
	(1..size).collect { (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }.join
  end	

  private

    def admin_required
      unless current_person.admin?
        flash[:error] = "Admin access required"
        redirect_to home_url
      end
    end
  
    # Create a Scribd-style PageView.
    # See http://www.scribd.com/doc/49575/Scaling-Rails-Presentation
    def create_page_view
      PageView.create(:person_id => session[:person_id],
                      :request_url => request.request_uri,
                      :ip_address => request.remote_ip,
                      :referer => request.env["HTTP_REFERER"],
                      :user_agent => request.env["HTTP_USER_AGENT"])
      if logged_in?
        # last_logged_in_at actually captures site activity, so update it now.
        current_person.last_logged_in_at = Time.now
        current_person.save
      end
    end
  
    def require_activation
      if logged_in?
        unless current_person.active? or current_person.admin?
          redirect_to logout_url
        end
      end
    end
    
    # A tracker to tell us about the activity of Insoshi installs.
    def tracker_vars
      @tracker_id = File.open("identifier").read rescue nil
      @env = ENV['RAILS_ENV']
    end
    
    # Warn the admin if his email address or password is still the default.
    def admin_warning
      default_domain = "example.com"
      default_password = "admin"
      if logged_in? and current_person.admin? 
        if current_person.email =~ /@#{default_domain}$/
          flash[:notice] = %(Warning: your email address is still at 
            #{default_domain}.
            <a href="#{edit_person_path(current_person)}">Change it here</a>.)
        end
        if current_person.unencrypted_password == default_password
          flash[:error] = %(Warning: your password is still the default.
            <a href="#{edit_person_path(current_person)}">Change it here</a>.)          
        end
      end
    end
end