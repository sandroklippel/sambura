-- SAMBURA: Monitor de atividade pesqueira suspeita. 
-- 
-- views

-- verificar_frota (embarcações sem frota)
CREATE VIEW verificar_frota AS 
SELECT r.rid::int4 as objectid, 
       r.embarcacao_onyx,
       r.embarcacao_raep, 
       r.tie,
       r.raep,
       r.data_hora, --  at time zone 'Brazil/East'
       r.veloc as velocidade,
       r.direcao,
       r.prof as profundidade, 
       sambura.func_area_nome(sde.st_point(r.longitude, r.latitude, 4326)) as zee
       FROM rastreamento r
       WHERE r.tipo is NULL;
