# language: pt
Funcionalidade: Autenticação de Usuários no Sistema

Como um Usuário do sistema
Quero acessar o sistema utilizando um e-mail ou matrícula e uma senha já cadastrada
A fim de responder formulários e ter acesso às ferramentas de gerenciamento (caso seja administrador).

@javascript
Cenário: Login bem-sucedido do Administrador
    Dado que eu sou um administrador cadastrado com o e-mail "admin@meusistema.com" e a senha "Password123!"
    E que estou na página de login
    Quando eu insiro "admin@meusistema.com" no campo "E-mail ou Matrícula"
    E eu insiro "Password123!" no campo "Senha"
    E clico no botão "Entrar"
    Então devo ser autenticado com sucesso e redirecionado para o dashboard de administração

@javascript
Cenário: Login bem-sucedido do Usuário Padrão com e-mail
    Dado que eu sou um usuário padrão cadastrado com o e-mail "joao.silva@email.com" e a senha "Password123!"
    E que estou na página de login
    Quando eu insiro "joao.silva@email.com" no campo "E-mail ou Matrícula"
    E eu insiro "Password123!" no campo "Senha"
    E clico no botão "Entrar"
    Então devo ser autenticado com sucesso e redirecionado para a minha página inicial

@javascript
Cenário: Login bem-sucedido do Usuário Padrão com matrícula
    Dado que eu sou um usuário padrão cadastrado com a matrícula "98765" e a senha "Password123!"
    E que estou na página de login
    Quando eu insiro "98765" no campo "E-mail ou Matrícula"
    E eu insiro "Password123!" no campo "Senha"
    E clico no botão "Entrar"
    Então devo ser autenticado com sucesso e redirecionado para a minha página inicial

@javascript
Cenário: Tentativa de login com credenciais inválidas
    Dado que estou na página de login
    Quando eu insiro "usuario.inexistente@email.com" no campo "E-mail ou Matrícula"
    E eu insiro "Password123!" no campo "Senha"
    E clico no botão "Entrar"
    Então devo ver uma mensagem de erro indicando que "Login ou senha inválidos."

@javascript
Cenário: Tentativa de login de usuário com senha errada
    Dado que eu sou um usuário padrão cadastrado com o e-mail "admin@meusistema.com" e a senha "Password123!"
    E que estou na página de login
    Quando eu insiro "admin@meusistema.com" no campo "E-mail ou Matrícula"
    E eu insiro "senha-errada" no campo "Senha"
    E clico no botão "Entrar"
    Então devo ver uma mensagem de erro indicando que "Login ou senha inválidos."

@javascript
Cenário: Tentativa de login com campos vazios
    Dado que estou na página de login
    Quando eu deixo os campos de login vazios
    E clico no botão "Entrar"
    Então devo ver uma mensagem de erro de campos obrigatórios

@javascript
Cenário: Tentativa de login com e-mail inválido
    Dado que estou na página de login
    Quando eu insiro "email-malformado" no campo "E-mail ou Matrícula"
    E eu insiro "qualquersenha" no campo "Senha"
    E clico no botão "Entrar"
    Então devo ver uma mensagem de erro indicando que "Login ou senha inválidos."

@javascript
Cenário: Verificar redirecionamento correto do administrador
    Dado que eu sou um administrador cadastrado com o e-mail "admin@test.com" e a senha "SecurePass123!"
    E que estou na página de login
    Quando eu insiro "admin@test.com" no campo "E-mail ou Matrícula"
    E eu insiro "SecurePass123!" no campo "Senha"
    E clico no botão "Entrar"
    Então devo ser autenticado com sucesso e redirecionado para o dashboard de administração
    E devo ter acesso às funcionalidades administrativas