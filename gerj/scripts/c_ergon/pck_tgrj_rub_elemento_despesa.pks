CREATE OR REPLACE 
PACKAGE C_ERGON.PCK_TGRJ_RUB_ELEMENTO_DESPESA
IS
/**************** INICIO_HELP: ****************
----------------------------------------------------
Nome:
  PACKAGE PCK_TGRJ_RUB_ELEMENTO_DESPESA
Prop�sito:
  Esta package tem por finalidade estabelecer as valida��es e cr�ticas
  necess�rias na inser��o, altera��o e remo��o de registros na tabela 
  TGRJ_RUB_ELEMENTO_DESPESA em fun��o das regras de neg�cio estabelecidadas.
Utiliza��o:
  Utilizada nas triggers da tabela TGRJ_RUB_ELEMENTO_DESPESA.
----------------------------------------------------
Nome:
  PROCEDURE MAIN_POS
Prop�sito:
  Esta procedure tem por finalidade executar as valida��es e cr�ticas
   necess�rias na trigger de "p�s" da tabela TGRJ_RUB_ELEMENTO_DESPESA.
Par�metros:
  P_TIPO_DML:
    Indica o tipo de opera��o DML que est� sendo executada sobre os
    registros da tabela TGRJ_RUB_ELEMENTO_DESPESA ("I" para "INSERT", "U" para
    "UPDATE", "D" para "DELETE");
Utiliza��o:
  Utilizada na trigger de after T_A_IUD_TGRJ_RUB_ELEMENTO_DESPESA.
----------------------------------------------------
Nome:
  PROCEDURE MAIN_PRE
Prop�sito:
  Esta procedure tem por finalidade executar as valida��es e cr�ticas
   necess�rias na trigger de "pr�" da tabela TGRJ_RUB_ELEMENTO_DESPESA.
Par�metros:
  P_TIPO_DML:
    Indica o tipo de opera��o DML que est� sendo executada sobre os
    registros da tabela TGRJ_RUB_ELEMENTO_DESPESA ("I" para "INSERT", "U" para
    "UPDATE", "D" para "DELETE");
Utiliza��o:
  Utilizada na trigger de pr� T_B_IUD_TGRJ_RUB_ELEMENTO_DESPESA.
----------------------------------------------------
***************** FINAL_HELP: ****************/
  --
  V_ROW_OLD   TGRJ_RUB_ELEMENTO_DESPESA%ROWTYPE;
  V_ROW_NEW   TGRJ_RUB_ELEMENTO_DESPESA%ROWTYPE;
  --
  TYPE TGRJ_RUB_ELEMENTO_DESPESA_REC IS TABLE OF TGRJ_RUB_ELEMENTO_DESPESA%ROWTYPE;
  --
  P_TGRJ_RUB_ELEMENTO_DESPESA             TGRJ_RUB_ELEMENTO_DESPESA_REC;
  P_TGRJ_RUB_ELEMENTO_DESPES_OLD         TGRJ_RUB_ELEMENTO_DESPESA_REC;
  P_INDICE                   NUMBER;
  --
  PROCEDURE INSERT_AUX (P_REGISTRO_AUX IN TGRJ_RUB_ELEMENTO_DESPESA%ROWTYPE);
  PROCEDURE UPDATE_AUX (P_REGISTRO_AUX IN TGRJ_RUB_ELEMENTO_DESPESA%ROWTYPE,
                        P_REGISTRO_OLD_AUX IN TGRJ_RUB_ELEMENTO_DESPESA%ROWTYPE);
  PROCEDURE DELETE_AUX (P_REGISTRO_AUX IN TGRJ_RUB_ELEMENTO_DESPESA%ROWTYPE);
  PROCEDURE MAIN_PRE (P_TIPO_DML IN VARCHAR2);
  PROCEDURE MAIN_POS (P_TIPO_DML IN VARCHAR2);
  --
END PCK_TGRJ_RUB_ELEMENTO_DESPESA;
/