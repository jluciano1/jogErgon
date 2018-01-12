CREATE OR REPLACE
PACKAGE C_ERGON.PCK_PGOV_EMAIL_ACAO
IS
/**************** INICIO_HELP: ****************
----------------------------------------------------
Nome:
  PACKAGE PCK_PGOV_EMAIL_ACAO
Prop€sito:
  Esta package tem por finalidade estabelecer as valida¡ies e crÃticas
  necess∑rias na inser¡Ño, altera¡Ño e remo¡Ño de registros na tabela 
  PGOV_EMAIL_ACAO em fun¡Ño das regras de neg€cio estabelecidadas.
Utiliza¡Ño:
  Utilizada nas triggers da tabela PGOV_EMAIL_ACAO.
----------------------------------------------------
Nome:
  PROCEDURE MAIN_POS
Prop€sito:
  Esta procedure tem por finalidade executar as valida¡ies e crÃticas
   necess∑rias na trigger de "p€s" da tabela PGOV_EMAIL_ACAO.
ParÇmetros:
  P_TIPO_DML:
    Indica o tipo de opera¡Ño DML que est∑ sendo executada sobre os
    registros da tabela PGOV_EMAIL_ACAO ("I" para "INSERT", "U" para
    "UPDATE", "D" para "DELETE");
Utiliza¡Ño:
  Utilizada na trigger de after T_A_IUD_PGOV_EMAIL_ACAO.
----------------------------------------------------
Nome:
  PROCEDURE MAIN_PRE
Prop€sito:
  Esta procedure tem por finalidade executar as valida¡ies e crÃticas
   necess∑rias na trigger de "pr»" da tabela PGOV_EMAIL_ACAO.
ParÇmetros:
  P_TIPO_DML:
    Indica o tipo de opera¡Ño DML que est∑ sendo executada sobre os
    registros da tabela PGOV_EMAIL_ACAO ("I" para "INSERT", "U" para
    "UPDATE", "D" para "DELETE");
Utiliza¡Ño:
  Utilizada na trigger de pr» T_B_IUD_PGOV_EMAIL_ACAO.
----------------------------------------------------
***************** FINAL_HELP: ****************/
  --
  V_ROW_OLD   PGOV_EMAIL_ACAO%ROWTYPE;
  V_ROW_NEW   PGOV_EMAIL_ACAO%ROWTYPE;
  --
  TYPE PGOV_EMAIL_ACAO_REC IS TABLE OF PGOV_EMAIL_ACAO%ROWTYPE;
  --
  P_PGOV_EMAIL_ACAO             PGOV_EMAIL_ACAO_REC;
  P_PGOV_EMAIL_ACAO_OLD         PGOV_EMAIL_ACAO_REC;
  P_INDICE                   NUMBER;
  --
  PROCEDURE INSERT_AUX (P_REGISTRO_AUX IN PGOV_EMAIL_ACAO%ROWTYPE);
  PROCEDURE UPDATE_AUX (P_REGISTRO_AUX IN PGOV_EMAIL_ACAO%ROWTYPE,
                        P_REGISTRO_OLD_AUX IN PGOV_EMAIL_ACAO%ROWTYPE);
  PROCEDURE DELETE_AUX (P_REGISTRO_AUX IN PGOV_EMAIL_ACAO%ROWTYPE);
  PROCEDURE MAIN_PRE (P_TIPO_DML IN VARCHAR2);
  PROCEDURE MAIN_POS (P_TIPO_DML IN VARCHAR2);
  --
END PCK_PGOV_EMAIL_ACAO;
/