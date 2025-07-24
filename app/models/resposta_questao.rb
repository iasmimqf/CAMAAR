class RespostaQuestao < ApplicationRecord
  self.table_name = "resposta_questoes"

  belongs_to :resposta_formulario
  belongs_to :questao


  validates :questao_id, presence: true
  validates :resposta_formulario_id, presence: true
  validates :questao_id, uniqueness: { scope: :resposta_formulario_id }

  validate :resposta_adequada_ao_tipo

  private

  def resposta_adequada_ao_tipo
    # Segurança: Se não tiver questao carregada, já retorna erro.
    if questao.nil?
      errors.add(:base, "Questão não está associada corretamente.")
      return
    end

    # Garante que valor_resposta não seja nil para facilitar validação
    resposta_valor = valor_resposta || (questao.tipo == 'Texto' ? nil : [])

    puts "DEBUG valor_resposta: #{valor_resposta.inspect} (#{valor_resposta.class})"
    
    case questao.tipo
    when "Escala"
      if valor_resposta.blank?
        errors.add(:valor_resposta, "é obrigatório para questões de escala")
      elsif !valor_resposta.between?(1, 5)
        errors.add(:valor_resposta, "deve estar entre 1 e 5")
      end
    when "Texto"
      if questao.obrigatoria && texto_resposta.blank?
        errors.add(:base, "A resposta para a questão '#{questao.enunciado}' é obrigatória.")
      end
      # Não valida valor_resposta nesse caso, pois não usado.

    when 'Checkbox'
      unless resposta_valor.is_a?(Array)
        errors.add(:base, "A resposta para a questão '#{questao.enunciado}' deve ser uma lista de opções.")
        return
      end

      if questao.obrigatoria && resposta_valor.empty?
        errors.add(:base, "É necessário selecionar ao menos uma opção para a questão '#{questao.enunciado}'.")
        return
      end

      max_opcao_index = questao.opcoes_array.size - 1
      resposta_valor.each do |opcao_selecionada|
        unless opcao_selecionada.is_a?(Integer) && opcao_selecionada.between?(0, max_opcao_index)
          errors.add(:base, "A opção selecionada não é válida para a questão '#{questao.enunciado}'.")
        end
      end

    else
      errors.add(:base, "Tipo de questão desconhecido: #{questao.tipo}")
    end
  end
end