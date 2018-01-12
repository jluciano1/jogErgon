create or replace function ttgrj_fnc_ergadm00222_getnome(p_lancamento in number,
                                                         p_numfita    in number) return varchar2 is
  v_nome varchar2(2000);

begin

  begin
    select distinct dr.nome_emp
      into v_nome
      from tgrj_detalhe_remessa dr, tgrj_arquivo_remessa ar
     where dr.lancamento = p_lancamento
       and ar.id_arquivo_remessa = dr.id_arquivo_remessa
       and ar.numfita = p_numfita;
  exception
    when no_data_found then
      begin
        select nome
          into v_nome
          from fitabanco
         where lancamento = p_lancamento;
      exception
        when no_data_found then
        v_nome := null;
      end;
    when too_many_rows then
      v_nome := null;
  end;

  return(v_nome);

end;
/