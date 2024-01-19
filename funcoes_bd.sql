-- SAMBURA: Monitor de atividade pesqueira. 
-- 
-- Funções diversas para uso em um banco de dados geoespacial ESRI (PostgreSQL)

CREATE OR REPLACE FUNCTION func_area_nome(sde.st_geometry) RETURNS varchar AS $$
   SELECT descricao FROM sambura.areas_zee a WHERE sde.st_within($1, a.shape) LIMIT 1;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION func_cidade_nome(sde.st_geometry) RETURNS varchar AS $$
   SELECT cidade FROM sambura.portos_atracadouros a WHERE sde.st_within($1, a.shape) ORDER BY nivel LIMIT 1;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION func_local_nome(sde.st_geometry) RETURNS varchar AS $$
   SELECT nome FROM sambura.portos_atracadouros a WHERE sde.st_within($1, a.shape) ORDER BY nivel LIMIT 1;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION func_sigla_nome(sde.st_geometry) RETURNS varchar AS $$
   SELECT sigla FROM sambura.portos_atracadouros a WHERE sde.st_within($1, a.shape) ORDER BY nivel LIMIT 1;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION func_indicativo_arrasteiros(text, timestamp, float, float, smallint, sde.st_geometry) RETURNS varchar AS $$
   SELECT NULL;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION func_indicativo_cerco(text, timestamp, float, float, smallint, sde.st_geometry) RETURNS varchar AS $$
   SELECT NULL;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION func_indicativo_emalhe(text, timestamp, float, float, smallint, sde.st_geometry) RETURNS varchar AS $$
   SELECT NULL;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION func_indicativo_espinhel_potes(text, timestamp, float, float, smallint, sde.st_geometry) RETURNS varchar AS $$
   SELECT NULL;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION func_indicativo_linha_superficie(text, timestamp, float, float, smallint, sde.st_geometry) RETURNS varchar AS $$
   SELECT NULL;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION func_indicativo(text, timestamp, float, float, smallint, sde.st_geometry) RETURNS varchar AS $$
   SELECT NULL;
$$ LANGUAGE SQL;