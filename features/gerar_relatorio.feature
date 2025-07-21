Funcionalidade: Exportação de resultados de formulários  
    Eu como Administrador  
    Quero baixar um arquivo CSV com resultados  
    Para analisar o desempenho das turmas  

    Contexto:  
        Dado que estou autenticado como administrador  
        E existem turmas com formulários enviados  

    Cenário: Exportar CSV para turmas selecionadas  
        Dado que acesso a página "Resultados"  
        Quando seleciono as turmas:  
        - "Turma 01 (Banco de Dados)"  
        - "Turma 02 (Banco de Dados)"  
        E clico em "Gerar CSV"  
        Então um arquivo CSV deve ser baixado com nome "resultados_turmas_1_2_banco_de_dados.csv"  
        E o arquivo deve conter:  
        | Turma       | Disciplina      | Média Professor | Média Disciplina | Respondidos/Enviados |  
        | Turma 01    | Banco de Dados  | 4.2             | 3.8              | 15/20                |  
        | Turma 02    | Banco de Dados  | 4.5             | 4.1              | 18/20                |  
        E as respostas textuais devem estar agrupadas por questão  
    
    Cenário: Tentar exportar sem seleção  
        Quando acesso a página de resultados  
        E não seleciono nenhuma turma  
        Então o botão "Gerar CSV" deve estar visível mas desabilitado 
    
    Cenário: Turma sem respostas não pode ser selecionada para exportação
        Dado que a "Turma 01 (Engenharia de Software)" possui formulário enviado mas nenhuma resposta
        Quando acesso a página de resultados
        Então o checkbox ao lado de "Turma 01 (Engenharia de Software)" deve estar desabilitado
        E quando tento clicar manualmente no checkbox
        Então a turma não é adicionada à lista de selecionadas