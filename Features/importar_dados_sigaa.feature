Funcionalidade: Importar dados do SIGAA

História de usuário:

Como um Administrador do sistema
Quero importar dados atualizados do SIGAA
A fim de manter a base de dados consistente 

Cenário: Importação bem-sucedida de arquivo do SIGAA
    Contexto:
        Dado que estou logado como administrador
        E estou na página "Importar do SIGAA"
        E possuo um arquivo JSON válido com a estrutura contendo:
            {"nome": "Ana Clara Jordao Perna",
                "curso": "CIÊNCIA DA COMPUTAÇÃO/CIC",
                "matricula": "190084006",
                "usuario": "190084006",
                "formacao": "graduando",
                "ocupacao": "dicente",
                "email": "acjpjvjp@gmail.com"}
        Quando faço upload do arquivo
        E clico no botão "Importar"
        Então o sistema deve exibir:
        "Sincronização concluída. 0 usuário(s) atualizado(s), 1 usuário(s) adicionado(s) e 0 usuário(s) desativado(s)."
        E os novos usuários devem estar disponíveis no sistema

Cenário: Importação mal-sucedida de arquivo no SIGAA
        Contexto:
            Dado que estou logado como administrador
            E estou na página "Importar do SIGAA"
            E possuo um arquivo JSON inválido com a estrutura contendo:
                {"nome": "",
                "curso": "CIÊNCIA DA COMPUTAÇÃO/CIC",
                "matricula": "",
                "usuario": "190084006",
                "formacao": "graduando",
                "ocupacao": "dicente",
                "email": "acjpjvjp@gmail.com"}
            Quando faço upload do arquivo
            E clico no botão "Importar"
            Então o sistema deve exibir:
            "Sincronização concluída. 0 usuário(s) atualizado(s), 1 usuário(s) adicionado(s) e 0 usuário(s) desativado(s)."
            E o novo usuário deve estar disponível no sistema com os dados:
                Nome: "Ana Clara Jordao Perna"
                Matrícula: "190084006"
                Status: "ATIVO"
                Tipo: "ALUNO"
    Cenário: Tentativa de importação com arquivo inválido
        Contexto:
            Dado que estou na página "Importar do SIGAA"
            Quando tento fazer upload de um arquivo "dados.pdf"
            Então o sistema deve exibir:
            "Formato de arquivo inválido. Por favor, envie um arquivo JSON."
            E o botão "Importar" deve permanecer desabilitado

    Cenário: Importação com dados incompletos
        Contexto:
            Dado que possuo um arquivo JSON com:
                {"nome": "",
                "curso": "CIÊNCIA DA COMPUTAÇÃO/CIC",
                "matricula": "",
                "usuario": "190084006",
                "formacao": "graduando",
                "ocupacao": "dicente",
                "email": "acjpjvjp@gmail.com"}
            Quando faço upload do arquivo
            E clico no botão "Importar"
            Então o sistema deve exibir:
            "Erro na importação: Campos obrigatórios faltando (nome, matricula)"
            E nenhum usuário deve ser adicionado ao sistema
            E deve ser gerado um relatório de erros destacando os campos problemáticos


               
