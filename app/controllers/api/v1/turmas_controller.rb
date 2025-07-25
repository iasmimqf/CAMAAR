# Caminho: app/controllers/api/v1/turmas_controller.rb
class Api::V1::TurmasController < Api::V1::BaseController
  # Garante que apenas um administrador autenticado possa aceder a esta lista.
  before_action :authenticate_admin_access!

  ##
  # Lista todas as turmas disponíveis.
  #
  # Descrição: Busca todas as turmas do banco de dados, incluindo a informação
  #    da disciplina associada para otimização de consultas. As turmas são
  #    ordenadas pelo nome da disciplina em ordem ascendente. A resposta é
  #    formatada para ser facilmente consumida pelo frontend.
  # Argumentos: Nenhum.
  # Retorno:
  #    - `JSON`: Uma array de objetos JSON, onde cada objeto representa uma turma
  #      com `id`, `nome` (da disciplina), `semestre` e `codigo` (da turma).
  # Efeitos colaterais: Nenhum efeito colateral observável no banco de dados.
  #    - Comunicação via API: Envia uma resposta JSON ao cliente.
  # GET /api/v1/turmas
  def index
    # Busca todas as turmas, incluindo a informação da disciplina para ser mais eficiente
    turmas = Turma.includes(:disciplina).order("disciplinas.nome ASC")

    # Formata a resposta para ser fácil de usar no frontend
    render json: turmas.map { |turma|
      {
        id: turma.id,
        nome: turma.disciplina.nome,
        semestre: turma.semestre,
        codigo: turma.codigo_turma
      }
    }
  end
end
