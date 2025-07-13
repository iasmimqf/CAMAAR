# app/controllers/admin/base_controller.rb
class Admin::BaseController < ApplicationController
  # Este filtro rodará antes de qualquer ação em qualquer controller
  # que herde de Admin::BaseController.
  before_action :authenticate_admin!

  private

  def authenticate_admin!
    unless current_usuario&.admin?
      flash[:alert] = "Acesso não autorizado"
      redirect_to root_path
    end
  end
end