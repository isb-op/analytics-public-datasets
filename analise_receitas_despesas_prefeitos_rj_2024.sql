/*
Projeto: Análise de financiamento de campanhas – Eleições 2024
Fonte de dados: TSE – Base dos Dados (BigQuery -  https://basedosdados.org/dataset/eef764df-bde8-4905-b115-6fc23b6ba9d6)
Tabelas: receitas_candidato e despesas_candidato
Escopo: 
    - Cargo: Prefeito 
    - Estado: Rio de Janeiro

Recurso Adicional:
  - Códigos de municípios (IBGE): https://www.ibge.gov.br/explica/codigos-dos-municipios.php
*/

-- ==========================================
-- 1. RECEITAS DE CAMPANHA – PREFEITOS (2024)
-- Município: Petrópolis/RJ (3303906)
-- ==========================================

-- Identificando candidatos
SELECT DISTINCT numero_candidato, sigla_partido
FROM `basedosdados.br_tse_eleicoes.receitas_candidato` 
WHERE ano = 2024 AND cargo = 'prefeito' AND sigla_uf = 'RJ' AND id_municipio = '3303906';

-- Informações gerais sobre a  os candidatos e valor de receita
SELECT numero_candidato, sigla_partido, valor_receita, fonte_receita, cpf_cnpj_doador, nome_doador, sigla_partido_doador, turno
FROM `basedosdados.br_tse_eleicoes.receitas_candidato` 
WHERE ano = 2024 AND cargo = 'prefeito' AND sigla_uf = 'RJ' AND id_municipio = '3303906'
ORDER BY valor_receita;

-- Valores de agregação para receita 
SELECT MAX(valor_receita) AS max_valor_receita, 
       MIN(valor_receita) AS min_valor_receita, 
       AVG(valor_receita) AS avg_valor_receita, 
       SUM(valor_receita) AS sum_valor_receita
FROM `basedosdados.br_tse_eleicoes.receitas_candidato` 
WHERE ano = 2024 AND sigla_uf = 'RJ' AND id_municipio = '3303906' AND cargo = 'prefeito';

-- Valores de agregação para receita relacionados ao candidato que venceu as eleições
-- Candidato: Hingo Gomes (PP) - 11 
SELECT MAX(valor_receita) AS max_valor_receita, 
       MIN(valor_receita) AS min_valor_receita, 
       AVG(valor_receita) AS avg_valor_receita, 
       SUM(valor_receita) AS sum_valor_receita
FROM `basedosdados.br_tse_eleicoes.receitas_candidato` 
WHERE ano = 2024 AND sigla_uf = 'RJ' AND id_municipio = '3303906' AND cargo = 'prefeito' AND numero_candidato = '11';

-- Valores de agregação para receita para o candidato disputou o segundo turno 
-- Candidato: Yuri Lucas Carius De Moura Almeida (PSOL) - 50  
SELECT MAX(valor_receita) AS max_valor_receita, 
       MIN(valor_receita) AS min_valor_receita, 
       ROUND(AVG(valor_receita), 1) AS avg_valor_receita, 
       ROUND(SUM(valor_receita), 1) AS sum_valor_receita
FROM `basedosdados.br_tse_eleicoes.receitas_candidato` 
WHERE ano = 2024 AND sigla_uf = 'RJ' AND id_municipio = '3303906' AND cargo = 'prefeito' AND numero_candidato = '50';

-- Quantidade de doadores distintos para o candidato 11
SELECT COUNT(DISTINCT cpf_cnpj_doador) AS qnt_de_doadores_distintos
FROM `basedosdados.br_tse_eleicoes.receitas_candidato` 
WHERE ano = 2024 AND sigla_uf = 'RJ' AND id_municipio = '3303906' AND numero_candidato = '11'; 


-- ==========================================
-- 2. RECEITAS DE CAMPANHA – PREFEITOS (2024)
-- Município: Todos/RJ 
-- ==========================================

-- Quantidade de doadores únicos
SELECT id_municipio, COUNT(DISTINCT cpf_cnpj_doador) AS qnt_doadores
FROM `basedosdados.br_tse_eleicoes.receitas_candidato` 
WHERE ano = 2024 AND sigla_uf = 'RJ' 
GROUP BY id_municipio
ORDER BY qnt_doadores DESC; 

-- Quantidade de receita total por candidato 
SELECT titulo_eleitoral_candidato, numero_candidato, id_municipio, 
       SUM(valor_receita) AS soma_valor_receita
FROM `basedosdados.br_tse_eleicoes.receitas_candidato` 
WHERE ano = 2024 AND sigla_uf = 'RJ' AND cargo = 'prefeito'
GROUP BY titulo_eleitoral_candidato, numero_candidato, id_municipio
ORDER BY soma_valor_receita DESC
LIMIT 100;

-- Filtrando somente candidatos com receita acima de 1000000
SELECT titulo_eleitoral_candidato, numero_candidato, id_municipio, sigla_partido, ROUND(SUM(valor_receita),1) AS soma_valor_receita
FROM `basedosdados.br_tse_eleicoes.receitas_candidato` 
WHERE ano = 2024 AND sigla_uf = 'RJ' AND cargo = 'prefeito'
GROUP BY titulo_eleitoral_candidato, numero_candidato, id_municipio, sigla_partido
HAVING soma_valor_receita > 1000000
ORDER BY soma_valor_receita DESC;

-- Incluindo o espectro partidário dos candidatos 
SELECT titulo_eleitoral_candidato, numero_candidato, id_municipio, sigla_partido, ROUND(SUM(valor_receita),1) AS soma_valor_receita,
       CASE WHEN sigla_partido IN ('REPUBLICANOS', 'NOVO', 'PP', 'AGIR', 'PL', 'PRTB', 'PRD', 'DC', 'PODE') THEN 'direita_centrodireita'
       WHEN sigla_partido IN ('PSD', 'MDB', 'UNIÃO', 'PSDB', 'AVANTE', 'MOBILIZA', 'PMB', 'CIDADANIA') THEN 'centro'
       WHEN sigla_partido IN ('PSB', 'PDT', 'PT', 'PSOL', 'REDE', 'PV', 'SOLIDARIEDADE') THEN 'esquerda_centroesquerda'
       ELSE 'extrema_esquerda' END AS espectro_partidario
FROM `basedosdados.br_tse_eleicoes.receitas_candidato` 
WHERE ano = 2024 AND sigla_uf = 'RJ' AND cargo = 'prefeito'
GROUP BY titulo_eleitoral_candidato, numero_candidato, id_municipio, sigla_partido
ORDER BY soma_valor_receita DESC
LIMIT 100; 


-- ==========================================
-- 3. DESPESAS DE CAMPANHA – PREFEITOS (2024)
-- Município: Petrópolis/RJ (3303906)
-- ==========================================

-- Avaliando as despesas do candidato 11
SELECT valor_despesa, origem_despesa, nome_fornecedor, cpf_cnpj_fornecedor, data_despesa
FROM `basedosdados.br_tse_eleicoes.despesas_candidato` 
WHERE ano = 2024 AND sigla_uf = 'RJ' AND id_municipio = '3303906' AND numero_candidato = '11';

-- Quantidade de fornecedores 
SELECT COUNT(DISTINCT cpf_cnpj_fornecedor) AS qnt_fornecedores
FROM `basedosdados.br_tse_eleicoes.despesas_candidato` 
WHERE ano = 2024 AND sigla_uf = 'RJ' AND id_municipio = '3303906' AND numero_candidato = '11';

-- Valores máx. e mín. de despesas
SELECT MAX(valor_despesa) AS valor_max_despesas,
       MIN(valor_despesa) AS valor_min_despesas
FROM `basedosdados.br_tse_eleicoes.despesas_candidato` 
WHERE ano = 2024 AND sigla_uf = 'RJ' AND id_municipio = '3303906' AND numero_candidato = '11';

-- Valor total de despesas
SELECT SUM(valor_despesa) AS valor_total_despesas
FROM `basedosdados.br_tse_eleicoes.despesas_candidato` 
WHERE ano = 2024 AND sigla_uf = 'RJ' AND id_municipio = '3303906' AND numero_candidato = '11';

-- ==========================================
-- 4. DESPESAS DE CAMPANHA – PREFEITOS (2024)
-- Município: Todos/RJ 
-- ==========================================

-- Quantidade de fornecedores e soma do valor total de despesas por candidato
SELECT numero_candidato, id_municipio, sigla_partido, COUNT(DISTINCT cpf_cnpj_fornecedor) AS qnt_fornecedores, ROUND(SUM(valor_despesa)) AS soma_valor_despesa,
       CASE WHEN SUM(valor_despesa) > 1000000 THEN 'alto'
       ELSE 'baixo' END AS categoria_despesas
FROM `basedosdados.br_tse_eleicoes.despesas_candidato` 
WHERE ano = 2024 AND sigla_uf = 'RJ' AND cargo = 'prefeito'
GROUP BY numero_candidato, id_municipio, sigla_partido
ORDER BY qnt_fornecedores DESC
LIMIT 100;