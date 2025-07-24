# app/mailers/custom_devise_mailer.rb
class CustomDeviseMailer < Devise::Mailer
  helper :application
  include Devise::Controllers::UrlHelpers
  default template_path: 'usuarios/mailer' # Mantém o caminho para suas views customizadas

  # Este método é chamado quando o Devise vai enviar as instruções de recuperação.
  # Ele agora será usado tanto para "Esqueci minha senha" quanto para "Novos usuários importados".
  def reset_password_instructions(record, token, opts={})
    @token = token
    # A URL para a página de definição de senha no seu frontend (React)
    @reset_url = "http://localhost:3002/definir-senha?token=#{@token}"
    
    # Adicionando uma variável para a view saber se é um email de 'primeiro acesso'
    # ou 'redefinição padrão'. Isso permite adaptar o texto na view.
    @is_initial_password_setup = opts[:initial_password_setup] || false 

    super # Chama o método original do Devise para continuar o processo de envio
  end

  # O método temporary_password_email NÃO É MAIS NECESSÁRIO
  # pois usaremos reset_password_instructions para ambos os cenários.
end