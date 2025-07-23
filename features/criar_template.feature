# language: pt
Funcionalidade: Criação de template de formulário

    Como administrador,
    Quero criar um template contendo questões
    Para gerar formulários de avaliação para as turmas

    Contexto:
        Dado que estou autenticado como administrador

    Cenário: Acessar página de criação de templates
        Quando acesso a página de administração de templates
        Então devo ver "Gerenciamento - Templates"
        E devo ver o botão "Novo Template"

    Cenário: Visualizar formulário de criação vazio
        Dado que acesso a página de criação de templates
        Então devo ver o campo "Título do Template"
        E devo ver o botão "Salvar Template"
        E devo ver o botão "Cancelar"

    @javascript
    Cenário: Criar template básico válido (fluxo completo)
        Dado que acesso a página de criação de templates
        Quando preencho o título com "Template Básico"
        E clico em "Salvar Template"
        Então devo ver a mensagem "Template 'Template Básico' salvo com sucesso"
        E devo estar na página de listagem de templates
        Quando clico em "Editar" do template "Template Básico"
        E adiciono uma questão do tipo "Texto" com enunciado "Como você avalia?"
        E clico em "Salvar"
        Então devo ver a mensagem "O template foi atualizado com sucesso"

    Cenário: Falha ao criar template sem título
        Dado que acesso a página de criação de templates
        Quando clico em "Salvar Template" sem preencher dados
        Então devo ver "Foram encontrados os seguintes erros"
        E devo ver "O título do template é obrigatório"

    Cenário: Template criado sem questões deve alertar na edição
        Dado que acesso a página de criação de templates
        Quando preencho o título com "Template Sem Questões"
        E clico em "Salvar Template"
        Então devo ver a mensagem "Template 'Template Sem Questões' salvo com sucesso"
        E devo estar na página de listagem de templates
        Quando clico em "Editar" do template "Template Sem Questões"
        E clico em "Salvar" sem adicionar questões
        Então devo ver "Foram encontrados os seguintes erros"
        E devo ver "Adicione pelo menos uma questão ao template"

    @javascript
    Cenário: Criar template com múltiplas questões de tipos diferentes
        Dado que acesso a página de criação de templates
        Quando preencho o título com "Avaliação Completa"
        E clico em "Salvar Template"
        Então devo ver a mensagem "Template 'Avaliação Completa' salvo com sucesso"
        Quando clico em "Editar" do template "Avaliação Completa"
        E adiciono uma questão do tipo "Texto" com enunciado "Comentários gerais"
        E adiciono uma questão do tipo "Escala" com enunciado "Nota geral" e opções "1,2,3,4,5"
        E clico em "Salvar"
        Então devo ver a mensagem "O template foi atualizado com sucesso"
        E o template deve ter 2 questões

    Cenário: Falha ao criar template com título duplicado
        Dado que existe um template com título "Template Único"
        E que acesso a página de criação de templates
        Quando preencho o título com "Template Único"
        E clico em "Salvar Template"
        Então devo ver "Foram encontrados os seguintes erros"
        E devo ver "Já existe um template com este nome"

    Cenário: Tentar salvar template sem título
        Quando deixo o campo "Título" em branco
        E clico em "Salvar Template"
        Então devo ver a mensagem de erro "O título do template é obrigatório"
        E o sistema não deve criar o template  
    
    Cenário: Tentar usar título de template já existente  
        Dado que existe um template chamado "Avaliação Padrão"  
        Quando tento criar outro template com o mesmo título  
        E clico em "Salvar Template"  
        Então devo ver "Já existe um template com este nome. Use um título diferente."  
    
    @javascript
    @javascript
    Cenário: Adicionar questão sem enunciado deve dar erro
        Dado que acesso a página de criação de templates
        Quando preencho o título com "Template Com Erro"
        E clico em "Salvar Template"
        Quando clico em "Editar" do template "Template Com Erro"
        E adiciono uma questão do tipo "Escala" sem enunciado
        E clico em "Salvar"
        Então devo ver "Foram encontrados os seguintes erros"

    Cenário: Template sem questões pode ser salvo mas deve alertar na edição
        Quando preencho apenas o título do template
        E não adiciono nenhuma questão
        E clico em "Salvar Template"
        Então devo ver a mensagem "Template 'Template Somente Título' salvo com sucesso"
        Quando clico em "Editar" do template "Template Somente Título"
        E clico em "Salvar" sem adicionar questões
        Então devo ver "Foram encontrados os seguintes erros"
        E devo ver "Adicione pelo menos uma questão ao template"
        Então devo ver "Foram encontrados os seguintes erros"
        E devo ver "Adicione pelo menos uma questão ao template"