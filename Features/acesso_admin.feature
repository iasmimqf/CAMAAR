Funcionalidade: Acesso de Administrador e Gerenciamento do Sistema

História de Usuário:

Como um Admin do sistema
Quero acessar o sistema com minhas credenciais
A fim de ter acesso às ferramentas de gerenciamento.

Cenário: Login bem-sucedido do Administrador
    Contexto:
        Dado que eu sou um administrador cadastrado com o e-mail "admin@meusistema.com" e a senha "senhaSuperSecretaAdmin"
        E eu estou na página de login

    Quando eu insiro "admin@meusistema.com" no campo de usuário
    E insiro "senhaSuperSecretaAdmin" no campo de senha
    E clico no botão "Entrar"
    Então devo ser autenticado com sucesso e redirecionado para o dashboard de administração
    E o menu de navegação lateral deve exibir a opção "Gerenciamento".

Cenário: Tentativa de login de administrador com senha errada
    Contexto:
        Dado que eu sou um administrador cadastrado com o e-mail "admin@meusistema.com"
        E eu estou na página de login
    
    Quando eu insiro "admin@meusistema.com" no campo de usuário
    E insiro "senha-errada" no campo de senha
    E clico no botão "Entrar"
    Então devo ver uma mensagem de erro indicando que "O usuário ou a senha estão incorretos"
    E não devo ter acesso ao dashboard de administração.