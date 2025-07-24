# language: pt
Funcionalidade: Visualização de formulários pendentes pelo usuário
    Como aluno de uma turma
    Quero visualizar meus formulários pendentes
    Para escolher qual responder

    Contexto:
        Dado que estou autenticado como aluno

    @javascript
    Cenário: Visualizar lista de formulários disponíveis
        Dado existem formulários não respondidos para minhas turmas
        E os formulários possuem diferentes templates e disciplinas
        Quando acesso "Meus Formulários"
        Então devo ver uma lista com os formulários pendentes
        E para cada formulário devo ver o template, disciplina, turma e data de criação
        E deve haver um botão "Responder" ativo para cada formulário

    @javascript
    Cenário: Nenhum formulário pendente para visualizar
        Dado não existem formulários não respondidos para minhas turmas
        Quando acesso "Meus Formulários"
        Então devo ver a mensagem "Você não possui formulários pendentes no momento"
        E a lista deve estar vazia

    @javascript
    Cenário: Formulários já respondidos não aparecem na lista
        Dado existem formulários para minhas turmas
        E eu já respondi alguns formulários
        Quando acesso "Meus Formulários"
        Então devo ver apenas os formulários que ainda não respondi
        E não devo ver os formulários já respondidos
        E deve haver um botão "Responder" apenas para formulários pendentes