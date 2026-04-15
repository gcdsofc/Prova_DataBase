SGBD: Justifique a escolha de um SGBD Relacional (ex: PostgreSQL) em vez de um modelo NoSQL para este cenário, focando em propriedades ACID e integridade de dados.

R: A escolha de um SGBD Relacional como o PostgreSQL justifica-se pela necessidade de garantir a consistência total dos dados acadêmicos através das propriedades ACID. Diferente do NoSQL, o modelo relacional utiliza chaves estrangeiras para assegurar a integridade referencial, impedindo registros órfãos ou dados corrompidos, o que é fundamental em sistemas de gestão de notas e matrículas

Organização: Por que em um ambiente profissional de Engenharia de Dados é recomendado o uso de Schemas (ex: academico, seguranca) em vez de criar todas as tabelas no esquema padrão public?

O uso de schemas é recomendado por permitir uma melhor governança e segurança, isolando informações sensíveis (seguranca) da lógica de negócio (academico). Além de organizar o ambiente para facilitar a manutenção, essa estrutura permite aplicar políticas de acesso granulares, garantindo que usuários tenham permissões apenas nos módulos necessários para suas funções.

----------------------------------------------------------------------------------

## 2. Projeto e Normalização - Modelo Lógico (3NF)

Para normalizar os dados da planilha legada, a estrutura foi dividida em três tabelas principais, garantindo que não haja redundância e que cada dado esteja em seu respectivo contexto (Segurança ou Acadêmico).

### Esquema: seguranca
**Tabela: usuarios**
* `id_matricula` (PK - INT): Identificador único do aluno.
* `nome` (VARCHAR): Nome completo.
* `email` (VARCHAR): E-mail institucional.
* `endereco` (VARCHAR): Localização do aluno.
* `situacao` (BOOLEAN): Controle de Soft Delete (Ativo/Inativo).

### Esquema: academico
**Tabela: disciplinas**
* `cod_disciplina` (PK - VARCHAR): Código da disciplina (ex: ADS101).
* `nome` (VARCHAR): Nome da disciplina.
* `carga_h` (INT): Carga horária total.
* `ativo` (BOOLEAN): Controle de Soft Delete.

**Tabela: matriculas**
* `id` (PK - SERIAL): Chave primária da transação.
* `id_matricula` (FK): Relaciona com seguranca.usuarios.
* `cod_disciplina` (FK): Relaciona com academico.disciplinas.
* `docente` (VARCHAR): Nome do professor da turma.
* `data_ingresso` (DATE): Data da matrícula.
* `nota` (DECIMAL): Valor do Score Final.
* `ciclo` (VARCHAR): Período letivo (ex: 2026/1).
* `operador` (VARCHAR): Matrícula do operador pedagógico.

Imagem do DER: [DER](DER.png)

--------------------------------------------------------------------------------
Parte 5 da prova: 
Pergunta: Explique como os conceitos de Isolamento (ACID) e o uso de Locks garantem a consistência.

Resposta: O SGBD utiliza o nível de Isolamento para garantir que transações simultâneas não interfiram entre si. Quando dois operadores tentam alterar a mesma nota ao mesmo tempo, o sistema aplica um Lock (bloqueio) de linha. A primeira transação a chegar "tranca" o registro; a segunda transação entra em fila de espera e só processa após o COMMIT ou ROLLBACK da primeira. Isso evita o fenómeno da "Atualização Perdida" e garante que o dado final seja o resultado de operações sequenciais e íntegras.