CREATE OR REPLACE
PACKAGE BODY C_ERGON.PCK_TGRJ_RUB_ELEMENTO_DESPESA
IS
  --
  PROCEDURE INSERT_AUX (P_REGISTRO_AUX IN TGRJ_RUB_ELEMENTO_DESPESA%ROWTYPE) IS
    V_SPID NUMBER;
    L_     NUMBER;
  BEGIN
    V_SPID := HADES_ERRO_PACK.GET_STOREDPROC_ID('C_ERGON','PCK_TGRJ_RUB_ELEMENTO_DESPESA','INSERT_AUX');
--
L_ := 10;
--
    P_INDICE := P_INDICE + 1;
--
L_ := 20;
--
    P_TGRJ_RUB_ELEMENTO_DESPESA.EXTEND;
--
L_ := 30;
--
    P_TGRJ_RUB_ELEMENTO_DESPES_OLD.EXTEND;
--
L_ := 40;
--
    P_TGRJ_RUB_ELEMENTO_DESPESA(P_INDICE) := P_REGISTRO_AUX;
  EXCEPTION WHEN OTHERS THEN 
    HADES_ERRO_PACK.TRATA_ERRO('C_Ergon',-1,SQLERRM,V_SPID,L_);
  END;
  --
  PROCEDURE UPDATE_AUX (P_REGISTRO_AUX IN TGRJ_RUB_ELEMENTO_DESPESA%ROWTYPE,
                        P_REGISTRO_OLD_AUX IN TGRJ_RUB_ELEMENTO_DESPESA%ROWTYPE) IS
    V_SPID NUMBER;
    L_     NUMBER;
  BEGIN
    V_SPID := HADES_ERRO_PACK.GET_STOREDPROC_ID('C_ERGON','PCK_TGRJ_RUB_ELEMENTO_DESPESA','UPDATE_AUX');
--
L_ := 50;
--
    P_INDICE := P_INDICE + 1;
--
L_ := 60;
--
    P_TGRJ_RUB_ELEMENTO_DESPESA.EXTEND;
--
L_ := 70;
--
    P_TGRJ_RUB_ELEMENTO_DESPES_OLD.EXTEND;
--
L_ := 80;
--
    P_TGRJ_RUB_ELEMENTO_DESPESA(P_INDICE) := P_REGISTRO_AUX;
--
L_ := 90;
--
    P_TGRJ_RUB_ELEMENTO_DESPES_OLD(P_INDICE) := P_REGISTRO_OLD_AUX;
  EXCEPTION WHEN OTHERS THEN 
    HADES_ERRO_PACK.TRATA_ERRO('C_Ergon',-1,SQLERRM,V_SPID,L_);
  END;
  --
  PROCEDURE DELETE_AUX (P_REGISTRO_AUX IN TGRJ_RUB_ELEMENTO_DESPESA%ROWTYPE) IS
    V_SPID NUMBER;
    L_     NUMBER;
  BEGIN
    V_SPID := HADES_ERRO_PACK.GET_STOREDPROC_ID('C_ERGON','PCK_TGRJ_RUB_ELEMENTO_DESPESA','DELETE_AUX');
--
L_ := 100;
--
    P_INDICE := P_INDICE + 1;
--
L_ := 110;
--
    P_TGRJ_RUB_ELEMENTO_DESPESA.EXTEND;
--
L_ := 120;
--
    P_TGRJ_RUB_ELEMENTO_DESPES_OLD.EXTEND;
--
L_ := 130;
--
    P_TGRJ_RUB_ELEMENTO_DESPES_OLD(P_INDICE) := P_REGISTRO_AUX;
  EXCEPTION WHEN OTHERS THEN 
    HADES_ERRO_PACK.TRATA_ERRO('C_Ergon',-1,SQLERRM,V_SPID,L_);
  END;
  --
  --!<PCK_TGRJ_RUB_ELEMENTO_DESPESA:MAIN_PRE>--
  PROCEDURE MAIN_PRE (P_TIPO_DML IN VARCHAR2) IS
    --
    v_ep               BOOLEAN;
    v_mens             VARCHAR2(2000);
    --
    V_SPID NUMBER;
    L_     NUMBER;
  BEGIN
    --
    V_SPID := HADES_ERRO_PACK.GET_STOREDPROC_ID('C_ERGON','PCK_TGRJ_RUB_ELEMENTO_DESPESA','MAIN_PRE');
    -- Chamada da PCK_BEFORE_CERGON.EPB__TGRJ_RUB_ELEMENTO_DESPESA
    --
--
L_ := 140;
--

      IF (P_TIPO_DML  = 'I' AND V_ROW_NEW.ID IS NULL) THEN
        SELECT TGRJ_RUB_ELEMENTO_DESPESA_SEQ.NEXTVAL
        INTO   V_ROW_NEW.ID
        FROM   DUAL;
      END IF;

      -- IF (P_TIPO_DML IN ('I','U')) THEN
      --   IF NOT PACK_UTIL_CERG.EH_QUADRINOMIO_VALIDO(V_ROW_NEW.TIPOVINC, V_ROW_NEW.REGJUR, V_ROW_NEW.CATEGORIA, V_ROW_NEW.SUBCATEGORIA) THEN
      --     ERGON_ERRO_PACK.TRATA_ERRO(99, 'O quadrinômio  Tipo de vínculo:'||V_ROW_NEW.TIPOVINC||' Regime Jurídico:'||V_ROW_NEW.REGJUR||' Categoria:'||V_ROW_NEW.CATEGORIA||' Subcategoria:'||V_ROW_NEW.SUBCATEGORIA||' é inválido.');
      --   END IF;  
      -- END IF;

      v_ep := PCK_EXEC_EP_CERG.EXEC_EP_PCK_BEFORE (
                'EPB__TGRJ_RUB_ELEMENTO_DESPESA', 
                (P_TIPO_DML = 'I'),
                (P_TIPO_DML = 'U'),
                (P_TIPO_DML = 'D'),
                 v_mens);
    --
--
L_ := 150;
--
    IF v_mens IS NOT NULL THEN
      --
      HADES_ERRO_PACK.TRATA_ERRO_EP ('C_Ergon', 10000, V_MENS);
      --
    END IF;
    --
--
L_ := 160;
--
    IF v_ep THEN
      --
      -- O EP retornou valor VERDADEIRO, ou seja, as VALIDAÇÕES do PRODUTO devem ser executadas
      --
--
L_ := 170;
--
      NULL;
      --
    END IF;
    --
  EXCEPTION WHEN OTHERS THEN 
  HADES_ERRO_PACK.TRATA_ERRO('C_Ergon',-1,SQLERRM,V_SPID,L_);
  END MAIN_PRE;
  --!/<PCK_TGRJ_RUB_ELEMENTO_DESPESA:MAIN_PRE>--
  --
  --!<PCK_TGRJ_RUB_ELEMENTO_DESPESA:MAIN_POS>--
  PROCEDURE MAIN_POS (P_TIPO_DML IN VARCHAR2) IS
    --
    v_ep                   BOOLEAN;
    v_mens                 VARCHAR2(2000);
    --
    V_SPID NUMBER;
    L_     NUMBER;
  BEGIN
    --
    V_SPID := HADES_ERRO_PACK.GET_STOREDPROC_ID('C_ERGON','PCK_TGRJ_RUB_ELEMENTO_DESPESA','MAIN_POS');
    -- varre a tabela auxiliar de TGRJ_RUB_ELEMENTO_DESPESA
    --
--
L_ := 180;
--
    FOR i IN 1..P_INDICE LOOP
      --
      -- Chamada da PCK_AFTER_CERGON.EPA__TGRJ_RUB_ELEMENTO_DESPESA
      --
--
L_ := 190;
--
      v_ep := PCK_EXEC_EP_CERG.EXEC_EP_PCK_AFTER (
                'EPA__TGRJ_RUB_ELEMENTO_DESPESA',
                (P_TIPO_DML = 'I'),
                (P_TIPO_DML = 'U'),
                (P_TIPO_DML = 'D'),
                i,
                v_mens);
      --
--
L_ := 200;
--
      IF v_mens IS NOT NULL THEN
        --
        HADES_ERRO_PACK.TRATA_ERRO_EP ('C_Ergon', 10000, V_MENS);
        --
      END IF;
      --
--
L_ := 210;
--
      IF v_ep THEN
        --
        -- O EP retornou valor VERDADEIRO, ou seja,
        -- as VALIDAÇÕES do PRODUTO devem ser executadas
        --
--
L_ := 220;
--
        --IF (P_TIPO_DML IN ('I', 'U')) THEN
--
L_ := 230;
--
        NULL;
        --
        -- usar P_TGRJ_RUB_ELEMENTO_DESPESA(i).campos
        --
        --END IF;-- P_TIPO_DML IN (I,U)
        --
      END IF;
      --
      --
    END LOOP;
  EXCEPTION WHEN OTHERS THEN 
    HADES_ERRO_PACK.TRATA_ERRO('C_Ergon',-1,SQLERRM,V_SPID,L_);
  END MAIN_POS;
  --
  --!/<PCK_TGRJ_RUB_ELEMENTO_DESPESA:MAIN_POS>--
BEGIN
  P_INDICE               := 0;
  P_TGRJ_RUB_ELEMENTO_DESPESA      := TGRJ_RUB_ELEMENTO_DESPESA_REC();
  P_TGRJ_RUB_ELEMENTO_DESPES_OLD  := TGRJ_RUB_ELEMENTO_DESPESA_REC();
END PCK_TGRJ_RUB_ELEMENTO_DESPESA;
/