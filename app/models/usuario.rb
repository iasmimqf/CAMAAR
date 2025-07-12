class Usuario < ApplicationRecord
  # Cria o atributo virtual 'login' para ser usado no formulário
  attr_writer :login

  def login
    @login || self.email || self.matricula
  end

  def admin?
    self.admin == true
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # --- Método de Autenticação Customizado ---
  # Este é o método que o Devise usa para encontrar o usuário no banco de dados.
  def self.find_for_database_authentication(warden_conditions)
    # Cria uma cópia das condições para não modificar o original
    conditions = warden_conditions.dup

    # Pega o valor do campo 'login' que veio do formulário e o remove das condições
    if (login = conditions.delete(:login))
      # Executa a busca no banco de dados.
      # 1. where(conditions.to_h) -> aplica outras condições, se houver.
      # 2. where(["lower..."]) -> faz a busca principal.
      where(conditions.to_h).where(["lower(email) = :value OR lower(matricula) = :value",
                                     { :value => login.downcase}]).first # Pega o primeiro usuário que encontrar
    elsif conditions.has_key?(:email) || conditions.has_key?(:matricula)
      # Fallback para o caso de o login vir por outros meios
      where(conditions.to_h).first
    end
  end

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