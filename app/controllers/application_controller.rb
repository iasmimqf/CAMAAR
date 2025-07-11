class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_in, keys: [:login, :password])
    # Você também pode precisar configurar para :sign_up e :account_update se for o caso
    # devise_parameter_sanitizer.permit(:sign_up, keys: [:nome, :matricula, :email, :password])
  end
end
