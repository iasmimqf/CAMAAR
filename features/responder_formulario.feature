Funcionalidade: Responder Formulário de Avaliação
    História de Usuário:
        Como um Aluno
        Quero responder aos formulários de avaliação disponíveis
        A fim de avaliar meus professores e disciplinas

    Cenário: Responder formulário com sucesso
        Contexto:
        Dado que estou autenticado como aluno
        E existe um formulário disponível para a turma "Banco de Dados - Turma 01"
        E o formulário contém:

        5 questões de múltipla escolha (escala 1-5)

        2 questões abertas

        Quando acesso a página "Formulários Pendentes"
        E seleciono o formulário da turma "Banco de Dados - Turma 01"
        E preencho todas as questões obrigatórias:

        Questão 1: Nota 4

        Questão 2: Nota 5

        ...

        Comentários: "O professor explica bem os conceitos"

        E clico em "Enviar Respostas"

        Então o sistema deve exibir "Formulário enviado com sucesso!"
        E o formulário deve ser marcado como "Respondido" no meu perfil
        E as respostas devem ser armazenadas anonimamente no sistema

    Cenário: Tentar enviar formulário incompleto
        Contexto:
        Dado que estou respondendo um formulário
        E deixei a questão 3 em branco (campo obrigatório)

        Quando clico em "Enviar Respostas"

        Então o sistema deve exibir:
        "Por favor, responda todas as questões obrigatórias"
        E deve destacar a questão 3 em vermelho
        E deve manter minhas outras respostas preenchidas