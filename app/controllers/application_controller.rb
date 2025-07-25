# Caminho: app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  ##
  # Protege contra ataques Cross-Site Request Forgery (CSRF).
  #
  # Descrição: Esta linha configura a proteção CSRF para todas as requisições.
  #    No entanto, ela é desativada especificamente para requisições que esperam
  #    formato JSON (comum em APIs), pois a proteção CSRF baseada em sessão/cookie
  #    não é tipicamente usada em APIs stateless que usam tokens (como JWT).
  # Argumentos: Nenhum.
  # Retorno: Nenhum valor explícito.
  # Efeitos colaterais:
  #    - Impede a submissão de requisições forjadas para endpoints HTML.
  #    - Permite requisições JSON sem verificação de token CSRF.
  protect_from_forgery with: :exception, unless: -> { request.format.json? }

  ##
  # Configura parâmetros permitidos para o Devise.
  #
  # Descrição: Este `before_action` é um callback do Devise que é executado
  #    antes das ações do controlador do Devise. Ele chama o método
  #    `configure_permitted_parameters` para permitir parâmetros adicionais
  #    durante os processos de registro, atualização de conta e login.
  # Argumentos: Nenhum.
  # Retorno: Nenhum valor explícito.
  # Efeitos colaterais: Modifica os parâmetros que o Devise permite para operações de usuário.
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  ##
  # Define os parâmetros permitidos para as operações do Devise.
  #
  # Descrição: Este método protege contra ataques de atribuição em massa,
  #    especificando quais atributos do modelo `Usuario` são permitidos
  #    durante as operações de `sign_up` (registro), `account_update`
  #    (atualização de conta) e `sign_in` (login) do Devise.
  # Argumentos: Nenhum.
  # Retorno: Nenhum.
  # Efeitos colaterais: Configura o `devise_parameter_sanitizer` para filtrar parâmetros.
  def configure_permitted_parameters
    # Suas configurações estão corretas e devem ser mantidas.
    added_attrs = [:username, :email, :password, :password_confirmation, :remember_me]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
    devise_parameter_sanitizer.permit :sign_in, keys: [ :login, :password ]
  end

  private

  ##
  # Define o caminho de redirecionamento após um login bem-sucedido.
  #
  # Descrição: Este método é um callback do Devise que é chamado após o login
  #    bem-sucedido de um usuário. Ele redireciona o usuário para o dashboard
  #    administrativo se for um administrador, ou para a página inicial (`root_path`)
  #    se for um usuário comum.
  # Argumentos:
  #    - `resource`: O objeto do recurso (usuário) que acabou de fazer login.
  # Retorno: Uma string representando o caminho da URL para redirecionamento.
  # Efeitos colaterais: Redirecionamento de página.
  # Este método é para o "Mundo do Admin" (HTML) e está correto.
  def after_sign_in_path_for(resource)
    if resource.admin?
      "/admin/dashboard"
    else
      root_path
    end
  end
end
