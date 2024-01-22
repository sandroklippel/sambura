-- SAMBURA: Monitor de atividade pesqueira. 
-- 
-- views

-- verificar_frota (embarcações sem frota)
CREATE OR REPLACE VIEW verificar_frota AS 
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

-- arrasteiros
CREATE OR REPLACE VIEW arrasteiros_movendo AS
SELECT * FROM arrasteiros WHERE velocidade >= 1;

CREATE OR REPLACE VIEW arrasteiros_parado AS
SELECT * FROM arrasteiros WHERE velocidade < 1;

-- cerco
CREATE OR REPLACE VIEW cerco_movendo AS
SELECT * FROM cerco WHERE velocidade >= 1;

CREATE OR REPLACE VIEW cerco_parado AS
SELECT * FROM cerco WHERE velocidade < 1;

-- emalhe
CREATE OR REPLACE VIEW emalhe_movendo AS
SELECT * FROM emalhe WHERE velocidade >= 1;

CREATE OR REPLACE VIEW emalhe_parado AS
SELECT * FROM emalhe WHERE velocidade < 1;

-- espinhel_potes
CREATE OR REPLACE VIEW espinhel_potes_movendo AS
SELECT * FROM espinhel_potes WHERE velocidade >= 1;

CREATE OR REPLACE VIEW espinhel_potes_parado AS
SELECT * FROM espinhel_potes WHERE velocidade < 1;

-- linha_superficie
CREATE OR REPLACE VIEW linha_superficie_movendo AS
SELECT * FROM linha_superficie WHERE velocidade >= 1;

CREATE OR REPLACE VIEW linha_superficie_parado AS
SELECT * FROM linha_superficie WHERE velocidade < 1;
