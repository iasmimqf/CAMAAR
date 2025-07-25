# language: pt
Funcionalidade: Criação de formulário para avaliação de turmas

	Como administrador,
	Quero criar um formulário baseado em um template
	Para avaliar o desempenho das turmas no semestre atual

	Contexto:
		Dado que estou autenticado como administrador
		E existem templates de formulário cadastrados
		E existem turmas ativas para o semestre atual

	Cenário: Criar formulário com template válido para turmas selecionadas
		Quando eu acesso a página de criação de formulário
		E eu seleciono o template "Avaliação Padrão"
		E eu seleciono as turmas "Turma 01", "Turma 03" e "Turma 04"
		E eu clico em "Criar Formulário"
		Então eu devo ver a mensagem de sucesso do formulário "Formulário criado com sucesso"
		E as turmas devem estar associadas ao novo formulário

	Cenário: Tentar criar formulário sem selecionar nenhuma turma
		Quando eu acesso a página de criação de formulário
		E eu não seleciono nenhuma turma
		E eu clico em "Criar Formulário"
		Então eu devo ver a mensagem de erro "Você deve selecionar ao menos uma turma"

	Cenário: Tentar criar formulário sem selecionar um template
		Quando eu acesso a página de criação de formulário
		E eu seleciono a turma "Turma 02"
		E eu clico em "Criar Formulário" 
		Então eu devo ver a mensagem de erro "Você deve selecionar um template"

	Cenário: Tentar criar formulário para turma já avaliada neste semestre
		Dado a turma "Turma 01" já foi avaliada neste semestre
		Quando eu acesso a página de criação de formulário
		E eu seleciono o template "Avaliação Padrão"
		E eu seleciono a turma "Turma 01"
		E eu clico em "Criar Formulário"
		Então eu devo ver a mensagem de erro "Esta turma já foi avaliada no semestre atual"

	Cenário: Impedir criação de formulário quando não há templates ou turmas cadastrados
		E não existem templates de formulário cadastrados
		E não existem turmas ativas para o semestre atual
		Quando eu acesso a página de criação de formulário
		Então eu devo ver a mensagem "Não é possível criar um formulário sem templates e turmas"
		E o botão "Criar Formulário" deve estar desabilitado
