class Formulario < ApplicationRecord
  # Relacionamento Muitos-para-Muitos: um formulário pode estar em várias turmas.
  has_and_belongs_to_many :turmas

  # Relação de um formulário que pertence a um criador (usuário).
  belongs_to :criador, class_name: 'Usuario'
  
  # Relação de um formulário que pertence a um template.
  belongs_to :template, optional: true

  # Relação de um formulário que tem muitas respostas.
  has_many :respostas
end