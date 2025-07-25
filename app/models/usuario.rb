# Caminho: app/models/usuario.rb

##
# Representa um usuário do sistema, podendo ser administrador, professor ou aluno.
#
# Descrição: Este modelo gerencia as informações dos usuários, suas credenciais
#    de autenticação (Devise), papéis (admin), e relacionamentos com turmas
#    e formulários. Inclui lógica para login por e-mail ou matrícula e
#    para listar formulários pendentes.
class Usuario < ApplicationRecord
  ##
  # Atributo de escrita virtual para login.
  #
  # Descrição: Permite que o atributo `login` seja definido externamente,
  #    facilitando a autenticação por e-mail ou matrícula.
  # Argumentos: Nenhum.
  # Retorno: Nenhum valor explícito.
  # Efeitos colaterais: Define um setter para `@login`.
  attr_writer :login

  # Relacionamentos
  ##
  # Associação: Possui muitos `RespostaFormularios`.
  #
  # Descrição: Define a relação onde um `Usuario` pode ter múltiplas
  #    `RespostaFormularios` associadas a ele, representando as respostas
  #    completas que o usuário enviou. Quando o usuário é destruído, suas
  #    respostas de formulário dependentes também são destruídas.
  # Argumentos: Nenhum.
  # Retorno: Uma coleção de objetos `RespostaFormulario` associados a este usuário.
  # Efeitos colaterais: Ao destruir um `Usuario`, suas `RespostaFormularios` dependentes também são destruídas.
  has_many :resposta_formularios, foreign_key: "respondente_id", dependent: :destroy

  ##
  # Associação: Relacionamento Muitos-para-Muitos com `Turmas`.
  #
  # Descrição: Um usuário pode estar matriculado em várias turmas, e uma turma
  #    pode ter vários usuários. Esta associação é gerenciada por uma
  #    tabela de junção implícita.
  # Argumentos: Nenhum.
  # Retorno: Uma coleção de objetos `Turma` associados a este usuário.
  # Efeitos colaterais: Gerencia a associação entre Usuários e Turmas.
  has_and_belongs_to_many :turmas

  ##
  # Associação: Possui muitos `Formularios` criados.
  #
  # Descrição: Define a relação onde um `Usuario` pode ter criado múltiplos
  #    `Formularios`. Quando o usuário é destruído, seus formulários criados
  #    dependentes também são destruídos.
  # Argumentos: Nenhum.
  # Retorno: Uma coleção de objetos `Formulario` criados por este usuário.
  # Efeitos colaterais: Ao destruir um `Usuario`, seus `Formularios` dependentes também são destruídos.
  has_many :formularios, foreign_key: "criador_id", dependent: :destroy

  ##
  # Retorna o valor de login do usuário (e-mail ou matrícula).
  #
  # Descrição: Este método prioriza o atributo virtual `@login` (se definido),
  #    caso contrário, retorna o `email` ou a `matricula` do usuário.
  # Argumentos: Nenhum.
  # Retorno: Uma `String` representando o e-mail ou a matrícula do usuário.
  # Efeitos colaterais: Nenhum.
  def login
    @login || self.email || self.matricula
  end

  ##
  # Verifica se o usuário possui privilégios de administrador.
  #
  # Descrição: Retorna `true` se o atributo `admin` do usuário for `true`,
  #    indicando que ele tem permissões administrativas.
  # Argumentos: Nenhum.
  # Retorno: `true` se o usuário for administrador, `false` caso contrário.
  # Efeitos colaterais: Nenhum.
  def admin?
    self.admin == true
  end

  ##
  # Retorna os formulários pendentes para o usuário.
  #
  # Descrição: Este método busca todos os formulários associados às turmas
  #    do usuário que ainda não foram respondidos por ele e que não estão expirados.
  #    Se o usuário não estiver em nenhuma turma, retorna uma coleção vazia.
  # Argumentos: Nenhum.
  # Retorno: Uma coleção de objetos `Formulario` que o usuário ainda precisa responder.
  # Efeitos colaterais: Nenhum.
  # ===============================================================
  # ▼▼▼ MÉTODO ATUALIZADO COM FILTRO DE PRAZO ▼▼▼
  # ===============================================================
  def formularios_pendentes
    return Formulario.none if self.turmas.empty?

    formularios_das_turmas = Formulario.joins(:turmas)
                                       .where(turmas: { id: self.turmas.pluck(:id) })
                                       # Adiciona a condição para o prazo:
                                       # O prazo deve ser NULO (sem prazo) OU estar no futuro.
                                       .where("formularios.prazo IS NULL OR formularios.prazo > ?", Time.current)
                                       .distinct

    formularios_respondidos_ids = self.resposta_formularios.pluck(:formulario_id)
    formularios_das_turmas.where.not(id: formularios_respondidos_ids)
  end
  # ===============================================================

  ##
  # Configuração do Devise para autenticação.
  #
  # Descrição: Configura o modelo `Usuario` para usar as funcionalidades
  #    de autenticação do Devise, incluindo autenticação baseada em banco de dados,
  #    registro, recuperação de senha e autenticação JWT. A estratégia de revogação
  #    JWT é definida para `JwtDenylist`.
  # Argumentos: Nenhum.
  # Retorno: Nenhum valor explícito.
  # Efeitos colaterais: Configura o comportamento de autenticação do usuário.
  devise :database_authenticatable, :registerable,
         :recoverable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  ##
  # Classe auxiliar para uma estratégia de revogação JWT nula.
  #
  # Descrição: Esta classe é uma implementação de uma estratégia de revogação
  #    JWT que não faz nada. É usada para fins de teste ou quando a revogação
  #    de JTI não é desejada.
  class NullDenylist
    ##
    # Método de revogação de JTI (vazio).
    #
    # Descrição: Não executa nenhuma ação de revogação.
    # Argumentos:
    #    - `jti`: O JTI (JWT ID) do token.
    #    - `exp`: A data de expiração do token.
    # Retorno: Nenhum valor explícito.
    # Efeitos colaterais: Nenhum.
    def self.revoke_jti(jti, exp); end

    ##
    # Verifica se um JTI foi revogado (sempre falso).
    #
    # Descrição: Sempre retorna `false`, indicando que nenhum JTI é considerado revogado.
    # Argumentos:
    #    - `jti`: O JTI (JWT ID) a ser verificado.
    # Retorno: `false`.
    # Efeitos colaterais: Nenhum.
    def self.jti_revoked?(jti); false; end

    ##
    # Verifica se um JWT foi revogado (sempre falso).
    #
    # Descrição: Delega a verificação para `jti_revoked?`, que sempre retorna `false`.
    # Argumentos:
    #    - `payload`: O payload do JWT.
    #    - `user`: O objeto do usuário.
    # Retorno: `false`.
    # Efeitos colaterais: Nenhum.
    def self.jwt_revoked?(payload, user); jti_revoked?(payload["jti"]); end
  end

  ##
  # Define a estratégia de revogação JWT para `NullDenylist`.
  #
  # Descrição: Atribui a `NullDenylist` como a estratégia de revogação JWT
  #    para este modelo, o que significa que a revogação de tokens não será
  #    efetivamente persistida ou verificada (a menos que seja alterado).
  # Argumentos: Nenhum.
  # Retorno: Nenhum valor explícito.
  # Efeitos colaterais: Configura o comportamento de revogação de JWT.
  self.jwt_revocation_strategy = NullDenylist

  ##
  # Validação de complexidade da senha.
  #
  # Descrição: Aplica uma validação de complexidade à senha do usuário.
  #    É executada apenas quando um novo registro é criado ou quando a senha
  #    existente é atualizada.
  # Argumentos: Nenhum.
  # Retorno: `true` se a validação passar, `false` caso contrário.
  # Efeitos colaterais: Adiciona erros ao objeto se a senha não atender aos requisitos de complexidade.
  validates :password, password_complexity: true, if: -> { new_record? || password.present? }

  ##
  # Retorna o comprimento permitido para a senha.
  #
  # Descrição: Define o range de comprimento mínimo e máximo para as senhas
  #    dos usuários.
  # Argumentos: Nenhum.
  # Retorno: Um `Range` (ex: `10..128`) indicando o comprimento permitido da senha.
  # Efeitos colaterais: Nenhum.
  def self.password_length
    10..128
  end

  ##
  # Encontra um usuário para autenticação de banco de dados.
  #
  # Descrição: Este método é sobrescrito do Devise para permitir a autenticação
  #    de usuários tanto por `email` quanto por `matricula`, ignorando o caso
  #    (maiúsculas/minúsculas) para ambos os campos.
  # Argumentos:
  #    - `warden_conditions`: Um hash de condições fornecido pelo Warden (Devise).
  # Retorno: O objeto `Usuario` encontrado, ou `nil` se nenhum usuário corresponder às condições.
  # Efeitos colaterais: Nenhum.
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if (login = conditions.delete(:login))
      where(conditions.to_h).where([
        "lower(email) = :value OR lower(matricula) = :value",
        { value: login.downcase }
      ]).first
    elsif conditions.has_key?(:email) || conditions.has_key?(:matricula)
      where(conditions.to_h).first
    end
  end

  ##
  # Associação: Possui muitas `Turmas` lecionadas.
  #
  # Descrição: Define a relação onde um `Usuario` (professor) pode lecionar
  #    múltiplas turmas. O `foreign_key` é especificado como `professor_id`.
  # Argumentos: Nenhum.
  # Retorno: Uma coleção de objetos `Turma` lecionados por este usuário.
  # Efeitos colaterais: Gerencia a associação entre Usuários e Turmas lecionadas.
  has_many :turmas_lecionadas, class_name: 'Turma', foreign_key: 'professor_id'

  ##
  # Associação: Possui muitos `Formularios` criados.
  #
  # Descrição: Define a relação onde um `Usuario` pode ter criado múltiplos
  #    `Formularios`. O `foreign_key` é especificado como `criador_id`.
  # Argumentos: Nenhum.
  # Retorno: Uma coleção de objetos `Formulario` criados por este usuário.
  # Efeitos colaterais: Gerencia a associação entre Usuários e Formulários criados.
  has_many :formularios_criados, class_name: 'Formulario', foreign_key: 'criador_id'

  ##
  # Associação: Possui muitas `Respostas` enviadas.
  #
  # Descrição: Define a relação onde um `Usuario` pode ter enviado múltiplas
  #    `Respostas`. O `foreign_key` é especificado como `avaliador_id`.
  #    (Nota: A classe `Resposta` pode ser um alias ou um modelo específico
  #    para respostas, dependendo da estrutura da sua aplicação. Se for
  #    `RespostaFormulario`, considere ajustar o `class_name`.)
  # Argumentos: Nenhum.
  # Retorno: Uma coleção de objetos `Resposta` enviados por este usuário.
  # Efeitos colaterais: Gerencia a associação entre Usuários e Respostas enviadas.
  has_many :respostas_enviadas, class_name: 'Resposta', foreign_key: 'avaliador_id'
end
