create or replace procedure ttgrj_dml_rjadm00069_gerar
	(
		pb_numfunc in pgov_conc_benef_ms605.numfunc%type default null,
		pb_numvinc in pgov_conc_benef_ms605.numvinc%type default null,
		pb_tipo in pgov_conc_benef_ms605.tipo%type default null,
		pb_dtfim in pgov_conc_benef_ms605.dt_fim%type default null
	)
is
	v_tipo			PGOV_CONC_BENEF_MS605.tipo%type;
	v_erro			varchar2(2000);
	v_result		number;
	v_msg			varchar2(200);
	v_dt_ini_min	date;
	v_mens			varchar2(100);
	v_dtfim			PGOV_CONC_BENEF_MS605.dt_fim%type;
	v_count			number;
begin

DECLARE
	CURSOR c_conc_benef is
		select numfunc, numvinc, tipo, dt_ini, to_date(dt_ini, 'dd/MM/yyyy') as dtini_aux, dt_fim, to_date(dt_fim, 'dd/MM/yyyy') as dtfim_aux,
			perc, valor, dtini_atraso, to_date(dtini_atraso, 'dd/MM/yyyy') as dtini_atraso_aux, dtfim_atraso,
			to_date(dtfim_atraso, 'dd/MM/yyyy') as dtfim_atraso_aux, mesano_pag, to_date(mesano_pag, 'dd/MM/yyyy') as dtmesano_aux, vl_atraso,
			flag_desligamento
		from pgov_conc_benef_ms605
			where numfunc = pb_numfunc
			and numvinc = pb_numvinc;
		l_conc_benef c_conc_benef%rowtype;
	BEGIN
	OPEN c_conc_benef;
	LOOP
		EXIT WHEN c_conc_benef%NOTFOUND;
		FETCH c_conc_benef INTO l_conc_benef;
	END LOOP;
	CLOSE c_conc_benef;

	--Busca a menor data da tabela de pgov_parcelas_ms605
	begin
		select min(dt_ini)
		into v_dt_ini_min
		from pgov_parcelas_ms605
		where numfunc = pb_numfunc
		and numvinc = pb_numvinc
		order by dt_ini;
	exception when others then
		v_dt_ini_min := null;
	end;

	begin
		select count(*)
		into v_count
		from PGOV_CONC_BENEF_MS605
		where numfunc = l_conc_benef.numfunc
		and numvinc = l_conc_benef.numvinc
		and tipo = 'ATRASADO MS605'
		and dt_fim is null;
		exception when no_data_found then
		v_count := 0;
	end;

	--Preenchimentos dos parâmetros caso o usuário clique logo no botão "Gerar Valor Retroativo".
	if l_conc_benef.dtini_aux is null then
		l_conc_benef.dtini_atraso := null;
	elsif l_conc_benef.dtfim_aux is null then
		l_conc_benef.dtfim_atraso := null;
	elsif l_conc_benef.dtmesano_aux is null then
		l_conc_benef.mesano_pag := null;
	end if;

	--Teste de mensagem de erro
	--ergon_erro_pack.trata_erro(99,'Teste de mensagem de erro');
	--return;

	if v_count = 1 then
		ergon_erro_pack.trata_erro(99,'Existe registro em aberto. Favor verificar!');
		return;
	elsif v_count = 0 then
		if l_conc_benef.tipo = 'ATRASADO MS605' and l_conc_benef.dt_fim is null then
			ergon_erro_pack.trata_erro(99,'Data Fim da Concessão Benefício não pode ser menor que Data Início.');
			return;
		elsif l_conc_benef.tipo = 'ATRASADO MS605' and l_conc_benef.dt_fim is not null then
		if l_conc_benef.dt_fim is not null then
			if l_conc_benef.dt_fim < l_conc_benef.dt_ini then
				ergon_erro_pack.trata_erro(99,'Data fim da Concessão Benefício não pode ser menor que data início.');
				return;
				--RAISE FORM_TRIGGER_FAILURE;
			end if;
		end if;
		if l_conc_benef.dtini_aux is not null and l_conc_benef.dtfim_aux is not null and l_conc_benef.dtmesano_aux is not null then
			 if l_conc_benef.dt_fim < l_conc_benef.dt_ini then
				ergon_erro_pack.trata_erro(99,'Data Fim da Concessão Benefício não pode ser menor que Data Início.');
				return;
			elsif l_conc_benef.dtfim_aux < l_conc_benef.dtini_aux then
				ergon_erro_pack.trata_erro(99,'Pagamento Retroativo - Data Fim do Período do Atrasado não pode ser MENOR que Data Início do Período do Atrasado.');
				return;
				--go_item('pgov_conc_benef_ms605.dtfim_aux');
			/* elsif l_conc_benef.dtini_aux >= l_conc_benef.dt_ini then
				ergon_erro_pack.trata_erro(99,'Pagamento Retroativo - Data Início do Período do Atrasado deverá ser MENOR que a Data Início da Concessão Benefício.');
				return; */
			elsif l_conc_benef.dtfim_aux >= l_conc_benef.dt_ini then
				ergon_erro_pack.trata_erro(99,'Existe registro em aberto. Favor verificar!');
				return;
			elsif (l_conc_benef.dtmesano_aux < l_conc_benef.dt_ini or l_conc_benef.dtmesano_aux > l_conc_benef.dt_fim) then
				ergon_erro_pack.trata_erro(99,'Pagamento Retroativo - Mês ano Pagamento do pagamento retroativo deverá ser IGUAL ou estar dentro do intervalo da Data Início da Concessão Benefício.');
				return;
			elsif l_conc_benef.dtfim_aux >= l_conc_benef.dtini_aux then --Se a data fim for maior que a data início, verificar se a data fim informada é menor que a
				if (l_conc_benef.dtfim_aux < v_dt_ini_min or l_conc_benef.dtini_aux < v_dt_ini_min) then
					ergon_erro_pack.trata_erro(99,'Não existe parcela para este intervalo de data informada.');
					return;
				else
					--Se todos os parâmetros forem informados certinhos
					l_conc_benef.dtini_atraso := l_conc_benef.dtini_aux;
					l_conc_benef.dtfim_atraso := l_conc_benef.dtfim_aux;
					l_conc_benef.mesano_pag	:= l_conc_benef.dtmesano_aux;
					--v_msg := dialog('Deseja Gerar o Valor Retroativo?' ,'Confirma operação?');
					v_msg := 'S';
					if v_msg = 'S' then
						begin
							PGOV_GERA_VALOR_RETRO_MS605(3,pb_numfunc,pb_numvinc,l_conc_benef.dtini_aux,l_conc_benef.dtfim_aux,null,100,v_erro,v_result,v_mens);
							if v_erro is null then
								l_conc_benef.vl_atraso := v_result;
							else
								ergon_erro_pack.trata_erro(99,v_erro);
								return;
								rollback;
								--clear_form(no_validate);
							end if;
						exception when others then
							ergon_erro_pack.trata_erro(99,'Erro na procedure PGOV_GERA_VALOR_RETRO_MS605. '||sqlerrm);
							return;
						end;
					end if;
				end if;
			end if;
			elsif l_conc_benef.dtini_aux is null or l_conc_benef.dtfim_aux is null or l_conc_benef.mesano_pag is null then
				ergon_erro_pack.trata_erro(99,'Para Gerar Valor Retroativo, os campos do Período Atrasado e Mes ano do pagamento deverão ser informados.');
				return;
			end if;
			elsif l_conc_benef.tipo <> 'ATRASADO MS605' or l_conc_benef.tipo is null then
				ergon_erro_pack.trata_erro(99,'Só é possível Gerar Valor Retroativo para Atrasado MS605!');
				return;
			end if;
		end if;
	end;
end;
/