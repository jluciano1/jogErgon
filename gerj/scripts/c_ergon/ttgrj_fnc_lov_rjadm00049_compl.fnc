CREATE OR REPLACE 
FUNCTION TTGRJ_FNC_LOV_RJADM00049_COMPL (p_rubrica IN NUMBER) 
RETURN  HAD_TYP_LOV_VARCHAR2_TAB PIPELINED IS

v_out  HAD_TYP_LOV_VARCHAR2_TAB := HAD_TYP_LOV_VARCHAR2_TAB();
v_mens VARCHAR2(4000);
BEGIN

  ttgrj_prc_valores_compl_async(p_rubrica, v_mens);

  IF (v_mens IS NULL) THEN
    FOR i IN (SELECT distinct valor, descricao FROM VALORES_COMPLEMENTOS) 
    LOOP
      pipe row (HAD_TYP_LOV_VARCHAR2(i.valor,i.descricao));
    END LOOP;  
  
  ELSE
    ergon_erro_pack.trata_erro(99, 'Erro ao carregar valores de complemento da rubrica '||p_rubrica);                                                                                                                                                                                                                                           
  END IF;

END;
/
