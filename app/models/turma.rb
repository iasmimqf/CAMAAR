# Caminho: app/models/turma.rb
class Turma < ApplicationRecord
  ##
  # Associação: Pertence a uma `Disciplina`.
  #
  # Descrição: Define a relação onde cada `Turma` está vinculada a uma `Disciplina` específica.
  #    As opções `foreign_key`, `primary_key` e `inverse_of` são usadas para configurar
  #    explicitamente a relação e otimizar o carregamento de dados.
  # Argumentos: Nenhum.
  # Retorno: O objeto `Disciplina` ao qual esta turma pertence.
  # Efeitos colaterais: Define um método `disciplina` e `disciplina=` para gerenciar a associação.
  belongs_to :disciplina,
             foreign_key: :disciplina_id,
             primary_key: :id,
             inverse_of: :turmas

  ##
  # Associação: Pertence a um `Professor` (Usuário).
  #
  # Descrição: Define a relação onde cada `Turma` pode ter um `Usuario` associado
  #    como seu professor. A opção `optional: true` permite que uma turma exista
  #    sem um professor atribuído inicialmente.
  # Argumentos: Nenhum.
  # Retorno: O objeto `Usuario` que é o professor desta turma, ou `nil`.
  # Efeitos colaterais: Define um método `professor` e `professor=` para gerenciar a associação.
  belongs_to :professor, class_name: "Usuario", optional: true

  ##
  # Associação: Relacionamento Muitos-para-Muitos com `Formularios`.
  #
  # Descrição: Uma turma pode estar associada a vários formulários, e um formulário
  #    pode estar em várias turmas. Esta associação é gerenciada por uma
  #    tabela de junção implícita.
  # Argumentos: Nenhum.
  # Retorno: Uma coleção de objetos `Formulario` associados a esta turma.
  # Efeitos colaterais: Gerencia a associação entre Turmas e Formularios.
  has_and_belongs_to_many :formularios

  ##
  # Associação: Relacionamento Muitos-para-Muitos com `Usuarios` (alunos).
  #
  # Descrição: Uma turma pode ter vários usuários (alunos) matriculados, e um usuário
  #    pode estar matriculado em várias turmas. Esta associação é gerenciada por uma
  #    tabela de junção implícita.
  # Argumentos: Nenhum.
  # Retorno: Uma coleção de objetos `Usuario` (alunos) associados a esta turma.
  # Efeitos colaterais: Gerencia a associação entre Turmas e Usuários.
  has_and_belongs_to_many :usuarios

  ##
  # Validação: Garante a presença de `codigo_turma`, `semestre` e `disciplina_id`.
  #
  # Descrição: Assegura que os campos essenciais para identificar uma turma
  #    estejam sempre preenchidos.
  # Argumentos: Nenhum.
  # Retorno: `true` se a validação passar, `false` caso contrário.
  # Efeitos colaterais: Adiciona erros ao objeto se algum dos campos estiver ausente.
  validates :codigo_turma, :semestre, :disciplina_id, presence: true

  ##
  # Validação: Garante a unicidade da combinação `codigo_turma`, `disciplina_id` e `semestre`.
  #
  # Descrição: Impede a criação de turmas duplicadas para a mesma disciplina no mesmo semestre.
  #    A mensagem de erro personalizada "já existe uma turma com esta combinação" é exibida
  #    se esta validação falhar.
  # Argumentos: Nenhum.
  # Retorno: `true` se a validação passar, `false` caso contrário.
  # Efeitos colaterais: Adiciona um erro ao objeto se a combinação não for única.
  validates_uniqueness_of :codigo_turma,
                          scope: [ :disciplina_id, :semestre ],
                          message: "já existe uma turma com esta combinação"

  ##
  # Retorna o nome completo da turma.
  #
  # Descrição: Constrói uma string formatada que representa o nome completo da turma,
  #    incluindo o nome da disciplina, o código da turma e o semestre.
  # Argumentos: Nenhum.
  # Retorno: Uma `String` contendo o nome completo da turma (ex: "Matemática - T1 (2023.1)").
  # Efeitos colaterais: Nenhum.
  def nome_completo
    "#{disciplina.nome} - #{codigo_turma} (#{semestre})"
  end
end
