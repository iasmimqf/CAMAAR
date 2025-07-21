# app/controllers/api/v1/formularios_controller.rb
class Api::V1::FormulariosController < ApplicationController
  # 1. Garante que apenas usuários logados possam acessar esta API.
  #    Como sua model é 'Usuario', o helper do Devise é 'authenticate_usuario!'
  before_action :authenticate_usuario!

  def index
    # 2. Verifica se o usuário logado é admin ou não para decidir quais formulários buscar.
    if current_usuario.admin?
      # Lógica para Admin: Pega todos os formulários.
      # Usamos .includes para carregar as associações de uma vez e evitar múltiplas queries (problema de N+1).
      formularios = Formulario.includes(:template, turmas: :disciplina).order(created_at: :desc)
    else
      # Lógica para Aluno: Usa o método que você já criou na model Usuario.
      # Também usamos .includes para otimizar.
      formularios = current_usuario.formularios_pendentes.includes(:template, turmas: :disciplina)
    end

    # 3. Formata os dados para o formato JSON que o frontend React espera.
    formularios_formatados = formularios.map do |form|
      # NOTA: Um formulário pode estar em várias turmas. Para simplificar a exibição,
      # estamos pegando os dados da primeira turma da lista.
      turma_principal = form.turmas.first

      {
        id: form.id,
        # ASSUMINDO que o nome do formulário vem do template associado.
        nome: form.template.nome, 
        # ASSUMINDO que o formulário tem um campo :prazo (data limite).
        prazo: form.try(:prazo) ? form.prazo.strftime("%d/%m/%Y") : "Não definido", 
        disciplina: turma_principal&.disciplina&.nome || "Não definida",
        turma: turma_principal&.nome_completo || "Não definida"
      }
    end

    # 4. Renderiza a lista como JSON.
    render json: formularios_formatados
  end
end