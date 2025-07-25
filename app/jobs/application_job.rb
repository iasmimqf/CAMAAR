# Caminho: app/jobs/application_job.rb

##
# Classe base para todos os jobs da aplicação.
#
# Descrição: Esta classe serve como a fundação para todos os jobs assíncronos
#    definidos na aplicação. Ela herda de `ActiveJob::Base` e pode ser
#    configurada com comportamentos padrão para todos os jobs, como
#    tentativas de reexecução e descarte de jobs em caso de erros específicos.
class ApplicationJob < ActiveJob::Base
  # Tenta automaticamente reexecutar jobs que encontraram um deadlock.
  # retry_on ActiveRecord::Deadlocked

  # A maioria dos jobs pode ser ignorada com segurança se os registros subjacentes não estiverem mais disponíveis.
  # discard_on ActiveJob::DeserializationError
end
