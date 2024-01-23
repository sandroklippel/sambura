-- SAMBURA: Monitor de atividade pesqueira. 
-- 
-- materialized views

-- arrasteiros
CREATE MATERIALIZED VIEW arrasteiros AS 
SELECT r.rid::int4 as objectid, 
       r.embarcacao_raep as embarcacao, 
       r.tie,
       r.raep,
       r.tipo,
       r.data_hora,
       r.veloc as velocidade,
       r.direcao,
       r.prof as profundidade, 
       sambura.func_area_nome(sde.st_point(r.longitude, r.latitude, 4326)) as zee,
       sde.st_distance(sde.st_point(r.longitude, r.latitude, 4326), l.shape, 'Nautical_Mile') as dist_costa, 
       func_indicativo(r.tipo, r.data_hora, r.veloc, r.direcao, r.prof, sde.st_point(r.longitude, r.latitude, 4326)) as indicativo,
       sde.st_point(r.longitude, r.latitude, 4326) as shape
       FROM rastreamento r, linha_de_costa l
       WHERE r.data_hora > now() - '1 day'::interval AND r.prof > 0 AND
             r.tipo IN ('arrasto de fundo oceânico', 
                        'arrasto de fundo peixes', 
                        'arrasto de fundo duplo peixes', 
                        'arrasto duplo rosa e cristalino',
                        'arrasto duplo sete-barbas');

-- cerco
CREATE MATERIALIZED VIEW cerco AS 
SELECT r.rid::int4 as objectid, 
       r.embarcacao_raep as embarcacao, 
       r.tie,
       r.raep,
       r.tipo,
       r.data_hora,
       r.veloc as velocidade,
       r.direcao,
       r.prof as profundidade, 
       sambura.func_area_nome(sde.st_point(r.longitude, r.latitude, 4326)) as zee,
       sde.st_distance(sde.st_point(r.longitude, r.latitude, 4326), l.shape, 'Nautical_Mile') as dist_costa, 
       func_indicativo(r.tipo, r.data_hora, r.veloc, r.direcao, r.prof, sde.st_point(r.longitude, r.latitude, 4326)) as indicativo,
       sde.st_point(r.longitude, r.latitude, 4326) as shape
       FROM rastreamento r, linha_de_costa l
       WHERE r.data_hora > now() - '1 day'::interval AND r.prof > 0 AND
             r.tipo IN ('cerco sardinha-verdadeira', 
                        'cerco sardinha-laje', 
                        'cerco bonito-listrado');

-- emalhe
CREATE MATERIALIZED VIEW emalhe AS 
SELECT r.rid::int4 as objectid, 
       r.embarcacao_raep as embarcacao, 
       r.tie,
       r.raep,
       r.tipo,
       r.data_hora,
       r.veloc as velocidade,
       r.direcao,
       r.prof as profundidade, 
       sambura.func_area_nome(sde.st_point(r.longitude, r.latitude, 4326)) as zee,
       sde.st_distance(sde.st_point(r.longitude, r.latitude, 4326), l.shape, 'Nautical_Mile') as dist_costa, 
       func_indicativo(r.tipo, r.data_hora, r.veloc, r.direcao, r.prof, sde.st_point(r.longitude, r.latitude, 4326)) as indicativo,
       sde.st_point(r.longitude, r.latitude, 4326) as shape
       FROM rastreamento r, linha_de_costa l
       WHERE r.data_hora > now() - '1 day'::interval AND r.prof > 0 AND
             r.tipo IN ('emalhe peixe-sapo', 
                        'emalhe de fundo', 
                        'emalhe');

-- espinhel_potes
CREATE MATERIALIZED VIEW espinhel_potes AS 
SELECT r.rid::int4 as objectid, 
       r.embarcacao_raep as embarcacao, 
       r.tie,
       r.raep,
       r.tipo,
       r.data_hora,
       r.veloc as velocidade,
       r.direcao,
       r.prof as profundidade, 
       sambura.func_area_nome(sde.st_point(r.longitude, r.latitude, 4326)) as zee,
       sde.st_distance(sde.st_point(r.longitude, r.latitude, 4326), l.shape, 'Nautical_Mile') as dist_costa, 
       func_indicativo(r.tipo, r.data_hora, r.veloc, r.direcao, r.prof, sde.st_point(r.longitude, r.latitude, 4326)) as indicativo,
       sde.st_point(r.longitude, r.latitude, 4326) as shape
       FROM rastreamento r, linha_de_costa l
       WHERE r.data_hora > now() - '1 day'::interval AND r.prof > 0 AND
             r.tipo IN ('espinhel de fundo', 
                        'potes polvo S', 
                        'potes polvo SE');

-- linha_superficie
CREATE MATERIALIZED VIEW linha_superficie AS 
SELECT r.rid::int4 as objectid, 
       r.embarcacao_raep as embarcacao, 
       r.tie,
       r.raep,
       r.tipo,
       r.data_hora,
       r.veloc as velocidade,
       r.direcao,
       r.prof as profundidade, 
       sambura.func_area_nome(sde.st_point(r.longitude, r.latitude, 4326)) as zee,
       sde.st_distance(sde.st_point(r.longitude, r.latitude, 4326), l.shape, 'Nautical_Mile') as dist_costa, 
       func_indicativo(r.tipo, r.data_hora, r.veloc, r.direcao, r.prof, sde.st_point(r.longitude, r.latitude, 4326)) as indicativo,
       sde.st_point(r.longitude, r.latitude, 4326) as shape
       FROM rastreamento r, linha_de_costa l
       WHERE r.data_hora > now() - '1 day'::interval AND r.prof > 0 AND
             r.tipo IN ('espinhel de superfície (itaipava)', 
                        'espinhel de superfície', 'linha',
                        'vara e isca viva');

-- rastreamento_off
CREATE MATERIALIZED VIEW rastreamento_off AS 
SELECT r.rid::int4 as objectid, 
       r.embarcacao_raep as embarcacao, 
       r.tie,
       r.raep,
       r.tipo,
       r.data_hora,
       r.veloc as velocidade,
       r.direcao,
       r.prof as profundidade, 
       sde.st_distance(sde.st_point(r.longitude, r.latitude, 4326), l.shape, 'Nautical_Mile') as dist_costa, 
       coalesce(sambura.func_local_nome(sde.st_point(r.longitude, r.latitude, 4326)), 
                sambura.func_cidade_nome(sde.st_point(r.longitude, r.latitude, 4326)), 
                sambura.func_area_nome(sde.st_point(r.longitude, r.latitude, 4326))) AS localizacao,
       sde.st_point(r.longitude, r.latitude, 4326) as shape
       FROM rastreamento r, linha_de_costa l
       WHERE r.data_hora < now() - '8 hours'::interval and r.data_hora > now() - '3 day'::interval;

-- portos
CREATE MATERIALIZED VIEW portos AS 
SELECT r.rid::int4 as objectid, 
       sambura.func_cidade_nome(sde.st_point(r.longitude, r.latitude, 4326)) as porto,
       sambura.func_local_nome(sde.st_point(r.longitude, r.latitude, 4326)) as atracadouro,
       r.tipo as frota,
       r.embarcacao_raep as embarcacao, 
       r.tie,
       r.raep,
       r.data_hora,
       r.veloc as velocidade,
       r.direcao,
       sde.st_point(r.longitude, r.latitude, 4326) as shape
       FROM rastreamento r, portos_atracadouros a
       WHERE r.data_hora > now() - '1 day'::interval AND a.nivel = 3 AND
       sde.st_within(sde.st_point(r.longitude, r.latitude, 4326), a.shape);
