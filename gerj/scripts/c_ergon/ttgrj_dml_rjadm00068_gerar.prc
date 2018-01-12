create or replace procedure ttgrj_dml_rjadm00068_Gerar
  ( 
    pb_numfunc in regras_pensao.numfunc%type default null,
    pb_numvinc in regras_pensao.numvinc%type default null,
    pb_numpens in regras_pensao.numpens%type default null,
    p_mens out varchar2
  ) 
is 
  v_erro        varchar2(2000);
  v_result      number;
  v_msg         varchar2(200);
  v_dt_ini_min  date;
  v_mens        varchar2(100);
  v_existe      number;
  v_dt_ini_max  date;
  v_dt_fim_max  date;
begin	   

DECLARE
  CURSOR c_regras_pensao is
    select numfunc, numvinc, tipopens, dtini, dtfim, percentual,
      numpens,                                to_date(dtfim, 'dd/MM/yyyy') as dtfim_aux,
      flex_campo_19, flex_campo_20, flex_campo_22, flex_campo_23,
      to_date(flex_campo_20, 'dd/MM/yyyy') as dtmesano_aux_20, to_date(flex_campo_22, 'dd/MM/yyyy') as dtini_aux_22, to_date(flex_campo_23, 'dd/MM/yyyy') as dtfim_aux_23
    from regras_pensao
       where numfunc = pb_numfunc 
         and numvinc = pb_numpens
         and numpens = pb_numpens;

    l_regras_pensao c_regras_pensao%rowtype;
  BEGIN
  OPEN c_regras_pensao;  
  LOOP
    EXIT WHEN c_regras_pensao%NOTFOUND;
    FETCH c_regras_pensao INTO l_regras_pensao;
  END LOOP;
  CLOSE c_regras_pensao;

   --Verifica se o instituidor está com benefício "ATIVO" para gerar valor retroativo. 
   begin
	    select 1
	      into v_existe
	      from pgov_beneficios_ms605
	     where numfunc      = l_regras_pensao.numfunc
	       and numvinc      = l_regras_pensao.numvinc
	       and st_beneficio = 'A'  
	       and dt_fim is null;
   exception
      when no_data_found then
         v_existe := 0;
   end;
   --Busca a menor data da tabela de parcelas_ms605
   begin
	    select min(dt_ini)
        into v_dt_ini_min
        from pgov_parcelas_ms605
       where numfunc = l_regras_pensao.numfunc
         and numvinc = l_regras_pensao.numvinc             
       order by dt_ini; 
   exception when others then
      v_dt_ini_min := null;     
   end;             
   --  
   --preenchimentos dos parâmetros caso o usuário clique logo no botão "Gerar Valor Retroativo". 
   if l_regras_pensao.dtini_aux_22 is null then
      l_regras_pensao.flex_campo_22 := null;   
   else
     l_regras_pensao.flex_campo_22 := to_char(l_regras_pensao.dtini_aux_22,'DD/MM/RRRR');	  
   end if;
   --
   if l_regras_pensao.dtfim_aux_23 is null then
      l_regras_pensao.flex_campo_23 := null;
   else
      l_regras_pensao.flex_campo_23 := to_char(l_regras_pensao.dtfim_aux_23,'DD/MM/RRRR');	  
   end if;
   --
   if l_regras_pensao.dtmesano_aux_20 is null then
	    l_regras_pensao.flex_campo_20 := null; 
   else
      l_regras_pensao.flex_campo_20 := to_char(l_regras_pensao.dtmesano_aux_20,'DD/MM/RRRR');	 
   end if;
   --
	 if l_regras_pensao.dtfim_aux is null then
	    l_regras_pensao.dtfim := null;  
	 else
	    l_regras_pensao.dtfim := pack_hades.format_data(l_regras_pensao.dtfim_aux);	    
      if l_regras_pensao.dtfim is null then
--         alerta('Data Fim inválida.');
--         raise FORM_TRIGGER_FAILURE;
         p_mens := 'Data Fim inválida.';
         return;         
      end if;    	 
	 end if;  
   --      
   --Verifica se o instituidor está com benefício "ATIVO" para gerar valor retroativo. 
   if v_existe = 0 then    	
--      alerta('A Regra só poderá ser gerada para benefícios ATIVOS.');	
      p_mens := 'A Regra só poderá ser gerada para benefícios ATIVOS.';
      return;
   --Verifica se o instituidor está com benefício "ATIVO" para gerar valor retroativo e se o tipo de pensão é 'PENSÃO MS605'.    
   elsif v_existe = 1 and l_regras_pensao.tipopens in ('PENSÃO MS605', 'BLOQUEIO JUD MS605') then 

      if l_regras_pensao.flex_campo_22 is not null and l_regras_pensao.flex_campo_23 is not null and l_regras_pensao.flex_campo_20 is not null and l_regras_pensao.dtini is not null and l_regras_pensao.percentual is not null then 	
         --  
         --Mudança de Regra: As datas do período Retroativo deverão ser menores que as datas informadas da pensão. Solicitado por Rosângela. 19/05/2015.        

         if l_regras_pensao.dtfim < l_regras_pensao.dtini then
--            alerta('Data Fim da Pensão não pode ser menor que Data Início da Pensão. ');     
            p_mens := 'Data Fim da Pensão não pode ser menor que Data Início da Pensão. ';
            return;
         elsif l_regras_pensao.dtfim_aux_23 < l_regras_pensao.dtini_aux_22 then
--            alerta('Pagamento Retroativo - Data fim do Período do Atrasado não pode ser MENOR que Data Início do Período do Atrasado.');
--            go_item('l_regras_pensao.dtfim_aux_23'); 
            p_mens := 'Pagamento Retroativo - Data fim do Período do Atrasado não pode ser MENOR que Data Início do Período do Atrasado.';
            return;
         elsif l_regras_pensao.dtini_aux_22 >= l_regras_pensao.dtini then   
            p_mens := 'Pagamento Retroativo - Data Início do Período do Atrasado deverá ser MENOR que a Data Início da Pensão.';
            return;
--            alerta('Pagamento Retroativo - Data Início do Período do Atrasado deverá ser MENOR que a Data Início da Pensão.');   
         elsif l_regras_pensao.dtfim_aux_23 >= l_regras_pensao.dtini then  
            p_mens := 'Pagamento Retroativo - Data Fim do Período do Atrasado deverá ser MENOR que a Data Início da Pensão.';
            return;
--             alerta('Pagamento Retroativo - Data Fim do Período do Atrasado deverá ser MENOR que a Data Início da Pensão.');	    
         elsif (l_regras_pensao.dtmesano_aux_20 < l_regras_pensao.dtini or l_regras_pensao.dtmesano_aux_20 > l_regras_pensao.dtfim) then
            p_mens := 'Pagamento Retroativo - Mês ano Pagamento do pagamento retroativo deverá ser IGUAL ou estar dentro do intervalo da Data Início da Pensão e Data Fim da Pensão. Favor verificar! ';
            return;
--            alerta('Pagamento Retroativo - Mês ano Pagamento do pagamento retroativo deverá ser IGUAL ou estar dentro do intervalo da Data Início da Pensão e Data Fim da Pensão. Favor verificar! ');         	
         --Se a data fim for maior que a data início (que está certo), verificar se a data fim informada é menor que a data da tabela de parcelas, 
         --para saber se está dentro do intervalo válido.           
         --   
         elsif l_regras_pensao.dtfim_aux_23 >= l_regras_pensao.dtini_aux_22 then 
            if (l_regras_pensao.dtfim_aux_23 < v_dt_ini_min or l_regras_pensao.dtini_aux_22 < v_dt_ini_min) then 
         	     --
--         	     alerta('Não existe intervalo para este período informado em PARCELAS MS605.'); 
         	     --
                 p_mens := 'Não existe intervalo para este período informado em PARCELAS MS605.';
                 return;
            else             	
				--Se todos os parâmetros forem informados certinhos
                --               
--               l_regras_pensao.flex_campo_22 := to_char(l_regras_pensao.dtini_aux_22,'DD/MM/RRRR');   
--               l_regras_pensao.flex_campo_23 := to_char(l_regras_pensao.dtfim_aux_23,'DD/MM/RRRR');
--               l_regras_pensao.flex_campo_20 := to_char(l_regras_pensao.dtmesano_aux_20,'DD/MM/RRRR');                        
               --	      	
--      	       v_msg := dialog('Deseja Gerar o Valor Retroativo ?' ,'Confirma operação?');
                   v_msg := 'S';
      	       --
      	       if v_msg = 'S' then    
                  begin
                     --alerta(:block_vinc.numfunc||' '||:block_vinc.numvinc||' '||:l_regras_pensao.dtini_aux_22)||' '||:l_regras_pensao.dtfim_aux_23||' '||:l_regras_pensao.numpens);
--                     PGOV_GERA_VALOR_RETRO_MS605(1,:block_vinc.numfunc,:block_vinc.numvinc,:l_regras_pensao.dtini_aux_22,:l_regras_pensao.dtfim_aux_23,:l_regras_pensao.numpens,:l_regras_pensao.percentual,v_erro,v_result,v_mens);                        

                     PGOV_GERA_VALOR_RETRO_MS605(1,l_regras_pensao.numfunc,l_regras_pensao.numvinc,l_regras_pensao.dtini_aux_22,l_regras_pensao.dtfim_aux_23,l_regras_pensao.numpens,l_regras_pensao.percentual,v_erro,v_result,v_mens);

                     if v_erro is null then             	   
            	          l_regras_pensao.flex_campo_19 := trim(TO_CHAR(v_result,'999999D99'));      	          
                     else
--               	        alerta(v_erro); 
                        p_mens := v_erro;
                        rollback;
                        return;
--               	        forms_ddl('rollback');
                       -- clear_form(no_validate);
                     end if; 
                     --
                  exception when others then
--                     alerta('Erro na procedure PGOV_GERA_VALOR_RETRO_MS605. '||sqlerrm);
                        p_mens := 'Erro na procedure PGOV_GERA_VALOR_RETRO_MS605. '||sqlerrm;
                        return;
                  end;             
         	     end if;  
         	   end if;   
         end if;       	
      elsif l_regras_pensao.dtini_aux_22 is null or l_regras_pensao.dtfim_aux_23 is null or l_regras_pensao.flex_campo_20 is null or l_regras_pensao.percentual is null then 	
--         alerta('Para Gerar Valor Retroativo, os campos Data Início da Pensão, Percentual, Período do Atrasado e Mes ano do pagamento deverão ser informados.'); 
        p_mens := 'Para Gerar Valor Retroativo, os campos Data Início da Pensão, Percentual, Período do Atrasado e Mes ano do pagamento deverão ser informados.';
        return;
      end if;
   elsif l_regras_pensao.tipopens not in ('PENSÃO MS605', 'BLOQUEIO JUD MS605') then
--      alerta('Só é possível Gerar Valor Retroativo para tipo pensão PENSÃO MS605 ou BLOQUEIO JUD MS605');  
        p_mens := 'Só é possível Gerar Valor Retroativo para tipo pensão PENSÃO MS605 ou BLOQUEIO JUD MS605';
        return;
   end if;	   
  end;
end;
/