# language: pt
Funcionalidade: Importar dados do SIGAA a partir de um Modal
	Como um administrador,
	eu quero um modal para escolher se vou importar Turmas ou Alunos,
	para que o processo de upload de arquivos seja claro e separado.

	Contexto:
		Dado que eu sou um administrador logado e estou na página de Gerenciamento

	@import_alunos @javascript
	Cenário: Importar um arquivo de Alunos para uma turma existente
		Dado que a disciplina "BANCOS DE DADOS" com código "CIC0097" já existe
		Quando eu clico no botão "Importar Dados"
		E o modal de importação aparece
		E eu clico no botão "Importar Alunos" dentro do modal
		E eu anexo o arquivo "alunos_da_turma_cic0097.json" ao campo "Selecione o arquivo de alunos"
		E clico no botão "Enviar Alunos"
		Então eu devo ver a mensagem "1 alunos importados/atualizados com sucesso!"
		E o usuário "Ana Clara Jordao Perna" deve ser criado e associado à turma "BANCOS DE DADOS".

	@import_turma @javascript
	Cenário: Importar um arquivo de Turmas com sucesso
		Quando eu clico no botão "Importar Dados"
		E o modal de importação aparece
		E eu clico no botão "Importar Turmas" dentro do modal
		E eu anexo o arquivo "turmas.json" ao campo "Selecione o arquivo de turmas"
		E clico no botão "Enviar Turmas"
		Então eu devo ver a mensagem "3 turmas importadas com sucesso!"
		E a turma de "BANCOS DE DADOS" deve ser criada no sistema.

	@cancelar_import @javascript
	Cenário: Cancelar a operação de importação
		Quando eu clico no botão "Importar Dados"
		E o modal de importação aparece
		E eu clico no botão "Cancelar" dentro do modal
		Então o modal de importação deve ser fechado
		E eu devo permanecer na página de Gerenciamento.

	@import_turma_formato_invalido @javascript
	Cenário: Tentar importar Turmas com um arquivo de formato incorreto (ex: .txt)
		Quando eu clico no botão "Importar Dados"
		E o modal de importação aparece
		E eu clico no botão "Importar Turmas" dentro do modal
		E eu anexo o arquivo "arquivo_invalido.txt" ao campo "Selecione o arquivo de turmas"
		E clico no botão "Enviar Turmas"
		Então eu devo ver a mensagem de erro "Erro: O ficheiro não é um JSON válido."
		E eu devo permanecer na página de Gerenciamento.

	@import_turma_json_malformado @javascript
	Cenário: Tentar importar Turmas com um JSON malformado
		Quando eu clico no botão "Importar Dados"
		E o modal de importação aparece
		E eu clico no botão "Importar Turmas" dentro do modal
		E eu anexo o arquivo "turmas_malformado.json" ao campo "Selecione o arquivo de turmas"
		E clico no botão "Enviar Turmas"
		Então eu devo ver a mensagem de erro "Erro: O ficheiro não é um JSON válido."

	@import_aluno_formato_invalido @javascript  
	Cenário: Tentar importar Alunos com um arquivo de formato incorreto (ex: .txt)
		Quando eu clico no botão "Importar Dados"
		E o modal de importação aparece
		E eu clico no botão "Importar Alunos" dentro do modal
		E eu anexo o arquivo "arquivo_invalido.txt" ao campo "Selecione o arquivo de alunos"
		E clico no botão "Enviar Alunos"
		Então eu devo ver a mensagem de erro "Erro: O ficheiro não é um JSON válido."
		E eu devo permanecer na página de Gerenciamento.

	@import_aluno_json_malformado @javascript
	Cenário: Tentar importar Alunos com um JSON malformado
		Quando eu clico no botão "Importar Dados"
		E o modal de importação aparece
		E eu clico no botão "Importar Alunos" dentro do modal
		E eu anexo o arquivo "alunos_malformado.json" ao campo "Selecione o arquivo de alunos"
		E clico no botão "Enviar Alunos"
		Então eu devo ver a mensagem de erro "Erro: O ficheiro não é um JSON válido."

	@import_alunos_turma_inexistente @javascript
	Cenário: Tentar importar Alunos para uma turma que não existe
		Quando eu clico no botão "Importar Dados"
		E o modal de importação aparece
		E eu clico no botão "Importar Alunos" dentro do modal
		E eu anexo o arquivo "alunos_da_turma_cic0097.json" ao campo "Selecione o arquivo de alunos"
		E clico no botão "Enviar Alunos"
		Então eu devo ver a mensagem "1 alunos importados/atualizados com sucesso!"
