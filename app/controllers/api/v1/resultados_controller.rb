# app/controllers/api/v1/resultados_controller.rb
require 'csv'

class Api::V1::ResultadosController < Api::V1::BaseController
  # GET /api/v1/resultados
  def index
    # Esta ação busca todas as turmas e prepara um resumo para o frontend.
    # Adapte os campos `respostas_dos_formularios` e `alunos` para os nomes
    # corretos das suas associações no model Turma.
    turmas = Turma.includes(:disciplina).map do |turma|
      respostas_count = turma.respostas_dos_formularios.count
      {
        id: turma.id,
        nome_turma: turma.codigo_turma,
        nome_disciplina: turma.disciplina.nome,
        semestre: turma.semestre,
        tem_respostas: respostas_count > 0,
        respondidos: respostas_count,
        enviados: turma.alunos.count
      }
    end

    render json: turmas
  end

  # GET /api/v1/resultados/exportar
  def exportar
    turma_ids = params[:turma_ids]
    
    unless turma_ids.present? && turma_ids.is_a?(Array)
      return render json: { error: 'Nenhuma turma selecionada' }, status: :bad_request
    end
    
    turmas = Turma.where(id: turma_ids).includes(:disciplina)
    
    # Gera o nome do arquivo de forma dinâmica.
    disciplina_nome = turmas.first.disciplina.nome.parameterize.underscore
    ids_string = turmas.map(&:id).join('_')
    filename = "resultados_turmas_#{ids_string}_#{disciplina_nome}.csv"

    # Gera o conteúdo do CSV.
    csv_data = CSV.generate(headers: true) do |csv|
      csv << ["Turma", "Disciplina", "Média Professor", "Média Disciplina", "Respondidos/Enviados"]
      
      turmas.each do |turma|
        # ATENÇÃO: A lógica para calcular as médias abaixo é um EXEMPLO.
        # Adapte para a sua realidade.
        media_prof = calcular_media_por_categoria(turma, 'professor')
        media_disc = calcular_media_por_categoria(turma, 'disciplina')
        respondidos_enviados = "#{turma.respostas_dos_formularios.count}/#{turma.alunos.count}"
        
        csv << [turma.codigo_turma, turma.disciplina.nome, media_prof, media_disc, respondidos_enviados]
      end
    end
    
    # Envia os dados do CSV como um arquivo para download.
    send_data csv_data, filename: filename, type: 'text/csv', disposition: 'attachment'
  end

  private

  # Este método é um EXEMPLO para calcular as médias.
  # Você precisará ajustar a consulta para corresponder à estrutura
  # dos seus models de Resposta, Questao e Categoria.
  def calcular_media_por_categoria(turma, categoria_nome)
    # Exemplo: Supondo que Resposta tenha `valor_numerico` e se associe
    # a uma Questao que tem uma Categoria com `nome`.
    respostas = turma.respostas_dos_formularios
                     .joins(questao: :categoria)
                     .where(categorias: { nome: categoria_nome })
    
    return 0.0 if respostas.empty?
    
    # Calcula a média e arredonda para 1 casa decimal.
    (respostas.average(:valor_numerico) || 0).round(1)
  end
end