-- ==========================================================
-- PROJECT: World Tourism Analytics Data Warehouse
-- AUTHOR: Alvaro Muzas Antuña
-- SCRIPT: 01_create_dimensions.sql
-- DESCRIPTION: Creation of dimension tables (Core Schema)
-- DATABASE: PostgreSQL
-- DATE: 05-08-2026
-- ==========================================================


-- ==========================================================
-- DIM_REGION
-- World Regions Dimension
-- ==========================================================


DROP TABLE IF EXISTS core.dim_region CASCADE;

CREATE TABLE core.dim_region (
	region_id 		SERIAL		NOT NULL,			-- Unique region identifier
	world_region 	VARCHAR(50) NOT NULL,			-- World region name

	CONSTRAINT pk_dim_region
		PRIMARY KEY (region_id),
		
	CONSTRAINT uq_dim_region_world_region
		UNIQUE (world_region)
);

COMMENT ON TABLE core.dim_region IS
'Stores the world regions used by the Data Warehouse.';

COMMENT ON COLUMN core.dim_region.region_id IS
'Unique identifier for each world region.';

COMMENT ON COLUMN core.dim_region.world_region IS
'World region name.';

-- ==========================================================
-- END DIM_REGION
-- ==========================================================


-- ==========================================================
-- DIM_YEAR
-- Time Dimension
-- ==========================================================


DROP TABLE IF EXISTS core.dim_year CASCADE;

CREATE TABLE core.dim_year (
    year_id     SERIAL      NOT NULL,       -- Unique year identifier
    year        SMALLINT    NOT NULL,       -- Calendar year
    decade      SMALLINT    NOT NULL,       -- Decade
    century     SMALLINT    NOT NULL,       -- Century

 CONSTRAINT pk_dim_year
    PRIMARY KEY (year_id),

CONSTRAINT uq_dim_year_year
    UNIQUE (year)
);

COMMENT ON TABLE core.dim_year IS
'Stores the years used by the Data Warehouse.';

COMMENT ON COLUMN core.dim_year.year_id IS
'Unique identifier for each year.';

COMMENT ON COLUMN core.dim_year.year IS
'Calendar year.';

COMMENT ON COLUMN core.dim_year.decade IS
'Decade of the year.';

COMMENT ON COLUMN core.dim_year.century IS
'Century of the year.';
-- ==========================================================
-- END DIM_YEAR
-- ==========================================================


-- ==========================================================
-- DIM_COUNTRY
-- Country Dimension
-- ==========================================================
DROP TABLE IF EXISTS core.dim_country CASCADE;

CREATE TABLE core.dim_country (
    country_id      SERIAL          NOT NULL,       -- Unique country identifier
    country_code    CHAR(3)         NOT NULL,       -- ISO 3166-1 alpha-3 country code
    country         VARCHAR(100)    NOT NULL,       -- Country name
    region_id       INTEGER         NOT NULL,       -- Region identifier

CONSTRAINT pk_dim_country
    PRIMARY KEY (country_id),

CONSTRAINT uq_dim_country_country_code
    UNIQUE (country_code),

CONSTRAINT uq_dim_country_country
    UNIQUE (country),

CONSTRAINT fk_dim_country_region
    FOREIGN KEY (region_id)
    REFERENCES core.dim_region (region_id)
);

COMMENT ON TABLE core.dim_country IS
'Stores the countries used by the Data Warehouse.';

COMMENT ON COLUMN core.dim_country.country_id IS
'Unique identifier for each country.';

COMMENT ON COLUMN core.dim_country.country_code IS
'ISO 3166-1 alpha-3 country code.';

COMMENT ON COLUMN core.dim_country.country IS
'Country name.';

COMMENT ON COLUMN core.dim_country.region_id IS
'Associated world region identifier.';
-- ==========================================================
-- END DIM_COUNTRY
-- ==========================================================


-- ==========================================================
-- DIM_POPULATION
-- Population Category Dimension
-- ==========================================================
DROP TABLE IF EXISTS core.dim_population CASCADE;

CREATE TABLE core.dim_population(
    population_id           SERIAL          NOT NULL,           -- Unique population category identifier
    population_category     VARCHAR(30)     NOT NULL,           -- Population category
    min_population          BIGINT          NOT NULL,           -- Minimum population
    max_population          BIGINT          NOT NULL,           -- Maximum population

CONSTRAINT pk_dim_population
    PRIMARY KEY (population_id),

CONSTRAINT uq_dim_population_category
    UNIQUE (population_category)
);

COMMENT ON TABLE core.dim_population IS
'Stores population categories used for country classification.';

COMMENT ON COLUMN core.dim_population.population_id IS
'Unique identifier for each population category.';

COMMENT ON COLUMN core.dim_population.population_category IS
'Population category.';

COMMENT ON COLUMN core.dim_population.min_population IS
'Minimum population value for the category.';

COMMENT ON COLUMN core.dim_population.max_population IS
'Maximum population value for the category.';
-- ==========================================================
-- END DIM_POPULATION
-- ==========================================================


-- ==========================================================
-- DIM_INCOME
-- Income Category Dimension
-- ==========================================================
DROP TABLE IF EXISTS core.dim_income CASCADE;

CREATE TABLE core.dim_income(
    income_id           SERIAL          NOT NULL,       -- Unique income category identifier
    income_category     VARCHAR(30)     NOT NULL,       -- Income category
    min_gdp             NUMERIC(12,2)   NOT NULL,       -- Minimum GDP per capita
    max_gdp             NUMERIC(12,2)   NOT NULL,       -- Maximum GDP per capita

CONSTRAINT pk_dim_income
    PRIMARY KEY (income_id),

CONSTRAINT uq_dim_income_category
    UNIQUE (income_category)
);

COMMENT ON TABLE core.dim_income IS
'Stores income categories used for country classification.';

COMMENT ON COLUMN core.dim_income.income_id IS
'Unique identifier for each income category.';

COMMENT ON COLUMN core.dim_income.income_category IS
'Income category.';

COMMENT ON COLUMN core.dim_income.min_gdp IS
'Minimum GDP per capita value for the category.';

COMMENT ON COLUMN core.dim_income.max_gdp IS
'Maximum GDP per capita value for the category.';
-- ==========================================================
-- END DIM_INCOME
-- ==========================================================


-- ==========================================================
-- DIM_HAPPINESS_BAND
-- Happiness Band Dimension
-- ==========================================================
DROP TABLE IF EXISTS core.dim_happiness_band CASCADE;

CREATE TABLE core.dim_happiness_band(
    happiness_band_id       SERIAL          NOT NULL,       -- Unique happiness band identifier
    happiness_band          VARCHAR(30)     NOT NULL,       -- Happiness band
    min_score               NUMERIC(4,2)    NOT NULL,       -- Minimum happiness score
    max_score               NUMERIC(4,2)    NOT NULL,       -- Maximum happiness score

CONSTRAINT pk_dim_happiness_band
    PRIMARY KEY (happiness_band_id),

CONSTRAINT uq_dim_happiness_band
    UNIQUE (happiness_band)
);

COMMENT ON TABLE core.dim_happiness_band IS
'Stores happiness bands used for country classification.';

COMMENT ON COLUMN core.dim_happiness_band.happiness_band_id IS
'Unique identifier for each happiness band.';

COMMENT ON COLUMN core.dim_happiness_band.happiness_band IS
'Happiness band.';

COMMENT ON COLUMN core.dim_happiness_band.min_score IS
'Minimum happiness score for the band.';

COMMENT ON COLUMN core.dim_happiness_band.max_score IS
'Maximum happiness score for the band.';
-- ==========================================================
-- END DIM_HAPPINESS_BAND
-- ==========================================================


-- ==========================================================
-- DIM_PEACE_BAND
-- Peace Band Dimension
-- ==========================================================
DROP TABLE IF EXISTS core.dim_peace_band CASCADE;

CREATE TABLE core.dim_peace_band (
    peace_band_id       SERIAL          NOT NULL,           -- Unique peace band identifier
    peace_band          VARCHAR(30)     NOT NULL,           -- Peace band
    min_score           NUMERIC(4,2)    NOT NULL,           -- Minimum peace score
    max_score           NUMERIC(4,2)    NOT NULL,           -- Maximum peace score

CONSTRAINT pk_dim_peace_band
    PRIMARY KEY (peace_band_id),

CONSTRAINT uq_dim_peace_band
    UNIQUE (peace_band)
);

COMMENT ON TABLE core.dim_peace_band IS
'Stores peace bands used for country classification.';

COMMENT ON COLUMN core.dim_peace_band.peace_band_id IS
'Unique identifier for each peace band.';

COMMENT ON COLUMN core.dim_peace_band.peace_band IS
'Peace band.';

COMMENT ON COLUMN core.dim_peace_band.min_score IS
'Minimum peace score for the band.';

COMMENT ON COLUMN core.dim_peace_band.max_score IS
'Maximum peace score for the band.';
-- ==========================================================
-- END DIM_PEACE_BAND
-- ==========================================================


-- ==========================================================
-- DIM_TOURISM
-- Tourism Category Dimension
-- ==========================================================
DROP TABLE IF EXISTS core.dim_tourism CASCADE;

CREATE TABLE core.dim_tourism (
    tourism_id          SERIAL          NOT NULL,           -- Unique tourism category identifier
    tourism_category    VARCHAR(30)     NOT NULL,           -- Tourism category
    min_arrivals        BIGINT          NOT NULL,           -- Minimum tourist arrivals
    max_arrivals        BIGINT          NOT NULL,           -- Maximum tourist arrivals

CONSTRAINT pk_dim_tourism
    PRIMARY KEY (tourism_id),

CONSTRAINT uq_dim_tourism_category
    UNIQUE (tourism_category)
);

COMMENT ON TABLE core.dim_tourism IS
'Stores tourism categories used for country classification.';

COMMENT ON COLUMN core.dim_tourism.tourism_id IS
'Unique identifier for each tourism category.';

COMMENT ON COLUMN core.dim_tourism.tourism_category IS
'Tourism category.';

COMMENT ON COLUMN core.dim_tourism.min_arrivals IS
'Minimum tourist arrivals for the category.';

COMMENT ON COLUMN core.dim_tourism.max_arrivals IS
'Maximum tourist arrivals for the category.';
-- ==========================================================
-- END DIM_TOURISM
-- ==========================================================


-- ==========================================================
-- DIM_UNESCO
-- UNESCO Category Dimension
-- ==========================================================
DROP TABLE IF EXISTS core.dim_unesco CASCADE;

CREATE TABLE core.dim_unesco(
    unesco_id           SERIAL          NOT NULL,           -- Unique UNESCO category identifier
    unesco_category     VARCHAR(30)     NOT NULL,           -- UNESCO category
    min_sites           SMALLINT        NOT NULL,           -- Minimum UNESCO sites
    max_sites           SMALLINT        NOT NULL,           -- Maximum UNESCO sites

CONSTRAINT pk_dim_unesco
    PRIMARY KEY (unesco_id),

CONSTRAINT uq_dim_unesco_category
    UNIQUE (unesco_category)
);

COMMENT ON TABLE core.dim_unesco IS
'Stores UNESCO categories used for country classification.';

COMMENT ON COLUMN core.dim_unesco.unesco_id IS
'Unique identifier for each UNESCO category.';

COMMENT ON COLUMN core.dim_unesco.unesco_category IS
'UNESCO category.';

COMMENT ON COLUMN core.dim_unesco.min_sites IS
'Minimum UNESCO sites for the category.';

COMMENT ON COLUMN core.dim_unesco.max_sites IS
'Maximum UNESCO sites for the category.';
-- ==========================================================
-- END DIM_UNESCO
-- ==========================================================


-- ==========================================================
-- FACT_COUNTRY_PROFILE
-- Country Profile Fact Table
-- ==========================================================
DROP TABLE IF EXISTS core.fact_country_profile CASCADE;

CREATE TABLE core.fact_country_profile (

    -- ================
    -- Primary Key
    -- ================

    fact_id                     SERIAL          NOT NULL,       -- Unique fact identifier

    -- ================
    -- Foreign Keys
    -- ================

    country_id                  INTEGER         NOT NULL,      -- Country identifier
    year_id                     INTEGER         NOT NULL,      -- Year identifier
    region_id                   INTEGER         NOT NULL,      -- Region identifier
    population_id               INTEGER         NOT NULL,      -- Population category identifier
    income_id                   INTEGER         NOT NULL,      -- Income category identifier
    happiness_band_id           INTEGER         NOT NULL,      -- Happiness band identifier
    peace_band_id               INTEGER         NOT NULL,      -- Peace band identifier
    tourism_id                  INTEGER         NOT NULL,      -- Tourism category identifier
    unesco_id                   INTEGER         NOT NULL,      -- UNESCO category identifier

    -- ================
    -- Measures
    -- ================

    population                  BIGINT,                        -- Population
    gdp_per_capita              NUMERIC(12,2),                 -- GDP per capita
    tourist_arrivals            BIGINT,                        -- International tourist arrivals
    unesco_sites                SMALLINT,                      -- Number of UNESCO sites
    happiness_score             NUMERIC(4,3),                  -- Happiness score
    happiness_rank              SMALLINT,                      -- Happiness rank
    gdp_factor                  NUMERIC(5,3),                  -- GDP contribution
    social_support              NUMERIC(5,3),                  -- Social support
    healthy_life_expectancy     NUMERIC(5,3),                  -- Healthy life expectancy
    freedom                     NUMERIC(5,3),                  -- Freedom to make life choices
    generosity                  NUMERIC(5,3),                  -- Generosity
    corruption                  NUMERIC(5,3),                  -- Perception of corruption
    dystopia_residual           NUMERIC(5,3),                  -- Dystopia residual
    peace_score                 NUMERIC(4,3),                  -- Peace score
    peace_rank                  SMALLINT,                      -- Peace rank

    -- ================
    -- Audit
    -- ================

    last_updated                TIMESTAMP,                     -- ETL load timestamp

CONSTRAINT pk_fact_country_profile
    PRIMARY KEY (fact_id),

CONSTRAINT fk_fact_country
    FOREIGN KEY (country_id)
    REFERENCES core.dim_country (country_id),

CONSTRAINT fk_fact_year
    FOREIGN KEY (year_id)
    REFERENCES core.dim_year (year_id),

CONSTRAINT fk_fact_region
    FOREIGN KEY (region_id)
    REFERENCES core.dim_region (region_id),

CONSTRAINT fk_fact_population
    FOREIGN KEY (population_id)
    REFERENCES core.dim_population (population_id),

CONSTRAINT fk_fact_income
    FOREIGN KEY (income_id)
    REFERENCES core.dim_income (income_id),

CONSTRAINT fk_fact_happiness_band
    FOREIGN KEY (happiness_band_id)
    REFERENCES core.dim_happiness_band (happiness_band_id),

CONSTRAINT fk_fact_peace_band
    FOREIGN KEY (peace_band_id)
    REFERENCES core.dim_peace_band (peace_band_id),

CONSTRAINT fk_fact_tourism
    FOREIGN KEY (tourism_id)
    REFERENCES core.dim_tourism (tourism_id),

CONSTRAINT fk_fact_unesco
    FOREIGN KEY (unesco_id)
    REFERENCES core.dim_unesco (unesco_id)

);

COMMENT ON TABLE core.fact_country_profile IS
'Stores the main socio-economic, tourism and quality of life indicators for each country and year.';

COMMENT ON COLUMN core.fact_country_profile.fact_id IS
'Unique identifier for each fact record.';

COMMENT ON COLUMN core.fact_country_profile.country_id IS
'Reference to the country dimension.';

COMMENT ON COLUMN core.fact_country_profile.year_id IS
'Reference to the year dimension.';

COMMENT ON COLUMN core.fact_country_profile.region_id IS
'Reference to the region dimension.';

COMMENT ON COLUMN core.fact_country_profile.population_id IS
'Reference to the population category dimension.';

COMMENT ON COLUMN core.fact_country_profile.income_id IS
'Reference to the income category dimension.';

COMMENT ON COLUMN core.fact_country_profile.happiness_band_id IS
'Reference to the happiness band dimension.';

COMMENT ON COLUMN core.fact_country_profile.peace_band_id IS
'Reference to the peace band dimension.';

COMMENT ON COLUMN core.fact_country_profile.tourism_id IS
'Reference to the tourism category dimension.';

COMMENT ON COLUMN core.fact_country_profile.unesco_id IS
'Reference to the UNESCO category dimension.';

COMMENT ON COLUMN core.fact_country_profile.population IS
'Total population.';

COMMENT ON COLUMN core.fact_country_profile.gdp_per_capita IS
'Gross Domestic Product per capita.';

COMMENT ON COLUMN core.fact_country_profile.tourist_arrivals IS
'International tourist arrivals.';

COMMENT ON COLUMN core.fact_country_profile.unesco_sites IS
'Number of UNESCO World Heritage sites.';

COMMENT ON COLUMN core.fact_country_profile.happiness_score IS
'Overall happiness score.';

COMMENT ON COLUMN core.fact_country_profile.happiness_rank IS
'Happiness ranking position.';

COMMENT ON COLUMN core.fact_country_profile.gdp_factor IS
'Contribution of GDP to happiness.';

COMMENT ON COLUMN core.fact_country_profile.social_support IS
'Contribution of social support to happiness.';

COMMENT ON COLUMN core.fact_country_profile.healthy_life_expectancy IS
'Contribution of healthy life expectancy to happiness.';

COMMENT ON COLUMN core.fact_country_profile.freedom IS
'Contribution of freedom to happiness.';

COMMENT ON COLUMN core.fact_country_profile.generosity IS
'Contribution of generosity to happiness.';

COMMENT ON COLUMN core.fact_country_profile.corruption IS
'Contribution of perceived corruption to happiness.';

COMMENT ON COLUMN core.fact_country_profile.dystopia_residual IS
'Dystopia residual contribution to happiness.';

COMMENT ON COLUMN core.fact_country_profile.peace_score IS
'Global Peace Index score.';

COMMENT ON COLUMN core.fact_country_profile.peace_rank IS
'Global Peace Index ranking position.';

COMMENT ON COLUMN core.fact_country_profile.last_updated IS
'Date and time of the last ETL update.';
-- ==========================================================
-- END FACT_COUNTRY_PROFILE
-- ==========================================================