prompt ***ATENÇÃO!!!*** Objeto TGRJ_EPB__VINCULO_QUE_CONTA não possui replace e deve ser mesclado manualmente com a versão existente no banco.
create FUNCTION "TGRJ_EPB__VINCULO_QUE_CONTA" (P_ROW_NEW    IN OUT NOCOPY VINCULO_QUE_CONTA%ROWTYPE,
                                        P_ROW_OLD    IN     VINCULO_QUE_CONTA%ROWTYPE,
                                        P_INSERTING  IN     BOOLEAN,
                                        P_UPDATING   IN     BOOLEAN,
                                        P_DELETING   IN     BOOLEAN,
                                        P_MENS       OUT    NOCOPY VARCHAR2) RETURN BOOLEAN IS
  v_transacao VARCHAR2(2000);
  --
BEGIN
  --
  -- Impede o lancamento de vinculac?es manualmente

  SELECT  UPPER(FLAG_PACK.GET_TRANSACAO) INTO v_transacao 
  FROM DUAL;

  IF UPPER(v_transacao) not in ('VINCULO','ERGadm00229') THEN
     p_mens := 'Não é permitido vinculação Manual. Caso necessite vincular algum item, utilize a tela de Vinculos atraves do campo Vinculo Anterior.';
  END IF;
  --
  RETURN (TRUE);
END;
/

