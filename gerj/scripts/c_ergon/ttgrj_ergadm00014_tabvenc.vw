CREATE OR REPLACE FORCE 
VIEW TTGRJ_ERGADM00014_TABVENC AS
SELECT VALOR 
     , EMPCOD 
     , EMPNOME 
     , TABELA 
     , NOME 
     , NOMEREF 
     , DTINAT 
     , LABEL1 
     , LABEL2 
     , LABEL3 
     , LABEL4
     , LABEL5
     , LABEL6 
     , LABEL 
     , FLEX_CAMPO_01 
     , FLEX_CAMPO_02 
     , (SELECT j.NOME FROM JORNADAS j WHERE j.SIGLA = t.FLEX_CAMPO_02 AND ROWNUM = 1) AS FLEX02_DESCR
     , FLEX_CAMPO_03 
     , FLEX_CAMPO_04 
     , FLEX_CAMPO_05 
     , PONTLEI 
     , DECIMAIS 
     , DECIMAIS1 
     , DECIMAIS2 
     , DECIMAIS3 
     , DECIMAIS4 
     , DECIMAIS5 
     , DECIMAIS6
     , NOME_PARTE1_REF 
     , NOME_PARTE2_REF 
     , NOME_PARTE3_REF 
     , ARREDONDA 
     , ARREDONDA1 
     , ARREDONDA2 
     , ARREDONDA3 
     , ARREDONDA4  
     , ARREDONDA5
     , ARREDONDA6
     , ROWID_REG
     , LINK_EMP
     , ASSOCIADO
FROM ERGADM00014_TABVENC t
/

