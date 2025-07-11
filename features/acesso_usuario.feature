Funcionalidade: Acesso do Usuário ao Sistema

História de Usuário:

Como um Usuário do sistema
Quero acessar o sistema utilizando um e-mail ou matrícula e uma senha já cadastrada
A fim de responder formulários.

Cenário: Login bem-sucedido com e-mail
    Contexto:
        Dado que eu sou um usuário padrão cadastrado com o e-mail "joao.silva@email.com" e a senha "senha123"
        E eu estou na página de login
    
    Quando eu insiro "joao.silva@email.com" no campo de usuário
    E insiro "senha123" no campo de senha
    E clico no botão "Entrar"
    Então devo ser autenticado com sucesso e redirecionado para a minha página inicial
    E o menu de navegação não deve exibir a opção "Gerenciamento".

Cenário: Login bem-sucedido com matrícula
    Contexto:
        Dado que eu sou um usuário padrão cadastrado com a matrícula "98765" e a senha "senha123"
        E eu estou na página de login
    
    Quando eu insiro "98765" no campo de usuário
    E insiro "senha123" no campo de senha
    E clico no botão "Entrar"
    Então devo ser autenticado com sucesso e redirecionado para a minha página inicial
    E o menu de navegação não deve exibir a opção "Gerenciamento".

Cenário: Tentativa de login com credenciais inválidas
    Contexto:
        Dado que eu estou na página de login
        Quando eu insiro "usuario.inexistente@email.com" no campo de usuário
    
    E insiro "senha123" no campo de senha
    E clico no botão "Entrar"
    Então devo ver uma mensagem de erro indicando que "O usuário ou a senha estão incorretos"
    E devo permanecer na página de login.
