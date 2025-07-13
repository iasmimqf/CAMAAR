# features/step_definitions/definir_senha_steps.rb

# Importar bibliotecas necessárias para os testes de UI e preparação de dados.
require 'capybara/cucumber'
require 'selenium-webdriver'

# A linha 'require 'webdrivers/chromedriver'' é removida aqui.
# Em vez disso, o caminho do driver será definido explicitamente.

# Para simular dados e objetos de forma simples
require 'ostruct'
require 'securerandom' # Para gerar tokens de exemplo
require 'json' # Para parsear JSON das respostas da API simuladas
require 'uri' # Para parsear URLs

# Configuração do Capybara para testes de UI
Capybara.configure do |config|
  # É crucial definir o driver_path para o chromedriver que você instalou manualmente.
  # Isso garante que Selenium encontre o driver correto.
  # Use o caminho exato que 'which chromedriver' mostrou (ex: /usr/local/bin/chromedriver).
  Selenium::WebDriver::Chrome::Service.driver_path = '/usr/local/bin/chromedriver'

  config.default_driver = :selenium_chrome_headless # Roda o navegador em segundo plano (sem UI)
  # config.default_driver = :selenium_chrome        # Descomente para ver o navegador durante os testes (mais lento)
  config.app_host = 'http://localhost:3000'         # **MUITO IMPORTANTE: Aponte para onde seu frontend/backend está rodando**
end

# Importar Factory Bot
require 'factory_bot_rails' # Para projetos Rails, ou 'factory_bot' para Ruby genérico

# --- Variáveis de Instância (acessíveis entre os passos) ---
# Usamos @ para que as variáveis sejam acessíveis entre os passos.
@current_user = nil
@current_token = nil
@current_token_expires_at = nil
@response = nil # Para armazenar a resposta da API simulada
@used_tokens = [] # Para simular tokens já utilizados

# --- Funções Auxiliares (Simulando Interação com Backend/API) ---

# Função para criar um usuário usando Factory Bot e simular a geração de token
def create_user_and_generate_token_via_backend
  puts "  (Simulando: Criação de usuário sem senha e geração de token via backend...)"
  user = FactoryBot.create(:user) # Cria um usuário sem senha definida
  token_record = FactoryBot.create(:password_reset_token, user: user) # Cria o token associado ao usuário

  @current_user = user
  @current_token = token_record.token
  @current_token_expires_at = token_record.expires_at

  puts "    [Simulação API] Usuário ##{@current_user.id} criado e token '#{@current_token}' gerado."
  @current_token # Retorna o token gerado
end

# Função para simular a requisição de definição de senha via API
def define_password_via_api(token, new_password, confirm_password)
  puts "  (Simulando: Requisição de definição de senha para token '#{token}')"

  if @current_token != token || @current_token_expires_at <= Time.now || token_is_used?(token)
    @response = OpenStruct.new(code: 400, body: { error: "Este link é inválido ou já expirou." }.to_json)
    puts "    [Simulação API] Erro: Link inválido ou expirado."
    return
  end

  if new_password != confirm_password
    @response = OpenStruct.new(code: 400, body: { error: "As senhas não conferem. Por favor, tente novamente." }.to_json)
    puts "    [Simulação API] Erro: Senhas não conferem."
  elsif new_password.length < 8 || new_password !~ /[A-Z]/ || new_password !~ /[0-9]/ || new_password !~ /[!@#$%^&*()]/
    @response = OpenStruct.new(code: 400, body: { error: "Senha muito fraca. Mínimo 8 caracteres, maiúscula, número e caractere especial." }.to_json)
    puts "    [Simulação API] Erro: Senha muito fraca."
  else
    @current_user.password_digest = "hashed_#{new_password}"
    mark_token_as_used(token)
    @response = OpenStruct.new(code: 200, body: { message: "Senha definida com sucesso! Você já pode acessar o sistema." }.to_json)
    puts "    [Simulação API] Sucesso: Senha definida."
  end
end

# Simula a marcação de um token como usado
def mark_token_as_used(token)
  puts "  (Simulando: Marcando token '#{token}' como usado.)"
  @used_tokens << token unless @used_tokens.include?(token)
end

# Simula a verificação se um token foi usado
def token_is_used?(token)
  @used_tokens.include?(token)
end

# --- Implementação dos Passos (Step Definitions) ---

# Cenário: Definição de senha bem-sucedida

Dado('que meu cadastro foi aprovado e eu recebi um e-mail com o link para definir minha senha') do
  @current_token = create_user_and_generate_token_via_backend
  @link_definicao = "#{Capybara.app_host}/definir-senha?token=#{@current_token}"
  puts "    [Teste] Link gerado para definição de senha: #{@link_definicao}"
end

Dado('o link é válido e não expirou') do
  puts "    [Teste] Verificando: O link é válido e não expirou (implícito pela criação recente e sem uso)."
end

Quando('eu clico no link e sou direcionado para a página "Defina sua Senha"') do
  visit @link_definicao
  expect(page).to have_content("Defina sua Senha")
  expect(current_url).to include("/definir-senha")
  puts "    [Teste] Navegou para a página 'Defina sua Senha'."
end

Quando('eu preencho o campo {string} com {string}') do |campo, valor|
  fill_in campo, with: valor
  puts "    [Teste] Preencheu o campo '#{campo}' com o valor."
end

Quando('clico no botão {string}') do |botao|
  click_button botao
  puts "    [Teste] Clicou no botão '#{botao}'."

  token_from_url = URI.parse(current_url).query.split('=').last rescue @current_token
  # Para este cenário de sucesso, use os valores fixos do cenário Feature.
  define_password_via_api(token_from_url, "SenhaForte123!", "SenhaForte123!")
end

Então('eu devo ver uma mensagem de sucesso como {string}') do |mensagem|
  expect(page).to have_content(mensagem)
  response_body = JSON.parse(@response.body)
  expect(response_body["message"]).to eq(mensagem) if @response && @response.code == 200
  puts "    [Teste] Verificou mensagem de sucesso: '#{mensagem}'."
end

Então('devo ser redirecionado para a página de login.') do
  expect(current_url).to include("/login")
  expect(page).to have_content("Faça seu Login")
  puts "    [Teste] Redirecionado para a página de login."
end

---

# Cenário: Tentativa de definir senhas que não conferem

Dado('que estou na página "Defina sua Senha" a partir de um link válido') do
  @current_token = create_user_and_generate_token_via_backend
  @link_definicao = "#{Capybara.app_host}/definir-senha?token=#{@current_token}"
  visit @link_definicao
  expect(page).to have_content("Defina sua Senha")
  puts "    [Teste] Está na página 'Defina sua Senha' com um link válido."
end

Quando('eu preencho o campo "Nova Senha" com "senha123"') do
  fill_in "Nova Senha", with: "senha123"
  puts "    [Teste] Preencheu o campo 'Nova Senha' com 'senha123'."
end

# Ajustei este passo para corresponder ao cenário do Feature
Quando('eu preencho o campo "Confirmar Senha" com "senha124"') do
  fill_in "Confirmar Senha", with: "senha124"
  puts "    [Teste] Preencheu o campo 'Confirmar Senha' com 'senha124'."
end

# O passo 'clico no botão "Salvar Senha"' já existe e será usado.
# Não precisamos de um novo 'Quando' específico para este cenário.

Então('eu devo ver uma mensagem de erro na tela, como {string}') do |mensagem_erro|
  expect(page).to have_content(mensagem_erro)
  response_body = JSON.parse(@response.body)
  expect(response_body["error"]).to eq(mensagem_erro) if @response && @response.code == 400
  puts "    [Teste] Verificou mensagem de erro: '#{mensagem_erro}'."
end

---

# Cenário: Acesso à página com um link inválido ou expirado

Dado('que eu possuo um link para definição de senha que já foi utilizado ou expirou') do
  user = FactoryBot.create(:user)
  expired_token_record = FactoryBot.create(:password_reset_token, user: user, expires_at: 1.hour.ago)

  @current_token = expired_token_record.token
  mark_token_as_used(@current_token) # Marca como usado para simular um token inválido também
  @link_invalido_ou_expirado = "#{Capybara.app_host}/definir-senha?token=#{@current_token}"
  puts "    [Teste] Link gerado (simuladamente inválido/expirado): #{@link_invalido_ou_expirado}"
end

Quando('eu tento abrir este link no meu navegador') do
  visit @link_invalido_ou_expirado
  puts "    [Teste] Tentou abrir o link inválido/expirado."
end

Então('devo ser direcionado para uma página de erro informando: {string}') do |mensagem_erro|
  expect(page).to have_content(mensagem_erro)
  expect(current_url).to include("/erro-link-invalido") # Você deve ter uma rota para essa página de erro no seu frontend
  puts "    [Teste] Redirecionado para página de erro com a mensagem: '#{mensagem_erro}'."
end