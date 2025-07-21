Funcionalidade: Cadastro de Usuários do Sistema

História de Usuário:

Como um Administrador do sistema
Quero poder cadastrar novos usuários manualmente
A fim de incluir usuários que não foram importados via sincronização com o SIGAA

Cenário: cadastrar novo usuário de forma bem sucedida

    Contexto:
        Dado que eu estou logado como administrador
        E estou na página de "Cadastro de Usuários"

    Quando eu preencho o formulário com:
        Campo	Valor
        Matrícula	13579
        Nome Completo	Exemplo Exemplo Exemplo
        E-mail	matrícula@unb.br
        Senha	senhaSegura123
        Confirmar_Senha	senhaSegura123

    E clico no botão "Cadastrar"
    Então o sistema deve exibir a mensagem "Usuário cadastrado com sucesso!"
    E o usuário deve ser adicionado à base de dados com status "ATIVO"
    E os campos do formulário devem ser limpos para um novo cadastro

Cenário: Tentativa de cadastro com matrícula já existente
    Contexto:
        Dado que existe um usuário cadastrado com matrícula "12345"
        E eu estou na página de "Cadastro de Usuários"
        Quando eu tento cadastrar um novo usuário com:
            Campo	Valor
            Matrícula	12345
            Nome Completo	João Carlos Silva
            E-mail	matrícula@unb.br
            Senha	senhaSegura123
            Confirmar_Senha	senhaSegura123

        E clico no botão "Cadastrar"

        Então o sistema deve exibir a mensagem "Erro: Matrícula já cadastrada no sistema"
        E o formulário não deve ser submetido
        E o campo "Matrícula" deve ser destacado em vermelho
