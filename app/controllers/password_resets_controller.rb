# app/controllers/password_resets_controller.rb
class PasswordResetsController < Devise::PasswordsController
  def edit
    # Devise já encontra o recurso (usuário) baseado no reset_password_token
    # e define @resource
    super
  end

  def update
    # Devise lida com os parâmetros e tenta redefinir a senha
    self.resource = resource_class.reset_password_by_token(resource_params)

    if resource.errors.empty?
      # Senha definida com sucesso
      # Definir a mensagem flash (para ser exibida na view atual)
      set_flash_message(:notice, :updated) if is_navigational_format?

      # Opcional: logar o usuário automaticamente após a redefinição
      sign_in(resource_name, resource) if sign_in_after_reset_password?

      # Para que a mensagem apareça ANTES do redirecionamento,
      # renderizamos a mesma view (edit) novamente, mas sem o formulário.
      # Podemos usar uma variável de instância para controlar o que a view mostra.
      @password_reset_successful = true # Sinaliza para a view que foi um sucesso
      render :edit # Renderiza a mesma página para exibir a mensagem flash
    else
      # Se houver erros (senhas não conferem, muito curtas, etc.)
      # Devise adiciona os erros ao recurso. Renderizar a view 'edit' novamente com os erros.
      set_flash_message(:alert, :not_updated) if is_navigational_format?
      render :edit
    end
  end

  protected

  # Este método não será mais usado diretamente se renderizarmos a view 'edit'
  # antes de um redirecionamento opcional.
  # No entanto, mantenha-o para outros fluxos do Devise se houver.
  def after_resetting_password_path_for(resource)
    new_usuario_session_path
  end

  def resource_params
    params.require(resource_name).permit(:password, :password_confirmation, :reset_password_token)
  end

  # Novo método para controlar se o usuário deve ser logado automaticamente
  def sign_in_after_reset_password?
    Devise.sign_in_after_reset_password
  end
end