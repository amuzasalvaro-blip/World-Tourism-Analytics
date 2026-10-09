-- ==========================================================
-- STAGING_TOURISM
-- ==========================================================
DROP TABLE IF EXISTS staging.tourism;

CREATE TABLE staging.tourism(
    country_name        VARCHAR(100),
    country_code        CHAR(3),
    world_region        VARCHAR(50)
);


-- ==========================================================
-- STAGING_UNESCO
-- ==========================================================
DROP TABLE IF EXISTS staging.unesco;

CREATE TABLE staging.unesco(
    heritage_id         INTEGER,
    heritage_name       VARCHAR(255),
    inscription_year    SMALLINT,
    danger              VARCHAR(10),
    longitude           NUMERIC(10,6),
    altitude            NUMERIC(10,6),
    area_hectares       NUMERIC(15,2),
    criteria            VARCHAR(50),
    category            VARCHAR(30),
    category_code       VARCHAR(10),
    country_name        VARCHAR(100),
    world_region        VARCHAR(50),
    country_code        CHAR(3)

);


-- ==========================================================
-- STAGING_WORLD_HAPPINESS
-- ==========================================================

DROP TABLE IF EXISTS staging.world_happiness;

CREATE TABLE staging.world_happiness (

    country_name                 VARCHAR(100),
    country_code                 CHAR(3),
    year                         SMALLINT,
    happiness_score              NUMERIC(4,3),
    happiness_rank               SMALLINT,
    gdp_factor                   NUMERIC(5,3),
    social_support               NUMERIC(5,3),
    healthy_life_expectancy      NUMERIC(5,3),
    freedom                      NUMERIC(5,3),
    generosity                   NUMERIC(5,3),
    corruption                   NUMERIC(5,3),
    dystopia_residual            NUMERIC(5,3),
    world_region                 VARCHAR(50)

);


-- ==========================================================
-- STAGING_POPULATION
-- ==========================================================

DROP TABLE IF EXISTS staging.population;

CREATE TABLE staging.population (

    country_name    VARCHAR(100),
    country_code    CHAR(3),

    "1960" BIGINT,
    "1961" BIGINT,
    "1962" BIGINT,
    "1963" BIGINT,
    "1964" BIGINT,
    "1965" BIGINT,
    "1966" BIGINT,
    "1967" BIGINT,
    "1968" BIGINT,
    "1969" BIGINT,
    "1970" BIGINT,
    "1971" BIGINT,
    "1972" BIGINT,
    "1973" BIGINT,
    "1974" BIGINT,
    "1975" BIGINT,
    "1976" BIGINT,
    "1977" BIGINT,
    "1978" BIGINT,
    "1979" BIGINT,
    "1980" BIGINT,
    "1981" BIGINT,
    "1982" BIGINT,
    "1983" BIGINT,
    "1984" BIGINT,
    "1985" BIGINT,
    "1986" BIGINT,
    "1987" BIGINT,
    "1988" BIGINT,
    "1989" BIGINT,
    "1990" BIGINT,
    "1991" BIGINT,
    "1992" BIGINT,
    "1993" BIGINT,
    "1994" BIGINT,
    "1995" BIGINT,
    "1996" BIGINT,
    "1997" BIGINT,
    "1998" BIGINT,
    "1999" BIGINT,
    "2000" BIGINT,
    "2001" BIGINT,
    "2002" BIGINT,
    "2003" BIGINT,
    "2004" BIGINT,
    "2005" BIGINT,
    "2006" BIGINT,
    "2007" BIGINT,
    "2008" BIGINT,
    "2009" BIGINT,
    "2010" BIGINT,
    "2011" BIGINT,
    "2012" BIGINT,
    "2013" BIGINT,
    "2014" BIGINT,
    "2015" BIGINT,
    "2016" BIGINT,
    "2017" BIGINT,
    "2018" BIGINT,
    "2019" BIGINT,
    "2020" BIGINT,
    "2021" BIGINT,
    "2022" BIGINT,
    "2023" BIGINT,
    "2024" BIGINT,
    "2025" BIGINT

);


-- ==========================================================
-- STAGING_GDP_PER_CAPITA
-- ==========================================================

DROP TABLE IF EXISTS staging.gdp_per_capita;

CREATE TABLE staging.gdp_per_capita (

    country_name    VARCHAR(100),
    country_code    CHAR(3),

    "1960" NUMERIC(12,2),
    "1961" NUMERIC(12,2),
    "1962" NUMERIC(12,2),
    "1963" NUMERIC(12,2),
    "1964" NUMERIC(12,2),
    "1965" NUMERIC(12,2),
    "1966" NUMERIC(12,2),
    "1967" NUMERIC(12,2),
    "1968" NUMERIC(12,2),
    "1969" NUMERIC(12,2),
    "1970" NUMERIC(12,2),
    "1971" NUMERIC(12,2),
    "1972" NUMERIC(12,2),
    "1973" NUMERIC(12,2),
    "1974" NUMERIC(12,2),
    "1975" NUMERIC(12,2),
    "1976" NUMERIC(12,2),
    "1977" NUMERIC(12,2),
    "1978" NUMERIC(12,2),
    "1979" NUMERIC(12,2),
    "1980" NUMERIC(12,2),
    "1981" NUMERIC(12,2),
    "1982" NUMERIC(12,2),
    "1983" NUMERIC(12,2),
    "1984" NUMERIC(12,2),
    "1985" NUMERIC(12,2),
    "1986" NUMERIC(12,2),
    "1987" NUMERIC(12,2),
    "1988" NUMERIC(12,2),
    "1989" NUMERIC(12,2),
    "1990" NUMERIC(12,2),
    "1991" NUMERIC(12,2),
    "1992" NUMERIC(12,2),
    "1993" NUMERIC(12,2),
    "1994" NUMERIC(12,2),
    "1995" NUMERIC(12,2),
    "1996" NUMERIC(12,2),
    "1997" NUMERIC(12,2),
    "1998" NUMERIC(12,2),
    "1999" NUMERIC(12,2),
    "2000" NUMERIC(12,2),
    "2001" NUMERIC(12,2),
    "2002" NUMERIC(12,2),
    "2003" NUMERIC(12,2),
    "2004" NUMERIC(12,2),
    "2005" NUMERIC(12,2),
    "2006" NUMERIC(12,2),
    "2007" NUMERIC(12,2),
    "2008" NUMERIC(12,2),
    "2009" NUMERIC(12,2),
    "2010" NUMERIC(12,2),
    "2011" NUMERIC(12,2),
    "2012" NUMERIC(12,2),
    "2013" NUMERIC(12,2),
    "2014" NUMERIC(12,2),
    "2015" NUMERIC(12,2),
    "2016" NUMERIC(12,2),
    "2017" NUMERIC(12,2),
    "2018" NUMERIC(12,2),
    "2019" NUMERIC(12,2),
    "2020" NUMERIC(12,2),
    "2021" NUMERIC(12,2),
    "2022" NUMERIC(12,2),
    "2023" NUMERIC(12,2),
    "2024" NUMERIC(12,2),
    "2025" NUMERIC(12,2)

);