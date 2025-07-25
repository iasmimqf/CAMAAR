# language: pt
Funcionalidade: Visualização de formulários não respondidos
    Eu como Participante de uma turma
    Quero visualizar meus formulários pendentes
    Para escolher qual responder

    Cenário: Visualizar lista de formulários disponíveis  
        Dado que estou logado como usuário
        E existem formulários não respondidos para minhas turmas:  
        | Nome                    | Disciplina      | Turma       | Prazo      |  
        | Avaliação Docente       | Banco de Dados  | Turma 01    | 15/08/2025 |  
        | Avaliação Sala de Aula  | Álgebra 1       | Turma 02    | 20/08/2025 |  
        Quando acesso "Meus Formulários"  
        Então devo ver uma lista contendo:  
            | Campo                          |
            | Nome do formulário             |
            | Matéria associada              |
            | Turma associada                |
            | Data limite para resposta      |
            | Botão "Responder" ativo        |  
    
    Cenário: Nenhum formulário pendente para visualizar
        Dado que estou logado como usuário
        E não existem formulários não respondidos para minhas turmas
        Quando acesso "Meus Formulários"
        Então devo ver a mensagem "Você não possui formulários pendentes no momento"
        E a lista deve estar vazia