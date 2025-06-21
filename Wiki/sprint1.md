# Wiki - Projeto CAMAAR  
*(Sprint 1: Especificação BDD)*  

## Equipe  

| Nome                              | Matrícula  | Papel           |  
|-----------------------------------|------------|----------------|  
| Iasmim de Queiroz Freitas         | 190108665  | **Scrum Master** |  
| Hudson Cauã Costa Lima            | 211055512  | **Product Owner** |  
| Luis Gustavo de Sousa Silva       | 200046527  | Desenvolvedor   |  
| Marcus Emanuel Carvalho T. Freitas| 222025960  | Desenvolvedor   |  

---

## Todas as Funcionalidades  

### Autenticação  

| Funcionalidade               | Regras de Negócio                          | Responsável | Pontos |  
|------------------------------|-------------------------------------------|-------------|--------|  
| Sistema de Login             | - Validação de credenciais                | Luis Gustavo| 3      |  
| Sistema de Definição de Senha| - Senha mínima 6 caracteres               | Marcus      | 3      |  

### Gestão de Templates  

| Funcionalidade               | Regras de Negócio                          | Responsável | Pontos |  
|------------------------------|-------------------------------------------|-------------|--------|  
| Criar Template               | - Admin logado, título e questões válidas | Iasmim      | 3      |  
| Editar/Deletar Template      | - Apenas admin criador pode editar        | Marcus      | 5      |  
| Visualizar Templates         | - Filtros por disciplina                  | Luis Gustavo| 2      |  

### Formulários & Relatórios  

| Funcionalidade               | Regras de Negócio                          | Responsável | Pontos |  
|------------------------------|-------------------------------------------|-------------|--------|  
| Criar Formulário             | - Requer template e turma existentes      | Iasmim      | 3      |  
| Responder Formulário         | - Progresso não é salvo parcialmente      | Hudson      | 3      |  
| Visualizar Formulários Pendentes | - Mostra apenas não respondidos/ativos | Iasmim      | 2      |  
| Gerar Relatório              | - Requer ≥1 formulário respondido         | Iasmim      | 3      |  
| Visualizar Resultados        | - Gráficos para questões numéricas        | Marcus      | 5      |  

### Integração  

| Funcionalidade               | Regras de Negócio                          | Responsável | Pontos |  
|------------------------------|-------------------------------------------|-------------|--------|  
| Importar Dados do SIGAA      | - Sincronização semanal automática        | Hudson      | 3      |  
| Atualizar Base com SIGAA     | - Campos mapeados: turmas/disciplinas     | Luis Gustavo| 5      |  

### Gestão de Usuários  

| Funcionalidade               | Regras de Negócio                          | Responsável | Pontos |  
|------------------------------|-------------------------------------------|-------------|--------|  
| Cadastrar Usuários           | - Tipos: admin/professor/aluno            | Hudson      | 5      |  

---

## Política de Branching - Sprint 1

### Branching Atual
Nesta primeira sprint, utilizamos uma única branch compartilhada para desenvolvimento:

- **`bdd`**: Branch temporária contendo todas as especificações BDD
- **`main`**: Branch protegida (versão estável)

### Observação sobre a Branch Atual

A branch `bdd` será mantida temporariamente como referência até que:

- **Validação completa** dos cenários BDD pelo Product Owner  
- **Transição concluída** para o novo fluxo de branches (com `develop` e branches por feature)  

*Esta branch será deletada assim que esses marcos forem atingidos.*

---

## Velocity da Sprint 1

### Métricas Chave
- **Total de pontos planejados:** 32
- **Pontos concluídos:** 32 (100%)
- **Média por membro:** 8 pontos

## 📌 Resumo da Sprint 1

### ✅ Conquistas
- **Especificação completa** de 13 funcionalidades em BDD
- **Alinhamento** das histórias com o protótipo do Figma
- **Cobertura** de cenários felizes e tristes para cada feature


### Melhorias no Versionamento
- **Branch `develop` será criada** para integração contínua
- **Branches específicas por tipo de trabalho**:
  ```markdown
  feat/    # Para novas funcionalidades (ex: feat/login)
  fix/     # Para correções (ex: fix/export-csv)
  docs/    # Para documentação