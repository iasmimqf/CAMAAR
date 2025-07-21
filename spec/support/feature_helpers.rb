# spec/support/feature_helpers.rb
module FeatureHelpers
  def login_as_admin
    admin = create(:usuario, :admin)
    login_as(admin, scope: :usuario)
    admin
  end

  def login_as_user
    user = create(:usuario)
    login_as(user, scope: :usuario)
    user
  end

  def create_template_with_questions(title = "Template Teste")
    template = create(:template, titulo: title)
    create(:questao, :escala, template: template, enunciado: "Questão de escala")
    create(:questao, :texto, template: template, enunciado: "Questão de texto")
    template
  end
end

RSpec.configure do |config|
  config.include FeatureHelpers, type: :feature
  config.include Warden::Test::Helpers
end
