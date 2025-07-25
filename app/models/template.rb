# Caminho: app/models/template.rb
class Template < ApplicationRecord
  # Associações
  ##
  # Associação: Pertence a um `Criador` (Usuário).
  #
  # Descrição: Define a relação onde cada `Template` tem um `Usuario`
  #    que o criou. O `class_name` é especificado como "Usuario" porque
  #    o nome da associação (`criador`) difere do nome da classe (`Usuario`).
  # Argumentos: Nenhum.
  # Retorno: O objeto `Usuario` que criou este template.
  # Efeitos colaterais: Define um método `criador` e `criador=` para gerenciar a associação.
  belongs_to :criador, class_name: "Usuario"

  ##
  # Associação: Possui muitos `Formularios`.
  #
  # Descrição: Define a relação onde um `Template` pode ter múltiplos
  #    `Formularios` associados a ele. A exclusão de um template será impedida
  #    se houver formulários associados (`dependent: :restrict_with_error`).
  # Argumentos: Nenhum.
  # Retorno: Uma coleção de objetos `Formulario` associados a este template.
  # Efeitos colaterais: Impede a exclusão do template se houver formulários dependentes.
  has_many :formularios, dependent: :restrict_with_error

  ##
  # Associação: Possui muitas `Questoes`.
  #
  # Descrição: Define a relação onde um `Template` pode ter múltiplas
  #    `Questoes` associadas a ele. Quando um template é destruído, todas as suas
  #    questões associadas também são destruídas (`dependent: :destroy`).
  # Argumentos: Nenhum.
  # Retorno: Uma coleção de objetos `Questao` associados a este template.
  # Efeitos colaterais: Ao destruir um `Template`, suas `Questoes` dependentes também são destruídas.
  has_many :questoes, class_name: 'Questao', dependent: :destroy

  # Validações
  ##
  # Validação: Garante a presença e unicidade do `titulo`.
  #
  # Descrição: Assegura que cada template tenha um título preenchido e que
  #    este título seja único em toda a aplicação.
  # Argumentos: Nenhum.
  # Retorno: `true` se a validação passar, `false` caso contrário.
  # Efeitos colaterais: Adiciona um erro ao objeto se `titulo` estiver ausente ou não for único.
  validates :titulo, presence: { message: "O título do template é obrigatório" }, uniqueness: { message: "Já existe um template com este nome. Use um título diferente." }

  ##
  # Validação customizada: Garante que o template tenha pelo menos uma questão.
  #
  # Descrição: Este método de validação customizada verifica se o template
  #    possui pelo menos uma questão válida (não marcada para exclusão).
  #    Se não houver questões válidas, um erro é adicionado ao objeto.
  # Argumentos: Nenhum.
  # Retorno: `true` se a validação passar, `false` caso contrário.
  # Efeitos colaterais: Adiciona um erro ao objeto se nenhuma questão válida for encontrada.
  validate :questoes_presentes

  ##
  # Atributos aninhados para questões.
  #
  # Descrição: Permite que os atributos de `questoes` sejam manipulados diretamente
  #    através do modelo `Template` (ex: em formulários). Permite a destruição de
  #    questões (`allow_destroy: true`) e rejeita atributos de questões onde o
  #    `enunciado` esteja em branco (`reject_if`).
  # Argumentos: Nenhum.
  # Retorno: Nenhum valor explícito.
  # Efeitos colaterais: Facilita a manipulação de questões ao salvar/atualizar um template.
  accepts_nested_attributes_for :questoes, allow_destroy: true, reject_if: proc { |attributes| attributes['enunciado'].blank? }

  private

  ##
  # Método privado de validação: Verifica a presença de questões válidas.
  #
  # Descrição: Implementa a lógica para garantir que o template contenha
  #    pelo menos uma questão que não esteja marcada para exclusão. Se todas
  #    as questões estiverem marcadas para destruição ou se não houver questões,
  #    um erro é adicionado.
  # Argumentos: Nenhum.
  # Retorno: Nenhum valor explícito. Adiciona erros ao objeto `errors` se a validação falhar.
  # Efeitos colaterais: Modifica o objeto `errors` do `Template`.
  def questoes_presentes
    # Garante que o template tenha pelo menos uma questão válida (não marcada para exclusão).
    valid_questoes = questoes.reject(&:marked_for_destruction?)
    errors.add(:base, "Adicione pelo menos uma questão ao template") if valid_questoes.empty?
  end
end
