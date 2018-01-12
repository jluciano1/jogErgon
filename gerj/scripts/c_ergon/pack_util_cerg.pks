CREATE OR REPLACE
PACKAGE PACK_UTIL_CERG IS
/**************** INICIO_HELP: ****************
----------------------------------------------------
Nome:
  FUNCTION SELEC_PARAMETROS_CONTA   RETORNA UTIL_TYP_PARAM_CONTA_TAB
Propósito
  Função que retorna os parâmetros de contagem de um vínculo em formato próprio para utilização em SELECTs das páginas do Ergon NG.
Parâmetros:
  P_NUMFUNC:
    Número do funcionário;
  P_NUMVINC:
    Número do vínculo;
  P_DATA:
    Data de referência (se não informado, a função assume SYSDATE).
Utilização:
  Nos controles de páginas que necessitem dos parâmetros de contagem como resultado de uma query.
  Exemplo de chamada no SELECT:
    SELECT *
      FROM TABLE(CAST(PACK_UTIL_CERG.SELEC_PARAMETROS_CONTA(<NUMFUNC>, <NUMVINC>, <DATA_REF>) AS UTIL_TYP_PARAM_CONTA_TAB));
---------------------------------------------------- 
Nome:
  FUNCTION SELEC_ITEMTABELA   RETORNA UTIL_TYP_ITEMTABELA_TAB
Propósito
  Função que retorna os dados de um item de tabela geral informado por parâmetro para utilização em SELECTs das páginas do Ergon NG.
Parâmetros:
  P_TABELA:
    Nome da tabela geral;
  P_ITEM:
    Nome do item da tabela geral cujas informações se deseja obter.
Utilização:
  Nos controles de páginas que necessitem dos parâmetros de contagem como resultado de uma query.
  Exemplo de chamada no SELECT:
    SELECT *
      FROM TABLE(CAST(PACK_UTIL_CERG.SELEC_ITEMTABELA(<TABELA>, <ITEM>) AS UTIL_TYP_ITEMTABELA_TAB));
---------------------------------------------------- 
***************** FINAL_HELP: ****************/
  --
  FUNCTION SELEC_PARAMETROS_CONTA (P_NUMFUNC IN NUMBER, P_NUMVINC IN NUMBER, P_DATA IN DATE DEFAULT NULL) RETURN UTIL_TYP_PARAM_CONTA_TAB;
  FUNCTION SELEC_ITEMTABELA (P_TABELA IN VARCHAR2, P_ITEM IN VARCHAR2) RETURN UTIL_TYP_ITEMTABELA_TAB;
  FUNCTION GET_DESCR_ITEM(P_TABELA IN VARCHAR2, P_ITEM IN VARCHAR2, P_CONCAT NUMBER DEFAULT 0) 
  RETURN VARCHAR2;
  FUNCTION EH_QUADRINOMIO_VALIDO(P_TIPOVINC IN VARCHAR2, P_REGJUR IN VARCHAR2, P_CATEG IN VARCHAR2, P_SUBCATEG IN VARCHAR2 DEFAULT NULL) 
  RETURN BOOLEAN;
  FUNCTION is_number (p_string IN VARCHAR2) RETURN NUMBER;

END PACK_UTIL_CERG;
/


