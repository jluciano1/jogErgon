SET SCAN OFF
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY HH24:MI:SS';
ALTER SESSION SET NLS_NUMERIC_CHARACTERS = '.,';
EXEC EXEC_SQL_HADES('ALTER TABLE TABELA DISABLE ALL TRIGGERS')
INSERT INTO TABELA
(DESCR, MULTI_EMP, SIS, TAB, TAMINFO, TAMINFO1, TAMINFO2, TAMINFO3, TIPO, TIPO1, TIPO2)
SELECT * FROM (
SELECT DESCR,MULTI_EMP,SIS,TAB,TAMINFO,TAMINFO1,TAMINFO2,TAMINFO3,TIPO,TIPO1,TIPO2 FROM TABELA WHERE 1=0 UNION ALL
SELECT 'Transa��es de Auditoria de Comando', 'N', 'C_Ergon', 'PGOV_AUDITORIA_NIV1', TO_NUMBER('50'), TO_NUMBER('20'), TO_NUMBER('10'), TO_NUMBER(''), 'A', 'A', 'A' FROM DUAL
) TEMP_20170921112925
WHERE (TAB) NOT IN
  (SELECT TAB FROM TABELA)
/
COMMIT;
EXEC EXEC_SQL_HADES('ALTER TABLE TABELA ENABLE ALL TRIGGERS')
SET SCAN ON
-----
SET SCAN OFF
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY HH24:MI:SS';
ALTER SESSION SET NLS_NUMERIC_CHARACTERS = '.,';
EXEC EXEC_SQL_HADES('ALTER TABLE ITEMTABELA_ DISABLE ALL TRIGGERS')
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT '', 'Aposentadoria Temporal', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT '', 'Aquisi��o Licen�a Especial', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT '', 'Atributos de Dependentes', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT '', 'Atributos de Funcion�rios', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT '', 'Atributos de Pensionistas', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT '', 'Averba��es', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT '', 'Cadastro de Funcion�rios para Atributo', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT '', 'Carga de Atributos Customizada', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT '', 'Cess�es', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT '', 'Cess�es Internas', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT '', 'Dados Gerais', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT '', 'Disposi��o Interna', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT '', 'Eventos de Cargo', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT '', 'Eventos de Enquadramento', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT '', 'Eventos de Mudan�a de Cargo', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT '', 'Eventos de Progress�o', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT '', 'Eventos de Remo��o', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT '', 'Exerc�cios/ Funcion�rio', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT '', 'Freq��ncia', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT '', 'Funcion�rios', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT '', 'Incorpora��o de Chefia', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT '', 'Ingresso', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT '', 'Instituidor de Pens�o', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT '', 'Lan�amento Manual', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT '', 'Lan�amento Manual Pensionista', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT '', 'Licen�as Especiais', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT '', 'Pensionista Previdenci�rio', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT '', 'Pensionistas', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT '', 'Pens�es Aliment�cias', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT '', 'Pr�-Contagem', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT '', 'Regra de Bloqueio ou Repasse', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT '', 'Regras de Pens�o Especial', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT '', 'Regras de Pens�o Previdenci�ria', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT '', 'Requisi��o', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT '', 'Vac�ncia', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT '', 'V�nculo', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT 'Aposentadorias e revers�es', 'ERGadm00230', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT 'Aquisi��o de licen�as especiais', 'ERGadm00254', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT 'Atributos do dependente', 'ERGadm00300', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT 'Atributos do funcion�rio', 'ERGadm00199', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT 'Atributos do pensionista', 'ERGadm00301', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT 'Averba��es de tempo', 'ERGadm00262', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT 'Eventos de cargo', 'ERGadm00156', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT 'Eventos de mudan�a de cargo', 'ERGadm00157', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT 'Eventos de mudan�a de jornada', 'ERGadm00160', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT 'Eventos de progress�o', 'ERGadm00158', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT 'Eventos de remo��o', 'ERGadm00159', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT 'Eventos de substitui��o', 'ERGadm00165', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT 'Movimentos do pensionista', 'ERGadm00143', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT 'Movimentos retroativos do pensionista', 'ERGadm00145', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT 'Pensionistas', 'ERGadm00237', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT 'Pensionista Previdenci�rio', 'RJadm00039', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT 'Dependentes do pensionista', 'ERGadm00468', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT 'Dados Gerais MS605', 'RJadm00067', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT 'Regras de pens�o especial', 'ERGadm00203', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT 'Regras de Pens�o MS605', 'RJadm00068', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT 'Regras de Pens�o Previdenci�ria', 'RJadm00040', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT 'V�nculos funcionais', 'ERGadm00229', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT 'Cess�es internas', 'ERGadm00188', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT 'Atividades e exerc�cios do funcion�rio', 'ERGadm00186', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT 'Movimentos de funcion�rios', 'ERGadm00142', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT 'Movimentos retroativos por funcion�rio', 'ERGadm00479', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT 'Movimentos retroativos por funcion�rio', 'ERGadm00144', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT 'Frequ�ncias', 'ERGadm00189', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT 'Lan�amento coletivo de frequ�ncias', 'ERGadm00243', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT 'Pr�-contagem', 'ERGadm00162', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT 'Licen�as especiais', 'ERGadm00152', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT 'Depend�ncias do dependente', 'ERGadm00224', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT 'Dependentes do funcion�rio', 'ERGadm00217', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT 'Regras de pens�o aliment�cia do funcion�rio', 'ERGadm00146', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
INSERT INTO ITEMTABELA_
(DESCR, ITEM, ITEM1, ITEM2, TAB)
SELECT * FROM (
SELECT DESCR,ITEM,ITEM1,ITEM2,TAB FROM ITEMTABELA_ WHERE 1=0 UNION ALL
SELECT '', 'ERGadm00187', '', '', 'PGOV_AUDITORIA_NIV1' FROM DUAL
) TEMP_20170921113219
WHERE (TAB,ITEM) NOT IN
  (SELECT TAB,ITEM FROM ITEMTABELA_)
/
COMMIT;
EXEC EXEC_SQL_HADES('ALTER TABLE ITEMTABELA_ ENABLE ALL TRIGGERS')
SET SCAN ON