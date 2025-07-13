# language: pt
Funcionalidade: Importar dados do SIGAA a partir de um Modal
	Como um administrador,
	eu quero um modal para escolher se vou importar Turmas ou Alunos,
	para que o processo de upload de arquivos seja claro e separado.

	Contexto:
		Dado que eu sou um administrador logado e estou na página de Gerenciamento

	@import_turma
	Cenário: Importar um arquivo de Turmas com sucesso
		Quando eu clico no botão "Importar Dados"
		E o modal de importação aparece
		E eu clico no botão "Importar Turmas" dentro do modal
		E eu anexo o arquivo "turmas.json" ao campo "Selecione o arquivo de turmas"
		E clico no botão "Enviar Turmas"
		Então eu devo ver a mensagem "Arquivo de turmas processado com sucesso!"
		E a turma de "BANCOS DE DADOS" deve ser criada no sistema.

	@import_alunos
	Cenário: Importar um arquivo de Alunos para uma turma existente
		Dado que a disciplina "BANCOS DE DADOS" com código "CIC0097" já existe
		Quando eu clico no botão "Importar Dados"
		E o modal de importação aparece
		E eu clico no botão "Importar Alunos" dentro do modal
		E eu anexo o arquivo "class_members.json" ao campo "Selecione o arquivo de alunos"
		E clico no botão "Enviar Alunos"
		Então eu devo ver a mensagem "Arquivo de alunos processado com sucesso!"
		E o usuário "Ana Clara Jordao Perna" deve ser criado e associado à turma "TA" de "BANCOS DE DADOS" do semestre "2021.2".

	@cancelar_import
	Cenário: Cancelar a operação de importação
		Quando eu clico no botão "Importar Dados"
		E o modal de importação aparece
		E eu clico no botão "Cancelar" dentro do modal
		Então o modal de importação deve ser fechado
		E eu devo permanecer na página de Gerenciamento.

	@import_turma_formato_invalido
	Cenário: Tentar importar Turmas com um arquivo de formato incorreto (ex: .txt)
		Quando eu clico no botão "Importar Dados"
		E o modal de importação aparece
		E eu clico no botão "Importar Turmas" dentro do modal
		E eu anexo o arquivo "arquivo_invalido.txt" ao campo "Selecione o arquivo de turmas"
		E clico no botão "Enviar Turmas"
		Então eu devo ver a mensagem de erro "Formato de arquivo inválido. Por favor, envie um arquivo .json."
		E eu devo permanecer na página de Gerenciamento.

	@import_turma_dados_invalidos
	Cenário: Tentar importar Turmas com dados obrigatórios faltando
		Quando eu clico no botão "Importar Dados"
		E o modal de importação aparece
		E eu clico no botão "Importar Turmas" dentro do modal
		E eu anexo o arquivo "turmas_sem_codigo.json" ao campo "Selecione o arquivo de turmas"
		E clico no botão "Enviar Turmas"
		Então eu devo ver a mensagem de erro "Erro na estrutura do arquivo: 'code' e 'name' são obrigatórios para a disciplina."

	@import_turma_json_malformado
	Cenário: Tentar importar Turmas com um JSON malformado
		Quando eu clico no botão "Importar Dados"
		E o modal de importação aparece
		E eu clico no botão "Importar Turmas" dentro do modal
		E eu anexo o arquivo "turmas_malformado.json" ao campo "Selecione o arquivo de turmas"
		E clico no botão "Enviar Turmas"
		Então eu devo ver a mensagem de erro "Erro ao processar o arquivo. Verifique a sintaxe do JSON."

	@import_aluno_formato_invalido
	Cenário: Tentar importar Alunos com um arquivo de formato incorreto (ex: .txt)
		Quando eu clico no botão "Importar Dados"
		E o modal de importação aparece
		E eu clico no botão "Importar Alunos" dentro do modal
		E eu anexo o arquivo "arquivo_invalido.txt" ao campo "Selecione o arquivo de alunos"
		E clico no botão "Enviar Alunos"
		Então eu devo ver a mensagem de erro "Formato de arquivo inválido. Por favor, envie um arquivo .json."
		E eu devo permanecer na página de Gerenciamento.

	@import_aluno_json_malformado
	Cenário: Tentar importar Alunos com um JSON malformado
		Quando eu clico no botão "Importar Dados"
		E o modal de importação aparece
		E eu clico no botão "Importar Alunos" dentro do modal
		E eu anexo o arquivo "alunos_malformado.json" ao campo "Selecione o arquivo de alunos"
		E clico no botão "Enviar Alunos"
		Então eu devo ver a mensagem de erro "Erro ao processar o arquivo. Verifique a sintaxe do JSON."

	@import_alunos_turma_inexistente
	Cenário: Tentar importar Alunos para uma turma que não existe
		Quando eu clico no botão "Importar Dados"
		E o modal de importação aparece
		E eu clico no botão "Importar Alunos" dentro do modal
		E eu anexo o arquivo "alunos_da_turma_cic0097.json" ao campo "Selecione o arquivo de alunos"
		E clico no botão "Enviar Alunos"
		Então eu devo ver a mensagem de erro "A disciplina com código CIC0097 não foi encontrada. Importe o arquivo de turmas primeiro."