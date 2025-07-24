# language: pt
Funcionalidade: Responder Formulário de Avaliação
    Como um aluno
    Quero responder aos formulários de avaliação disponíveis
    Para avaliar meus professores e disciplinas

    Contexto:
        Dado que estou autenticado como aluno

    @javascript
    Cenário: Responder formulário com sucesso
        Dado existe um formulário disponível para a turma "Banco de Dados - Turma 01"
        E o formulário contém 3 questões de múltipla escolha (escala 1-5)
        E o formulário contém 2 questões abertas
        Quando acesso a página de formulários "Formulários Pendentes"
        E seleciono o formulário da turma "Banco de Dados - Turma 01"
        E preencho todas as questões obrigatórias com notas válidas
        E preencho o comentário com "O professor explica bem os conceitos"
        E clico no botão "Enviar Respostas" do formulário
        Então o sistema deve exibir "Formulário enviado com sucesso!"
        E as respostas devem ser armazenadas no sistema

    @javascript
    Cenário: Tentar enviar formulário incompleto
        Dado existe um formulário disponível para a turma "Algoritmos - Turma 02"
        E o formulário contém 2 questões de múltipla escolha (escala 1-5)
        E uma das questões é obrigatória
        Quando acesso a página de formulários "Formulários Pendentes"
        E seleciono o formulário da turma "Algoritmos - Turma 02"
        E deixo uma questão obrigatória em branco
        E clico no botão "Enviar Respostas" do formulário
        Então eu devo ver a mensagem de erro do formulário "Por favor, responda todas as questões obrigatórias"
        E minhas outras respostas devem permanecer preenchidas

    @javascript
    Cenário: Tentar responder formulário já respondido
        Dado existe um formulário disponível para a turma "Estruturas - Turma 03"
        E eu já respondi este formulário anteriormente
        Quando acesso a página de formulários "Formulários Pendentes"
        Então o formulário "Estruturas - Turma 03" não deve aparecer na lista
        E eu devo ver a mensagem de formulário "Você não possui formulários pendentes no momento"