# app/models/resposta_questao.rb

class RespostaQuestao < ApplicationRecord
  self.table_name = 'resposta_questoes'

  belongs_to :resposta_formulario
  belongs_to :questao

  validates :questao_id, presence: true
  validates :resposta_formulario_id, presence: true
  validates :questao_id, uniqueness: { scope: :resposta_formulario_id }

  serialize :valor_resposta, JSON

  validate :resposta_adequada_ao_tipo

  private

  # ==================================================================
  # MÉTODO DE VALIDAÇÃO FINAL E CORRETO
  # ==================================================================
  def resposta_adequada_ao_tipo
    case questao.tipo
    when 'Escala'
      # 1. Valida se o valor é um array com um único número inteiro.
      unless valor_resposta.is_a?(Array) && valor_resposta.size == 1 && valor_resposta.first.is_a?(Integer)
        errors.add(:valor_resposta, "deve ser uma única opção para a escala.")
        return
      end

      valor_numerico = valor_resposta.first
      max_opcao_index = questao.opcoes_array.size - 1

      # ===============================================================
      # ▼▼▼ DEBUG ADICIONAL PARA DIAGNÓSTICO FINAL ▼▼▼
      # ===============================================================
      Rails.logger.debug "DEBUG VALIDAÇÃO ESCALA: Valor recebido=#{valor_numerico}, Opções válidas (índices)=0..#{max_opcao_index}, Opções=#{questao.opcoes_array.inspect}"

      # 2. Valida se o número está dentro do range de opções válidas (ex: 0 a 4).
      unless valor_numerico.between?(0, max_opcao_index)
        errors.add(:valor_resposta, "'#{valor_numerico}' não é uma opção válida para esta questão.")
      end

    when 'Texto'
      if questao.obrigatoria && texto_resposta.blank?
        errors.add(:texto_resposta, "é obrigatório")
      end

    when 'Checkbox'
      # 1. Valida se o valor é um array.
      unless valor_resposta.is_a?(Array)
        errors.add(:valor_resposta, "deve ser uma lista de opções.")
        return
      end

      if questao.obrigatoria && valor_resposta.empty?
        errors.add(:valor_resposta, "é obrigatório para questões de checkbox.")
        return
      end

      # 2. Valida se TODAS as opções selecionadas estão dentro do range válido.
      max_opcao_index = questao.opcoes_array.size - 1
      valor_resposta.each do |opcao_selecionada|
        unless opcao_selecionada.is_a?(Integer) && opcao_selecionada.between?(0, max_opcao_index)
          errors.add(:valor_resposta, "'#{opcao_selecionada}' não é uma opção válida.")
        end
      end
    end
  end
end
