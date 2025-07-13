# app/models/question.rb
class Question < ApplicationRecord
  belongs_to :template
  validates :prompt, presence: true
  validates :question_type, presence: true, inclusion: { in: %w[scale text] }
  validates :options, presence: true, if: -> { scale? }

  def scale?
    question_type == 'scale'
  end
end