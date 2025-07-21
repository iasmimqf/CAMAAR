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
    case questao.tipo
    when "Escala"
      if valor_resposta.blank?
        errors.add(:valor_resposta, "é obrigatório para questões de escala")
      elsif !valor_resposta.between?(1, 5)
        errors.add(:valor_resposta, "deve estar entre 1 e 5")
      end
    when "Texto"
      if questao.obrigatoria && texto_resposta.blank?
        errors.add(:texto_resposta, "é obrigatório")
      end
    end
  end
end
