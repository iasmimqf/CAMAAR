# language: pt
Funcionalidade: Autenticação de Usuários no Sistema

Como um Usuário do sistema
Quero acessar o sistema utilizando um e-mail ou matrícula e uma senha já cadastrada
A fim de responder formulários e ter acesso às ferramentas de gerenciamento (caso seja administrador).

Cenário: Login bem-sucedido do Administrador
    Dado que eu sou um administrador cadastrado com o e-mail "admin@meusistema.com" e a senha "senhaSuperSecretaAdmin"
    E que eu estou na página de login
    Quando eu preencho o campo "E-mail ou Matrícula" com "admin@meusistema.com"
    E eu insiro "senhaSuperSecretaAdmin" no campo de "Senha"
    E clico no botão "Entrar"
    Então devo ser autenticado com sucesso e redirecionado para o dashboard de administração
    E o menu de navegação lateral deve exibir a opção "Gerenciamento".

Cenário: Login bem-sucedido do Usuário Padrão com e-mail
    Dado que eu sou um usuário padrão cadastrado com o e-mail "joao.silva@email.com" e a senha "senha123"
    E que eu estou na página de login
    Quando eu preencho o campo "E-mail ou Matrícula" com "joao.silva@email.com"
    E eu insiro "senha123" no campo de "Senha"
    E clico no botão "Entrar"
    Então devo ser autenticado com sucesso e redirecionado para a minha página inicial
    E o menu de navegação não deve exibir a opção "Gerenciamento".

Cenário: Login bem-sucedido do Usuário Padrçao com matrícula
    Dado que eu sou um usuário padrão cadastrado com a matrícula "98765" e a senha "senha123"
    E que eu estou na página de login
    Quando eu preencho o campo "E-mail ou Matrícula" com "98765"
    E eu insiro "senha123" no campo de "Senha"
    E clico no botão "Entrar"
    Então devo ser autenticado com sucesso e redirecionado para a minha página inicial
    E o menu de navegação não deve exibir a opção "Gerenciamento".

Cenário: Tentativa de login com credenciais inválidas
    Dado que eu estou na página de login
    Quando eu preencho o campo "E-mail ou Matrícula" com "usuario.inexistente@email.com"
    E eu insiro "senha123" no campo de "Senha"
    E clico no botão "Entrar"
    Então devo ver uma mensagem de erro indicando que "Login ou senha inválidos."
    E devo permanecer na página de login.


Cenário: Tentativa de login de usuário com senha errada
    Dado que eu sou um usuário cadastrado com o e-mail "admin@meusistema.com"
    E que eu estou na página de login
    Quando eu preencho o campo "E-mail ou Matrícula" com "admin@meusistema.com"
    E eu insiro "senha-errada" no campo de "Senha"
    E clico no botão "Entrar"
    Então devo ver uma mensagem de erro indicando que "Login ou senha inválidos."
    E não devo ter acesso ao dashboard de administração.