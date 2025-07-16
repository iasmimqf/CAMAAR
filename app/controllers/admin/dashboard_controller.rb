class Admin::DashboardController < ApplicationController
  # Este "filtro" roda antes de qualquer ação neste controller
  # para garantir que apenas admins logados possam acessá-lo.
  before_action :authenticate_admin!

  def index
    # Aqui você pode adicionar lógica no futuro,
    # como buscar dados para exibir no dashboard.
  end

  private

  def authenticate_admin!
    # Se o usuário atual não existir ou não for admin,
    # ele é redirecionado para a página inicial com uma mensagem de alerta.
    redirect_to root_path, alert: "Acesso negado. Você não é um administrador." unless current_usuario&.admin?
  end
end