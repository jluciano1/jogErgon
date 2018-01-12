create or replace view ttgrj_ergadm00222_credbanc as
SELECT FB.FICHA,
       FB.MES_ANO,
       FB.NUMERO,
       FB.NUMFUNC,
       FB.NUMVINC,
       FB.NUMPENS,
       FB.LANCAMENTO,
       FB.NUMDEPEN,
       FB.NOME,
       FC.NUMFITA,
       FC.VALOR,
       FC.PERCENTUAL,
       FF.BANCO,
       FF.DATA_CREDITO,
       FF.DATA_ENVIO,
       FF.OBS,
       ROWIDTOCHAR(FB.ROWID) rowid_reg,
       ttgrj_fnc_ergadm00222_getnome(FB.LANCAMENTO, FC.NUMFITA) FNC_GETNOME
  FROM FITABANCO FB, FB_CREDITOS FC, FB_FITAS_P_BANCO FF
 WHERE FB.LANCAMENTO = FC.LANCAMENTO
   AND FC.NUMFITA = FF.NUMFITA;
/