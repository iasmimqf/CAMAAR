# app/models/template.rb
class Template < ApplicationRecord
  has_many :questions, dependent: :destroy
  accepts_nested_attributes_for :questions, allow_destroy: true, reject_if: :all_blank
  
  validates :title, presence: true, uniqueness: true
  validate :has_at_least_one_question

  private

  def has_at_least_one_question
    errors.add(:base, "Adicione pelo menos uma questão ao template") if questions.empty? || questions.all?(&:marked_for_destruction?)
  end
end
