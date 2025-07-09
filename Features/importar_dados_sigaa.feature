Funcionalidade: Importar dados do SIGAA

História de usuário:

Como um Administrador do sistema
Quero importar dados atualizados do SIGAA
A fim de manter a base de dados consistente 

Cenário: Importação bem-sucedida de arquivo do SIGAA
    Contexto:
        Dado que estou logado como administrador
        E estou na página "Importar do SIGAA"
        E possuo um arquivo CSV válido com a estrutura contendo:
        nome,curso,matricula,usuario,formacao,ocupacao,email
        Ana Clara Jordao Perna,CIÊNCIA DA COMPUTAÇÃO/CIC,190084006,190084006,graduando,dicente,acjpjvjp@gmail.com

        Quando faço upload do arquivo
        E clico no botão "Importar"
        Então o sistema deve exibir:
        "Sincronização concluída. 0 usuário(s) atualizado(s), 1 usuário(s) adicionado(s) e 0 usuário(s) desativado(s)."
        E os novos usuários devem estar disponíveis no sistema

Cenário: Importação mal-sucedida de arquivo no SIGAA
        Contexto:
            Dado que estou logado como administrador
            E estou na página "Importar do SIGAA"
            E possuo um arquivo CSV inválido com a estrutura contendo:
            nome,curso,matricula,usuario,formacao,ocupacao,email
            ,CIÊNCIA DA COMPUTAÇÃO/CIC,190084006,190084006,,dicente,acjpjvjp@gmail.com
            
            Quando faço upload do arquivo
            E clico no botão "Importar"
            Então o sistema deve exibir:
            "Erro na Sincronização"
