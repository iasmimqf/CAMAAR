História de Usuário:

Como um Administrador
Quero atualizar a base de dados já existente com os dados atuais do SIGAA
A fim de corrigir a base de dados do sistema.

Cenário: Sincronização bem-sucedida com novos usuários, atualizações e desativações

    Contexto:
        Dado que a base de dados do sistema atualmente contém:

        matricula	nome_completo	status
        12345	Ana Souza	ATIVO
        54321	Bruno Costa	ATIVO

        E eu possuo um arquivo "exportacao_sigaa.csv" com os seguintes dados atualizados:

        matricula	nome_completo	status_sigaa
        12345	Ana Souza da Silva	ATIVO
        67890	Carlos Pereira	ATIVO


    Quando eu faço o upload do arquivo "exportacao_sigaa.csv"
    E eu clico no botão "Sincronizar Agora"
    Então o sistema deve processar o arquivo
    E eu devo ver uma mensagem de sucesso resumindo as ações: "Sincronização concluída. 1 usuário(s) atualizado(s), 1 usuário(s) adicionado(s) e 1 usuário(s) desativado(s)."
    E na base de dados do sistema:

    acao_verificacao	matricula	nome_completo	status_final
    O usuário	12345	deve ter o nome atualizado para "Ana Souza da Silva"	e permanecer "ATIVO"
    O usuário	54321	que não veio no arquivo, deve ter seu status mudado para	"INATIVO"
    Um novo usuário	67890	com o nome "Carlos Pereira"	deve ser criado como "ATIVO"

Cenário: Tentativa de upload com um tipo de arquivo não suportado

Quando eu tento fazer o upload de um arquivo chamado "documento.pdf"
Então o sistema deve rejeitar o arquivo
E eu devo ver uma mensagem de erro como "Formato de arquivo inválido. Por favor, envie um arquivo nos formatos CSV ou XLSX."
E nenhuma alteração deve ser realizada na base de dados.

Cenário: Arquivo de sincronização com colunas faltando
    Contexto:
        Dado que eu possuo um arquivo "sigaa_incompleto.csv" onde a coluna obrigatória "matricula" está ausente
    
    Quando eu faço o upload do arquivo "sigaa_incompleto.csv"
    E eu clico no botão "Sincronizar Agora"
    Então o processamento deve falhar antes de iniciar as alterações
    E eu devo ver uma mensagem de erro como "O arquivo está mal formatado. A coluna 'matricula' é obrigatória e não foi encontrada."

Cenário: Arquivo de sincronização contém linhas com dados inválidos
    Contexto:
        Dado que eu possuo um arquivo "sigaa_com_erros.csv" com os seguintes dados:

        matricula	nome_completo	status_sigaa
        11111	Mariana Lima	ATIVO
        MATRICULA_INVALIDA	Pedro Rocha	ATIVO
        22222	Julia Alves	ATIVO

    Quando eu faço o upload deste arquivo e inicio a sincronização
    Então o sistema deve processar as linhas válidas
    E eu devo ver uma mensagem de sucesso parcial: "Sincronização concluída com erros. 2 usuário(s) processado(s) com sucesso."
    E eu devo ter a opção de baixar um relatório de erros
    E o relatório de erros deve conter a linha "MATRICULA_INVALIDA" com o motivo da falha "Matrícula em formato inválido."