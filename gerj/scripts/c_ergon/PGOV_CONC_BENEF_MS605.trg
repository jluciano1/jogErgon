prompt ***ATENÇÃO!!!*** Objeto PGOV_CONC_BENEF_MS605 não possui replace e deve ser mesclado manualmente com a versão existente no banco.

create TRIGGER "C_ERGON"."PGOV_CONC_BENEF_MS605" 
BEFORE DELETE OR INSERT OR UPDATE
ON PGOV_CONC_BENEF_MS605
REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
  L_            number;
  v_dt_ini_min  date;
  v_count       number;
  v_qtd_a       number;
  v_dt_fim_max  date;
  v_dt_ini_max  date;
  v_dt_min_ini  date;
  v_existe      number;
  v_cont        number(1);
  v_categoria   VARCHAR2(20);
  v_benef       number;
 
BEGIN
--
--Busca a menor data da tabela de parcelas_ms605
   begin
      select min(dt_ini)
        into v_dt_ini_min
        from pgov_parcelas_ms605
       where numfunc = :old.numfunc
         and numvinc = :old.numvinc
       order by dt_ini;
   exception when others then
      v_dt_ini_min := null;
   end;
  --
--Verifica se existe data em aberto para o tipo "MENSAL MS605" ou "ATRASADO MS605"
   /*begin
      select count(*)
        into v_count
        from pgov_conc_benef_ms605
       where numfunc = :new.numfunc
         and numvinc = :new.numvinc
         and tipo    = :new.tipo
         and dt_fim is null;
   exception when no_data_found then
      v_count := 0;
   end;*/
   --
---Busca a última data fim da conc_beneficio
   begin
      select max(dt_fim), min(dt_ini), max(dt_ini)
        into v_dt_fim_max, v_dt_min_ini, v_dt_ini_max
        from pgov_conc_benef_ms605
       where numfunc = :new.numfunc
         and numvinc = :new.numvinc
         and tipo    = :new.tipo;
   end;
   --
   begin
      select count(1)
        into v_cont
        from pgov_conc_benef_ms605
       where numvinc  = :new.numvinc
         and numfunc  = :new.numfunc
         and tipo     = :new.tipo
         and pack_hades.eh_concomitante(:new.dt_ini, :new.dt_fim, dt_ini, dt_fim) = 1
         and dt_ini    <> :new.dt_ini;
   end;
   --  
   L_ := 30;
   --
IF FLAG_PACK.GET_TRANSACAO in ('Dados do Benefício MS605', 'RJadm00069') THEN      
   IF (INSERTING) THEN
      --
      L_ := 40;
      --
      begin
         select 1
           into v_existe
           from pgov_beneficios_ms605
          where numfunc      = :new.numfunc
            and numvinc      = :new.numvinc
            and st_beneficio = 'A'  
            and dt_fim is null;
      exception
         when no_data_found then
            v_existe := 0;
      end;
      --Verifica se existe benefício com a situação "ATIVO"
      if v_existe = 0 then
         
         raise_application_error(-20001,'A Concessão de Benefícios só poderá ser gerada para benefícios ativos.');
        
      end if;      
      --
      BEGIN
         SELECT CATEGORIA
           INTO V_CATEGORIA
           FROM VINCULOS
          WHERE NUMFUNC = :NEW.NUMFUNC
            AND NUMERO  = :NEW.NUMVINC;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            V_CATEGORIA := NULL;
      END;
      --Verifica se categoria do instituidor é 09 AUDITOR FISCAL.
      IF V_CATEGORIA <> '09 AUDITOR FISCAL' THEN
         raise_application_error(-20001,'O Tipo de concessão MS605 só é permitido para servidores/impetrantes com categoria de Auditor Fiscal da Fazenda do Estado do Rio de Janeiro.');     
      END IF;
      --      
      IF (:NEW.DT_FIM < :NEW.DT_INI)THEN
         raise_application_error(-20001,' ATENÇÃO! Data fim do Benefício não pode ser MENOR que data início! '||L_);
      ELSIF :NEW.TIPO IS NULL THEN
         raise_application_error(-20001,' ATENÇÃO! O Tipo de Benefício deverá ser informado! '||L_);
      ELSIF :NEW.DT_INI IS NULL THEN
         raise_application_error(-20001,' ATENÇÃO! Pagamento Retroativo - Data início deverá ser informada! '||L_);
      ELSIF :NEW.DTINI_ATRASO > sysdate or :NEW.DTFIM_ATRASO > sysdate or :NEW.MESANO_PAG > sysdate THEN
         raise_application_error(-20001,' ATENÇÃO! Pagamento Retroativo - Data não poderá ser MAIOR que a data corrente. Favor verificar! '||L_);
      END IF;
      --
      IF :NEW.VL_ATRASO IS NULL THEN
         --
         IF :NEW.DTINI_ATRASO IS NOT NULL OR :NEW.DTFIM_ATRASO IS NOT NULL OR :NEW.MESANO_PAG IS NOT NULL THEN
            raise_application_error(-20001,' ATENÇÃO! Não foi gerado valor retroativo. Favor verificar! '||L_);
         END IF;
         --
      ELSE
         --
         IF :NEW.DTINI_ATRASO IS NULL THEN
            raise_application_error(-20001,' ATENÇÃO! Pagamento Retroativo - Data Início deverá ser preenchida. '||L_);
         ELSIF :NEW.DTFIM_ATRASO  IS NULL THEN
            raise_application_error(-20001,' ATENÇÃO! Pagamento Retroativo - Data Fim deverá ser preenchida.'||L_);
         ELSIF :NEW.MESANO_PAG IS NULL THEN
            raise_application_error(-20001,' ATENÇÃO! Pagamento Retroativo - Mês ano Pagamento deverá ser preenchido. '||L_);
         ELSIF (:NEW.DTINI_ATRASO < v_dt_ini_min OR :NEW.DTFIM_ATRASO < v_dt_ini_min)THEN
            raise_application_error(-20001,' ATENÇÃO! Não existe intervalo para esta data informada. '||L_);
         END IF;
      END IF;
      --
      IF :NEW.DTFIM_ATRASO < :NEW.DTINI_ATRASO THEN
         raise_application_error(-20001,' ATENÇÃO! Pagamento Retroativo - Data fim não pode ser MENOR que data início! '||L_);
      ELSIF (:NEW.DT_FIM < :NEW.DTINI_ATRASO OR :NEW.DT_FIM < :NEW.DTFIM_ATRASO)THEN
         raise_application_error(-20001,' Data fim do Benefício não pode ser menor que o período do Atrasado em Pagamento Retroativo. Favor verificar! '||L_);
      ELSIF (:NEW.MESANO_PAG < :NEW.DT_INI or :NEW.MESANO_PAG > :NEW.DT_FIM) then
         raise_application_error(-20001,'Pagamento Retroativo - Mês ano Pagamento do pagamento retroativo deverá ser IGUAL ou estar dentro do intervalo da Data Início da Pensão e Data Fim da Pensão. Favor verificar! '||L_);
      END IF;
      --
      --Se existir algum registro em aberto para MENSAL MS605
      IF V_CONT >= 1 THEN
         --ergon_erro_pack.trata_erro (04711);
         raise_application_error(-20001, 'Não é possível criar concessão de benefícios, de mesmo tipo concomitantes, para o mesmo pensionista. '||L_);
      END IF;
      --
      IF (:NEW.TIPO = 'ATRASADO MS605')THEN
         IF (:NEW.DT_FIM IS NULL OR :NEW.DTINI_ATRASO IS NULL OR :NEW.DTFIM_ATRASO IS NULL OR :NEW.MESANO_PAG IS NULL OR :NEW.VL_ATRASO IS NULL)THEN
             raise_application_error(-20001,' ATENÇÃO! Para tipo de concessão "ATRASADO MS605" data início, data fim e dados do pagamento retroativo deverão estar preenchidos e gerado! '||L_);
         END IF;
      END IF;
      --
      --Se data da Concessão for encerrada, e se existir regra de pensão alimentícia aberta para esta concessão
      --então automaticamente encerrará a regra de pensão alimentícia em aberto. LUANA 05/07/2016. SGD 2867.
      IF :NEW.DT_FIM IS NOT NULL THEN
         BEGIN
            FOR R1 IN (SELECT DTFIM, NUMDEP
                        FROM REGRAS_PENSAO_AL
                       WHERE NUMFUNC = :NEW.NUMFUNC
                         AND NUMVINC = :NEW.NUMVINC
                         AND BASE    = 'PENSÃO AL MS605'
                         AND DTFIM IS NULL)
                LOOP 
                   BEGIN
                      UPDATE REGRAS_PENSAO_AL
                         SET DTFIM   = :NEW.DT_FIM
                       WHERE NUMFUNC = :NEW.NUMFUNC
                         AND NUMVINC = :NEW.NUMVINC
                         AND NUMDEP  = R1.NUMDEP
                         AND BASE    = 'PENSÃO AL MS605'
                         AND (DTFIM IS NULL);
                         --
                   EXCEPTION
                      WHEN OTHERS THEN  
                         ROLLBACK;            
                         raise_application_error(-20001,'Erro ao encerrar regra. '||L_||' '||sqlerrm);   
                    END;                   
                END LOOP;                 
         EXCEPTION               
            WHEN OTHERS THEN
               ROLLBACK;  
               raise_application_error(-20001,'Erro inesperado. '||L_||' '||sqlerrm);                 
         END;
         --
         COMMIT;
         --
      END IF;    
      --LUANA 05/07/2016. SGD 2867.
   ELSIF (UPDATING) THEN     
     --
     L_ := 50;
     --
     begin
         select 1
           into v_existe
           from pgov_beneficios_ms605
          where numfunc      = :old.numfunc
            and numvinc      = :old.numvinc
            and st_beneficio = 'A'  
            and dt_fim is null;
     exception
        when no_data_found then
           v_existe := 0;
     end;
     --Verifica se existe benefício com a situação "ATIVO"
     if v_existe = 0 then
         
        raise_application_error(-20001,'A Concessão de Benefícios só poderá ser gerada para benefícios ativos.');
        
     end if;      
     --     
     BEGIN
        SELECT CATEGORIA
          INTO V_CATEGORIA
          FROM VINCULOS
         WHERE NUMFUNC = :OLD.NUMFUNC
           AND NUMERO  = :OLD.NUMVINC;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
           V_CATEGORIA := NULL;
     END;
     --Verifica se categoria do instituidor é 09 AUDITOR FISCAL.
     IF V_CATEGORIA <> '09 AUDITOR FISCAL' THEN
        raise_application_error(-20001,'O Tipo de concessão MS605 só é permitido para servidores/impetrantes com categoria de Auditor Fiscal da Fazenda do Estado do Rio de Janeiro.');     
     END IF;       
     --
     IF :NEW.DTFIM_ATRASO < :NEW.DTINI_ATRASO THEN
        raise_application_error(-20001,' ATENÇÃO! Pagamento Retroativo - Data fim do Período do Atrasado não pode ser MENOR que Data Início do Período do Atrasado. '||L_);
     ELSIF (:NEW.DT_FIM < :NEW.DTINI_ATRASO OR :NEW.DT_FIM < :NEW.DTFIM_ATRASO)THEN
        raise_application_error(-20001,' ATENÇÃO! Data fim do Benefício não pode ser menor que o período do Atrasado do Pagamento Retroativo. Favor verificar! '||L_);
     END IF;
     --
     IF (:NEW.DT_FIM < :NEW.DT_INI) THEN
        raise_application_error(-20001,' ATENÇÃO! Data fim do Benefício não pode ser MENOR que data início! '||L_);
     ELSIF :NEW.TIPO IS NULL THEN
        raise_application_error(-20001,' ATENÇÃO! O Tipo de Benefício deverá ser informado! '||L_);
     ELSIF :NEW.DT_INI IS NULL THEN
        raise_application_error(-20001,' ATENÇÃO! Data início deverá ser informada! '||L_);
     ELSIF (:NEW.MESANO_PAG < :NEW.DT_INI or :NEW.MESANO_PAG > :NEW.DT_FIM) then
         raise_application_error(-20001,'Pagamento Retroativo - Mês ano Pagamento do pagamento retroativo deverá ser IGUAL ou estar dentro do intervalo da Data Início da Pensão e Data Fim da Pensão. Favor verificar! '||L_);
     END IF;
     --
     IF (:NEW.VL_ATRASO IS NULL) THEN
        --
        IF :NEW.DTINI_ATRASO IS NOT NULL OR :NEW.DTFIM_ATRASO IS NOT NULL OR :NEW.MESANO_PAG IS NOT NULL THEN
           raise_application_error(-20001,' ATENÇÃO! Não foi gerado valor retroativo. Favor verificar! '||L_);
        END IF;
        --
     ELSIF (:OLD.VL_ATRASO IS NOT NULL OR :NEW.VL_ATRASO IS NOT NULL)THEN
        --
        IF :NEW.DTINI_ATRASO IS NULL THEN
           raise_application_error(-20001,' ATENÇÃO! Pagamento Retroativo - Data Início deverá ser preenchida. '||L_);
        ELSIF :NEW.DTFIM_ATRASO  IS NULL THEN
           raise_application_error(-20001,' ATENÇÃO! Pagamento Retroativo - Data Fim deverá ser preenchida. '||L_);
        ELSIF :NEW.MESANO_PAG IS NULL THEN
           raise_application_error(-20001,' ATENÇÃO! Pagamento Retroativo - Mês ano Pagamento deverá ser preenchido. '||L_);
        ELSIF (:NEW.DTINI_ATRASO < v_dt_ini_min OR :NEW.DTFIM_ATRASO < v_dt_ini_min)THEN
           raise_application_error(-20001,' ATENÇÃO! Não existe parcela para este intervalo de data informada. '||L_);
        END IF;
     END IF;
     --
     --Se existir algum registro em aberto para MENSAL MS605
     IF V_CONT >= 1 THEN
        --ergon_erro_pack.trata_erro (04711);
        raise_application_error(-20001, 'Não é possível criar concessão de benefícios, de mesmo tipo concomitantes, para o mesmo pensionista. '||L_);
      END IF;
     --
     IF (:NEW.TIPO = 'ATRASADO MS605')THEN
         IF (:NEW.DT_FIM IS NULL OR :NEW.DTINI_ATRASO IS NULL OR :NEW.DTFIM_ATRASO IS NULL OR :NEW.MESANO_PAG IS NULL OR :NEW.VL_ATRASO IS NULL)THEN
            raise_application_error(-20001,' ATENÇÃO! Para tipo de concessão "ATRASADO MS605" data início, data fim e dados do pagamento retroativo deverão estar preenchidos e gerado! '||L_);
         END IF;
     END IF;     
     --
     --Se data da Concessão for encerrada, e se existir regra de pensão alimentícia aberta para esta concessão
     --então automaticamente encerrará a regra de pensão alimentícia em aberto. LUANA 05/07/2016. SGD 2867.
     IF NVL(:NEW.DT_FIM,pack_hades.data_maxima) <> nvl(:OLD.DT_FIM,pack_hades.data_maxima) THEN        
        BEGIN
           FOR R1 IN (SELECT DTFIM, NUMDEP
                        FROM REGRAS_PENSAO_AL
                       WHERE NUMFUNC = :NEW.NUMFUNC
                         AND NUMVINC = :NEW.NUMVINC
                         AND BASE    = 'PENSÃO AL MS605'
                         AND DTFIM IS NULL OR DTFIM = :OLD.DT_FIM)
                LOOP 
                   BEGIN
                      UPDATE REGRAS_PENSAO_AL
                         SET DTFIM   = :NEW.DT_FIM
                       WHERE NUMFUNC = :NEW.NUMFUNC
                         AND NUMVINC = :NEW.NUMVINC
                         AND NUMDEP  = R1.NUMDEP
                         AND BASE    = 'PENSÃO AL MS605'
                         AND (DTFIM IS NULL OR DTFIM = :OLD.DT_FIM);
                         --
                   EXCEPTION
                      WHEN OTHERS THEN   
                         ROLLBACK;           
                         raise_application_error(-20001,'Erro ao encerrar regra. '||L_||' '||sqlerrm);   
                    END;                   
                END LOOP;                 
        EXCEPTION               
           WHEN OTHERS THEN
              ROLLBACK;   
              raise_application_error(-20001,'Erro inesperado. '||L_||' '||sqlerrm);                 
        END;
        --
        COMMIT;
        --             
     END IF;
     --LUANA 05/07/2016. SGD 2867.
     --A pedido da Rosangela, na tela, por enquanto NÃO existirá a opção de exclusão de registro de concessão. Luana 26/08/2016.
   ELSIF DELETING THEN
      begin
         select 1
           into v_existe
           from pgov_beneficios_ms605
          where numfunc      = :old.numfunc
            and numvinc      = :old.numvinc
            and st_beneficio = 'A'  
            and dt_fim is null;
      exception
         when no_data_found then
            v_existe := 0;
      end;
     --Verifica se existe benefício com a situação "ATIVO"
     if v_existe = 1 then
         
        raise_application_error(-20001,'Concessão de Benefícios não poderá ser excluída.');
        
     end if;      
     --   
  END IF;
END IF;   
END PGOV_CONC_BENEF_MS605;
/