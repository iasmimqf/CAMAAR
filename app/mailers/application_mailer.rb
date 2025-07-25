# Caminho: app/mailers/application_mailer.rb

##
# Classe base para todos os mailers da aplicação.
#
# Descrição: Este mailer serve como a fundação para todos os e-mails enviados
#    pela aplicação. Ele define configurações padrão, como o endereço de e-mail
#    do remetente e o layout a ser utilizado para as mensagens.
class ApplicationMailer < ActionMailer::Base
  ##
  # Define o endereço de e-mail remetente padrão para todos os e-mails.
  #
  # Descrição: Configura o endereço de e-mail que será exibido como remetente
  #    (`From`) em todos os e-mails enviados por mailers que herdam desta classe.
  # Argumentos: Nenhum.
  # Retorno: O endereço de e-mail padrão do remetente.
  # Efeitos colaterais: Define o cabeçalho 'From' para os e-mails gerados.
  default from: "nao-responda@camaar.com.br"

  ##
  # Define o layout padrão para os e-mails.
  #
  # Descrição: Especifica o arquivo de layout (`mailer.html.erb` ou `mailer.text.erb`)
  #    que será usado para envolver o conteúdo de todos os e-mails gerados por mailers
  #    que herdam desta classe.
  # Argumentos: Nenhum.
  # Retorno: O nome do layout padrão ("mailer").
  # Efeitos colaterais: Aplica um layout consistente a todas as mensagens de e-mail.
  layout "mailer"
end
