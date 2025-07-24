# Caminho: app/controllers/api/v1/importacoes_controller.rb
require "securerandom"

class Api::V1::ImportacoesController < Api::V1::BaseController
  before_action :authenticate_admin_access!

  # POST /api/v1/importacoes/importar_turmas
  # ESTA AÇÃO AGORA ESPERA O JSON DE TURMAS BÁSICO (com "name" e "class")
  def importar_turmas
    file = params[:file]
    return render json: { error: 'Nenhum arquivo de turmas enviado.' }, status: :bad_request unless file.present?

    results = []

    ActiveRecord::Base.transaction do
      turmas_basicas_data = JSON.parse(file.read)

      turmas_basicas_data.each do |turma_info|
        Rails.logger.info "Processando turma básica: #{turma_info['code']} - #{turma_info['class']['classCode']} - #{turma_info['class']['semester']}"
        begin
          # 1. Encontrar ou criar a Disciplina
          disciplina = Disciplina.find_or_create_by!(codigo: turma_info['code']) do |d|
            d.nome = turma_info['name'] # O nome da disciplina vem do JSON aqui!
            d.descricao = "Disciplina importada automaticamente via JSON de turmas."
          end
          Rails.logger.info "  Disciplina (ID: #{disciplina.id}, Código: #{disciplina.codigo}) - Criada/Encontrada."

          # 2. Encontrar ou criar a Turma
          turma_class_info = turma_info['class']
          turma = Turma.find_or_create_by!(
            disciplina: disciplina,
            codigo_turma: turma_class_info['classCode'],
            semestre: turma_class_info['semester']
          ) do |t|
            t.horario = turma_class_info['time'] # Horário vem do JSON aqui
            # Professor não vem neste JSON, então será nulo inicialmente ou ajustado depois
            # t.professor = nil # Ou um professor padrão
          end
          Rails.logger.info "  Turma (ID: #{turma.id}, Código: #{turma.codigo_turma}) - Criada/Encontrada."

          results << {
            status: 'success',
            type: 'turma_basica',
            turma_id: turma.id,
            disciplina_codigo: disciplina.codigo,
            codigo_turma: turma.codigo_turma,
            semestre: turma.semestre,
            horario: turma.horario
          }

        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.error "Erro de validação ao processar turma básica: #{e.message} - Dados: #{turma_info.inspect}"
          results << { status: 'error', message: "Erro de validação ao processar turma: #{e.message}", data: turma_info }
        rescue StandardError => e
          Rails.logger.error "Erro inesperado ao processar turma básica: #{e.message} - Dados: #{turma_info.inspect}"
          results << { status: 'error', message: "Erro inesperado ao processar turma: #{e.message}", data: turma_info }
        end
      end
    end

    render json: { message: 'Turmas importadas com sucesso!', results: results }, status: :ok

  rescue JSON::ParserError => e
    Rails.logger.error "Arquivo JSON inválido para importar_turmas: #{e.message}"
    render json: { error: 'Arquivo JSON de turmas inválido. Certifique-se de que o arquivo contém JSON válido.' }, status: :unprocessable_entity
  rescue StandardError => e
    Rails.logger.error "Ocorreu um erro geral durante a importação de turmas: #{e.message}"
    render json: { error: "Ocorreu um erro geral durante a importação de turmas: #{e.message}" }, status: :internal_server_error
  end

  # POST /api/v1/importacoes/importar_alunos
  # ESTA AÇÃO ESPERA O JSON COMPLETO COM TURMAS, DOCENTES E DISCENTES ANINHADOS
  def importar_alunos
    file = params[:file]
    return render json: { error: 'Nenhum arquivo de alunos enviado.' }, status: :bad_request unless file.present?

    results = []

    ActiveRecord::Base.transaction do
      turmas_completas_data = JSON.parse(file.read) # Renomeado para clareza

      turmas_completas_data.each do |turma_info| # Cada 'turma_info' aqui é um objeto de turma completa
        Rails.logger.info "Processando importação de alunos (e turma/professor) para turma: #{turma_info['code']} - #{turma_info['classCode']} - #{turma_info['semester']}"
        begin
          # 1. Encontrar ou criar a Disciplina (do JSON de alunos)
          disciplina = Disciplina.find_or_create_by!(codigo: turma_info['code']) do |d|
            d.nome = "Nome da Disciplina para #{turma_info['code']}" # ATENÇÃO: Nome da disciplina não vem aqui, precisa de lógica
            d.descricao = "Disciplina importada via importação de alunos."
          end
          Rails.logger.info "  Disciplina (ID: #{disciplina.id}, Código: #{disciplina.codigo}) - Criada/Encontrada."

          # 2. Encontrar ou criar o Docente (Professor)
          docente_json = turma_info['docente']
          professor = Usuario.find_or_initialize_by(matricula: docente_json['usuario']) do |u|
            u.nome = docente_json['nome']
            u.email = docente_json['email']
            u.ocupacao = docente_json['ocupacao']
            u.formacao = docente_json['formacao']
            u.password = SecureRandom.urlsafe_base64(10) + "Aa!2" if u.new_record? || u.encrypted_password.blank?
            u.password_confirmation = u.password if u.new_record? || u.encrypted_password.blank?
          end

          should_send_reset_email_for_professor = professor.new_record? || professor.encrypted_password.blank?
          Rails.logger.info "  Professor (Matrícula: #{professor.matricula}, Email: #{professor.email}) - new_record?: #{professor.new_record?}, encrypted_password.blank?: #{professor.encrypted_password.blank?}"
          Rails.logger.info "  -> should_send_reset_email_for_professor: #{should_send_reset_email_for_professor}"

          professor.save!
          Rails.logger.info "  Professor salvo. ID: #{professor.id}"

          # CORREÇÃO AQUI: TIRADO O 'reset' DUPLICADO DA VARIÁVEL
          if should_send_reset_email_for_professor # <-- CORRIGIDO AQUI!
            Rails.logger.info "  -> Enviando instruções de redefinição de senha para professor #{professor.email}..."
            professor.send_reset_password_instructions
          else
            Rails.logger.info "  -> Não enviando instruções para professor #{professor.email} (já existe ou já tem senha)."
          end

          # 3. Encontrar ou criar a Turma (usando os dados da 'turma_info' que contém os alunos)
          turma = Turma.find_or_create_by!(
            disciplina: disciplina,
            codigo_turma: turma_info['classCode'],
            semestre: turma_info['semester']
          ) do |t|
            t.horario = turma_info['class']['time'] if turma_info['class'] && turma_info['class']['time'].present? # Se o horário estiver no JSON de alunos
            # REMOVIDO: t.professor = professor (para evitar 'wrong number of arguments')
          end
          # Atribua o professor APÓS a turma ser criada/encontrada
          turma.professor = professor unless turma.professor == professor
          turma.save! # Salva a turma com o professor atribuído, se houver mudança
          Rails.logger.info "  Turma (ID: #{turma.id}, Código: #{turma.codigo_turma}, Professor: #{turma.professor&.matricula}) - Criada/Encontrada."

          turma.usuarios << professor unless turma.usuarios.include?(professor)

          discentes_count = 0
          if turma_info['dicente'].present?
            turma_info['dicente'].each do |dicente_json|
              aluno = Usuario.find_or_initialize_by(matricula: dicente_json['matricula']) do |u|
                u.nome = dicente_json['nome']
                u.email = dicente_json['email']
                u.ocupacao = dicente_json['ocupacao'] || 'dicente'
                u.formacao = dicente_json['formacao']
                u.curso = dicente_json['curso']
                u.admin = false
                u.password = SecureRandom.urlsafe_base64(10) + "Aa!2" if u.new_record? || u.encrypted_password.blank?
                u.password_confirmation = u.password if u.new_record? || u.encrypted_password.blank?
              end

              should_send_reset_email_for_aluno = aluno.new_record? || aluno.encrypted_password.blank?
              Rails.logger.info "    Aluno (Matrícula: #{aluno.matricula}, Email: #{aluno.email}) - new_record?: #{aluno.new_record?}, encrypted_password.blank?: #{aluno.encrypted_password.blank?}"
              Rails.logger.info "    -> should_send_reset_email_for_aluno: #{should_send_reset_email_for_aluno}"

              aluno.save!
              Rails.logger.info "    Aluno salvo. ID: #{aluno.id}"

              if should_send_reset_email_for_aluno
                Rails.logger.info "    -> Enviando instruções de redefinição de senha para aluno #{aluno.email}..."
                aluno.send_reset_password_instructions
              else
                Rails.logger.info "    -> Não enviando instruções para aluno #{aluno.email} (já existe ou já tem senha)."
              end

              turma.usuarios << aluno unless turma.usuarios.include?(aluno)
              discentes_count += 1
            end
          end

          results << {
            status: 'success',
            type: 'turma_completa',
            turma_id: turma.id,
            disciplina_codigo: disciplina.codigo,
            codigo_turma: turma.codigo_turma,
            semestre: turma.semestre,
            professor_matricula: professor.matricula,
            discentes_importados: discentes_count
          }

        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.error "Erro de validação ao processar turma completa: #{e.message} - Dados: #{turma_info.inspect}"
          results << { status: 'error', message: "Erro de validação ao processar aluno/turma: #{e.message}", data: turma_info }
        rescue StandardError => e
          Rails.logger.error "Erro inesperado ao processar turma completa: #{e.message} - Dados: #{turma_info.inspect}"
          results << { status: 'error', message: "Erro inesperado ao processar aluno/turma: #{e.message}", data: turma_info }
        end
      end
    end

    render json: { message: 'Alunos importados com sucesso!', results: results }, status: :ok

  rescue JSON::ParserError => e
    Rails.logger.error "Arquivo JSON inválido para importar_alunos: #{e.message}"
    render json: { error: 'Arquivo JSON de alunos inválido. Certifique-se de que o arquivo contém JSON válido.' }, status: :unprocessable_entity
  rescue StandardError => e
    Rails.logger.error "Ocorreu um erro geral durante a importação de alunos: #{e.message}"
    render json: { error: "Ocorreu um erro geral durante a importação de alunos: #{e.message}" }, status: :internal_server_error
  end

  private
  # (Seu authenticate_admin_access! ou outros métodos privados)
end