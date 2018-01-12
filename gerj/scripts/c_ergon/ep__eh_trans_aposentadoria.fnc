CREATE OR REPLACE FUNCTION EP__EH_TRANS_APOSENTADORIA RETURN NUMBER
IS
/**************** INICIO_HELP: ****************
--------------------------------------------------Nome:
  FUNCTION EP__EH_TRANS_APOSENTADORIA RETORNA NUMBER
Prop�sito:
  Permitir ao usu�rio que indique transa��es customizadas respons�veis pela manipula��o de registros de aposentadorias.
Par�metros:
  N�o h�.
Retorno:
  0 : N�o se trata de uma transa��o customizada de aposentadoria;
  1 : Se trata de uma transa��o customizada de aposentadoria;
Utiliza��o:
  Utilizada para customizar a fun��o pack_ergon.eh_trans_aposent_temporal.
--------------------------------------------------***************** FINAL_HELP: ****************/
BEGIN
  if flag_pack.get_transacao in ('RJadm00084') then
    return 1;
  else
    return 0;
  end if;
END;
/