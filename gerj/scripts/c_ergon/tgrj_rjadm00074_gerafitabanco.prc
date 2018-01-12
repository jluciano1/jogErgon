CREATE OR REPLACE 
PROCEDURE TGRJ_RJADM00074_GERAFITABANCO (P_DATA_FITA          IN DATE
                                        ,P_NUMFOLHA_FITA      IN NUMBER
                                        ,P_DATA_CREDITO       IN OUT DATE
                                        ,P_DATA_CREDITO_ATIVO IN OUT DATE
                                        ,P_DATA_ENVIO         IN DATE
                                        ,P_CHK_DATA           IN VARCHAR2
                                        ,P_MES_ANO_FOLHA      IN DATE
                                        ,P_NUM_FOLHA          IN NUMBER
                                        ,P_MENS               OUT VARCHAR2)
IS
	v_trg_record 				number;
	v_folha_record 			number;
	v_arquivo_ok 				boolean := TRUE;
	v_arquivo 					varchar2(1000) := null;
	v_sigla 						varchar2(50) := null;
	v_obs 							varchar2(100) := null;
	v_diretorio 				varchar2(100) := null;
	v_contador					integer := 0;
	--v_posicao_final 		integer := 0;
	v_posicao_final 		pls_integer := 0;
	v_pos_1o_hifen 			pls_integer := 0;
	v_pos_2o_hifen 			pls_integer := 0;
	v_pos_2o_# 				  pls_integer := 0;
	WRK_QTD_FITAS       NUMBER;
	v_erro							varchar2(3000);
BEGIN
--
  iF (P_DATA_FITA IS NULL) THEN
     P_MENS := 'Preencha o MÃªs/Ano da Folha para que seja gerada a fita bancaria!';
     RETURN;
  END if;

  IF (P_NUMFOLHA_FITA  IS NULL) THEN
     P_MENS := 'Preencha o nÃºmero da Folha para que seja gerada a fita bancaria!';
     RETURN;
  END IF;

  IF NVL(P_CHK_DATA,'N') = 'S' THEN

		 P_DATA_CREDITO       :=  PGOV_DIA_UTIL_PAGAMENTO(FLAG_PACK.GET_EMPRESA,
                                                   					 P_DATA_FITA,
                                                   					 'INATIVO');

         P_DATA_CREDITO_ATIVO := 	PGOV_DIA_UTIL_PAGAMENTO(FLAG_PACK.GET_EMPRESA,
                                                       					 P_DATA_FITA,
                                                       					 'ATIVO');

  END IF;

  iF (P_DATA_CREDITO IS NULL) THEN
	     P_MENS := ('Preencha a Data de CrÃ©dito Inativo para que seja gerada a fita bancaria!');
	     RETURN;
  END if;

	iF P_DATA_CREDITO_ATIVO IS NULL THEN
	     P_MENS := ('Preencha a Data de CrÃ©dito Ativo para que seja gerada a fita bancaria!');
	     RETURN;
	END if;

  iF (P_DATA_ENVIO IS NULL) THEN
     P_MENS := ('Preencha a data de Envio para que seja gerada a fita bancaria!');
     RETURN;
  END if;

  iF (P_DATA_CREDITO < P_DATA_FITA) THEN
     P_MENS := ('Data de CrÃ©dito nÃ£o pode ser inferior ao MÃªs/Ano da Folha!');
     RETURN;
  END if;

  iF (P_DATA_ENVIO < P_DATA_FITA) THEN
     P_MENS := 'Data de Envio nÃ£o pode ser inferior ao MÃªs/Ano da Folha!';
     RETURN;
  END if;

  iF P_DATA_CREDITO < P_DATA_ENVIO THEN
     P_MENS := ('Data de Envio nÃ£o pode ser superior a Data de CrÃ©dito!');
     RETURN;
  END if;

  SELECT COUNT(*)
    INTO WRK_QTD_FITAS
    FROM FB_FITAS_FOLHAS FB,
         FB_FITAS_P_BANCO FP
   WHERE FB.NUMFITA = FP.NUMFITA
     AND FB.MES_ANO_FOLHA = P_DATA_FITA
     AND FB.NUM_FOLHA     = P_NUMFOLHA_FITA
     AND TO_NUMBER(FP.FLEX_CAMPO_04) = flag_pack.get_empresa()
     AND SUBSTR(FP.OBS,1,4) <> 'SAPE';

  IF WRK_QTD_FITAS > 0 THEN
    P_MENS := ('As fitas para este MÃªs/Ano/NÃºmero de folha jÃ¡ foram geradas!');
    RETURN;
  END IF;

  --MESSAGE('Iniciando GeraÃ§Ã£o da Fita bancaria resumo...');
  GERA_FITA (P_DATA_FITA,
					             P_NUMFOLHA_FITA,
					             P_DATA_CREDITO,
					             P_DATA_CREDITO_ATIVO,
					             P_DATA_ENVIO,
					             FLAG_PACK.GET_EMPRESA,
					             0,
					             null);


  --ALERTA('Processo terminado com sucesso!');

  BEGIN

   PCK_SEND_EMAIL.prcEnviarEmail('CONTRACHEQUE WEB Folha : '||P_NUM_FOLHA||' Competencia: '||TO_CHAR(P_MES_ANO_FOLHA, 'MM/YYYY')||' Empresa: '||FLAG_PACK.GET_EMPRESA,
                                 'A folha informada conforme tÃ­tulo recebeu data de crÃ©dito. : '||TO_CHAR(P_DATA_CREDITO,'DD/MM/YYYY'),
                                 'SIGRH',
                                 NULL);

   EXCEPTION
   	WHEN OTHERS THEN
   	  P_MENS := ('10000 Erro nÃ£o esperado: '||SQLERRM(SQLCODE));
      RETURN;
   END;
/*
	P_DATA_FITA := NULL;
	P_NUMFOLHA_FITA := NULL;
	P_DATA_CREDITO := NULL;
	P_DATA_CREDITO_ATIVO := NULL;
	P_DATA_ENVIO := NULL;
*/

END;
/