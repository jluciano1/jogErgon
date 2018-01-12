CREATE OR REPLACE
PACKAGE C_ERGON.PCK_TGRJ_SISOBI_REL
IS
/**************** INICIO_HELP: ****************
----------------------------------------------------
Nome:
  PACKAGE PCK_TGRJ_SISOBI_REL
Propósito:
  Esta package tem por finalidade estabelecer as validações e críticas
  necessárias na inserção, alteração e remoção de registros na tabela 
  TGRJ_SISOBI_REL em função das regras de negócio estabelecidadas.
Utilização:
  Utilizada nas triggers da tabela TGRJ_SISOBI_REL.
----------------------------------------------------
Nome:
  PROCEDURE MAIN_POS
Propósito:
  Esta procedure tem por finalidade executar as validações e críticas
   necessárias na trigger de "pós" da tabela TGRJ_SISOBI_REL.
Parâmetros:
  P_TIPO_DML:
    Indica o tipo de operação DML que está sendo executada sobre os
    registros da tabela TGRJ_SISOBI_REL ("I" para "INSERT", "U" para
    "UPDATE", "D" para "DELETE");
Utilização:
  Utilizada na trigger de after T_A_IUD_TGRJ_SISOBI_REL.
----------------------------------------------------
Nome:
  PROCEDURE MAIN_PRE
Propósito:
  Esta procedure tem por finalidade executar as validações e críticas
   necessárias na trigger de "pré" da tabela TGRJ_SISOBI_REL.
Parâmetros:
  P_TIPO_DML:
    Indica o tipo de operação DML que está sendo executada sobre os
    registros da tabela TGRJ_SISOBI_REL ("I" para "INSERT", "U" para
    "UPDATE", "D" para "DELETE");
Utilização:
  Utilizada na trigger de pré T_B_IUD_TGRJ_SISOBI_REL.
----------------------------------------------------
***************** FINAL_HELP: ****************/
  --
  V_ROW_OLD   TGRJ_SISOBI_REL%ROWTYPE;
  V_ROW_NEW   TGRJ_SISOBI_REL%ROWTYPE;
  --
  TYPE TGRJ_SISOBI_REL_REC IS TABLE OF TGRJ_SISOBI_REL%ROWTYPE;
  --
  P_TGRJ_SISOBI_REL             TGRJ_SISOBI_REL_REC;
  P_TGRJ_SISOBI_REL_OLD         TGRJ_SISOBI_REL_REC;
  P_INDICE                   NUMBER;
  --
  PROCEDURE INSERT_AUX (P_REGISTRO_AUX IN TGRJ_SISOBI_REL%ROWTYPE);
  PROCEDURE UPDATE_AUX (P_REGISTRO_AUX IN TGRJ_SISOBI_REL%ROWTYPE,
                        P_REGISTRO_OLD_AUX IN TGRJ_SISOBI_REL%ROWTYPE);
  PROCEDURE DELETE_AUX (P_REGISTRO_AUX IN TGRJ_SISOBI_REL%ROWTYPE);
  PROCEDURE MAIN_PRE (P_TIPO_DML IN VARCHAR2);
  PROCEDURE MAIN_POS (P_TIPO_DML IN VARCHAR2);
  --
END PCK_TGRJ_SISOBI_REL;
/