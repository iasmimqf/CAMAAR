# Caminho: app/models/jwt_denylist.rb

##
# Representa uma lista de tokens JWT revogados (denylist).
#
# Descrição: Este modelo é utilizado pelo Devise e `devise-jwt` para gerenciar
#    tokens JWT que foram invalidados (por exemplo, após um logout do usuário).
#    Quando um token é adicionado a esta lista, ele não pode mais ser usado
#    para autenticação, mesmo que ainda não tenha expirado.
class JwtDenylist < ApplicationRecord
  ##
  # Inclui a estratégia de revogação de JTI (JWT ID) do Devise JWT.
  #
  # Descrição: Este módulo fornece a lógica necessária para que o Devise JWT
  #    possa invalidar tokens com base em seu JTI (identificador único do JWT).
  #    Ele permite que o modelo funcione como um repositório para tokens revogados.
  # Argumentos: Nenhum.
  # Retorno: Nenhum valor explícito.
  # Efeitos colaterais: Adiciona métodos e comportamento relacionados à revogação de JWT ao modelo.
  include Devise::JWT::RevocationStrategies::JTIMatcher

  ##
  # Define o nome da tabela do banco de dados para este modelo.
  #
  # Descrição: Especifica explicitamente que este modelo deve usar a tabela
  #    `jwt_denylist` no banco de dados. Isso é útil quando o nome da tabela
  #    não segue a convenção de nomenclatura padrão do Rails (plural do nome da classe).
  # Argumentos: Nenhum.
  # Retorno: O nome da tabela ("jwt_denylist").
  # Efeitos colaterais: Mapeia o modelo para uma tabela específica no banco de dados.
  self.table_name = "jwt_denylist"
end

