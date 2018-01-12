CREATE OR REPLACE PACKAGE tgrj_relat_util
IS
/**************** INICIO_HELP: ****************
----------------------------------------------------
Nome:
  PACKAGE PACK_PROMOCAO
Prop�sito:
  Esta package disponibiliza procedures e functions utilit�rias para os
  processos de execu��o de relat�rios via Job.
Utiliza��o:
  Utilizada pelas transa��es e rotinas que agendam ou executam relat�rios via requisi��o HTTP.
----------------------------------------------------
Nome:
  FUNCTION get_url_report
Prop�sito:
  Esta fun��o tem por finalidade de retornar a URL base do servidor de reports.
  Essa URL deve ser editada na package body para cada ambiente que utilizar� o servidor de relat�rios.
Utiliza��o:
  Utilizada pelas rotinas que executam relat�rios por meio de requisi��o HTTP.
----------------------------------------------------
Nome:
  FUNCTION get_conection
Prop�sito:
  Esta fun��o tem por finalidade de retornar a conex�o que o reports far� com banco de dados.
  Far� parte da URL de requisi��o dos reports.
  Essa string de conex�o deve ser editada na package body para cada ambiente que utilizar� o servidor de relat�rios.
Utiliza��o:
  Utilizada pelas rotinas que executam relat�rios por meio de requisi��o HTTP.
----------------------------------------------------
Nome:
  FUNCTION get_conection
Prop�sito:
  Esta fun��o tem por finalidade de retornar a conex�o que o reports far� com banco de dados.
  Far� parte da URL de requisi��o dos reports.
  Essa string de conex�o deve ser editada na package body para cada ambiente que utilizar� o servidor de relat�rios.
Utiliza��o:
  Utilizada pelas rotinas que executam relat�rios por meio de requisi��o HTTP.
----------------------------------------------------
Nome:
  FUNCTION get_user_http_authentication
Prop�sito:
  Esta fun��o tem por finalidade de retornar o usu�rio de autentica��o da requisi��o http ao servidor de relat�rios 
  feita pela package do Oracle UTL_HTTP. Trabalha em conjunto com a fun��o GET_PASS_HTTP_AUTHENTICATION.
  Esse usu�rio deve ser editado na package body para cada ambiente que utilizar� o servidor de relat�rios.
Utiliza��o:
  Utilizada pelas rotinas que usam a UTL_HTTP para executar relat�rios por meio de requisi��o HTTP.
----------------------------------------------------
Nome:
  FUNCTION get_pass_http_authentication
Prop�sito:
  Esta fun��o tem por finalidade de retornar a senha de autentica��o da requisi��o http ao servidor de relat�rios 
  feita pela package do Oracle UTL_HTTP. Trabalha em conjunto com a fun��o GET_USER_HTTP_AUTHENTICATION.
  Esse usu�rio deve ser editado na package body para cada ambiente que utilizar� o servidor de relat�rios.
Utiliza��o:
  Utilizada pelas rotinas que usam a UTL_HTTP para executar relat�rios por meio de requisi��o HTTP.
----------------------------------------------------
Nome:
  FUNCTION get_dir_relat_agenda
Prop�sito:
  Esta fun��o tem por finalidade de retornar o diret�rio tempor�rio de gera��o dos relat�rios pelo servidor de relat�rios.
  Esse caminho deve ser editado na package body para cada ambiente que utilizar� o servidor de relat�rios.
Utiliza��o:
  Utilizada pelas rotinas que executam relat�rios por meio de requisi��o HTTP.
----------------------------------------------------
***************** FINAL_HELP: ****************/
  FUNCTION get_url_report
    RETURN VARCHAR2;
  --
  FUNCTION get_user_http_authentication
    RETURN VARCHAR2;
  --
  FUNCTION get_pass_http_authentication
  RETURN VARCHAR2;
  --
  FUNCTION get_conection
    RETURN VARCHAR2;
  --    
  FUNCTION get_dir_relat_agenda
    RETURN VARCHAR2;
  --
  FUNCTION get_next_lote_seq
    RETURN NUMBER;
  --
  FUNCTION gera_req_agenda_rep(
      P_REPETICAO   NUMBER,
      P_USUARIO     VARCHAR2,
      P_RELATORIO   VARCHAR2,
      P_DATA_AGENDA DATE,
      P_EMPRESA     VARCHAR2,
      P_EXPIRACAO   NUMBER,
      P_ARQUIVO     VARCHAR2,
      P_PARAMETRO HAD_TYP_ARRAY_VARCHAR2 DEFAULT NULL,
      P_VALOR HAD_TYP_ARRAY_VARCHAR2 DEFAULT NULL,
      P_MENS OUT VARCHAR2 )
    RETURN NUMBER;
  --
  FUNCTION GET_MENSAGEM_REPORT (P_ID NUMBER) RETURN VARCHAR2;
END;
/