create FUNCTION TTGRJ_EPA__REGRAS_PENSAO_AL (P_ROW_NEW   IN OUT NOCOPY REGRAS_PENSAO_AL%ROWTYPE,
                                                        P_ROW_OLD   IN REGRAS_PENSAO_AL%ROWTYPE,
                                                        P_INSERTING IN BOOLEAN,
                                                        P_UPDATING  IN BOOLEAN,
                                                        P_DELETING  IN BOOLEAN,
                                                        P_MENS      OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS

BEGIN
  --

  IF P_INSERTING OR P_UPDATING THEN
	--Somente se tiver valor de dívida.
	--
	IF P_ROW_NEW.FLEX_CAMPO_12 IS NOT NULL THEN

	  BEGIN
	  --Recupera o saldo devedor do servidor quando a folha for consolidada.
		SELECT SUM(NVL(FR.VALOR,0))
		  INTO P_ROW_NEW.FLEX_CAMPO_14
		  FROM DEPENDENTES DE,
			   FITABANCO   FB,
			   REGRAS_PENSAO_AL RP,
			   FICHAS_RUBRICAS  FR
	     WHERE DE.NUMFUNC  = RP.NUMFUNC
		   AND DE.NUMERO   = RP.NUMDEP
		   AND FB.NUMFUNC  = RP.NUMFUNC
		   AND FB.NUMVINC  = RP.NUMVINC
		   AND FB.NUMDEPEN = RP.NUMDEP
		   AND FB.NUMFUNC  = DE.NUMFUNC
		   AND FB.NUMDEPEN = DE.NUMERO
		   AND FB.FICHA    = FR.FICHA
		   AND FR.MES_ANO_DIREITO >= RP.DTINI
		   AND FR.MES_ANO_DIREITO <= NVL(RP.DTFIM,PACK_ERGON.DATA_MAXIMA)
		   AND RP.DTINI = P_ROW_NEW.DTINI
		   AND FR.RUBRICA = DECODE(P_ROW_NEW.BASE,'BLOQ JUD V FIXO', 4040, DECODE(P_ROW_NEW.BASE, 'BLOQ JUD REMUN',4041,4336))
		   AND DE.FLEX_CAMPO_03 = 'TERCEIRO'
		   AND NOT EXISTS (SELECT 1
			  			     FROM ERG_ESTORNO_FF EE
						    WHERE EE.MES_ANO_ORIG= FB.MES_ANO
						      AND EE.NUM_FOLHA_ORIG = FB.NUMERO
						      AND EE.NUMFUNC = FB.NUMFUNC
						      AND EE.NUMVINC = FB.NUMVINC) --SGD-1729
		   AND FB.NUMDEPEN IS NOT NULL
		   AND FB.NUMFUNC = P_ROW_NEW.NUMFUNC
		   and FB.NUMVINC = P_ROW_NEW.NUMVINC
		   and FB.NUMDEPEN = P_ROW_NEW.NUMDEP
		   and fb.numdepen = fr.complemento
		   AND pack_cergon.PGOV_EH_CONSOLIDADA_TD_CREDIT(FB.MES_ANO, FB.NUMERO,FB.EMP_CODIGO) > 0;
           
		   --- Alterado esta linha por que estava com erro de obj null
           P_ROW_NEW.FLEX_CAMPO_14 := to_number(NVL(P_ROW_NEW.FLEX_CAMPO_12,0), '99999999.999999') - to_number(NVL(P_ROW_NEW.FLEX_CAMPO_14,0), '99999999.999999');
           
	  EXCEPTION
		WHEN OTHERS THEN
		  P_MENS := 'Erro ao recuperar o saldo devedor do servidor. Favor informar ao Suporte.';
		  RETURN(TRUE);
	  END;
	  --
	  --
	  BEGIN

		SELECT to_char(max(mes_ano),'MM/YYYY')
		  INTO P_ROW_NEW.FLEX_CAMPO_15
		  FROM DEPENDENTES DE,
			   FITABANCO   FB,
			   REGRAS_PENSAO_AL RP,
			   FICHAS_RUBRICAS  FR
	     WHERE DE.NUMFUNC  = RP.NUMFUNC
	  	   AND DE.NUMERO   = RP.NUMDEP
		   AND FB.NUMFUNC  = RP.NUMFUNC
		   AND FB.NUMVINC  = RP.NUMVINC
		   AND FB.NUMDEPEN = RP.NUMDEP
		   AND FB.NUMFUNC  = DE.NUMFUNC
		   AND FB.NUMDEPEN = DE.NUMERO
		   AND FB.FICHA    = FR.FICHA
		   AND FR.MES_ANO_DIREITO >= RP.DTINI
		   AND FR.MES_ANO_DIREITO <= NVL(RP.DTFIM,PACK_ERGON.DATA_MAXIMA)
		   AND RP.DTINI = P_ROW_NEW.DTINI
		   AND FR.RUBRICA = DECODE(P_ROW_NEW.BASE,'BLOQ JUD V FIXO', 4040, DECODE(P_ROW_NEW.BASE, 'BLOQ JUD REMUN',4041,4336))
		   AND DE.FLEX_CAMPO_03 = 'TERCEIRO'
		   AND FB.NUMDEPEN IS NOT NULL
		   AND FB.NUMFUNC  = P_ROW_NEW.NUMFUNC
		   and FB.NUMVINC  = P_ROW_NEW.NUMVINC
		   and FB.NUMDEPEN = P_ROW_NEW.NUMDEP
		   AND pack_cergon.PGOV_EH_CONSOLIDADA_TD_CREDIT(FB.MES_ANO, FB.NUMERO,FB.EMP_CODIGO) > 0;

	  EXCEPTION
		WHEN OTHERS THEN
		  P_MENS := 'Erro ao recuperar o último mês pago. Favor informar ao Suporte.';
		  RETURN(TRUE);
	  END;

	  IF P_ROW_NEW.FLEX_CAMPO_15 IS NOT NULL THEN

		BEGIN

		 SELECT SUM(VALORLIQ)
		   INTO P_ROW_NEW.FLEX_CAMPO_17
		   FROM FITABANCO   FB
		  WHERE FB.MES_ANO = TO_DATE('01/'||P_ROW_NEW.FLEX_CAMPO_15,'DD/MM/YYYY')
		    AND FB.NUMFUNC  = P_ROW_NEW.NUMFUNC
		    and FB.NUMVINC  = P_ROW_NEW.NUMVINC
		    and FB.NUMDEPEN = P_ROW_NEW.NUMDEP
		    AND pack_cergon.PGOV_EH_CONSOLIDADA_TD_CREDIT(FB.MES_ANO, FB.NUMERO,FB.EMP_CODIGO) > 0;
		EXCEPTION

		  WHEN OTHERS THEN
			P_MENS :='Erro ao recuperar o último valor pago. Favor informar ao Suporte.';
			RETURN(TRUE);
		END;

	  END IF;

	END IF;

  END IF;

  RETURN(TRUE);

END;
/