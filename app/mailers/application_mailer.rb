class ApplicationMailer < ActionMailer::Base
  # Define o endereço de e-mail remetente padrão para todos os e-mails
  default from: "nao-responda@camaar.com.br"
  layout "mailer"
end
