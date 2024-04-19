#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# MIT License

# Copyright (c) 2024 Sandro Klippel

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

"""
File: karakuri.py
Author: Sandro Klippel
Date: 2024-01-15
Description: Automata que extrai, transforma e por fim carrega 
as informações do rastreamento das embarcações pesqueiras 
em um banco de dados geográfico. 
SAMBURA: Monitor de atividade pesqueira. 
"""

import time
import logging
import os
import re

import rasterio
import numpy as np
import pandas as pd

from datetime import datetime
from sqlalchemy import create_engine
from sqlalchemy.dialects.postgresql import INTEGER

from selenium.common.exceptions import TimeoutException
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait
from selenium import webdriver

def ler_configuracoes(fn):
    credentials = {}
    with open(fn, 'r') as file:
        for line in file:
            key, value = line.strip().split('|')
            credentials[key] = value
    return credentials

def extrai_tie(string):
    """Extrai o número o TIE"""
    match = re.match(r'(\d+)[a-zA-Z]{2}', string.strip())
    if match:
        tie = match.group(1)
        return tie.zfill(10)
    else:
        return None

def extrai_velocidade(string):
    match = re.match(r'([\d,]+)\s+Nós', string)
    if match:
        number = match.group(1).replace(',', '.')
        return float(number)
    else:
        return None
    
def extrai_direcao(string):
    match = re.match(r'([\d]+)\s+º', string)
    if match:
        number = match.group(1).replace(',', '.')
        return int(number)
    else:
        return None
    
def extrai_latlon_dec(string):
    """Extrai a latitude ou longitude em decimal"""   
    match = re.match(r"(\d+)°\s*(\d+)\'\s*([\d,]+)\"\s*([NSWEOL])", string)
    if match:
        degree = float(match.group(1))
        minute = float(match.group(2))
        second = float(match.group(3).replace(',', '.'))
        direction = match.group(4)
        signal = -1 if direction in 'SWO' else 1
        dec = (((minute + (second/60))/60) + degree) * signal
        return dec
    else:
        return None
    
def parse_csv(csv_file, periodo):
    """lê e processa o arquivo de rastreamento retornando um dataframe"""

    df = pd.read_csv(csv_file, sep=';', skiprows=4, skipfooter=1, encoding='latin_1', header=None, engine='python',
                 parse_dates=['data_hora'], on_bad_lines='skip', date_format = r'%d/%m/%Y %H:%M:%S',
                 converters={'tie': extrai_tie, 'veloc': extrai_velocidade, 'direcao': extrai_direcao, 'latitude': extrai_latlon_dec, 'longitude': extrai_latlon_dec},
                 names=['embarcacao_onyx', 'd1', 'd2', 'd3', 'data_hora', 'latitude', 'longitude', 'd4', 'd5', 'd6', 'd7', 'veloc', 'direcao', 'd8', 'status', 'bateria', 'tie', 'd9', 'msg', 'situacao'], 
                 usecols=['embarcacao_onyx', 'data_hora', 'latitude', 'longitude', 'veloc', 'direcao', 'status', 'bateria', 'tie'])
    
    df2 = df[df.data_hora > pd.Timestamp.now() - pd.to_timedelta(periodo)].query('longitude > -60.87283426 and latitude > -37.21483560 and longitude < 8.52888612 and latitude < 13.23380451') # filtra área e data
    return df2

def busca_prof(coord_list, batimetria):
    """recupera informacoes da profundidade para as coordenadas"""
    bat = rasterio.open(batimetria)
    arr_sampled = bat.sample(coord_list, indexes=1, masked=False)
    prof = pd.DataFrame(arr_sampled)
    # zero em terra e fora da área de abrangência do arquivo raster 
    # deixa a profundidade em valores positivos
    prof = prof.replace(-32768, 0).mask(prof > 0, 0) * -1 
    return prof
        
def descarta_csv(file_path):
    # Split the file path into directory and filename
    directory, filename = os.path.split(file_path)

    # Create the new filename
    new_filename = f"last_{filename}"
    new_file_path = os.path.join(directory, new_filename)

    # remove the last file if exists
    if os.path.isfile(new_file_path):
        os.remove(new_file_path)

    # Rename the file
    os.rename(file_path, new_file_path)

def bot(pagina, usuario, senha):
    """busca as informações de rastreamento das embarcações"""

    options = webdriver.ChromeOptions()
    driver = webdriver.Remote(command_executor='http://localhost:4444', options=options)
    driver.implicitly_wait(10) # espera uma resposta por 10 segundos por padrão 
    actions = ActionChains(driver)

    try:
        driver.get(f"""{pagina}/view/Login.aspx?ReturnUrl=%2fview%2f""")
        
        driver.find_element(By.ID, "txtUser_I").send_keys(usuario)
        senha1 = WebDriverWait(driver, 20).until(EC.element_to_be_clickable((By.ID, "txtPassword_I_CLND")))
        senha1.click()
        senha2 = WebDriverWait(driver, 20).until(EC.element_to_be_clickable((By.ID, "txtPassword_I")))
        senha2.click()
        senha2.send_keys(senha)
        
        driver.find_element(By.ID, "btnLogin").click()
        
        # guarda o número de janelas (tabs) e a janela atual
        windows_now = driver.window_handles
        main_page = driver.current_window_handle
        
        menu = WebDriverWait(driver, 50).until(EC.visibility_of_element_located((By.ID, "ctl00_panelMenu_mainMenu_DXI3_P")))
        actions.move_to_element(menu).perform()
        time.sleep(5)
        relatorios = WebDriverWait(driver, 50).until(EC.visibility_of_element_located((By.CSS_SELECTOR, "#ctl00_panelMenu_mainMenu_DXI3i5_T > .dx-vam")))
        relatorios.click()
            
        WebDriverWait(driver, 100).until(EC.new_window_is_opened(windows_now))
        driver.switch_to.window(driver.window_handles[-1]) # vai para a última pagina aberta
        WebDriverWait(driver, 100).until(EC.url_matches(f"""{pagina}/view/report/ReportViewer.aspx"""))
        
        time.sleep(10)
        salvar_arquivo = WebDriverWait(driver, 100).until(EC.element_to_be_clickable((By.CSS_SELECTOR, "#docViewer_Splitter_RibbonToolbar_T0G1I0 .dxr-lblContent")))
        salvar_arquivo.click() # salvar arquivo
        time.sleep(2)
        salvar_csv = WebDriverWait(driver, 100).until(EC.element_to_be_clickable((By.ID, "docViewer_Splitter_RibbonToolbar_PM_DXI8_T")))
        salvar_csv.click()
        
        # fecha a pagina ativa
        time.sleep(5)
        driver.close()
        
        driver.switch_to.window(main_page) # volta para a primeira pagina
        time.sleep(5)
        # sair da pagina e fecha navegador
        driver.find_element(By.CSS_SELECTOR, "#ctl00_panelMenu_mainMenu_DXI6_T > .dx-vam").click() # sair
    finally:
        driver.quit() # fecha o navegador

def main():

    # obtem as configuracoes
    conf = ler_configuracoes('var/sambura.conf')
    csv_file = conf['csv']
    pagina = conf['pagina']
    usuario = conf['usuario']
    senha = conf['senha']
    psqlhost = conf['psqlhost']
    psqldb = conf['psqldb']
    psqluser = conf['psqluser']
    psqlpasswd = conf['psqlpasswd']
    periodo = conf['periodo']
    batimetria = conf['batimetria']
    logfile = conf['logfile']

    # log
    logging.basicConfig(filename=logfile,
                        filemode='w',
                        encoding='utf-8',
                        format='%(asctime)s %(levelname)s:%(message)s', 
                        datefmt='%Y-%m-%d %H:%M:%S', 
                        level=logging.INFO)

    # busca os dados no sítio internet
    logging.info('Buscando os dados de rastreamento.')
    bot(pagina, usuario, senha)

    if os.path.isfile(csv_file):
        try:
            # executa o processamento do arquivo
            logging.info('Processando o arquivo CSV.')
            sambura_db = create_engine(f"postgresql://{psqluser}:{psqlpasswd}@{psqlhost}:5432/{psqldb}")
            chave_tie = pd.read_sql_table('chave_tie', sambura_db, schema='sambura', index_col='rid')
            df = parse_csv(csv_file, periodo)
            rastreamento = pd.merge(df, chave_tie, on="tie", how="left", validate='many_to_one') # agrega info da frota
            coord_list = [(x, y) for x, y in zip(rastreamento["longitude"], rastreamento["latitude"])] # extrai lista com coordenadas
            prof = busca_prof(coord_list, batimetria)
            rastreamento["prof"] = prof
            # envia para o banco de dados
            logging.info('Enviando para o banco de dados.')
            with sambura_db.connect() as conn: 
                with conn.begin():
                    conn.exec_driver_sql("TRUNCATE rastreamento")
                    rastreamento.to_sql(name='rastreamento', con=conn, schema='sambura', index_label='rid', if_exists='append', dtype={'rid': INTEGER})
                    conn.exec_driver_sql("REFRESH MATERIALIZED VIEW arrasteiros")
                    conn.exec_driver_sql("REFRESH MATERIALIZED VIEW cerco")
                    conn.exec_driver_sql("REFRESH MATERIALIZED VIEW emalhe")
                    conn.exec_driver_sql("REFRESH MATERIALIZED VIEW espinhel_potes")
                    conn.exec_driver_sql("REFRESH MATERIALIZED VIEW linha_superficie")
                    conn.exec_driver_sql("REFRESH MATERIALIZED VIEW portos")
                    conn.exec_driver_sql("REFRESH MATERIALIZED VIEW rastreamento_off")
            logging.info('Todas as etapas finalizadas.')
        except:
            logging.error('Erro no processamento do arquivo CSV.')
        finally:
            # descarta o arquivo
            descarta_csv(csv_file)
    else:
        # algo errado aconteceu
        logging.error('Algo errado aconteceu e o arquivo CSV não foi gerado.')

if __name__ == '__main__':
    main()