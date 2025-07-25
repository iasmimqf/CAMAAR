# Caminho: app/controllers/api/v1/passwords_controller.rb

class Api::V1::PasswordsController < ApplicationController
  # Desabilita a proteção CSRF, pois esta é uma API JSON
  skip_before_action :verify_authenticity_token

  ##
  # Solicita a redefinição de senha para um usuário.
  #
  # Descrição: Busca um usuário pelo e-mail ou matrícula (ignorando maiúsculas/minúsculas).
  #    Se o usuário for encontrado, utiliza o método do Devise para gerar um token de redefinição
  #    e enfileirar o envio de um e-mail com as instruções. Por segurança, retorna uma mensagem
  #    genérica de sucesso mesmo que o usuário não seja encontrado, para evitar enumeração de contas.
  # Argumentos:
  #    - `params[:login]`: Uma string contendo o e-mail ou a matrícula do usuário que solicita a redefinição.
  # Retorno:
  #    - `JSON`: Retorna um JSON com `status: "ok"` e uma `message` informativa, sempre com status `:ok` (200).
  # Efeitos colaterais:
  #    - Envio de e-mails: Se o usuário for encontrado, um e-mail com o link de redefinição de senha é enviado.
  #    - Alterações no banco de dados: Gera um `reset_password_token` e `reset_password_sent_at` para o usuário.
  #    - Comunicação via API: Envia uma resposta JSON ao cliente.
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

  ##
  # Efetiva a redefinição de senha de um usuário usando um token.
  #
  # Descrição: Recebe o `reset_password_token`, a nova `password` e a `password_confirmation`.
  #    Utiliza o método do Devise para validar o token e atualizar a senha do usuário.
  #    Retorna sucesso se a senha for redefinida, ou uma lista de erros se houver falhas
  #    (ex: token inválido/expirado, senhas não coincidentes, validações de senha).
  # Argumentos:
  #    - `reset_password_params`: Hash de parâmetros contendo `reset_password_token`,
  #      `password` e `password_confirmation`.
  # Retorno:
  #    - `JSON`: Retorna um JSON com `status: "ok"` e uma `message` de sucesso com status `:ok` (200)
  #      se a senha for redefinida com sucesso.
  #    - `JSON`: Retorna um JSON com `errors` (array de strings) e status `:unprocessable_entity` (422)
  #      se houver erros de validação ou token inválido.
  # Efeitos colaterais:
  #    - Alterações no banco de dados: Atualiza a senha do usuário e invalida o `reset_password_token`.
  #    - Comunicação via API: Envia respostas JSON ao cliente.
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

  ##
  # Define os parâmetros permitidos para a redefinição de senha.
  #
  # Descrição: Método auxiliar que utiliza o `strong_parameters` do Rails para
  #    garantir que apenas os atributos `reset_password_token`, `password` e
  #    `password_confirmation` sejam aceitos na requisição de redefinição de senha,
  #    prevenindo ataques de atribuição em massa.
  # Argumentos: Nenhum.
  # Retorno: Um hash de parâmetros filtrados.
  # Efeitos colaterais: Nenhum.
  # Strong Parameters para garantir que apenas os parâmetros necessários sejam aceitos
  def reset_password_params
    params.permit(:reset_password_token, :password, :password_confirmation)
  end
end
