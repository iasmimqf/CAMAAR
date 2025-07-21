# language: pt
Funcionalidade: Autenticação de Usuários no Sistema

Como um Usuário do sistema
Quero acessar o sistema utilizando um e-mail ou matrícula e uma senha já cadastrada
A fim de responder formulários e ter acesso às ferramentas de gerenciamento (caso seja administrador).

Cenário: Login bem-sucedido do Administrador
    Dado que eu sou um administrador cadastrado com o e-mail "admin@meusistema.com" e a senha "Password123!"
    Quando eu insiro "admin@meusistema.com" no campo "E-mail ou Matrícula"
    E eu insiro "Password123!" no campo "Senha"
    E clico no botão "Entrar"
    Então devo ser autenticado com sucesso e redirecionado para o dashboard de administração

Cenário: Login bem-sucedido do Usuário Padrão com e-mail
    Dado que eu sou um usuário padrão cadastrado com o e-mail "joao.silva@email.com" e a senha "Password123!"
    Quando eu insiro "joao.silva@email.com" no campo "E-mail ou Matrícula"
    E eu insiro "Password123!" no campo "Senha"
    E clico no botão "Entrar"
    Então devo ser autenticado com sucesso e redirecionado para a minha página inicial

Cenário: Login bem-sucedido do Usuário Padrçao com matrícula
    Dado que eu sou um usuário padrão cadastrado com a matrícula "98765" e a senha "Password123!"
    Quando eu insiro "98765" no campo "E-mail ou Matrícula"
    E eu insiro "Password123!" no campo "Senha"
    E clico no botão "Entrar"
    Então devo ser autenticado com sucesso e redirecionado para a minha página inicial

Cenário: Tentativa de login com credenciais inválidas
    Quando eu insiro "usuario.inexistente@email.com" no campo "E-mail ou Matrícula"
    E eu insiro "Password123!" no campo "Senha"
    E clico no botão "Entrar"
    Então devo ver uma mensagem de erro indicando que "Login ou senha inválidos."


Cenário: Tentativa de login de usuário com senha errada
    Dado que eu sou um usuário padrão cadastrado com o e-mail "admin@meusistema.com" e a senha "Password123!"
    Quando eu insiro "admin@meusistema.com" no campo "E-mail ou Matrícula"
    E eu insiro "senha-errada" no campo "Senha"
    E clico no botão "Entrar"
    Então devo ver uma mensagem de erro indicando que "Login ou senha inválidos."