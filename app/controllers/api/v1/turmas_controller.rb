# Caminho: app/controllers/api/v1/turmas_controller.rb
class Api::V1::TurmasController < Api::V1::BaseController
  # Garante que apenas um administrador autenticado possa aceder a esta lista
  before_action :authenticate_admin_access!

  # GET /api/v1/turmas
  def index
    # Busca todas as turmas, incluindo a informação da disciplina para ser mais eficiente
    turmas = Turma.includes(:disciplina).order('disciplinas.nome ASC')
    
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