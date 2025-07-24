# language: pt

Funcionalidade: Criação de template de formulário
    Como administrador,
    Quero criar um template contendo questões
    Para gerar formulários de avaliação para as turmas

    Contexto:
        Dado que estou autenticado como administrador

    Cenário: Criar template válido com múltiplas questões
        Dado que acesso a página de criação de templates
        Quando preencho o título com "Avaliação Docente - 2024"
        E adiciono as seguintes questões:
            | Tipo      | Enunciado                     | Obrigatória | Opções (se aplicável) |
            | Escala    | Satisfação com a disciplina   | Sim         | 5, 4, 3, 2, 1         |
            | Escala    | Satisfação com o docente      | Sim         | 5, 4, 3, 2, 1         |
            | Texto     | Alguma sugestão construtiva?  | Não         |                       |
        E clico em "Salvar Template"
        Então devo ver a mensagem "Template 'Avaliação Docente - 2024' salvo com sucesso"
        E o template deve aparecer na lista de templates disponíveis

    Cenário: Tentar salvar template sem título
        Dado que acesso a página de criação de templates
        Quando deixo o campo "Título" em branco
        E clico em "Salvar Template"
        Então devo ver a mensagem de erro "O título do template é obrigatório"
        E o sistema não deve criar o template

    Cenário: Tentar usar título de template já existente
        Dado que existe um template chamado "Avaliação Padrão"
        E que acesso a página de criação de templates
        Quando preencho o título com "Avaliação Padrão"
        E adiciono uma questão válida
        E clico em "Salvar Template"
        Então devo ver a mensagem de erro "Já existe um template com este nome. Use um título diferente."
        E o sistema não deve criar o template

    Cenário: Adicionar questão sem enunciado
        Dado que acesso a página de criação de templates
        Quando preencho o título com "Template Teste"
        E adiciono uma questão do tipo "Escala" sem enunciado
        E clico em "Salvar Template"
        Então devo ver a mensagem de erro "Existem questões incompletas. Revise os campos marcados."
        E o sistema não deve criar o template

    Cenário: Tentar salvar template sem questões
        Dado que acesso a página de criação de templates
        Quando preencho o título com "Template Vazio"
        E não adiciono nenhuma questão
        E clico em "Salvar Template"
        Então devo ver a mensagem de erro "Adicione pelo menos uma questão ao template"
        E o sistema não deve criar o template

    Cenário: Validar questão do tipo escala sem opções
        Dado que acesso a página de criação de templates
        Quando preencho o título com "Template Teste"
        E adiciono uma questão do tipo "Escala" com enunciado "Teste" mas sem opções
        E clico em "Salvar Template"
        Então devo ver a mensagem de erro "Questões do tipo escala devem ter opções definidas"
        E o sistema não deve criar o template

    Cenário: Editar questão existente no template
        Dado que acesso a página de criação de templates
        E preencho o título com "Template Editável"
        E adiciono uma questão do tipo "Texto" com enunciado "Questão inicial"
        Quando edito o enunciado da questão para "Questão modificada"
        E marco a questão como obrigatória
        E clico em "Salvar Template"
        Então devo ver a mensagem "Template 'Template Editável' salvo com sucesso"
        E a questão deve aparecer com o enunciado "Questão modificada"
        E a questão deve estar marcada como obrigatória

    Cenário: Remover questão do template
        Dado que acesso a página de criação de templates
        E preencho o título com "Template com Remoção"
        E adiciono as seguintes questões:
            | Tipo  | Enunciado     | Obrigatória |
            | Texto | Questão 1     | Sim         |
            | Texto | Questão 2     | Não         |
        Quando removo a segunda questão
        E clico em "Salvar Template"
        Então devo ver a mensagem "Template 'Template com Remoção' salvo com sucesso"
        E o template deve ter apenas 1 questão
        E deve aparecer apenas a "Questão 1" na lista de questões