CREATE OR REPLACE PROCEDURE C_ERG_ALTERAR_APOS (P_OPER IN VARCHAR2
                            ,P_NUMFUNC IN NUMBER
                            ,P_NUMVINC IN NUMBER
                            ,P_TIPOAPOS IN  VARCHAR2
                            ,P_DTINI IN DATE
                            ,P_DTFIM IN DATE DEFAULT NULL
                            ,P_DT_HOMOLOG IN DATE DEFAULT NULL
                            ,P_ANOSTRAB IN NUMBER  DEFAULT NULL
                            ,P_DIASTRAB IN NUMBER  DEFAULT NULL
                            ,P_ANOSAPOS IN NUMBER  DEFAULT NULL
                            ,P_FRACAO1 IN NUMBER  DEFAULT NULL
                            ,P_FRACAO2 IN NUMBER DEFAULT NULL
                            ,P_OBS IN VARCHAR2 DEFAULT NULL
                            ,P_FLEX_02 IN VARCHAR2 DEFAULT NULL
                            ,P_FLEX_04 IN VARCHAR2 DEFAULT NULL
                           ) AS

 V_APOS ERG_APOSENTADORIA%ROWTYPE;
 V_AUX ERG_APOSENTADORIA%ROWTYPE;
 V_RESULT VARCHAR2(2000);
 V_EXISTE NUMBER;
 V_PROP CHAR(1);
 V_TPROP CHAR(1);
 v_existe_aposent NUMBER;

BEGIN

    IF (P_NUMFUNC IS NULL OR P_NUMVINC IS NULL) THEN
      ERGON_ERRO_PACK.TRATA_ERRO(99, 'É necessário informar o vínculo para alterar uma aposentadoria.');
    END IF;

    IF P_DTINI IS NULL THEN
      ERGON_ERRO_PACK.TRATA_ERRO(99, 'É necessário informar a data de início para alterar a aposentadoria.');
    END IF;

    IF P_TIPOAPOS IS NULL THEN
      ERGON_ERRO_PACK.TRATA_ERRO(99, 'É necessário informar o tipo de aposentadoria para alterar a aposentadoria.');
    END IF;

    SELECT COUNT(*) INTO V_EXISTE
      FROM ERG_APOSENTADORIA A
     WHERE A.NUMFUNC   = P_NUMFUNC
       AND A.NUMVINC   = P_NUMVINC;

    IF V_EXISTE < 1 THEN
      ERGON_ERRO_PACK.TRATA_ERRO(99,'Vínculo não possui registro de aposentadoria!');
    END IF;

    V_APOS.NUMFUNC      :=  P_NUMFUNC;
    V_APOS.NUMVINC      :=  P_NUMVINC;
    V_APOS.DTINI        :=  P_DTINI;
    V_APOS.DTFIM        :=  P_DTFIM;
    V_APOS.OBS          :=  P_OBS;
    V_APOS.TIPOAPOS     :=  P_TIPOAPOS;
    V_APOS.DT_HOMOLOG   :=  P_DT_HOMOLOG;

    SELECT PROPORC, TIPOPROP INTO V_PROP, V_TPROP
      FROM TIPO_APOS
     WHERE TIPO = P_TIPOAPOS;

    IF V_PROP = 'N' THEN
        V_APOS.FRACAO1        :=    NULL;
        V_APOS.FRACAO2        :=    NULL;
        V_APOS.ANOSTRAB        :=    NULL;
        V_APOS.ANOSAPOS        :=    NULL;
        V_APOS.DIASTRAB        :=    NULL;
    ELSIF V_TPROP = 'F' THEN
        V_APOS.FRACAO1        :=    P_FRACAO1;
        V_APOS.FRACAO2        :=    P_FRACAO2;
        V_APOS.ANOSTRAB        :=    NULL;
        V_APOS.ANOSAPOS        :=    NULL;
        V_APOS.DIASTRAB        :=    NULL;
    ELSE
        V_APOS.FRACAO1        :=    NULL;
        V_APOS.FRACAO2        :=    NULL;
        V_APOS.ANOSTRAB        :=    P_ANOSTRAB;
        V_APOS.ANOSAPOS        :=    P_ANOSAPOS;
        V_APOS.DIASTRAB        :=    P_DIASTRAB;
    END IF;

    BEGIN
    
    IF P_OPER = 'ALTERAR' THEN
       SELECT * INTO V_AUX
         FROM ERG_APOSENTADORIA
        WHERE NUMFUNC = P_NUMFUNC
          AND NUMVINC = P_NUMVINC
          AND DTINI   = P_DTINI;
       
       IF P_FLEX_02 IS NOT NULL THEN   
         V_AUX.FLEX_CAMPO_02 := P_FLEX_02;   
       END IF;
       
       V_AUX.FLEX_CAMPO_04 := P_FLEX_04;
       
    ELSIF P_OPER = 'ALTERAR PERC' THEN

      SELECT COUNT(1)
        INTO v_existe_aposent
        FROM ERG_APOSENTADORIA
       WHERE NUMFUNC = P_NUMFUNC
         AND NUMVINC = P_NUMVINC
         AND DTINI = P_DTINI;
         
       IF P_FLEX_02 IS NOT NULL THEN   
         V_AUX.FLEX_CAMPO_02 := P_FLEX_02;   
       END IF;  
       
       V_AUX.FLEX_CAMPO_04 := P_FLEX_04;
       
      IF v_existe_aposent > 0 THEN
        ergon_erro_pack.trata_erro(99, 'Já existe registro de aposentadoria com início em ' || P_DTINI || '.');
      END IF;

      SELECT * INTO V_AUX
        FROM ERG_APOSENTADORIA
       WHERE NUMFUNC = P_NUMFUNC
         AND NUMVINC = P_NUMVINC
         AND DTFIM IS NULL;

      IF (P_DTINI < V_AUX.DTINI) THEN
        ergon_erro_pack.trata_erro(99, 'A data de início da alteração ' || P_DTINI || ' deve ser superior a data de ínicio do registro em aberto ' || V_AUX.DTINI || '.');
      END IF;

    END IF;


        V_APOS.FIMAPOS_TIPOEVENTO     :=   V_AUX.FIMAPOS_TIPOEVENTO;
        V_APOS.FIMAPOS_CARGO          :=   V_AUX.FIMAPOS_CARGO;
        V_APOS.FIMAPOS_FORMAPROV      :=   V_AUX.FIMAPOS_FORMAPROV;
        V_APOS.FIMAPOS_SETOR          :=   V_AUX.FIMAPOS_SETOR;
        V_APOS.FIMAPOS_REFERENCIA     :=   V_AUX.FIMAPOS_REFERENCIA;
        V_APOS.FIMAPOS_JORNADA        :=   V_AUX.FIMAPOS_JORNADA;
        V_APOS.FIMAPOS_NUMERO_VAGA    :=   V_AUX.FIMAPOS_NUMERO_VAGA;
        V_APOS.FLEX_CAMPO_01          :=   V_AUX.FLEX_CAMPO_01;
        V_APOS.FLEX_CAMPO_02          :=   V_AUX.FLEX_CAMPO_02;
        V_APOS.FLEX_CAMPO_03          :=   V_AUX.FLEX_CAMPO_03;
        V_APOS.FLEX_CAMPO_04          :=   V_AUX.FLEX_CAMPO_04;
        V_APOS.FLEX_CAMPO_05          :=   V_AUX.FLEX_CAMPO_05;
        V_APOS.FLEX_CAMPO_06          :=   V_AUX.FLEX_CAMPO_06;
        V_APOS.FLEX_CAMPO_07          :=   V_AUX.FLEX_CAMPO_07;
        V_APOS.FLEX_CAMPO_08          :=   V_AUX.FLEX_CAMPO_08;
        V_APOS.FLEX_CAMPO_09          :=   V_AUX.FLEX_CAMPO_09;
        V_APOS.FLEX_CAMPO_10          :=   V_AUX.FLEX_CAMPO_10;
        V_APOS.FLEX_CAMPO_11          :=   V_AUX.FLEX_CAMPO_11;
        V_APOS.FLEX_CAMPO_12          :=   V_AUX.FLEX_CAMPO_12;
        V_APOS.FLEX_CAMPO_13          :=   V_AUX.FLEX_CAMPO_13;
        V_APOS.FLEX_CAMPO_14          :=   V_AUX.FLEX_CAMPO_14;
        V_APOS.FLEX_CAMPO_15          :=   V_AUX.FLEX_CAMPO_15;
        V_APOS.FLEX_CAMPO_16          :=   V_AUX.FLEX_CAMPO_16;
        V_APOS.FLEX_CAMPO_17          :=   V_AUX.FLEX_CAMPO_17;
        V_APOS.FLEX_CAMPO_18          :=   V_AUX.FLEX_CAMPO_18;
        V_APOS.FLEX_CAMPO_19          :=   V_AUX.FLEX_CAMPO_19;
        V_APOS.FLEX_CAMPO_20          :=   V_AUX.FLEX_CAMPO_20;

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
          ERGON_ERRO_PACK.TRATA_ERRO(99,'Registro de aposentadoria não encontrado!');
    END;

    V_RESULT := GERA_APOSENTADORIA_TEMPORAL(P_OPER,V_APOS,P_NUMFUNC,P_NUMVINC,P_DTINI);

    IF V_RESULT IS NOT NULL THEN
        ERGON_ERRO_PACK.TRATA_ERRO(99,V_RESULT);
    END IF;
END;
/