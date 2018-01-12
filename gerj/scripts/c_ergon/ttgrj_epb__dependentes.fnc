CREATE OR REPLACE FUNCTION TTGRJ_EPB__DEPENDENTES (P_ROW_NEW   IN OUT NOCOPY DEPENDENTES%ROWTYPE,
                                                   P_ROW_OLD   IN DEPENDENTES%ROWTYPE,
                                                   P_INSERTING IN BOOLEAN,
                                                   P_UPDATING  IN BOOLEAN,
                                                   P_DELETING  IN BOOLEAN,
                                                   P_MENS      OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS
  
BEGIN
  --  
  IF P_INSERTING THEN
    IF P_ROW_NEW.PARENTESCO IS NULL THEN
      P_MENS := 'O Parentesco deve ser informado.';
    END IF;
  END IF;
  
  IF P_INSERTING OR P_UPDATING THEN
	
	IF UPPER(P_ROW_NEW.FLEX_CAMPO_03) = 'TERCEIRO' THEN

	  IF P_ROW_NEW.FLEX_CAMPO_08 IS NULL THEN
		P_ROW_NEW.FLEX_CAMPO_08 := 'NÃO';
	  END IF;
	  --
	  ---
	  IF P_ROW_NEW.FLEX_CAMPO_08 = 'SIM' THEN

	    IF p_row_new.banco IS NULL THEN
          p_row_new.banco := pack_hades.get_opcao('C_Ergon', 'GOVRJ', 'BANCO_PADRAO');
        END IF;
	 
		P_ROW_NEW.AGENCIA := '0000';
		P_ROW_NEW.CONTA := NULL;
		P_ROW_NEW.TIPOPAG := 'SEMCC';
		
		  
	  ELSIF P_ROW_NEW.FLEX_CAMPO_08 = 'NÃO' THEN

	    IF  P_ROW_NEW.TIPOPAG NOT IN ('CONTA','ESPEC') THEN  
	      P_MENS := ('Favor preencher o tipo de pagamento Conta ou Espécie quando o Depósito Judicial não estiver sobre responsabilidade do Orgão');
	    END IF;
		  
	    IF P_ROW_NEW.TIPOPAG IN ('CONTA','ESPEC') AND P_ROW_NEW.AGENCIA IS NULL THEN
	      P_MENS := ('Favor informar a agência.');
	    END IF;
		  
	    IF P_ROW_NEW.CONTA IS NULL AND P_ROW_NEW.TIPOPAG = 'CONTA' THEN
          P_MENS := ('Favor informar a Conta Corrente quando o tipo de pagamento por CONTA.');    
	    END IF;
		  
	  END IF;	
	
	END IF;	
		
  END IF;
  
  RETURN(TRUE);
  
END;
/