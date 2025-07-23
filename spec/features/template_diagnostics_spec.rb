# spec/features/template_diagnostics_spec.rb
require 'rails_helper'

RSpec.feature "Template System Diagnostics", type: :feature do
  let!(:admin_user) { create(:usuario, admin: true) }

  before do
    sign_in admin_user
  end

  scenario "Verificar acesso básico à lista de templates" do
    begin
      visit admin_templates_path
      puts "✅ Conseguiu acessar admin_templates_path"
      puts "URL atual: #{current_path}"
      puts "Conteúdo da página: #{page.body.first(500)}"
    rescue => e
      puts "❌ Erro ao acessar admin_templates_path: #{e.message}"
    end
  end

  scenario "Verificar rotas disponíveis" do
    puts "\n=== ROTAS DE TEMPLATES ==="
    routes_output = `bundle exec rails routes | findstr /i template`
    puts routes_output
  end

  scenario "Verificar se new_admin_template_path existe" do
    begin
      puts "\n=== TESTE DE new_admin_template_path ==="
      visit new_admin_template_path
      puts "✅ new_admin_template_path funciona!"
    rescue NoMethodError => e
      puts "❌ new_admin_template_path não existe: #{e.message}"
    rescue => e
      puts "❌ Outro erro em new_admin_template_path: #{e.message}"
    end
  end

  scenario "Verificar modelo Template" do
    puts "\n=== TESTE DO MODELO TEMPLATE ==="
    template = Template.new(titulo: "Teste")
    
    puts "Atributos disponíveis:"
    puts Template.attribute_names.inspect
    
    puts "Associações:"
    puts Template.reflect_on_all_associations.map(&:name).inspect
    
    if template.respond_to?(:criador)
      puts "✅ Template tem atributo criador"
    else
      puts "❌ Template NÃO tem atributo criador"
    end
    
    if template.respond_to?(:criador_id)
      puts "✅ Template tem atributo criador_id"
    else
      puts "❌ Template NÃO tem atributo criador_id"
    end
  end
end
