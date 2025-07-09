class Usuario < ApplicationRecord
  # Relacionamento Muitos-para-Muitos: um usuário pode estar em várias turmas.
  has_and_belongs_to_many :turmas

  # Relação de um professor para muitas turmas.
  # A foreign_key especifica que a coluna em 'turmas' é 'professor_id'.
  has_many :turmas_lecionadas, class_name: 'Turma', foreign_key: 'professor_id'

  # Relação de um criador para muitos formulários.
  has_many :formularios_criados, class_name: 'Formulario', foreign_key: 'criador_id'

  # Relação de um avaliador para muitas respostas.
  has_many :respostas_enviadas, class_name: 'Resposta', foreign_key: 'avaliador_id'
end