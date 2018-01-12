CREATE OR REPLACE
PACKAGE C_ERGON.PCK_TGRJ_HABILITACOES
IS
/**************** INICIO_HELP: ****************
----------------------------------------------------
Nome:
  PACKAGE PCK_TGRJ_HABILITACOES
Prop�sito:
  Esta package tem por finalidade estabelecer as valida��es e cr�ticas
  necess�rias na inser��o, altera��o e remo��o de registros na tabela 
  TGRJ_HABILITACOES em fun��o das regras de neg�cio estabelecidadas.
Utiliza��o:
  Utilizada nas triggers da tabela TGRJ_HABILITACOES.
----------------------------------------------------
Nome:
  PROCEDURE MAIN_POS
Prop�sito:
  Esta procedure tem por finalidade executar as valida��es e cr�ticas
   necess�rias na trigger de "p�s" da tabela TGRJ_HABILITACOES.
Par�metros:
  P_TIPO_DML:
    Indica o tipo de opera��o DML que est� sendo executada sobre os
    registros da tabela TGRJ_HABILITACOES ("I" para "INSERT", "U" para
    "UPDATE", "D" para "DELETE");
Utiliza��o:
  Utilizada na trigger de after T_A_IUD_TGRJ_HABILITACOES.
----------------------------------------------------
Nome:
  PROCEDURE MAIN_PRE
Prop�sito:
  Esta procedure tem por finalidade executar as valida��es e cr�ticas
   necess�rias na trigger de "pr�" da tabela TGRJ_HABILITACOES.
Par�metros:
  P_TIPO_DML:
    Indica o tipo de opera��o DML que est� sendo executada sobre os
    registros da tabela TGRJ_HABILITACOES ("I" para "INSERT", "U" para
    "UPDATE", "D" para "DELETE");
Utiliza��o:
  Utilizada na trigger de pr� T_B_IUD_TGRJ_HABILITACOES.
----------------------------------------------------
***************** FINAL_HELP: ****************/
  --
  V_ROW_OLD   TGRJ_HABILITACOES%ROWTYPE;
  V_ROW_NEW   TGRJ_HABILITACOES%ROWTYPE;
  --
  TYPE TGRJ_HABILITACOES_REC IS TABLE OF TGRJ_HABILITACOES%ROWTYPE;
  --
  P_TGRJ_HABILITACOES             TGRJ_HABILITACOES_REC;
  P_TGRJ_HABILITACOES_OLD         TGRJ_HABILITACOES_REC;
  P_INDICE                   NUMBER;
  --
  PROCEDURE INSERT_AUX (P_REGISTRO_AUX IN TGRJ_HABILITACOES%ROWTYPE);
  PROCEDURE UPDATE_AUX (P_REGISTRO_AUX IN TGRJ_HABILITACOES%ROWTYPE,
                        P_REGISTRO_OLD_AUX IN TGRJ_HABILITACOES%ROWTYPE);
  PROCEDURE DELETE_AUX (P_REGISTRO_AUX IN TGRJ_HABILITACOES%ROWTYPE);
  PROCEDURE MAIN_PRE (P_TIPO_DML IN VARCHAR2);
  PROCEDURE MAIN_POS (P_TIPO_DML IN VARCHAR2);
  --
END PCK_TGRJ_HABILITACOES;
/