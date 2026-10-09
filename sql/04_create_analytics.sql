-- ============================================================
-- ANALYTICS
-- Creación de la capa de análisis
-- ============================================================

-- ============================================================
-- 1. COMPRUEBA LA ESTRUCTURA DE LA TABLA DE HECHOS
-- ============================================================

SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'core'
  AND table_name = 'fact_country_profile'
ORDER BY ordinal_position;

-- ============================================================
-- 2. COMPRUEBA EL NÚMERO DE REGISTROS DE LA TABLA DE HECHOS
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT country_id) AS countries,
    COUNT(DISTINCT year_id) AS years,
    COUNT(DISTINCT region_id) AS regions,
    COUNT(DISTINCT population_id) AS populations,
    COUNT(DISTINCT income_id) AS incomes,
    COUNT(DISTINCT happiness_band_id) AS happiness_bands,
    COUNT(DISTINCT peace_band_id) AS peace_bands,
    COUNT(DISTINCT tourism_id) AS tourism,
    COUNT(DISTINCT unesco_id) AS unesco
FROM core.fact_country_profile;

-- ============================================================
-- 3. COMPRUEBA QUE NO EXISTEN DUPLICADOS DE PAÍS + AÑO
-- ============================================================

SELECT
    country_id,
    year_id,
    COUNT(*) AS occurrences
FROM core.fact_country_profile
GROUP BY
    country_id,
    year_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;

-- ============================================================
-- 4. COMPRUEBA QUE LAS CLAVES FORÁNEAS NO SEAN NULL
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(country_id) AS countries,
    COUNT(year_id) AS years,
    COUNT(region_id) AS regions,
    COUNT(population_id) AS populations,
    COUNT(income_id) AS incomes,
    COUNT(happiness_band_id) AS happiness_bands,
    COUNT(peace_band_id) AS peace_bands,
    COUNT(tourism_id) AS tourism,
    COUNT(unesco_id) AS unesco
FROM core.fact_country_profile;

-- ============================================================
-- 5. COMPRUEBA LAS MEDIDAS DE LA TABLA DE HECHOS
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(population) AS population,
    COUNT(gdp_per_capita) AS gdp_per_capita,
    COUNT(tourist_arrivals) AS tourist_arrivals,
    COUNT(unesco_sites) AS unesco_sites,
    COUNT(happiness_score) AS happiness_score,
    COUNT(happiness_rank) AS happiness_rank,
    COUNT(peace_score) AS peace_score,
    COUNT(peace_rank) AS peace_rank
FROM core.fact_country_profile;

-- ============================================================
-- 6. COMPRUEBA LOS RANGOS DE LAS MEDIDAS
-- ============================================================

SELECT
    MIN(population) AS min_population,
    MAX(population) AS max_population,
    MIN(gdp_per_capita) AS min_gdp_per_capita,
    MAX(gdp_per_capita) AS max_gdp_per_capita,
    MIN(tourist_arrivals) AS min_tourist_arrivals,
    MAX(tourist_arrivals) AS max_tourist_arrivals,
    MIN(unesco_sites) AS min_unesco_sites,
    MAX(unesco_sites) AS max_unesco_sites,
    MIN(happiness_score) AS min_happiness_score,
    MAX(happiness_score) AS max_happiness_score,
    MIN(peace_score) AS min_peace_score,
    MAX(peace_score) AS max_peace_score
FROM core.fact_country_profile;

-- ============================================================
-- 7. COMPRUEBA EL ESQUEMA ANALYTICS
-- ============================================================

SELECT
    table_schema,
    table_name,
    table_type
FROM information_schema.tables
WHERE table_schema = 'analytics'
ORDER BY table_name;

-- ============================================================
-- 8. VISTA ANALÍTICA: EVOLUCIÓN DE FELICIDAD POR PAÍS Y AÑO
-- ============================================================

CREATE OR REPLACE VIEW analytics.vw_happiness_evolution AS

SELECT
    -- ========================================================
    -- 8.1 IDENTIFICACIÓN GEOGRÁFICA Y TEMPORAL
    -- ========================================================

    c.country_code,
    y.year_id,
    y.year,
    c.region_id,

    -- ========================================================
    -- 8.2 POBLACIÓN Y ECONOMÍA
    -- ========================================================

    f.population,
    f.gdp_per_capita,

    -- ========================================================
    -- 8.3 FELICIDAD
    -- ========================================================

    f.happiness_score,
    f.happiness_rank,

    -- ========================================================
    -- 8.4 PAZ
    -- ========================================================

    f.peace_score,
    f.peace_rank,

    -- ========================================================
    -- 8.5 TURISMO Y PATRIMONIO
    -- ========================================================

    f.tourist_arrivals,
    f.unesco_sites

FROM core.fact_country_profile f

-- ============================================================
-- PAÍS
-- ============================================================

INNER JOIN core.dim_country c
    ON f.country_id = c.country_id

-- ============================================================
-- AÑO
-- ============================================================

INNER JOIN core.dim_year y
    ON f.year_id = y.year_id

ORDER BY
    c.country_code,
    y.year;

-- ============================================================
-- 8.1 COMPRUEBA LA VISTA
-- ============================================================

SELECT *
FROM analytics.vw_happiness_evolution
LIMIT 20;

-- ============================================================
-- 8.2 COMPRUEBA EL NÚMERO DE REGISTROS DE LA VISTA
-- ============================================================

SELECT COUNT(*) AS total_rows
FROM analytics.vw_happiness_evolution;

-- ============================================================
-- 9. VISTA ANALÍTICA: GDP PER CAPITA Y FELICIDAD
-- ============================================================

CREATE OR REPLACE VIEW analytics.vw_gdp_happiness AS

SELECT
    -- ========================================================
    -- 9.1 IDENTIFICACIÓN GEOGRÁFICA Y TEMPORAL
    -- ========================================================

    c.country_code,
    y.year_id,
    y.year,
    f.region_id,

    -- ========================================================
    -- 9.2 INDICADORES ECONÓMICOS
    -- ========================================================

    f.gdp_per_capita,
    f.income_id,

    -- ========================================================
    -- 9.3 INDICADORES DE FELICIDAD
    -- ========================================================

    f.happiness_score,
    f.happiness_rank,
    f.happiness_band_id,

    -- ========================================================
    -- 9.4 OTROS INDICADORES
    -- ========================================================

    f.population,
    f.peace_score,
    f.tourist_arrivals,
    f.unesco_sites

FROM core.fact_country_profile f

INNER JOIN core.dim_country c
    ON f.country_id = c.country_id

INNER JOIN core.dim_year y
    ON f.year_id = y.year_id

ORDER BY
    c.country_code,
    y.year;

-- ============================================================
-- 9.1 COMPRUEBA LA VISTA
-- ============================================================

SELECT *
FROM analytics.vw_gdp_happiness
LIMIT 20;

-- ============================================================
-- 9.2 COMPRUEBA EL NÚMERO DE REGISTROS
-- ============================================================

SELECT COUNT(*) AS total_rows
FROM analytics.vw_gdp_happiness;

-- ============================================================
-- 10. VISTA ANALÍTICA: PAZ Y FELICIDAD
-- ============================================================

CREATE OR REPLACE VIEW analytics.vw_peace_happiness AS

SELECT
    -- ========================================================
    -- 10.1 IDENTIFICACIÓN GEOGRÁFICA Y TEMPORAL
    -- ========================================================

    c.country_code,
    y.year_id,
    y.year,
    f.region_id,

    -- ========================================================
    -- 10.2 INDICADORES DE PAZ
    -- ========================================================

    f.peace_score,
    f.peace_rank,
    f.peace_band_id,

    -- ========================================================
    -- 10.3 INDICADORES DE FELICIDAD
    -- ========================================================

    f.happiness_score,
    f.happiness_rank,
    f.happiness_band_id,

    -- ========================================================
    -- 10.4 OTROS INDICADORES
    -- ========================================================

    f.gdp_per_capita,
    f.population,
    f.tourist_arrivals,
    f.unesco_sites

FROM core.fact_country_profile f

INNER JOIN core.dim_country c
    ON f.country_id = c.country_id

INNER JOIN core.dim_year y
    ON f.year_id = y.year_id

ORDER BY
    c.country_code,
    y.year;

-- ============================================================
-- 10.1 COMPRUEBA LA VISTA
-- ============================================================

SELECT *
FROM analytics.vw_peace_happiness
LIMIT 20;

-- ============================================================
-- 10.2 COMPRUEBA EL NÚMERO DE REGISTROS
-- ============================================================

SELECT COUNT(*) AS total_rows
FROM analytics.vw_peace_happiness;

-- ============================================================
-- 11. VISTA ANALÍTICA: TURISMO Y FELICIDAD
-- ============================================================

CREATE OR REPLACE VIEW analytics.vw_tourism_happiness AS

SELECT
    -- ========================================================
    -- 11.1 IDENTIFICACIÓN GEOGRÁFICA Y TEMPORAL
    -- ========================================================

    c.country_code,
    y.year_id,
    y.year,
    f.region_id,

    -- ========================================================
    -- 11.2 INDICADORES DE TURISMO
    -- ========================================================

    f.tourist_arrivals,
    f.tourism_id,

    -- ========================================================
    -- 11.3 INDICADORES DE FELICIDAD
    -- ========================================================

    f.happiness_score,
    f.happiness_rank,
    f.happiness_band_id,

    -- ========================================================
    -- 11.4 INDICADORES ECONÓMICOS Y DEMOGRÁFICOS
    -- ========================================================

    f.gdp_per_capita,
    f.population,

    -- ========================================================
    -- 11.5 INDICADORES DE PAZ Y UNESCO
    -- ========================================================

    f.peace_score,
    f.peace_rank,
    f.unesco_sites

FROM core.fact_country_profile f

INNER JOIN core.dim_country c
    ON f.country_id = c.country_id

INNER JOIN core.dim_year y
    ON f.year_id = y.year_id

ORDER BY
    c.country_code,
    y.year;

-- ============================================================
-- 11.1 COMPRUEBA LA VISTA
-- ============================================================

SELECT *
FROM analytics.vw_tourism_happiness
LIMIT 20;

-- ============================================================
-- 11.2 COMPRUEBA EL NÚMERO DE REGISTROS
-- ============================================================

SELECT COUNT(*) AS total_rows
FROM analytics.vw_tourism_happiness;

-- ============================================================
-- 12. VISTA ANALÍTICA: TURISMO Y PATRIMONIO UNESCO
-- ============================================================

CREATE OR REPLACE VIEW analytics.vw_tourism_unesco AS

SELECT
    -- ========================================================
    -- 12.1 IDENTIFICACIÓN GEOGRÁFICA Y TEMPORAL
    -- ========================================================

    c.country_code,
    y.year_id,
    y.year,
    f.region_id,

    -- ========================================================
    -- 12.2 INDICADORES DE TURISMO
    -- ========================================================

    f.tourist_arrivals,
    f.tourism_id,

    -- ========================================================
    -- 12.3 INDICADORES UNESCO
    -- ========================================================

    f.unesco_sites,
    f.unesco_id,

    -- ========================================================
    -- 12.4 INDICADORES ECONÓMICOS Y DEMOGRÁFICOS
    -- ========================================================

    f.gdp_per_capita,
    f.population,

    -- ========================================================
    -- 12.5 INDICADORES DE FELICIDAD Y PAZ
    -- ========================================================

    f.happiness_score,
    f.happiness_rank,
    f.peace_score,
    f.peace_rank

FROM core.fact_country_profile f

INNER JOIN core.dim_country c
    ON f.country_id = c.country_id

INNER JOIN core.dim_year y
    ON f.year_id = y.year_id

ORDER BY
    c.country_code,
    y.year;

-- ============================================================
-- 12.1 COMPRUEBA LA VISTA
-- ============================================================

SELECT *
FROM analytics.vw_tourism_unesco
LIMIT 20;

-- ============================================================
-- 12.2 COMPRUEBA EL NÚMERO DE REGISTROS
-- ============================================================

SELECT COUNT(*) AS total_rows
FROM analytics.vw_tourism_unesco;

-- ============================================================
-- 13. VISTA ANALÍTICA: RANKING DE PAÍSES POR FELICIDAD
-- ============================================================

CREATE OR REPLACE VIEW analytics.vw_country_happiness_ranking AS

SELECT

    -- ========================================================
    -- 13.1 IDENTIFICACIÓN GEOGRÁFICA Y TEMPORAL
    -- ========================================================

    c.country_code,
    y.year_id,
    y.year,
    f.region_id,

    -- ========================================================
    -- 13.2 INDICADORES DE FELICIDAD
    -- ========================================================

    f.happiness_score,
    f.happiness_rank,
    f.happiness_band_id,

    -- ========================================================
    -- 13.3 RANKING CALCULADO
    -- ========================================================

    RANK() OVER (
        PARTITION BY y.year
        ORDER BY f.happiness_score DESC
    ) AS happiness_position,

    -- ========================================================
    -- 13.4 OTROS INDICADORES
    -- ========================================================

    f.gdp_per_capita,
    f.peace_score,
    f.tourist_arrivals,
    f.unesco_sites,
    f.population

FROM core.fact_country_profile f

INNER JOIN core.dim_country c
    ON f.country_id = c.country_id

INNER JOIN core.dim_year y
    ON f.year_id = y.year_id

ORDER BY
    y.year,
    happiness_position;

-- ============================================================
-- 13.1 COMPRUEBA LA VISTA
-- ============================================================

SELECT *
FROM analytics.vw_country_happiness_ranking
LIMIT 20;

-- ============================================================
-- 13.2 COMPRUEBA EL NÚMERO DE REGISTROS
-- ============================================================

SELECT COUNT(*) AS total_rows
FROM analytics.vw_country_happiness_ranking;

-- ============================================================
-- 14. VISTA ANALÍTICA: RESUMEN ANUAL POR REGIÓN
-- ============================================================

CREATE OR REPLACE VIEW analytics.vw_regional_yearly_summary AS

SELECT

    -- ========================================================
    -- 14.1 IDENTIFICACIÓN TEMPORAL Y GEOGRÁFICA
    -- ========================================================

    f.region_id,
    y.year_id,
    y.year,

    -- ========================================================
    -- 14.2 COBERTURA
    -- ========================================================

    COUNT(DISTINCT f.country_id) AS countries,

    -- ========================================================
    -- 14.3 POBLACIÓN Y ECONOMÍA
    -- ========================================================

    SUM(f.population) AS total_population,
    AVG(f.gdp_per_capita) AS avg_gdp_per_capita,

    -- ========================================================
    -- 14.4 FELICIDAD
    -- ========================================================

    AVG(f.happiness_score) AS avg_happiness_score,

    -- ========================================================
    -- 14.5 PAZ
    -- ========================================================

    AVG(f.peace_score) AS avg_peace_score,

    -- ========================================================
    -- 14.6 TURISMO
    -- ========================================================

    SUM(f.tourist_arrivals) AS total_tourist_arrivals,

    -- ========================================================
    -- 14.7 PATRIMONIO UNESCO
    -- ========================================================

    SUM(f.unesco_sites) AS total_unesco_sites

FROM core.fact_country_profile f

INNER JOIN core.dim_year y
    ON f.year_id = y.year_id

GROUP BY
    f.region_id,
    y.year_id,
    y.year

ORDER BY
    y.year,
    f.region_id;

-- ============================================================
-- 14.1 COMPRUEBA LA VISTA
-- ============================================================

SELECT *
FROM analytics.vw_regional_yearly_summary
LIMIT 20;

-- ============================================================
-- 14.2 COMPRUEBA EL NÚMERO DE REGISTROS
-- ============================================================

SELECT COUNT(*) AS total_rows
FROM analytics.vw_regional_yearly_summary;

-- ============================================================
-- 15. COMPRUEBA LAS VISTAS DE LA CAPA ANALYTICS
-- ============================================================

SELECT
    table_schema,
    table_name,
    table_type
FROM information_schema.tables
WHERE table_schema = 'analytics'
ORDER BY table_name;