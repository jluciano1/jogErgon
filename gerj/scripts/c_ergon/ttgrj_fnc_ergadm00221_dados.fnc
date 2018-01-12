create or replace function ttgrj_fnc_ergadm00221_dados(p_lancamento in number,
                                                       p_retorno in varchar2) return varchar2 is

  v_agencia varchar2(200);
  v_conta   varchar2(200);
  v_banco   varchar2(200);

begin

  select distinct dr.cod_agencia, dr.c_corrente, dr.cod_banco
    into v_agencia, v_conta, v_banco
    from tgrj_detalhe_remessa dr, tgrj_arquivo_remessa ar
   where dr.lancamento = p_lancamento
     and ar.id_arquivo_remessa = dr.id_arquivo_remessa
     and ar.numfita IS NULL
     and ar.flag_cancela IS NULL;

  if p_retorno = 'A' then
    return(v_agencia);
  elsif p_retorno = 'C' then
    return(v_conta);
  elsif p_retorno = 'B' then
    return(v_banco);
  end if;

exception
  when others then
  return(null);

end;
/