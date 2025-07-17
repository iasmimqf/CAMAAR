# app/mailers/custom_devise_mailer.rb
class CustomDeviseMailer < Devise::Mailer
  helper :application
  include Devise::Controllers::UrlHelpers
  default template_path: 'devise/mailer'

  # Este método é chamado quando o Devise vai enviar as instruções de recuperação.
  def reset_password_instructions(record, token, opts={})
    @token = token
    
    # AQUI ESTÁ A MÁGICA:
    # Criamos a URL que aponta para a página do seu frontend (React),
    # passando o token como um parâmetro.
    @reset_url = "http://localhost:3002/definir-senha?token=#{@token}"
    
    # Chamamos o método original para que ele continue o processo de envio do e-mail,
    # mas agora usando a nossa URL customizada.
    super
  end
end
