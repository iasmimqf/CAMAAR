# Caminho: app/models/application_record.rb

##
# Classe base para todos os modelos da aplicação.
#
# Descrição: Esta classe serve como a fundação para todos os modelos do
#    Active Record na aplicação. Ela herda de `ActiveRecord::Base` e é
#    configurada como uma classe abstrata primária, o que significa que
#    outros modelos herdarão dela, mas ela própria não corresponderá a uma
#    tabela no banco de dados.
class ApplicationRecord < ActiveRecord::Base
  ##
  # Define a classe como uma classe abstrata primária.
  #
  # Descrição: Este método indica que `ApplicationRecord` não deve ser
  #    instanciado diretamente e não possui uma tabela correspondente no
  #    banco de dados. Em vez disso, ela serve como uma base para outros
  #    modelos herdeiros.
  # Argumentos: Nenhum.
  # Retorno: Nenhum valor explícito.
  # Efeitos colaterais: Configura o comportamento do Active Record para esta classe.
  primary_abstract_class
end
# Caminho: app/models/application_record.rb

##
# Classe base para todos os modelos da aplicação.
#
# Descrição: Esta classe serve como a fundação para todos os modelos do
#    Active Record na aplicação. Ela herda de `ActiveRecord::Base` e é
#    configurada como uma classe abstrata primária, o que significa que
#    outros modelos herdarão dela, mas ela própria não corresponderá a uma
#    tabela no banco de dados.
class ApplicationRecord < ActiveRecord::Base
  ##
  # Define a classe como uma classe abstrata primária.
  #
  # Descrição: Este método indica que `ApplicationRecord` não deve ser
  #    instanciado diretamente e não possui uma tabela correspondente no
  #    banco de dados. Em vez disso, ela serve como uma base para outros
  #    modelos herdeiros.
  # Argumentos: Nenhum.
  # Retorno: Nenhum valor explícito.
  # Efeitos colaterais: Configura o comportamento do Active Record para esta classe.
  primary_abstract_class
end

