CREATE OR REPLACE PROCEDURE tgrj_cria_relat_inform_rend(
    P_RELATORIO     IN HAD_TYP_ARRAY_VARCHAR2 DEFAULT NULL,
    P_MES_ANO_FOLHA IN VARCHAR2,
    P_USUARIO       IN VARCHAR2,
    P_EMPRESA       IN VARCHAR2,
    P_ARQUIVO       IN HAD_TYP_ARRAY_VARCHAR2,
    P_MENS OUT VARCHAR2,
    P_ID_AGENDA OUT NUMBER,
    P_ID_LOTE OUT NUMBER)
IS
  comita      NUMBER;
  v_id_lote   NUMBER;
  v_id_agenda NUMBER;
  v_mens      VARCHAR2(2000)       := '';
  cont        NUMBER               := p_relatorio.count;
  arr_aux HAD_TYP_ARRAY_VARCHAR2   := HAD_TYP_ARRAY_VARCHAR2();
  arr_param HAD_TYP_ARRAY_VARCHAR2 := HAD_TYP_ARRAY_VARCHAR2();
  arr_valor HAD_TYP_ARRAY_VARCHAR2 := HAD_TYP_ARRAY_VARCHAR2();
BEGIN
  arr_param.extend();
  arr_param(1) := 'P_MES_ANO_FOLHA';
  --
  arr_param.extend();
  arr_param(2) := 'DESTYPE';
  --
  arr_param.extend();
  arr_param(3) := 'DESNAME';
  --
  arr_param.extend();
  arr_param(4) := 'DESFORMAT';
  --
  arr_param.extend();
  arr_param(5) := 'P_TITULO';
  -----
  arr_valor.extend();
  arr_valor(1) := p_mes_ano_folha;
  --
  arr_valor.extend();
  arr_valor(2) := '';
  --
  arr_valor.extend();
  arr_valor(3) := '';
  --
  arr_valor.extend();
  arr_valor(4) := '';
  --
  arr_valor.extend();
  arr_valor(5) := '';
  -----
  SELECT tgrj_lote_report_seq.nextval INTO v_id_lote FROM dual;
  comita := p_relatorio.count;
  FOR i IN 1..cont
  LOOP
    v_id_agenda := tgrj_relat_util.gera_req_agenda_rep(1,p_usuario,p_relatorio(i),sysdate,p_empresa,1,p_arquivo(i),arr_param,arr_valor,v_mens);
    IF v_mens   IS NOT NULL THEN
      comita    := comita - 1;
      ROLLBACK;
      p_mens := v_mens;
      RETURN;
    ELSE
      BEGIN
        INSERT
        INTO tgrj_lote_report VALUES
          (
            v_id_lote,
            v_id_agenda,
            flag_pack.get_sis,
            flag_pack.get_transacao
          );
      EXCEPTION
      WHEN OTHERS THEN
        p_mens := 'Agendamento em lote não realizado: ' || sqlerrm;
        RETURN;
      END;
    END IF;
  END LOOP;
  --
  IF comita <> cont THEN
    ROLLBACK;
  ELSE
    COMMIT;
  END IF;
END;
/