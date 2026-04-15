parte 3 da prova:
-- ==========================================================
-- 1. ESTRUTURA E NAMESPACES (DDL)
-- ==========================================================

-- Criação dos Schemas
CREATE SCHEMA academico;
CREATE SCHEMA seguranca;

-- Tabela de Usuários (dentro de seguranca)
-- Implementação de Soft Delete via coluna 'ativo'
CREATE TABLE seguranca.usuarios (
    id_matricula INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    endereco VARCHAR(150),
    ativo BOOLEAN DEFAULT TRUE 
);

-- Tabela de Disciplinas (dentro de academico)
CREATE TABLE academico.disciplinas (
    cod_disciplina VARCHAR(20) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    carga_h INT,
    ativo BOOLEAN DEFAULT TRUE
);

-- Tabela de Matrículas/Histórico (dentro de academico)
-- Implementação de Governança via coluna 'situacao'
CREATE TABLE academico.matriculas (
    id SERIAL PRIMARY KEY,
    id_matricula INT REFERENCES seguranca.usuarios(id_matricula),
    cod_disciplina VARCHAR(20) REFERENCES academico.disciplinas(cod_disciplina),
    matricula_operador VARCHAR(20),
    docente VARCHAR(100),
    data_ingresso DATE,
    nota DECIMAL(4,2),
    ciclo VARCHAR(10),
    situacao VARCHAR(20) DEFAULT 'ATIVO' 
);

-- ==========================================================
-- 2. SEGURANÇA E PRIVACIDADE (DCL)
-- ==========================================================

-- Criação dos Perfis
CREATE ROLE professor_role;
CREATE ROLE coordenador_role;

-- Permissões do Coordenador: Acesso total
GRANT ALL PRIVILEGES ON SCHEMA academico TO coordenador_role;
GRANT ALL PRIVILEGES ON SCHEMA seguranca TO coordenador_role;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA academico TO coordenador_role;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA seguranca TO coordenador_role;

-- Permissões do Professor
GRANT USAGE ON SCHEMA academico TO professor_role;
GRANT USAGE ON SCHEMA seguranca TO professor_role;

-- Professor pode ver tudo em matriculas
GRANT SELECT ON academico.matriculas TO professor_role;

-- Professor pode atualizar APENAS a coluna de notas
GRANT UPDATE (nota) ON academico.matriculas TO professor_role;

-- Privacidade: Professor vê nome e matrícula, mas NÃO tem acesso ao e-mail
GRANT SELECT (id_matricula, nome, endereco, ativo) ON seguranca.usuarios TO professor_role;

-- ==========================================================
-- 3. POPULAÇÃO DE DADOS (DML)
-- Baseado na PLANILHA_LEGADA.csv
-- ==========================================================

-- Inserindo Usuários
INSERT INTO seguranca.usuarios (id_matricula, nome, email, endereco) VALUES
(2026001, 'Ana Beatriz Lima', 'ana.lima@aluno.edu.br', 'Braganca Paulista/SP'),
(2026002, 'Bruno Henrique Souza', 'bruno.souza@aluno.edu.br', 'Atibaia/SP'),
(2026003, 'Caio Oliveira', 'caio.oliveira@aluno.edu.br', 'Bom Jesus dos Perdoez/SP'),
(2026004, 'Daniela Costa', 'daniela.costa@aluno.edu.br', 'Itatiba/SP'),
(2026005, 'Eduarda Nunes', 'eduarda.nunes@aluno.edu.br', 'Itatiba/SP'),
(2026006, 'Felipe Araujo', 'felipe.araujo@aluno.edu.br', 'Louveira/SP');

-- Inserindo Disciplinas
INSERT INTO academico.disciplinas (cod_disciplina, nome, carga_h) VALUES
('ADS101', 'Banco de Dados', 80),
('ADS102', 'Engenharia de Software', 80),
('ADS103', 'Algoritmos', 60),
('ADS104', 'Redes de Computadores', 60),
('ADS105', 'Sistemas Operacionais', 60),
('ADS106', 'Estruturas de Dados', 80);

-- Inserindo Matrículas e Notas
INSERT INTO academico.matriculas (id_matricula, cod_disciplina, matricula_operador, docente, data_ingresso, nota, ciclo) VALUES
(2026001, 'ADS101', 'OP9001', 'Prof. Carlos Mendes', '2026-01-20', 9.1, '2026/1'),
(2026001, 'ADS102', 'OP9001', 'Profa. Juliana Castro', '2026-01-20', 8.4, '2026/1'),
(2026002, 'ADS101', 'OP9002', 'Prof. Carlos Mendes', '2026-01-21', 7.3, '2026/1'),
(2026003, 'ADS101', 'OP9003', 'Prof. Carlos Mendes', '2026-01-22', 5.8, '2026/1'),
(2026004, 'ADS104', 'OP9002', 'Profa. Marina Lopes', '2026-01-24', 8.1, '2026/1'),
(2026005, 'ADS106', 'OP9002', 'Prof. Ricardo Faria', '2026-01-24', 8.7, '2026/1'),
(2026006, 'ADS101', 'OP9004', 'Prof. Carlos Mendes', '2026-01-25', 6.4, '2026/1'),
(2026006, 'ADS103', 'OP9004', 'Prof. Renato Alves', '2026-01-25', 5.6, '2026/1');

---------------------------------------------------------------------------------

Parte 4 da prova: 

-- 1. Listagem de Matriculados: Nome dos alunos, disciplinas e ciclo (Filtrando 2026/1)
SELECT 
    u.nome AS nome_aluno, 
    d.nome AS nome_disciplina, 
    m.ciclo
FROM academico.matriculas m
JOIN seguranca.usuarios u ON m.id_matricula = u.id_matricula
JOIN academico.disciplinas d ON m.cod_disciplina = d.cod_disciplina
WHERE m.ciclo = '2026/1';

-- 2. Baixo Desempenho: Média de notas por disciplina (Apenas médias < 6.0)
SELECT 
    d.nome AS disciplina, 
    AVG(m.nota) AS media_geral
FROM academico.matriculas m
JOIN academico.disciplinas d ON m.cod_disciplina = d.cod_disciplina
GROUP BY d.nome
HAVING AVG(m.nota) < 6.0;

-- 3. Alocação de Docentes: Todos os docentes e suas disciplinas (Incluindo os sem turmas)
-- Nota: Aqui usamos LEFT JOIN para garantir que docentes sem disciplinas também apareçam.
SELECT 
    m.docente AS nome_docente, 
    d.nome AS nome_disciplina
FROM academico.matriculas m
RIGHT JOIN academico.disciplinas d ON m.cod_disciplina = d.cod_disciplina;
-- Dica: Se tivesses uma tabela separada de docentes, o LEFT JOIN seria nela. 
-- Como os dados estão em 'matriculas', o RIGHT JOIN na 'disciplinas' ou um LEFT na 'docentes' resolve.

-- 4. Destaque Académico: Nome do aluno e maior nota em "Banco de Dados" (Subconsulta)
SELECT 
    u.nome AS aluno_destaque, 
    m.nota AS maior_nota
FROM academico.matriculas m
JOIN seguranca.usuarios u ON m.id_matricula = u.id_matricula
JOIN academico.disciplinas d ON m.cod_disciplina = d.cod_disciplina
WHERE d.nome = 'Banco de Dados'
AND m.nota = (
    SELECT MAX(nota) 
    FROM academico.matriculas m2
    JOIN academico.disciplinas d2 ON m2.cod_disciplina = d2.cod_disciplina
    WHERE d2.nome = 'Banco de Dados'
);