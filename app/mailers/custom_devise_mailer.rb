# Caminho: app/mailers/custom_devise_mailer.rb
class CustomDeviseMailer < Devise::Mailer
  ##
  # Inclui helpers da aplicação para uso nas views de e-mail.
  #
  # Descrição: Permite que métodos definidos em `ApplicationHelper`
  #    sejam utilizados dentro dos templates de e-mail deste mailer.
  # Argumentos: Nenhum.
  # Retorno: Nenhum valor explícito.
  # Efeitos colaterais: Disponibiliza helpers globais nas views de e-mail.
  helper :application

  ##
  # Inclui helpers para geração de URLs do Devise.
  #
  # Descrição: Permite o acesso a métodos como `root_url`, `new_password_url`, etc.,
  #    que são necessários para construir URLs dentro dos e-mails do Devise.
  # Argumentos: Nenhum.
  # Retorno: Nenhum valor explícito.
  # Efeitos colaterais: Disponibiliza métodos de geração de URL.
  include Devise::Controllers::UrlHelpers

  ##
  # Define o caminho padrão para os templates de e-mail do Devise.
  #
  # Descrição: Especifica o diretório onde os templates de e-mail específicos
  #    do Devise (como `reset_password_instructions.html.erb`) estão localizados.
  # Argumentos: Nenhum.
  # Retorno: O caminho padrão dos templates ("devise/mailer").
  # Efeitos colaterais: Altera a localização padrão dos templates de e-mail.
  default template_path: "devise/mailer"

  ##
  # Envia instruções para redefinição de senha.
  #
  # Descrição: Este método é sobrescrito do Devise para personalizar a URL
  #    de redefinição de senha. Ele constrói uma URL que aponta para a página
  #    de frontend (React) da aplicação, passando o token de redefinição como parâmetro,
  #    e então chama o método `super` para continuar o processo de envio do e-mail.
  # Argumentos:
  #    - `record`: O objeto do usuário (`Usuario`) para o qual a senha será redefinida.
  #    - `token`: O token de redefinição de senha gerado pelo Devise.
  #    - `opts`: Opções adicionais (hash de opções).
  # Retorno: O objeto `Mail::Message` que representa o e-mail a ser enviado.
  # Efeitos colaterais:
  #    - Gera uma URL de redefinição de senha customizada (`@reset_url`).
  #    - Enfileira o envio de um e-mail de redefinição de senha para o usuário.
  # Este método é chamado quando o Devise vai enviar as instruções de recuperação.
  def reset_password_instructions(record, token, opts = {})
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
