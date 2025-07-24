# app/controllers/password_resets_controller.rb
module Admin
  class PasswordResetsController < Devise::PasswordsController
    # Esta classe herda de Devise::PasswordsController para reutilizar a lógica do Devise.
    # A ação 'edit' é chamada quando o usuário clica no link de definição de senha.
    # A ação 'update' é chamada quando o formulário de senha é submetido.

    # Se precisar de lógica customizada antes das ações do Devise, pode adicionar aqui.
    # Por exemplo, para um cenário de "primeira senha" vs "redefinição normal",
    # pode ser que você queira pular a autenticação inicial do Devise para esta rota.
    # skip_before_action :require_no_authentication, only: [:edit, :update] # Pode ser necessário, dependendo da sua setup.

    # Ação 'edit' para exibir o formulário de definição de senha.
    # Esta ação será invocada pelo GET /definir-senha
    def edit
      # 'super' chama o método 'edit' do Devise::PasswordsController pai.
      # O Devise já vai cuidar de encontrar o usuário pelo reset_password_token na URL.
      super
    end

    # Ação 'update' para processar a submissão do formulário da nova senha.
    # Esta ação será invocada pelo PATCH/PUT /definir-senha (se você adicionar estas rotas customizadas)
    # Ou pelo PATCH/PUT /usuarios/password (rota padrão do Devise)
    def update
      super
    end

    protected

    # Redireciona para a página de login após a redefinição de senha bem-sucedida.
    def after_resetting_password_path_for(resource)
      new_usuario_session_path # Rota de login do Devise
    end

    # Se precisar de um método para buscar o recurso de senha customizado
    # def resource_params
    #   params.require(resource_name).permit(:password, :password_confirmation, :reset_password_token)
    # end
  end
end
