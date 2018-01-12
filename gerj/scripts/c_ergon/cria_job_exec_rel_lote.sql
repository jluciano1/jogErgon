DECLARE
  v NUMBER;
BEGIN
  
  -- Criando o JOB para executar a cada 5s
  DBMS_JOB.SUBMIT (v, 'BEGIN pgov_gera_rel_agendados_lote; END;', SYSDATE, 'SYSDATE+1/(12*60*24)');
  COMMIT;
  
  DBMS_OUTPUT.PUT_LINE('JOB Criado: ' || v);
  
END;
/