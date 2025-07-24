# app/controllers/admin/base_controller.rb
class Admin::BaseController < ApplicationController
  # Usa os helpers padrão do Devise para autenticação baseada em cookie/sessão.

  # 1. Primeiro, garante que QUALQUER usuário esteja logado.
  #    Se não estiver, o Devise o redireciona para a página de login.
  before_action :authenticate_usuario!

  # 2. Depois, executa nosso próprio método para verificar se o usuário é admin.
  before_action :check_admin_privileges

  private

  def check_admin_privileges
    # Se o usuário logado (current_usuario) não for admin,
    # ele é redirecionado para a página inicial com um alerta.
    unless current_usuario.admin?
      flash[:alert] = "Acesso não autorizado. Você não tem permissão de administrador."
      redirect_to root_path
    end
  end
end
