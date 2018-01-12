prompt ***ATENÇÃO!!!*** Objeto PCK_TGRJ_RUBRICA_PENSAO não possui replace e deve ser mesclado manualmente com a versão existente no banco.
CREATE
PACKAGE C_ERGON.PCK_TGRJ_RUBRICA_PENSAO
IS
  /**************** INICIO_HELP: ****************
  ----------------------------------------------------
  Nome:
    PACKAGE PCK_TGRJ_RUBRICA_PENSAO
  Propósito:
    Esta package tem por finalidade estabelecer as validações e críticas
    necessárias na inserção, alteração e remoção de registros na tabela 
    TGRJ_RUBRICA_PENSAO em função das regras de negócio estabelecidadas.
  Utilização:
    Utilizada nas triggers da tabela TGRJ_RUBRICA_PENSAO.
  ----------------------------------------------------
  Nome:
    PROCEDURE MAIN_POS
  Propósito:
    Esta procedure tem por finalidade executar as validações e críticas
     necessárias na trigger de "pós" da tabela TGRJ_RUBRICA_PENSAO.
  Parâmetros:
    P_TIPO_DML:
      Indica o tipo de operação DML que est· sendo executada sobre os
      registros da tabela TGRJ_RUBRICA_PENSAO ("I" para "INSERT", "U" para
      "UPDATE", "D" para "DELETE");
  Utilização:
    Utilizada na trigger de after T_A_IUD_TGRJ_RUBRICA_PENSAO.
  ----------------------------------------------------
  Nome:
    PROCEDURE MAIN_PRE
  Propósito:
    Esta procedure tem por finalidade executar as validações e críticas
     necessárias na trigger de "pré" da tabela TGRJ_RUBRICA_PENSAO.
  Par‚metros:
    P_TIPO_DML:
      Indica o tipo de operação DML que est· sendo executada sobre os
      registros da tabela TGRJ_RUBRICA_PENSAO ("I" para "INSERT", "U" para
      "UPDATE", "D" para "DELETE");
  Utilização:
    Utilizada na trigger de pré T_B_IUD_TGRJ_RUBRICA_PENSAO.
  ----------------------------------------------------
  ***************** FINAL_HELP: ****************/
  --
  V_ROW_OLD   TGRJ_RUBRICA_PENSAO%ROWTYPE;
  V_ROW_NEW   TGRJ_RUBRICA_PENSAO%ROWTYPE;
  --
  TYPE TGRJ_RUBRICA_PENSAO_REC IS TABLE OF TGRJ_RUBRICA_PENSAO%ROWTYPE;
  --
  P_TGRJ_RUBRICA_PENSAO             TGRJ_RUBRICA_PENSAO_REC;
  P_TGRJ_RUBRICA_PENSAO_OLD         TGRJ_RUBRICA_PENSAO_REC;
  P_INDICE                   NUMBER;
  --
  PROCEDURE INSERT_AUX (P_REGISTRO_AUX IN TGRJ_RUBRICA_PENSAO%ROWTYPE);
  PROCEDURE UPDATE_AUX (P_REGISTRO_AUX IN TGRJ_RUBRICA_PENSAO%ROWTYPE,
                        P_REGISTRO_OLD_AUX IN TGRJ_RUBRICA_PENSAO%ROWTYPE);
  PROCEDURE DELETE_AUX (P_REGISTRO_AUX IN TGRJ_RUBRICA_PENSAO%ROWTYPE);
  PROCEDURE MAIN_PRE (P_TIPO_DML IN VARCHAR2);
  PROCEDURE MAIN_POS (P_TIPO_DML IN VARCHAR2);
  --
END PCK_TGRJ_RUBRICA_PENSAO;
/