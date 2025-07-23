# Caminho: app/controllers/api/v1/importacoes_controller.rb
class Api::V1::ImportacoesController < Api::V1::BaseController
  before_action :authenticate_admin_access!

  # POST /api/v1/importacoes/importar_turmas
  def importar_turmas
    file = params[:file]
    return render json: { error: 'Nenhum arquivo enviado.' }, status: :bad_request unless file.present?

    ActiveRecord::Base.transaction do
      turmas_data = JSON.parse(file.read)
      turmas_data.each do |turma_info|
        disciplina = Disciplina.find_or_create_by!(codigo: turma_info['disciplina_codigo']) do |d|
          d.nome = turma_info['disciplina_nome']
        end

        professor = Usuario.find_or_create_by!(email: turma_info['professor_email']) do |u|
          u.password = 'Professor@123'
          u.nome = turma_info['professor_email'].split('@').first.titleize
          u.matricula = "P#{SecureRandom.hex(4)}"
        end

        Turma.find_or_create_by!(
          disciplina: disciplina,
          codigo_turma: turma_info['codigo_turma'],
          semestre: turma_info['semestre']
        ) do |t|
          t.professor = professor
        end
      end
    end

    render json: { message: 'Turmas importadas com sucesso!' }, status: :ok
  rescue JSON::ParserError
    render json: { error: 'Arquivo JSON inválido.' }, status: :unprocessable_entity
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: "Erro de validação: #{e.message}" }, status: :unprocessable_entity
  end

  # POST /api/v1/importacoes/importar_alunos
  def importar_alunos
    file = params[:file]
    return render json: { error: 'Nenhum arquivo enviado.' }, status: :bad_request unless file.present?

    ActiveRecord::Base.transaction do
      alunos_data = JSON.parse(file.read)
      alunos_data.each do |aluno_info|
        # LÓGICA SIMPLIFICADA: Tenta criar cada aluno.
        # Se um email ou matrícula já existir, o `create!` irá falhar,
        # o que é bom, pois nos avisa de um problema nos dados.
        aluno = Usuario.create!(
          nome:      aluno_info['nome'],
          email:     aluno_info['email'],
          matricula: aluno_info['matricula'],
          password:  aluno_info['password'] || 'Aluno@1234',
          admin:     false
        )

        # Associa o aluno às turmas
        aluno_info['turmas'].each do |codigo_turma|
          turma = Turma.find_by(codigo_turma: codigo_turma)
          aluno.turmas << turma if turma && !aluno.turmas.include?(turma)
        end
      end
    end

    render json: { message: 'Alunos importados com sucesso!' }, status: :ok
  rescue JSON::ParserError
    render json: { error: 'Arquivo JSON inválido.' }, status: :unprocessable_entity
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: "Erro de validação: #{e.message}" }, status: :unprocessable_entity
  end
end