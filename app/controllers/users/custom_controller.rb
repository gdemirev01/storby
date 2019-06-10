class Users::CustomController < ApplicationController
    before_action :authenticate_user!
    
    def library
        render :template => "users/library"
    end 
end