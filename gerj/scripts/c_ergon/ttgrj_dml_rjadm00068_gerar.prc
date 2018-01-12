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

   --Verifica se o instituidor est� com benef�cio "ATIVO" para gerar valor retroativo. 
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
   --preenchimentos dos par�metros caso o usu�rio clique logo no bot�o "Gerar Valor Retroativo". 
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
--         alerta('Data Fim inv�lida.');
--         raise FORM_TRIGGER_FAILURE;
         p_mens := 'Data Fim inv�lida.';
         return;         
      end if;    	 
	 end if;  
   --      
   --Verifica se o instituidor est� com benef�cio "ATIVO" para gerar valor retroativo. 
   if v_existe = 0 then    	
--      alerta('A Regra s� poder� ser gerada para benef�cios ATIVOS.');	
      p_mens := 'A Regra s� poder� ser gerada para benef�cios ATIVOS.';
      return;
   --Verifica se o instituidor est� com benef�cio "ATIVO" para gerar valor retroativo e se o tipo de pens�o � 'PENS�O MS605'.    
   elsif v_existe = 1 and l_regras_pensao.tipopens in ('PENS�O MS605', 'BLOQUEIO JUD MS605') then 

      if l_regras_pensao.flex_campo_22 is not null and l_regras_pensao.flex_campo_23 is not null and l_regras_pensao.flex_campo_20 is not null and l_regras_pensao.dtini is not null and l_regras_pensao.percentual is not null then 	
         --  
         --Mudan�a de Regra: As datas do per�odo Retroativo dever�o ser menores que as datas informadas da pens�o. Solicitado por Ros�ngela. 19/05/2015.        

         if l_regras_pensao.dtfim < l_regras_pensao.dtini then
--            alerta('Data Fim da Pens�o n�o pode ser menor que Data In�cio da Pens�o. ');     
            p_mens := 'Data Fim da Pens�o n�o pode ser menor que Data In�cio da Pens�o. ';
            return;
         elsif l_regras_pensao.dtfim_aux_23 < l_regras_pensao.dtini_aux_22 then
--            alerta('Pagamento Retroativo - Data fim do Per�odo do Atrasado n�o pode ser MENOR que Data In�cio do Per�odo do Atrasado.');
--            go_item('l_regras_pensao.dtfim_aux_23'); 
            p_mens := 'Pagamento Retroativo - Data fim do Per�odo do Atrasado n�o pode ser MENOR que Data In�cio do Per�odo do Atrasado.';
            return;
         elsif l_regras_pensao.dtini_aux_22 >= l_regras_pensao.dtini then   
            p_mens := 'Pagamento Retroativo - Data In�cio do Per�odo do Atrasado dever� ser MENOR que a Data In�cio da Pens�o.';
            return;
--            alerta('Pagamento Retroativo - Data In�cio do Per�odo do Atrasado dever� ser MENOR que a Data In�cio da Pens�o.');   
         elsif l_regras_pensao.dtfim_aux_23 >= l_regras_pensao.dtini then  
            p_mens := 'Pagamento Retroativo - Data Fim do Per�odo do Atrasado dever� ser MENOR que a Data In�cio da Pens�o.';
            return;
--             alerta('Pagamento Retroativo - Data Fim do Per�odo do Atrasado dever� ser MENOR que a Data In�cio da Pens�o.');	    
         elsif (l_regras_pensao.dtmesano_aux_20 < l_regras_pensao.dtini or l_regras_pensao.dtmesano_aux_20 > l_regras_pensao.dtfim) then
            p_mens := 'Pagamento Retroativo - M�s ano Pagamento do pagamento retroativo dever� ser IGUAL ou estar dentro do intervalo da Data In�cio da Pens�o e Data Fim da Pens�o. Favor verificar! ';
            return;
--            alerta('Pagamento Retroativo - M�s ano Pagamento do pagamento retroativo dever� ser IGUAL ou estar dentro do intervalo da Data In�cio da Pens�o e Data Fim da Pens�o. Favor verificar! ');         	
         --Se a data fim for maior que a data in�cio (que est� certo), verificar se a data fim informada � menor que a data da tabela de parcelas, 
         --para saber se est� dentro do intervalo v�lido.           
         --   
         elsif l_regras_pensao.dtfim_aux_23 >= l_regras_pensao.dtini_aux_22 then 
            if (l_regras_pensao.dtfim_aux_23 < v_dt_ini_min or l_regras_pensao.dtini_aux_22 < v_dt_ini_min) then 
         	     --
--         	     alerta('N�o existe intervalo para este per�odo informado em PARCELAS MS605.'); 
         	     --
                 p_mens := 'N�o existe intervalo para este per�odo informado em PARCELAS MS605.';
                 return;
            else             	
				--Se todos os par�metros forem informados certinhos
                --               
--               l_regras_pensao.flex_campo_22 := to_char(l_regras_pensao.dtini_aux_22,'DD/MM/RRRR');   
--               l_regras_pensao.flex_campo_23 := to_char(l_regras_pensao.dtfim_aux_23,'DD/MM/RRRR');
--               l_regras_pensao.flex_campo_20 := to_char(l_regras_pensao.dtmesano_aux_20,'DD/MM/RRRR');                        
               --	      	
--      	       v_msg := dialog('Deseja Gerar o Valor Retroativo ?' ,'Confirma opera��o?');
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
--         alerta('Para Gerar Valor Retroativo, os campos Data In�cio da Pens�o, Percentual, Per�odo do Atrasado e Mes ano do pagamento dever�o ser informados.'); 
        p_mens := 'Para Gerar Valor Retroativo, os campos Data In�cio da Pens�o, Percentual, Per�odo do Atrasado e Mes ano do pagamento dever�o ser informados.';
        return;
      end if;
   elsif l_regras_pensao.tipopens not in ('PENS�O MS605', 'BLOQUEIO JUD MS605') then
--      alerta('S� � poss�vel Gerar Valor Retroativo para tipo pens�o PENS�O MS605 ou BLOQUEIO JUD MS605');  
        p_mens := 'S� � poss�vel Gerar Valor Retroativo para tipo pens�o PENS�O MS605 ou BLOQUEIO JUD MS605';
        return;
   end if;	   
  end;
end;
/