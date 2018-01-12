prompt ***ATENÇÃO!!!*** Objeto TGRJ_EPB__REGRAS_PENSAO_AL não possui replace e deve ser mesclado manualmente com a versão existente no banco.
create
FUNCTION TGRJ_EPB__REGRAS_PENSAO_AL (
      P_ROW_NEW   IN OUT REGRAS_PENSAO_AL%ROWTYPE,
      P_ROW_OLD   IN REGRAS_PENSAO_AL%ROWTYPE,
      P_INSERTING IN BOOLEAN,
      P_UPDATING  IN BOOLEAN,
      P_DELETING  IN BOOLEAN,
      P_MENS OUT nocopy VARCHAR2 )
    RETURN BOOLEAN
  IS
    --
    reg_vinc vinculos%rowtype;
    reg_pens pensionistas%rowtype;
    v_cpf    number;
    v_cnpj   number;
    V_COUNT  number := 0;
    v_nome_transacao varchar2(1000) := flag_pack.get_transacao;
    V_BASE   NUMBER := 0;
    --
    --MS605
    V_CATEGORIA     VARCHAR2(20);
    V_DT_INI_MIN    DATE;
    V_EXISTE        NUMBER;
    v_cont          number;
    v_terc          varchar2(1);

  BEGIN
  --
  RETURN(TRUE);
  --Se transação for diferente do MS605, NÃO poderá realizar transação do MS605.
  --LUANA 23/03/2016. SGD 1543.
  IF FLAG_PACK.GET_TRANSACAO NOT IN ('Regras de Pensão MS605', 'RJadm00068') THEN

     IF P_ROW_OLD.BASE IN ('PENSÃO AL MS605','BLOQ JUD MS605') THEN
        P_MENS := 'Para realizar transações do MS605, deve ser utilizado o módulo MS605. Favor procurar setor CICJ.';
        return (true);
     ELSIF P_ROW_NEW.BASE IN ('PENSÃO AL MS605','BLOQ JUD MS605') THEN
        P_MENS := 'Para realizar transações do MS605, deve ser utilizado o módulo MS605. Favor procurar setor CICJ.';
        return (true);
     END IF;

  END IF;
  --
  IF P_INSERTING OR
     P_DELETING  OR
     P_UPDATING  THEN
     --
     -- Validação do acesso transversal
     -- Usuários "Previdenciarios" somente poderão atualizar dados de funcinarios inativos ou falecidos
     -- Usuários "Não Previdenciarios" somente poderão atualizar dados de funcinarios ativos
     -- Usuários "Privilegiados" poderão acessar qualquer funcionarios, ou seja, ativos, inativos e falecidos
     --
     DECLARE
       --
       V_DML       CHAR(1)                             DEFAULT NULL;
       --
     BEGIN
       IF P_INSERTING  THEN V_DML := 'I'; END IF;
       IF P_UPDATING   THEN V_DML := 'U'; END IF;
       IF P_DELETING   THEN V_DML := 'D'; END IF;
       --
       P_MENS := VERIFICA_TABELAS_ERGON(V_DML,'REGRAS_PENSAO_AL',NVL(P_ROW_NEW.NUMFUNC,P_ROW_OLD.NUMFUNC), NVL(P_ROW_NEW.NUMVINC,P_ROW_OLD.NUMVINC), NULL, NULL);
       --
     END;
  END IF;
  --
  --

    -- VERIFICAR SE O VINCULO ¿¿FALECIDO
    IF p_inserting OR p_updating THEN
      /*Allan 08/08/2013*/
      /*Allan 04/06/2014 Incluída a base BLOQ JUD SERV FALEC no teste a pedido da Vera*/


      /*IF (p_row_new.base IS NOT NULL AND p_row_new.base <> 'ENCERRAMENTO FOLHA')AND
         (p_row_new.base IS NOT NULL AND p_row_new.base <> 'BLOQ JUD SERV FALEC')
         AND P_ROW_NEW.Flex_Campo_03 is null --Quando flex_campo_03 é nulo não é terceiro
          THEN*/

       --Inserido por Rodrigo Machado em 15/05/2015, assim basta inserir as bases na tabela CERG_BASE_PENSAO_AL
       --sem necessidade de modificação de código. SGD 2027
       SELECT COUNT(1)
        INTO V_BASE
        FROM ITEMTABELA
       WHERE TAB = 'CERG_BASE_PENSAO_AL'
         AND ITEM = p_row_new.base;

      IF V_BASE = 0 THEN

        IF p_row_new.dtini <> trunc(p_row_new.dtini,'MM') THEN
           p_mens := 'Data Inicial da Regra Inválida!. Calculo para regras de pensão apenas para  mê integral. ';
        ELSIF p_row_new.dtfim <> LAST_DAY(p_row_new.dtfim) THEN
           p_mens := 'Data Final da Regra Inválida!. Calculo para regras de pensão apenas para mês integral. ';
        END IF;
      END IF;

      SELECT *
      INTO reg_vinc
      FROM VINCULOS
      WHERE NUMFUNC                 = p_row_new.NUMFUNC
      AND numero                    = p_row_new.numvinc;
      --
      IF (reg_vinc.dtvac            IS NOT NULL  and p_row_new.dtini > reg_vinc.dtvac )
        AND reg_vinc.formavac = pack_hades.get_opcao ('Ergon','ERGON','VAC_FALEC') THEN
        --
        IF p_row_new.flex_campo_03 IS NULL THEN
          p_mens                   := 'Servidor Falecido, informe para qual Pensionista ser¿¿esconto de Pens¿¿Alimento!';
        ELSE
          BEGIN
            SELECT *
            INTO reg_pens
            FROM pensionistas
            WHERE numfunc = p_row_new.numfunc
            AND numvinc   = p_row_new.numvinc
            AND numero    = to_number(p_row_new.flex_campo_03);
          EXCEPTION
          WHEN no_data_found THEN
            p_mens := 'Pensionista informado não cadastrado!';
          WHEN OTHERS THEN
            p_mens := 'Erro verificando pensionista selecionado. Informe ao Analista de Sistemas.';
          END;
        END IF;
      END IF;

      --Modificado por Rodrigo Machado com o intuito de tratar o CPNJ e CPF
      --tanto do terceiro quanto de PA genericamente. EM 20/09/2012.
      if pack_hades.get_opcao ('C_Ergon','GOVRJ','CNPJ_CPF_DEPENDENTE') = 'S'
      THEN
         --if P_ROW_NEW.base in ('REPASSE A TERCEIRO','REPASSE A TERCEIRO %')
         -- Hor¿¿o em 20/09/12. As bases acima foram removidas por Solange.
         -- As bases que devem ser consideradas s¿¿as abaixo.
         -- Deve ter mais uma que ainda n¿¿foi criada.
         if P_ROW_NEW.base in ('BLOQ JUD REMUN','BLOQ JUD V FIXO','BLOQ JUD SERV FALEC')
         THEN

          BEGIN
           SELECT CPF, FLEX_CAMPO_02
             INTO v_cpf, v_cnpj
            FROM DEPENDENTES
           WHERE numfunc = p_row_new.numfunc
             AND numero = p_row_new.numdep;

           IF v_cpf IS NULL AND v_cnpj IS NULL THEN
              P_MENS := 'Regra para terceiros favor informar ou CPF ou CNPJ do Terceiro'  ;
           END IF;

          EXCEPTION
             WHEN NO_DATA_FOUND THEN
               P_MENS := 'Dependente n¿¿cadastrado.';
             WHEN OTHERS THEN
               P_MENS := 'Erro n¿¿espeado: '||SQLERRM(SQLCODE);

          END;

         else

           --Feito por Rodrigo Machado em 16/05/2014 conforme SGD 1432
           --A data 01/01/2014 somente foi colocada para fazer a compara¿¿ quando o valor nulo
           IF NVL(P_ROW_NEW.DTFIM,TO_DATE('01/01/2014','DD/MM/YYYY')) = NVL(P_ROW_OLD.DTFIM,TO_DATE('01/01/2014','DD/MM/YYYY')) THEN

                BEGIN
                SELECT CPF
                  INTO v_cpf
                 FROM DEPENDENTES
                WHERE numfunc = p_row_new.numfunc
                  AND numero = p_row_new.numdep;

                IF v_cpf IS NULL THEN

                      SELECT COUNT(1)
                      INTO V_COUNT
                      FROM ERG_REPRES_LEGAL ER,
                           ERG_DEPEN_REPR   ED
                     WHERE ER.NUMERO = ED.NUMREP
                       AND ED.NUMDEP = p_row_new.numdep
                       AND ED.NUMFUNC = p_row_new.numfunc
                       AND ED.RECEBE_CREDITO = 'S'
                       AND ER.CPF IS NOT NULL;

                   IF V_COUNT = 0 AND UPPER(v_nome_transacao) <> 'REGRA DE BLOQUEIO OU REPASSE' THEN
                     --Modificado conforme SGD 872 por Rodrigo Machado em 09/07/2013.
                     --IF NVL(P_ROW_OLD.DTFIM,'01/01/1900') = NVL(P_ROW_NEW.DTFIM,'01/01/1900') THEN
                       P_MENS := 'Regra para PA favor informar o CPF do Dependente ou Representante Legal' ;
                     --END IF;
                   END IF;
                END IF;

               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    P_MENS := 'Dependente não cadastrado.';
                  WHEN OTHERS THEN
                    P_MENS := 'Erro não espeado: '||SQLERRM(SQLCODE);

               END;

          END IF;

         END IF;

      END IF;

    END IF;
    --
    /*====================================================================================
       Regra: O cadastro de Regras só é permitido para categoria de Auditor Fiscal da
       Fazenda do Estado do Rio de Janeiro. LUANA 29/07/2015. SGD 1543.
      ======================================================================================*/
    if FLAG_PACK.GET_TRANSACAO IN ('Regras de Pensão MS605', 'RJadm00068') then

      if p_inserting OR p_updating then
         --
         begin
            select categoria
              into v_categoria
              from vinculos
             where numfunc = p_row_new.numfunc
              and numero   = p_row_new.numvinc;
         exception
            when no_data_found then
               v_categoria := null;
         end;
         --
         if v_categoria <> '09 AUDITOR FISCAL' then

            p_mens := 'As Pensões Alimentícias MS605 só estão disponíveis para servidores com vínculo de Auditor Fiscal da Fazenda do Estado do Rio de Janeiro.';

         end if;
         --
         --Busca a menor data da tabela de parcelas_ms605
         begin
            select min(dt_ini)
                  into v_dt_ini_min
                  from pgov_parcelas_ms605
                 where numfunc = p_row_new.numfunc
                   and numvinc = p_row_new.numvinc
                   order by dt_ini;
         exception when others then
            v_dt_ini_min := null;
         end;
         --
         --Verifica se o instituidor está com benefício "ATIVO" para gerar valor retroativo.
         begin
            select 1
              into v_existe
              from pgov_beneficios_ms605
             where numfunc      = p_row_new.numfunc
               and numvinc      = p_row_new.numvinc
               and st_beneficio = 'A'
               and dt_fim is null;
         exception
            when no_data_found then
               v_existe := 0;
         end;
         --
         --Verifica se existe a regra possui benefício com a situação "ATIVO"
         if v_existe = 0 then

            p_mens := 'A Regra só poderá ser gerada para benefícios ativos.';

         end if;
         --
         --Verifica se o dependente é TERCEIRO
         begin
            select 'S'
              into v_terc
              from dependentes
             where numfunc       = p_row_new.numfunc
               and numero        = p_row_new.numdep
               and upper(flex_campo_03) = 'TERCEIRO';
         exception
            when no_data_found then
               v_terc := 'N';
         end;
         --
         -- Se for dependente TERCEIRO, então gerar regra somente para BLOQ JUD MS605, senão gerar somente regra para PENSÃO AL MS605.
         if v_terc = 'S' and p_row_new.base <> 'BLOQ JUD MS605' then

            p_mens := 'Para Terceiro a regra só permite tipo de base BLOQ JUD MS605.'||p_row_new.flex_campo_23||' '||p_row_new.flex_campo_22;

         elsif v_terc = 'N' and p_row_new.base <> 'PENSÃO AL MS605' then

            p_mens := 'Para diferente de Terceiro a regra só permite tipo de base PENSÃO AL MS605.'||p_row_new.flex_campo_23||' '||p_row_new.flex_campo_22;

         end if;
         --
         if to_date(p_row_new.flex_campo_23,'dd/mm/yyyy') < to_date(p_row_new.flex_campo_22,'dd/mm/yyyy') then

            p_mens := 'Pagamento Retroativo - Data Fim do Período do Atrasado não pode ser MENOR que Data Início do Período do Atrasado. '||p_row_new.flex_campo_23||' '||p_row_new.flex_campo_22;

         elsif to_date(p_row_new.flex_campo_22,'dd/mm/yyyy') >= p_row_new.dtini then

            p_mens := 'Pagamento Retroativo - Data Início do Período do Atrasado deverá ser MENOR que a Data Início da Pensão.';

         elsif to_date(p_row_new.flex_campo_23,'dd/mm/yyyy') >= p_row_new.dtini then

            p_mens := 'Pagamento Retroativo - Data Fim do Período do Atrasado deverá ser MENOR que a Data Início da Pensão.';

         elsif (to_date(p_row_new.flex_campo_21,'dd/mm/yyyy') < p_row_new.dtini or to_date(p_row_new.flex_campo_21,'dd/mm/yyyy') > p_row_new.dtfim) then

            p_mens := 'Pagamento Retroativo - Mês ano Pagamento do pagamento retroativo deverá ser IGUAL ou estar dentro do intervalo da Data Início da Pensão e Data Fim da Pensão. Favor verificar! ';

         end if;
         --
         if p_row_new.flex_campo_17 is null then
            --
            if p_row_new.flex_campo_22 is not null or p_row_new.flex_campo_23 is not null or p_row_new.flex_campo_21 is not null then

               p_mens := 'Não foi gerado valor retroativo. Favor verificar!';

            end if;

         else

            if p_row_new.flex_campo_22 is null then

               p_mens := 'Pagamento Retroativo - Data Início deverá ser preenchida.';

            elsif p_row_new.flex_campo_23 is null then

               p_mens := 'Pagamento Retroativo - Data Fim deverá ser preenchida.';

            elsif p_row_new.flex_campo_21 is null then

               p_mens := 'Mês ano pagamento deverá ser preenchido.';

            elsif to_date(p_row_new.flex_campo_23,'dd/mm/yyyy') > to_date(p_row_new.flex_campo_22,'dd/mm/yyyy')then

               if (p_row_new.flex_campo_22 < v_dt_ini_min or p_row_new.flex_campo_23 < v_dt_ini_min)then

                  p_mens := 'Não existe intervalo para esta data informada. '||v_dt_ini_min;

               end if;

            end if;
         end if;
         --
         if p_row_new.percentual is null then

            p_mens := 'O percentual deve ser informado para o sistema realizar o cálculo do pagamento.';

         end if;
         --
         if p_row_new.base = 'BLOQ JUD MS605' and v_terc = 'S' then

            if p_row_new.flex_campo_12 is null then

               p_mens := 'Para tipo pensão BLOQ JUD MS605, o valor divida bloqueio deverá ser informado. ';

            end if;

         end if;
      end if;
      --
      --Esta alteração tem por objetivo inserir, atualizar ou deletar registros
      --na tabela pgov_saldo_bloq_ms605, referente ao bloqueio judicial que
      --incluímos na tabela regras_pensao_al. LUANA 17/07/2015.
      --if FLAG_PACK.GET_TRANSACAO = 'Regra de Bloqueio ou Repasse' then

      --Verifica registro na pgov_saldo_bloq_ms605
      begin
         select 1
           into v_cont
           from pgov_saldo_bloq_ms605
          where numfunc        = p_row_new.numfunc
            and numvinc        = p_row_new.numvinc
            and numdep         = p_row_new.numdep
            and dt_ini         = p_row_old.dtini
            and nome_beneficio = 'MS605';
      exception when no_data_found then
         v_cont := 0;
      end;
      --
      if p_inserting then

         --Verifica categoria
         begin
            select categoria
              into v_categoria
              from vinculos
             where numfunc = p_row_new.numfunc
               and numero  = p_row_new.numvinc;
         exception
            when no_data_found then
               v_categoria := null;
         end;
         --
         if p_row_new.base = 'BLOQ JUD MS605' and v_categoria = '09 AUDITOR FISCAL' then

            begin
               insert into pgov_saldo_bloq_ms605 (numfunc, numvinc, numdep, nome_beneficio, vl_saldo, dt_ini, dt_fim,
                                                  dtatualizacao)
                     values (p_row_new.numfunc, p_row_new.numvinc, p_row_new.numdep, 'MS605', p_row_new.flex_campo_12,
                             p_row_new.dtini, p_row_new.dtfim, p_row_new.dtini);
            exception
               when others then
                  p_mens := 'Erro ao inserir registro '||sqlerrm;
            end;

         end if;

      elsif p_updating then

         --Verifica categoria
         begin
            select categoria
              into v_categoria
              from vinculos
             where numfunc = p_row_old.numfunc
               and numero  = p_row_old.numvinc;
         exception
            when no_data_found then
               v_categoria := null;
         end;
         --
         --NÃO haverá mais atualização na tabela pgov_saldo_bloq_ms605 pela tela Regras de Pensão
         --alimentícia MS605, somente pela rotina do Guilherme. Luana 01/03/2016. SGD2656.
         /*if v_cont = 1 and p_row_old.base = p_row_new.base and v_categoria = '09 AUDITOR FISCAL' then

            begin
               update pgov_saldo_bloq_ms605
                  set dt_fim         = p_row_new.dtfim,
                      vl_saldo       = p_row_new.flex_campo_12,
                      dt_ini         = p_row_new.dtini,
                      dtatualizacao  = p_row_new.dtini
                 where numfunc        = p_row_old.numfunc
                   and numvinc        = p_row_old.numvinc
                   and numdep         = p_row_old.numdep
                   and dt_ini         = p_row_old.dtini
                   and nome_beneficio = 'MS605';
            exception when others then
               p_mens := 'Erro ao atualizar registro '||sqlerrm;
            end;*/

         if v_cont = 1 and p_row_old.base <> p_row_new.base and v_categoria = '09 AUDITOR FISCAL' then --Quando existir registro, mas se for ALTERADA para outra base
                                                                                                       --então deletar da pgov_saldo_bloq_ms605.
            begin
               delete from pgov_saldo_bloq_ms605
                      where numfunc        = p_row_old.numfunc
                        and numvinc        = p_row_old.numvinc
                        and numdep         = p_row_old.numdep
                        and dt_ini         = p_row_old.dtini
                        and nome_beneficio = 'MS605';
            exception when others then
               p_mens := 'Erro ao excluir registro '||sqlerrm;
            end;

         elsif v_cont = 0 and p_row_new.base = 'BLOQ JUD MS605' and v_categoria = '09 AUDITOR FISCAL' then --Quando NÃO existir registro, mas se for ALTERADA para a
                                                                                                           --base 'BLOQ JUD MS605' então inserir na pgov_saldo_bloq_ms605.
            begin
               insert into pgov_saldo_bloq_ms605 (numfunc, numvinc, numdep, nome_beneficio, vl_saldo, dt_ini, dt_fim,
                                                  dtatualizacao)
                    values (p_row_new.numfunc, p_row_new.numvinc, p_row_new.numdep, 'MS605', p_row_new.flex_campo_12,
                            p_row_new.dtini, p_row_new.dtfim, p_row_new.dtini);
            exception
               when others then
                  p_mens := 'Erro ao inserir registro '||sqlerrm;
            end;

         end if;

      elsif p_deleting then

         --Verifica categoria
         begin
            select categoria
              into v_categoria
              from vinculos
             where numfunc = p_row_old.numfunc
               and numero  = p_row_old.numvinc;
         exception
            when no_data_found then
               v_categoria := null;
         end;
         --
         if v_categoria = '09 AUDITOR FISCAL' then

            begin
               delete from pgov_saldo_bloq_ms605
                     where numfunc        = p_row_old.numfunc
                       and numvinc        = p_row_old.numvinc
                       and numdep         = p_row_old.numdep
                       and dt_ini         = p_row_old.dtini
                       and nome_beneficio = 'MS605';
            exception when others then
               p_mens := 'Erro ao excluir registro '||sqlerrm;
            end;
         end if;
      end if;
   end if;--LUANA 29/07/2015.
    --
    RETURN (TRUE);
  END TGRJ_EPB__REGRAS_PENSAO_AL;
/