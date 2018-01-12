CREATE OR REPLACE FUNCTION EP__EH_TRANS_APOSENTADORIA RETURN NUMBER
IS
/**************** INICIO_HELP: ****************
--------------------------------------------------Nome:
  FUNCTION EP__EH_TRANS_APOSENTADORIA RETORNA NUMBER
Propósito:
  Permitir ao usuário que indique transações customizadas responsáveis pela manipulação de registros de aposentadorias.
Parâmetros:
  Não há.
Retorno:
  0 : Não se trata de uma transação customizada de aposentadoria;
  1 : Se trata de uma transação customizada de aposentadoria;
Utilização:
  Utilizada para customizar a função pack_ergon.eh_trans_aposent_temporal.
--------------------------------------------------***************** FINAL_HELP: ****************/
BEGIN
  if flag_pack.get_transacao in ('RJadm00084') then
    return 1;
  else
    return 0;
  end if;
END;
/