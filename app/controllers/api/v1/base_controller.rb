# app/controllers/api/v1/base_controller.rb
class Api::V1::BaseController < ApplicationController
  # >>> CORREÇÃO CRUCIAL: Inclui os helpers de autenticação do Devise <<<
  # Isso garante que 'user_signed_in?', 'current_usuario', etc.
  # estejam disponíveis em TODOS os controllers que herdam de Api::V1::BaseController.
  include Devise::Controllers::Helpers

  # Desativa a proteção CSRF para todos os controladores da API.
  # A segurança será garantida pela verificação de sessão (login) e CORS.
  # É bom ter essa linha explícita aqui para controllers de API.
  skip_before_action :verify_authenticity_token

  private

  # Centraliza a lógica de autenticação e verificação de admin para APIs.
  # Note que esta função é chamada explicitamente (ex: `before_action :authenticate_admin_access!`)
  # nos controllers que de fato precisam de acesso de admin.
  def authenticate_admin_access! # Renomeado para evitar conflito e clareza
    # Primeiro, verifica se há um utilizador logado usando os helpers do Devise.
    unless user_signed_in? # Agora 'user_signed_in?' funcionará aqui
      render json: { error: "Sessão não encontrada. Por favor, faça login novamente." }, status: :unauthorized and return
    end

    # Depois, verifica se o utilizador logado é um administrador.
    # 'current_usuario' funcionará aqui também.
    unless current_usuario.admin?
      render json: {
        error: "Acesso não autorizado. Requer privilégios de administrador.",
        usuario_logado: "Logado como: #{current_usuario.email} (Admin: #{current_usuario.admin?})"
      }, status: :forbidden and return # Adicionado 'and return' para garantir que a resposta seja enviada e a execução pare.
    end
    # Se a execução chegar até aqui, o usuário está logado E é admin.
    # A action original do controller que chamou este 'before_action' será executada.
  end
end
