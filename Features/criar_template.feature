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
        | Escala    | Satisfação com a disciplina   | Sim         |  5, 4, 3, 2, 1        |  
        | Escala    | Satisfação com o docente      | Sim         |  5, 4, 3, 2, 1        |  
        | Texto     | Alguma sugestão construtiva?  | Não         |                       |  
        E clico em "Salvar Template"  
        Então devo ver a mensagem "Template 'Avaliação Docente - 2024' salvo com sucesso"  
        E o template deve aparecer na lista de templates disponíveis  

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
    
    Cenário: Adicionar questão sem enunciado  
        Quando preencho o título do template  
        E adiciono uma questão do tipo "Escala (1-5)" sem enunciado  
        E clico em "Salvar Template"  
        Então devo ver "Existem questões incompletas. Revise os campos marcados." 
    
    Cenário: Tentar salvar template sem questões  
        Quando preencho apenas o título do template  
        E não adiciono nenhuma questão  
        E clico em "Salvar Template"  
        Então devo ver "Adicione pelo menos uma questão ao template"  
        E o botão de salvar deve permanecer desabilitado  