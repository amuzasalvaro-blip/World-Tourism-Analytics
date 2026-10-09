-- ==========================================================
-- 03_LOAD_CORE
-- CARGA DE DIMENSIONES
-- ==========================================================


-- ==========================================================
-- DIM_REGION
-- ==========================================================

-- Limpia la dimensión antes de cargarla.
DELETE FROM core.dim_region;

SELECT setval(
    pg_get_serial_sequence('core.dim_region', 'region_id'),
    1,
    false
);

-- Carga las regiones únicas desde Staging en la dimensión de regiones.
INSERT INTO core.dim_region (world_region)
SELECT DISTINCT world_region
FROM staging.tourism
WHERE world_region IS NOT NULL
  AND TRIM(world_region) <> ''
ORDER BY world_region;

-- Comprueba las regiones cargadas.
SELECT *
FROM core.dim_region
ORDER BY region_id;


-- ==========================================================
-- DIM_YEAR
-- ==========================================================

-- Limpia la dimensión antes de cargarla.
DELETE FROM core.dim_year;

SELECT setval(
    pg_get_serial_sequence('core.dim_year', 'year_id'),
    1,
    false
);

-- Carga todos los años necesarios para el modelo.
INSERT INTO core.dim_year (year, decade, century)
SELECT
    year,
    (year / 10) * 10 AS decade,
    ((year - 1) / 100) + 1 AS century
FROM generate_series(1960, 2026) AS year
ORDER BY year;

-- Comprueba los años cargados.
SELECT *
FROM core.dim_year
ORDER BY year_id;


-- ============================================================
-- DIM_COUNTRY
-- ============================================================

-- Limpia la dimensión antes de cargarla.
DELETE FROM core.dim_country;

SELECT setval(
    pg_get_serial_sequence('core.dim_country', 'country_id'),
    1,
    false
);

-- Carga los países válidos con su región.
INSERT INTO core.dim_country (country_code, country, region_id)
SELECT
    country_code,
    country_name,
    r.region_id
FROM (
    SELECT DISTINCT ON (country_name)
        country_code,
        country_name,
        world_region
    FROM (
        SELECT
            c.country_code,
            COALESCE(t.country_name, u.country_name, p.country_name) AS country_name,
            COALESCE(t.world_region, u.world_region) AS world_region,
            CASE
                WHEN t.country_code IS NOT NULL THEN 1
                WHEN u.country_code IS NOT NULL THEN 2
                ELSE 3
            END AS source_priority
        FROM (
            SELECT DISTINCT UPPER(TRIM(country_code)) AS country_code
            FROM staging.population

            UNION

            SELECT DISTINCT UPPER(TRIM(country_code))
            FROM staging.gdp_per_capita

            UNION

            SELECT DISTINCT UPPER(TRIM(country_code))
            FROM staging.tourism

            UNION

            SELECT DISTINCT UPPER(TRIM(country_code))
            FROM staging.global_peace_index

            UNION

            SELECT DISTINCT UPPER(TRIM(country_code))
            FROM staging.unesco
        ) c

        LEFT JOIN (
            SELECT DISTINCT
                UPPER(TRIM(country_code)) AS country_code,
                country_name,
                world_region
            FROM staging.tourism
        ) t ON c.country_code = t.country_code

        LEFT JOIN (
            SELECT DISTINCT
                UPPER(TRIM(country_code)) AS country_code,
                country_name,
                world_region
            FROM staging.unesco
        ) u ON c.country_code = u.country_code

        LEFT JOIN (
            SELECT DISTINCT
                UPPER(TRIM(country_code)) AS country_code,
                country_name
            FROM staging.population
        ) p ON c.country_code = p.country_code

        WHERE COALESCE(t.country_name, u.country_name, p.country_name) IS NOT NULL
          AND COALESCE(t.world_region, u.world_region) IS NOT NULL
          AND c.country_code ~ '^[A-Z]{3}$'
          AND c.country_code NOT IN (
              'AFE','AFW','ARB','CEB','EAP','EAS','ECA','ECS',
              'EUU','HIC','HPC','LAC','LCN','LDC','LIC','LMC',
              'LMY','MEA','MIC','MNA','NAC','SAS','SSA','SSF',
              'TEA','TEC','TLA','TMN','TSA','TSS','UMC','WLD',
              'CSS','EAR','EMU','IBD','IBT','IDA','IDB','IDX',
              'INX','LTE','OED','OSS','PRE','PSS','PST','SST','CHI'
          )
    ) countries
    ORDER BY country_name, source_priority, country_code
) countries
JOIN core.dim_region r
    ON r.world_region = CASE
        WHEN countries.world_region = 'Asia and the Pacific' THEN 'Asia'
        WHEN countries.world_region = 'Europe and North America' THEN 'Europe'
        WHEN countries.world_region = 'Latin America and the Caribbean' THEN 'South America'
        ELSE countries.world_region
    END
ORDER BY country_code;

-- Comprueba los países cargados.
SELECT *
FROM core.dim_country
ORDER BY country_id;


-- ============================================================
-- DIM_POPULATION
-- ============================================================

-- Limpia la dimensión antes de cargarla.
DELETE FROM core.dim_population;

SELECT setval(
    pg_get_serial_sequence('core.dim_population', 'population_id'),
    1,
    false
);

-- Carga las categorías de población.
INSERT INTO core.dim_population (
    population_category,
    min_population,
    max_population
)
VALUES
    ('Muy baja', 0, 99999),
    ('Baja', 100000, 999999),
    ('Media', 1000000, 9999999),
    ('Alta', 10000000, 99999999),
    ('Muy alta', 100000000, 1463865525);

-- Comprueba las categorías cargadas.
SELECT *
FROM core.dim_population
ORDER BY population_id;

-- Comprueba que los rangos de población son consecutivos.
SELECT
    population_category,
    min_population,
    max_population,
    LAG(max_population) OVER (ORDER BY population_id) AS previous_max
FROM core.dim_population
ORDER BY population_id;


-- ============================================================
-- DIM_INCOME
-- ============================================================

-- Limpia la dimensión antes de cargarla.
DELETE FROM core.dim_income;

SELECT setval(
    pg_get_serial_sequence('core.dim_income', 'income_id'),
    1,
    false
);

-- Carga las categorías de PIB per cápita.
INSERT INTO core.dim_income (
    income_category,
    min_gdp,
    max_gdp
)
VALUES
    ('Muy bajo', 0, 999.99),
    ('Bajo', 1000, 4999.99),
    ('Medio', 5000, 14999.99),
    ('Alto', 15000, 49999.99),
    ('Muy alto', 50000, 147252.18);

-- Comprueba las categorías cargadas.
SELECT *
FROM core.dim_income
ORDER BY income_id;

-- Comprueba que los rangos de PIB per cápita son consecutivos.
SELECT
    income_category,
    min_gdp,
    max_gdp,
    LAG(max_gdp) OVER (ORDER BY income_id) AS previous_max
FROM core.dim_income
ORDER BY income_id;


-- ============================================================
-- DIM_HAPPINESS_BAND
-- ============================================================

-- Limpia la dimensión antes de cargarla.
DELETE FROM core.dim_happiness_band;

SELECT setval(
    pg_get_serial_sequence('core.dim_happiness_band', 'happiness_band_id'),
    1,
    false
);

-- Carga las categorías de felicidad.
INSERT INTO core.dim_happiness_band (
    happiness_band,
    min_score,
    max_score
)
VALUES
    ('Muy baja', 0, 3.999),
    ('Baja', 4, 4.999),
    ('Media', 5, 5.999),
    ('Alta', 6, 6.999),
    ('Muy alta', 7, 8);

-- Comprueba las categorías cargadas.
SELECT *
FROM core.dim_happiness_band
ORDER BY happiness_band_id;

-- Comprueba que los rangos de felicidad son consecutivos.
SELECT
    happiness_band,
    min_score,
    max_score,
    LAG(max_score) OVER (ORDER BY happiness_band_id) AS previous_max
FROM core.dim_happiness_band
ORDER BY happiness_band_id;


-- ============================================================
-- DIM_PEACE_BAND
-- ============================================================

-- Limpia la dimensión antes de cargarla.
DELETE FROM core.dim_peace_band;

SELECT setval(
    pg_get_serial_sequence('core.dim_peace_band', 'peace_band_id'),
    1,
    false
);

-- Carga las categorías del Global Peace Index.
INSERT INTO core.dim_peace_band (
    peace_band,
    min_score,
    max_score
)
VALUES
    ('Muy alta', 0, 1.5),
    ('Alta', 1.5, 2),
    ('Media', 2, 2.5),
    ('Baja', 2.5, 3),
    ('Muy baja', 3, 4);

-- Comprueba las categorías cargadas.
SELECT *
FROM core.dim_peace_band
ORDER BY peace_band_id;

-- Comprueba que los rangos de paz son consecutivos.
SELECT
    peace_band,
    min_score,
    max_score,
    LAG(max_score) OVER (ORDER BY peace_band_id) AS previous_max
FROM core.dim_peace_band
ORDER BY peace_band_id;


-- ============================================================
-- DIM_TOURISM
-- ============================================================

-- Limpia la dimensión antes de cargarla.
DELETE FROM core.dim_tourism;

SELECT setval(
    pg_get_serial_sequence('core.dim_tourism', 'tourism_id'),
    1,
    false
);

-- Carga las categorías de llegadas de turistas.
INSERT INTO core.dim_tourism (
    tourism_category,
    min_arrivals,
    max_arrivals
)
VALUES
    ('Muy bajo', 0, 999999),
    ('Bajo', 1000000, 4999999),
    ('Medio', 5000000, 9999999),
    ('Alto', 10000000, 24999999),
    ('Muy alto', 25000000, 100000000);

-- Comprueba las categorías cargadas.
SELECT *
FROM core.dim_tourism
ORDER BY tourism_id;

-- Comprueba que los rangos de turismo son consecutivos.
SELECT
    tourism_category,
    min_arrivals,
    max_arrivals,
    LAG(max_arrivals) OVER (ORDER BY tourism_id) AS previous_max
FROM core.dim_tourism
ORDER BY tourism_id;


-- ============================================================
-- DIM_UNESCO
-- ============================================================

-- Limpia la dimensión antes de cargarla.
DELETE FROM core.dim_unesco;

-- Reinicia el contador del ID.
SELECT setval(
    pg_get_serial_sequence('core.dim_unesco', 'unesco_id'),
    1,
    false
);

-- Carga las categorías de sitios UNESCO.
INSERT INTO core.dim_unesco (
    unesco_category,
    min_sites,
    max_sites
)
VALUES
    ('Muy baja', 0, 4),
    ('Baja', 5, 9),
    ('Media', 10, 19),
    ('Alta', 20, 39),
    ('Muy alta', 40, 100);

-- Comprueba las categorías cargadas.
SELECT *
FROM core.dim_unesco
ORDER BY unesco_id;

-- Comprueba que los rangos UNESCO son consecutivos.
SELECT
    unesco_category,
    min_sites,
    max_sites,
    LAG(max_sites) OVER (
        ORDER BY unesco_id
    ) AS previous_max
FROM core.dim_unesco
ORDER BY unesco_id;

-- ============================================================
-- FACT_COUNTRY_PROFILE
-- ============================================================






-- ============================================================
-- CARGA DE LA TABLA DE HECHOS: PERFIL PAÍS-AÑO
-- 1 país + 1 año = 1 registro
-- Periodo: 2011-2024
-- ============================================================

WITH population_long AS (

-- ========================================================
-- 1. PREPARA LA POBLACIÓN: convierte años en filas
 -- ========================================================
    SELECT
        p.country_code,
        p.country_name,
        v.year,
        v.population
    FROM staging.population p
    CROSS JOIN LATERAL (
        VALUES
            (2011, p."2011"),
            (2012, p."2012"),
            (2013, p."2013"),
            (2014, p."2014"),
            (2015, p."2015"),
            (2016, p."2016"),
            (2017, p."2017"),
            (2018, p."2018"),
            (2019, p."2019"),
            (2020, p."2020"),
            (2021, p."2021"),
            (2022, p."2022"),
            (2023, p."2023"),
            (2024, p."2024")
    ) v(year, population)
    WHERE v.population IS NOT NULL
),


-- ============================================================
-- 2. PREPARA EL GDP PER CAPITA: convierte años en filas
-- ============================================================

gdp_long AS (
    SELECT
        g.country_code,
        v.year,
        v.gdp_per_capita
    FROM staging.gdp_per_capita g
    CROSS JOIN LATERAL (
        VALUES
            (2011, g."2011"),
            (2012, g."2012"),
            (2013, g."2013"),
            (2014, g."2014"),
            (2015, g."2015"),
            (2016, g."2016"),
            (2017, g."2017"),
            (2018, g."2018"),
            (2019, g."2019"),
            (2020, g."2020"),
            (2021, g."2021"),
            (2022, g."2022"),
            (2023, g."2023"),
            (2024, g."2024")
    ) v(year, gdp_per_capita)
    WHERE v.gdp_per_capita IS NOT NULL
),


-- ============================================================
-- 3. PREPARA GLOBAL PEACE INDEX: convierte años en filas
-- ============================================================

gpi_long AS (
    SELECT
        g.country_code,
        v.year,
        v.peace_score,
        v.peace_rank
    FROM staging.global_peace_index g
    CROSS JOIN LATERAL (
        VALUES
            (2011, g."2011_Score", g."2011_Rank"),
            (2012, g."2012_Score", g."2012_Rank"),
            (2013, g."2013_Score", g."2013_Rank"),
            (2014, g."2014_Score", g."2014_Rank"),
            (2015, g."2015_Score", g."2015_Rank"),
            (2016, g."2016_Score", g."2016_Rank"),
            (2017, g."2017_Score", g."2017_Rank"),
            (2018, g."2018_Score", g."2018_Rank"),
            (2019, g."2019_Score", g."2019_Rank"),
            (2020, g."2020_Score", g."2020_Rank"),
            (2021, g."2021_Score", g."2021_Rank"),
            (2022, g."2022_Score", g."2022_Rank"),
            (2023, g."2023_Score", g."2023_Rank"),
            (2024, g."2024_Score", g."2024_Rank")
    ) v(year, peace_score, peace_rank)
    WHERE v.peace_score IS NOT NULL
),


-- ============================================================
-- 4. CUENTA LOS SITIOS UNESCO POR PAÍS
-- ============================================================

unesco_counts AS (
    SELECT
        UPPER(TRIM(country_code)) AS country_code,
        COUNT(*)::smallint AS unesco_sites
    FROM staging.unesco
    WHERE country_code IS NOT NULL
      AND TRIM(country_code) <> ''
    GROUP BY UPPER(TRIM(country_code))
),


-- ============================================================
-- 5. CONSTRUYE EL CONJUNTO FINAL DE DATOS
-- ============================================================

base_data AS (
    SELECT
        c.country_id,
        y.year_id,
        c.region_id,

        -- Claves de las dimensiones
        dp.population_id,
        di.income_id,
        dh.happiness_band_id,
        dpeace.peace_band_id,
        dt.tourism_id,
        du.unesco_id,

        -- Medidas
        p.population,
        gdp.gdp_per_capita,
        t.tourist_arrivals,
        COALESCE(u.unesco_sites, 0)::smallint AS unesco_sites,

        -- World Happiness
        h.life_evaluation AS happiness_score,
        h.rank AS happiness_rank,
        h.gdp_factor,
        h.social_support,
        h.healthy_life_expectancy,
        h.freedom,
        h.generosity,
        h.corruption,
        h.dystopia_residual,

        -- Global Peace Index
        gpi.peace_score,
        gpi.peace_rank

    FROM population_long p


    -- ========================================================
    -- 5.1 PAÍS
    -- ========================================================

    INNER JOIN core.dim_country c
        ON UPPER(TRIM(p.country_code)) = c.country_code


    -- ========================================================
    -- 5.2 AÑO
    -- ========================================================

    INNER JOIN core.dim_year y
        ON y.year = p.year


    -- ========================================================
    -- 5.3 POBLACIÓN
    -- ========================================================

    INNER JOIN core.dim_population dp
        ON p.population >= dp.min_population
       AND p.population <= dp.max_population


    -- ========================================================
    -- 5.4 GDP PER CAPITA
    -- ========================================================

    INNER JOIN gdp_long gdp
        ON UPPER(TRIM(p.country_code))
           = UPPER(TRIM(gdp.country_code))
       AND p.year = gdp.year


    INNER JOIN core.dim_income di
        ON gdp.gdp_per_capita >= di.min_gdp
       AND gdp.gdp_per_capita <= di.max_gdp


    -- ========================================================
    -- 5.5 WORLD HAPPINESS
    -- ========================================================

    INNER JOIN staging.world_happiness h
        ON TRIM(p.country_name) = TRIM(h.country_name)
       AND p.year = h.year


    INNER JOIN core.dim_happiness_band dh
        ON h.life_evaluation >= dh.min_score
       AND h.life_evaluation < dh.max_score


    -- ========================================================
    -- 5.6 TURISMO
    -- ========================================================

    INNER JOIN staging.tourism t
        ON UPPER(TRIM(p.country_code))
           = UPPER(TRIM(t.country_code))
       AND p.year = t.year


    INNER JOIN core.dim_tourism dt
        ON t.tourist_arrivals >= dt.min_arrivals
       AND t.tourist_arrivals < dt.max_arrivals


    -- ========================================================
    -- 5.7 GLOBAL PEACE INDEX
    -- ========================================================

    INNER JOIN gpi_long gpi
        ON UPPER(TRIM(p.country_code))
           = UPPER(TRIM(gpi.country_code))
       AND p.year = gpi.year


    INNER JOIN core.dim_peace_band dpeace
        ON gpi.peace_score >= dpeace.min_score
       AND gpi.peace_score < dpeace.max_score


    -- ========================================================
    -- 5.8 UNESCO
    -- ========================================================

    LEFT JOIN unesco_counts u
        ON UPPER(TRIM(p.country_code)) = u.country_code


    INNER JOIN core.dim_unesco du
        ON COALESCE(u.unesco_sites, 0) >= du.min_sites
       AND COALESCE(u.unesco_sites, 0) < du.max_sites
)


-- ============================================================
-- 6. INSERTA EN LA TABLA DE HECHOS
-- ============================================================

INSERT INTO core.fact_country_profile (
    fact_id,
    country_id,
    year_id,
    region_id,
    population_id,
    income_id,
    happiness_band_id,
    peace_band_id,
    tourism_id,
    unesco_id,
    population,
    gdp_per_capita,
    tourist_arrivals,
    unesco_sites,
    happiness_score,
    happiness_rank,
    gdp_factor,
    social_support,
    healthy_life_expectancy,
    freedom,
    generosity,
    corruption,
    dystopia_residual,
    peace_score,
    peace_rank,
    last_updated
)

SELECT

    -- ========================================================
    -- 6.1 FACT_ID
    -- ========================================================

    (
        SELECT COALESCE(MAX(fact_id), 0)
        FROM core.fact_country_profile
    )
    +
    ROW_NUMBER() OVER (
        ORDER BY country_id, year_id
    ) AS fact_id,


    -- ========================================================
    -- 6.2 CLAVES FORÁNEAS
    -- ========================================================

    country_id,
    year_id,
    region_id,
    population_id,
    income_id,
    happiness_band_id,
    peace_band_id,
    tourism_id,
    unesco_id,


    -- ========================================================
    -- 6.3 MEDIDAS
    -- ========================================================

    population,
    gdp_per_capita,
    tourist_arrivals,
    unesco_sites,
    happiness_score,
    happiness_rank,
    gdp_factor,
    social_support,
    healthy_life_expectancy,
    freedom,
    generosity,
    corruption,
    dystopia_residual,
    peace_score,
    peace_rank,


    -- ========================================================
    -- 6.4 FECHA DE CARGA
    -- ========================================================

    CURRENT_TIMESTAMP

FROM base_data;

