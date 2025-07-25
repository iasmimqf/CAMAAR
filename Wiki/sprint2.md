# Wiki - Projeto CAMAAR  
*(Sprint 2: Implementação Autenticação & Formulários & Relatórios 🔄

| Funcionalidade               | Status | Responsável | Observações |
|------------------------------|--------|-------------|-------------|
| Sistema de Login e Autenticação             | ✅ DONE | Iasmin (Back) + Luis (Front) | Interface e backend integrados |
| Sistema de Definição de Senhas             | 🔄 DOING | Hudson (Back) + Luis (Front) | Interface e backend integrados |
| Criar Formulário             | ✅ DONE | Marcus (Back) + Luis (Front) | Interface e backend integrados |
| Responder Formulário         | ✅ DONE | Marcus (Back) + Luis (Front) | Fluxo completo implementado |
| Visualizar Formulários Pendentes | ✅ DONE | Marcus (Back) + Luis (Front) | Interface responsiva |
| Gerar Relatório              | 📋 SPRINT 3 | A definir | Pendente: CSV export completo |
| Visualizar Resultados        | 📋 SPRINT 3 | A definir | Pendente: Dashboard e gráficos |ures)*  

## Equipe  

| Nome                              | Matrícula  | Papel           |  
|-----------------------------------|------------|----------------|  
| Iasmim de Queiroz Freitas         | 190108665  | **Scrum Master** |  
| Hudson Cauã Costa Lima            | 211055512  | **Product Owner** |  
| Luis Gustavo de Sousa Silva       | 200046527  | Desenvolvedor   |  
| Marcus Emanuel Carvalho T. Freitas| 222025960  | Desenvolvedor   |  

---
## Link do repositório - https://github.com/iasmimqf/CAMAAR

## Sprint 2 - Objetivos e Resultados

### Objetivos da Sprint 2
- **Implementação das features** cujos cenários BDD foram especificados na Sprint 1
- **Desenvolvimento dos controllers, views e models** necessários
- **Integração e validação** das funcionalidades implementadas
- **Documentação atualizada** das features na Wiki do repositório
- **Kanban organizado** usando a interface de projetos do GitHub

### Metodologia de Testes
**Nota sobre RSpec:** Embora inicialmente planejado o uso de RSpec para testes unitários, a equipe optou por focar na implementação das funcionalidades usando Cucumber para testes BDD durante esta sprint. **O RSpec será implementado na Sprint 3** para complementar a cobertura de testes com testes unitários e de integração.

### Kanban - Organização do Trabalho
O projeto utiliza a interface de projetos do GitHub com as seguintes lanes:
- **Backlog**: Features planejadas para implementação
- **Doing**: Features em desenvolvimento ativo
- **Done**: Features implementadas e testadas
- **Accepted**: Features validadas e aceitas pelo Product Owner

## Status das Funcionalidades - Sprint 2  

### Autenticação ✅

| Funcionalidade               | Status | Responsável | Observações |
|------------------------------|--------|-------------|-------------|
| Sistema de Login e Autenticação | ✅ DONE | Iasmim + Hudson + Luis (Front) | Sistema completo + validações Devise + interface |
| Sistema de Definição de Senha| 🔄 DOING | Hudson + Iasmim + Luis (Front) | Validações backend + formulários responsivos |

### Gestão de Templates ✅

| Funcionalidade               | Status | Responsável | Observações |
|------------------------------|--------|-------------|-------------|
| Criar Template               | ✅ DONE | Marcus (Back) + Luis (Front) + Iasmim (Integração) | CRUD completo, interface integrada |
| Editar/Deletar Template      | ✅ DONE | Marcus (Back + Testes) + Luis (Front) | Validações, permissões e UX completos |
| Visualizar Templates         | ✅ DONE | Marcus (Back) + Luis (Front) | Interface administrativa responsiva |

### Formulários & Relatórios 🔄

| Funcionalidade               | Status | Responsável  Observações |
|------------------------------|--------|--------------------------|
| Criar Formulário             | ✅ DONE |  Marcus | Interface e backend integrados |
| Responder Formulário         | ✅ DONE | Marcus | Fluxo completo implementado |
| Visualizar Formulários Pendentes | ✅ DONE | Marcus | Interface responsiva |
| Gerar Relatório              | � SPRINT 3 | A definir | Pendente: CSV export completo |
| Visualizar Resultados        | 📋 SPRINT 3 | A definir | Pendente: Dashboard e gráficos |

### Integração 📋

| Funcionalidade               | Status | Responsável | Observações |
|------------------------------|--------|-------------|-------------|
| Integrar Front-end com Backend (Formulários/Templates) | 🔄 DOING | Iasmim + Hudson | Conexão de interfaces com APIs |
| Importar Dados do SIGAA      | 📋 SPRINT 2 | Hudson | Análise completa, implementação pendente |
| Atualizar Base com SIGAA     | 📋 SPRINT 2 | Iasmim | Arquitetura planejada |


## Implementações Técnicas Realizadas

### Models & Backend (Marcus)
- **Template**: Modelo consolidado com documentação completa e scopes
- **Questao**: Modelo português ativo (Question em inglês removido)
- **Usuario**: Sistema de autenticação com Devise integrado
- **Formulario**: Relacionamentos e validações implementadas
- **Turma/Disciplina**: Estrutura base com foreign keys

### Controllers & API (Marcus)
- **Admin::TemplatesController**: CRUD completo para templates
- **Admin::FormulariosController**: Gestão de formulários e relatórios
- **ApplicationController**: Autenticação e autorização base
- **HomeController**: Endpoints principais

### Front-end & Interface (Luis Gustavo)
- **Interface administrativa**: Layout completo e responsivo
- **Formulários dinâmicos**: Criação e edição de templates
- **Páginas de listagem**: Filtros e paginação
- **Componentes reutilizáveis**: Botões, modais, navegação
- **UX/UI**: Design consistente e intuitivo

### Integração & Coordenação (Iasmim & Hudson)
- **Fluxos end-to-end**: Validação de funcionalidades completas
- **Coordenação técnica**: Integração entre front e back
- **Verificação de requisitos**: Validação com critérios de aceitação
- **Testes de aceitação**: Validação de cenários de usuário

### Testes & Quality Assurance (Marcus + Equipe)
- **13 features BDD**: Especificadas em Gherkin/Cucumber
- **Testes de formulários**: Cobertura de cenários críticos
- **85% de aprovação**: Nos testes implementados
- **Testes de integração**: Validação de fluxos completos

## Política de Branching - Sprint 2

### Fluxo Atual
- **`main`**: Branch protegida (versão estável)
- **`feature/F7-F8`**: Branch de desenvolvimento ativa
- **Branches específicas** por funcionalidade

### Processo de Desenvolvimento
1. **Feature branches** criadas a partir de `main`
2. **Push** para branches específica
3. **Testes automáticos** executados no CI

---

### Distribuição de Responsabilidades - Sprint 2

#### Front-end 🎨
**Luis Gustavo** - Desenvolvedor Front-end
- Interface administrativa completa
- Layouts responsivos
- Componentes de formulários
- Navegação e UX

#### Back-end & Testes 🔧
**Marcus** - Desenvolvedor Back-end
- Models consolidados (Template, Questao)
- Controllers implementados
- Testes BDD de formulários
- Validações e regras de negócio

#### Integração & Verificação 🔗
**Iasmim** (Scrum Master) & **Hudson** (Product Owner)
- Integração de telas e funcionalidades
- Verificação de requisitos
- Coordenação entre front-end e back-end
- Validação de fluxos completos

### Distribuição por Membro
| Membro | Responsabilidade Principal | Status |
|--------|---------------------------|---------|
| Luis Gustavo | Front-end & Interface | ✅ Meta superada |
| Marcus | Back-end & Testes | ✅ Meta superada |
| Iasmim | Integração & Coordenação | ✅ Meta atingida |
| Hudson | Verificação & Validação | ✅ Meta atingida | 

## Resumo da Sprint 2

### ✅ Sucessos
- **Front-end completo** desenvolvido por Luis Gustavo
- **Back-end robusto** implementado por Marcus com testes BDD
- **Integração eficiente** coordenada por Iasmim e Hudson
- **Interface administrativa** completamente funcional
- **Consolidação dos models** com nomenclatura consistente
- **Colaboração excepcional** entre as equipes

### 🔄 Funcionalidades Principais Implementadas
- **Sistema de Templates:** CRUD completo com validações
- **Gestão de Formulários:** Interface administrativa funcional
- **Autenticação:** Sistema seguro com Devise
- **Estrutura de Dados:** Models consolidados e relacionamentos

### 📋 Roadmap Sprint 3 - Prioridades

#### 🎯 Funcionalidades Críticas
1. **Relatórios Avançados**
   - Exportação CSV completa
   - Filtros e agregações
   - **Responsável:** Marcus (back-end) + Luis Gustavo (front-end)

2. **Visualização de Resultados**
   - Gráficos interativos
   - Dashboard analítico
   - Métricas em tempo real
   - **Responsável:** Luis Gustavo (front-end) + Marcus (API)

#### 🧪 Melhoria de Testes
3. **Refatoração de Testes**
   - Implementação de RSpec (testes unitários)
   - Ampliação da cobertura BDD
   - Testes de integração
   - **Responsável:** Marcus (liderança) + toda equipe

4. **Qualidade de Código**
   - Code review sistemático
   - Documentação técnica
   - Performance optimization
   - **Responsável:** Iasmim (coordenação) + Hudson (validação)

## 8. Próximas Iterações

### Sprint 3: Expansão e Refinamento
**Período:** Março 2025  
**Foco:** Aprimoramento da experiência do usuário e novas funcionalidades

#### Funcionalidades Planejadas:
- **Relatórios Avançados** (gerar_relatorio.feature)
  - Exportação para múltiplos formatos (CSV, PDF, Excel)
  - Filtros e personalização de relatórios
  - Responsável: Marcus + Luis (interface)

- **Sincronização SIGAA** (sincronizacao_sigaa.feature)
  - API de integração com SIGAA
  - Atualização automática de dados acadêmicos
  - Responsável: Hudson + Iasmim

- **Dashboard Administrativo** (admin features)
  - Visão geral de todas as avaliações
  - Métricas e estatísticas
  - Responsável: Luis + Marcus

### Sprint 4: Otimização e Deploy
**Período:** Abril 2025  
**Foco:** Performance, segurança e produção

#### Objetivos:
- Otimização de performance
- Testes de carga e stress
- Deploy em produção
- Documentação final do usuário

## 9. Lições Aprendidas

### Sucessos 📈
- **Colaboração Efetiva:** Time trabalhou de forma sincronizada
- **BDD/TDD:** Abordagem orientada a testes reduziu bugs significativamente
- **Arquitetura Rails:** Framework facilitou desenvolvimento rápido
- **Divisão de Responsabilidades:** Cada membro contribuiu com suas especialidades

### Desafios Superados 🎯
- **Integração:** Merge de diferentes componentes sem conflitos
- **Testes:** Implementação de suite de testes abrangente
- **UI/UX:** Interface intuitiva apesar da complexidade do domínio
- **Prazo:** Entrega dentro do cronograma estabelecido

### Melhorias para Próximos Sprints 🔧
- **Code Review:** Processo mais sistemático
- **Documentação:** Manter docs sempre atualizadas
- **Performance:** Monitoramento proativo
- **Testes:** Cobertura ainda mais ampla

## 10. Conclusão

O **Sprint 2** foi um marco importante no desenvolvimento do sistema CAMAAR. A equipe conseguiu implementar com sucesso os sistemas fundamentais de **autenticação** e **formulários**, estabelecendo uma base sólida para as próximas iterações.

### Principais Conquistas:
✅ **Sistema de autenticação robusto** com controle de acesso  
✅ **CRUD completo de templates** com interface intuitiva  
✅ **Sistema de formulários funcionais** pronto para uso  
✅ **85% dos testes BDD** passando com sucesso  
✅ **Documentação técnica** abrangente e atualizada  

### Próximos Passos:
🎯 Implementação de relatórios avançados  
🎯 Integração com SIGAA  
🎯 Dashboard administrativo  
🎯 Otimização para produção  

---

**CAMAAR Team - Sprint 2 concluído com sucesso! 🚀**  
*Próxima iteração: Sprint 3 - Março 2025*
