CREATE OR REPLACE PACKAGE BODY tgrj_relat_util
IS
  FUNCTION get_url_report
    RETURN VARCHAR2
  IS
    url         VARCHAR2(2000):='';
    v_repserver VARCHAR2(2000):='';   

  BEGIN
  
    SELECT PACK_HADES.GET_OPCAO('Hades','WEB','REPORTSSERVER')
      INTO v_repserver
    FROM DUAL;
    
    url := 'http://10.113.7.113:9002/reports/rwservlet?server='||v_repserver;
      
    RETURN url;
    
  END;
  --
  FUNCTION get_conection
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN ('hades/hades@rioprevam');
  END get_conection;  
  --
  FUNCTION GET_USER_HTTP_AUTHENTICATION
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN null;
  END GET_USER_HTTP_AUTHENTICATION;
  --
  FUNCTION GET_PASS_HTTP_AUTHENTICATION
  RETURN VARCHAR2
  IS
  BEGIN
    RETURN null;
  END GET_PASS_HTTP_AUTHENTICATION;
  --
  FUNCTION get_dir_relat_agenda
    RETURN VARCHAR2
  IS
    dir VARCHAR2(200):='/local/archon/web/temp/';
  BEGIN
    RETURN dir;
  END;
--
  FUNCTION get_next_lote_seq
    RETURN NUMBER
  IS
  v_ret NUMBER;
  BEGIN
    SELECT tgrj_lote_report_seq.nextval INTO v_ret FROM dual;
    RETURN v_ret;
  END;
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
    RETURN NUMBER
  IS
    v_id          NUMBER;
    v_resposta    VARCHAR2(1);
    v_agendamento DATE;
    mens_verif    VARCHAR2(200);
    l_param       HAD_TYP_ARRAY_VARCHAR2;
  BEGIN
    
    l_param := HAD_TYP_ARRAY_VARCHAR2();
    l_param.extend(5);

    FOR x IN 1..P_REPETICAO
    LOOP
      SELECT HAD_AGENDA_RELAT_SEQ.NEXTVAL INTO v_id FROM dual;
      BEGIN
        INSERT
        INTO had_agenda_relat
          (
            id,
            usuario,
            relatorio,
            data_hora,
            status,
            emp_codigo,
            dias_expiracao,
            arquivo
          )
          VALUES
          (
            v_id,
            P_USUARIO,
            P_RELATORIO,
            P_DATA_AGENDA,
            'EM FILA',
            P_EMPRESA,
            P_EXPIRACAO,
            tgrj_relat_util.get_dir_relat_agenda || P_ARQUIVO || '_' || v_id || '.pdf'
          );
      EXCEPTION
      WHEN OTHERS THEN
        p_mens := 'Ocorreu o seguinte erro no agendamento da execução (1): ' || HAD_FORMATA_MSG_ERRO(sqlerrm);
        RETURN NULL;
      END;

      BEGIN

        FOR i IN 1..P_PARAMETRO.count LOOP       
          CASE P_PARAMETRO(i)
            WHEN 'DESNAME'      THEN l_param(1) := 'x';
            WHEN 'DESTYPE'      THEN l_param(2) := 'x';
            WHEN 'DESFORMAT'    THEN l_param(3) := 'x';
            WHEN 'P_HADUSUARIO' THEN l_param(4) := 'x';
            WHEN 'P_HADEMPRESA' THEN l_param(5) := 'x';
            ELSE null;
          END CASE;
        END LOOP;  

        -- DESNAME
        IF (l_param(1) IS NULL) THEN
          INSERT INTO had_agenda_relat_param (id,parametro,valor)
          VALUES(v_id,'DESNAME', P_ARQUIVO||'_'||v_id||'.pdf');
        END IF;
        -- DESTYPE
        IF (l_param(2) IS NULL) THEN
          INSERT INTO had_agenda_relat_param (id,parametro,valor)
          VALUES(v_id,'DESTYPE', 'file');
        END IF;
        -- DESFORMAT
        IF (l_param(3) IS NULL) THEN
          INSERT INTO had_agenda_relat_param (id,parametro,valor)
          VALUES(v_id,'DESFORMAT', 'pdf');
        END IF;
        -- P_HADUSUARIO
        IF (l_param(4) IS NULL) THEN
          INSERT INTO had_agenda_relat_param (id,parametro,valor)
          VALUES(v_id,'P_HADUSUARIO', flag_pack.get_usuario());
        END IF;
        -- P_HADEMPRESA
        IF (l_param(5) IS NULL) THEN
          INSERT INTO had_agenda_relat_param (id,parametro,valor)
          VALUES(v_id,'P_HADEMPRESA', NVL(P_EMPRESA, flag_pack.get_empresa()));
        END IF;

        FOR i IN 1..P_PARAMETRO.count()
        LOOP
        IF P_PARAMETRO(i) NOT IN ('DESFORMAT','DESTYPE','DESNAME', 'P_USUARIO', 'P_EMP_CODIGO' )  THEN
            INSERT
            INTO had_agenda_relat_param
              (
                id,
                parametro,
                valor
              )
              VALUES
              (
                v_id,
                P_PARAMETRO(i),
                P_VALOR(i)
              );
        END IF;
        END LOOP;
      EXCEPTION
      WHEN OTHERS THEN
        p_mens := 'Ocorreu o seguinte erro no agendamento da execução (2): ' || HAD_FORMATA_MSG_ERRO(sqlerrm);
        RETURN NULL;
      END;
    END LOOP;
    v_resposta     := had_verif_param_rel(v_id,mens_verif);
    IF (v_resposta != 'S') THEN
      p_mens       := 'Parâmetros do relatório "' || P_RELATORIO || '" não estão válidos.';
      RETURN NULL;
    END IF;
    RETURN v_id;
  END;

  FUNCTION GET_MENSAGEM_REPORT (P_ID NUMBER) RETURN VARCHAR2 IS
    V_PARAM VARCHAR2(32000);
    CURSOR CS_PARAM IS
      SELECT * FROM had_agenda_relat_param
      WHERE ID = P_ID AND UPPER(PARAMETRO) NOT IN ('DESTYPE');
    v_report varchar2(1000);
    v_diretorio varchar2(4000);
    V_DESTINO varchar2(4000);
    V_FORMAT VARCHAR2(100);

    v_rel had_agenda_relat%rowtype;
    c_concatstr varchar2(10) := chr(13)||chr(10);

    V_MENSREPORT VARCHAR2(10000);

  BEGIN
    --
    select * into v_rel
    from had_agenda_relat
    where id=p_id;
    --
    select lower(arquivo) into v_report
    from relatorios
    where nome in (select relatorio
                   from had_agenda_relat
                   where id=p_id);
    V_PARAM := 'report='||v_report;
    FOR RC IN CS_PARAM LOOP
      IF UPPER(RC.PARAMETRO)='DESFORMAT' THEN
        V_FORMAT := RC.VALOR;
      ELSIF UPPER(RC.PARAMETRO)='DESNAME' THEN
         V_DESTINO := RC.VALOR;
      ELSE
        V_PARAM := V_PARAM||c_concatstr||RC.PARAMETRO||'='''||RC.VALOR||'''';
      END IF;

    END LOOP;
    --
    V_PARAM := 'DESNAME='||V_DESTINO||c_concatstr||
               'DESFORMAT='||V_FORMAT||c_concatstr||
               V_PARAM;


    RETURN v_rel.MENSAGEM||c_concatstr||v_rel.MSG_USU||c_concatstr||V_PARAM;
  END GET_MENSAGEM_REPORT;

END;
/