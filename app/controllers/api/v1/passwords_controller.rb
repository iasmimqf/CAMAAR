# app/controllers/api/v1/passwords_controller.rb

class Api::V1::PasswordsController < ApplicationController
  # Desabilita a proteção CSRF, pois esta é uma API JSON
  skip_before_action :verify_authenticity_token

  # Ação para SOLICITAR a redefinição de senha
  # Rota: POST /api/v1/password
  def forgot
    # Busca o usuário pelo e-mail ou matrícula, ignorando se é maiúscula ou minúscula
    user = Usuario.where("lower(email) = :value OR lower(matricula) = :value", { value: params[:login].to_s.downcase }).first

    if user.present?
      # Usa o método do Devise para gerar um token e enfileirar o e-mail de redefinição
      user.send_reset_password_instructions
    end

    # IMPORTANTE: Mesmo se o usuário não for encontrado, retornamos uma mensagem de sucesso.
    # Isso é uma medida de segurança para evitar que alguém use esta API para descobrir
    # quais e-mails ou matrículas estão cadastrados no sistema.
    render json: { status: "ok", message: "Se o seu e-mail ou matrícula estiver em nossa base de dados, você receberá um link para redefinir sua senha." }, status: :ok
  end

  # Ação para EFETIVAMENTE redefinir a senha com o token
  # Rota: PUT /api/v1/password
  def reset
    # Usa o método do Devise para encontrar o usuário pelo token e atualizar a senha
    erros = Usuario.reset_password_by_token(reset_password_params).errors.full_messages

    # Verifica se houve erros no processo (token inválido, senhas não conferem, etc.)
    if erros.empty?
      # Se não houver erros, a senha foi redefinida com sucesso
      render json: { status: "ok", message: "Sua senha foi redefinida com sucesso." }, status: :ok
    else
      # Se houver erros, retorna as mensagens para o frontend
      render json: { errors: erros }, status: :unprocessable_entity
    end
  end

  private

  # Strong Parameters para garantir que apenas os parâmetros necessários sejam aceitos
  def reset_password_params
    params.permit(:reset_password_token, :password, :password_confirmation)
  end
end
