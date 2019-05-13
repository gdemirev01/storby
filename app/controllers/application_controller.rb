class ApplicationController < ActionController::Base
	protect_from_forgery with: :exception
    before_action :configure_permitted_parameters, if: :devise_controller?
    Rails.application.config.filter_parameters += [:card_number]
    Rails.application.config.filter_parameters += [:card_verification]
    protected

    def configure_permitted_parameters
        devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:name, :email, :password, :current_password, :is_female, :date_of_birth, :profile_pic, role: [:name]) }
        devise_parameter_sanitizer.permit(:account_update) { |u| u.permit(:name, :email, :password, :current_password, :is_female, :date_of_birth, :profile_pic, role: [:name]) }
    end
end
