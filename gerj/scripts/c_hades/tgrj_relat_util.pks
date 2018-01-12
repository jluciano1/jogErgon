CREATE OR REPLACE PACKAGE tgrj_relat_util
IS
/**************** INICIO_HELP: ****************
----------------------------------------------------
Nome:
  PACKAGE PACK_PROMOCAO
Propósito:
  Esta package disponibiliza procedures e functions utilitárias para os
  processos de execução de relatórios via Job.
Utilização:
  Utilizada pelas transações e rotinas que agendam ou executam relatórios via requisição HTTP.
----------------------------------------------------
Nome:
  FUNCTION get_url_report
Propósito:
  Esta função tem por finalidade de retornar a URL base do servidor de reports.
  Essa URL deve ser editada na package body para cada ambiente que utilizará o servidor de relatórios.
Utilização:
  Utilizada pelas rotinas que executam relatórios por meio de requisição HTTP.
----------------------------------------------------
Nome:
  FUNCTION get_conection
Propósito:
  Esta função tem por finalidade de retornar a conexão que o reports fará com banco de dados.
  Fará parte da URL de requisição dos reports.
  Essa string de conexão deve ser editada na package body para cada ambiente que utilizará o servidor de relatórios.
Utilização:
  Utilizada pelas rotinas que executam relatórios por meio de requisição HTTP.
----------------------------------------------------
Nome:
  FUNCTION get_conection
Propósito:
  Esta função tem por finalidade de retornar a conexão que o reports fará com banco de dados.
  Fará parte da URL de requisição dos reports.
  Essa string de conexão deve ser editada na package body para cada ambiente que utilizará o servidor de relatórios.
Utilização:
  Utilizada pelas rotinas que executam relatórios por meio de requisição HTTP.
----------------------------------------------------
Nome:
  FUNCTION get_user_http_authentication
Propósito:
  Esta função tem por finalidade de retornar o usuário de autenticação da requisição http ao servidor de relatórios 
  feita pela package do Oracle UTL_HTTP. Trabalha em conjunto com a função GET_PASS_HTTP_AUTHENTICATION.
  Esse usuário deve ser editado na package body para cada ambiente que utilizará o servidor de relatórios.
Utilização:
  Utilizada pelas rotinas que usam a UTL_HTTP para executar relatórios por meio de requisição HTTP.
----------------------------------------------------
Nome:
  FUNCTION get_pass_http_authentication
Propósito:
  Esta função tem por finalidade de retornar a senha de autenticação da requisição http ao servidor de relatórios 
  feita pela package do Oracle UTL_HTTP. Trabalha em conjunto com a função GET_USER_HTTP_AUTHENTICATION.
  Esse usuário deve ser editado na package body para cada ambiente que utilizará o servidor de relatórios.
Utilização:
  Utilizada pelas rotinas que usam a UTL_HTTP para executar relatórios por meio de requisição HTTP.
----------------------------------------------------
Nome:
  FUNCTION get_dir_relat_agenda
Propósito:
  Esta função tem por finalidade de retornar o diretório temporário de geração dos relatórios pelo servidor de relatórios.
  Esse caminho deve ser editado na package body para cada ambiente que utilizará o servidor de relatórios.
Utilização:
  Utilizada pelas rotinas que executam relatórios por meio de requisição HTTP.
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