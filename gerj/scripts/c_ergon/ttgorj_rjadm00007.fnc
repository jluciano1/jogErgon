create or replace function ttgorj_rjadm00007(p_tipo_req in varchar2,
                                             p_tipoorg_req in varchar2,
											 p_orgao_ext_req in varchar2, 
                                             p_funcao_req    in varchar2,
                                             p_tipo_onus_req in varchar2,
											 p_tipo_ressarc_req in varchar2)return ttgorj_typ_rjadm00007_tab pipelined is
  cursor c1 is
	select v.numfunc,
		   f.nome,
		   v.numero,
		   v.dtexerc,
		   v.flex_campo_07 orgao_ext_req,
		   v.funcao_req,
		   v.flex_campo_06 tipoorg_req,
		   v.tipo_req,
		   v.tipo_onus_req,
		   v.tipo_ressarc_req,
		   v.emp_codigo,
		   v.flex_campo_08  flex_campo_08
		from vinculos v,
			 funcionarios f
	   where v.numfunc = f.numero
		 and v.tipo_req is not null
         and v.emp_codigo = flag_pack.get_empresa
		 and upper(v.tipo_req) = upper(nvl(p_tipo_req,v.tipo_req))
         and upper(v.flex_campo_06) = upper(nvl(p_tipoorg_req,v.flex_campo_06))
		 and upper(v.flex_campo_07) = upper( nvl(p_orgao_ext_req,v.flex_campo_07))
 		 and upper(v.funcao_req) = upper(nvl(p_funcao_req,v.funcao_req) )
		 and upper(v.tipo_onus_req) = upper(nvl(p_tipo_onus_req,v.tipo_onus_req))
		 and upper(v.tipo_ressarc_req) = upper(nvl(p_tipo_ressarc_req,v.tipo_ressarc_req));
		 
begin 

  if (p_tipo_req is null and p_tipoorg_req is null and p_orgao_ext_req is null and p_funcao_req is null and p_tipo_onus_req is null and p_tipo_ressarc_req is null) then
    return;
  end if;
  
  for rr in c1 loop
    pipe row (ttgorj_typ_rjadm00007(rr.numfunc, rr.nome, rr.numero, rr.numfunc||'/'||rr.numero, rr.dtexerc, rr.orgao_ext_req, rr.funcao_req, rr.tipoorg_req, rr.tipo_req, rr.tipo_onus_req, rr.tipo_ressarc_req, rr.emp_codigo, rr.flex_campo_08));
  end loop;

  return;

end;
/