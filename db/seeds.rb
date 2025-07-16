# db/seeds.rb

puts "Populando o banco de dados com usuários de teste..."

# --- Usuário Administrador ---
# Ele procura um usuário com este e-mail. Se não encontrar, ele o cria.
Usuario.find_or_create_by!(email: 'admin@email.com') do |user|
  puts "Criando usuário admin..."
  user.nome = 'Admin do Sistema'
  user.password      = 'password123'
  user.password_confirmation      = 'password123'
  user.admin         = true
end

# --- Usuário Padrão (Aluno) ---
Usuario.find_or_create_by!(email: 'aluno@email.com') do |user|
  puts "Criando usuário aluno..."
  user.nome = 'Aluno Teste'
  user.matricula     = '02'
  user.password      = 'password123'
  user.password_confirmation      = 'password123'
  user.admin         = false
end

puts "Usuários de teste criados com sucesso!"
puts "----------------------------------------"
puts "Admin: admin@email.com | Senha: password123"
puts "Aluno: aluno@email.com | Senha: password123"
puts "----------------------------------------"