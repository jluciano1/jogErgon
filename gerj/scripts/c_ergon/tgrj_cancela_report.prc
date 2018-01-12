CREATE OR REPLACE
PROCEDURE tgrj_cancela_report(p_id_report IN HAD_TYP_ARRAY_NUMBER
                            , p_status    IN VARCHAR2) 
IS
BEGIN
  FOR x IN 1..p_id_report.count LOOP
    BEGIN
      UPDATE had_agenda_relat
      SET
        mensagem   = 'Alteração do status=' || p_status,
        status     = p_status,
        msg_usu    = NULL,
        msg_gestor = NULL
      WHERE id = p_id_report(x);
      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        ergon_erro_pack.trata_erro('Erro ao alterar o status do relatório. Entre em contato com o suporte.');
    END;
  END LOOP;
END tgrj_cancela_report;
/