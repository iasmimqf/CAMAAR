class Resposta < ApplicationRecord
  # Relação de uma resposta que pertence a um formulário.
  belongs_to :formulario

  # Relação de uma resposta que pertence a um avaliador (usuário).
  belongs_to :avaliador, class_name: 'Usuario'
end