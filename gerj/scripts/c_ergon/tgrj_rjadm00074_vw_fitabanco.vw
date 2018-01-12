CREATE OR REPLACE
VIEW TGRJ_RJADM00074_VW_FITABANCO
AS
  SELECT DISTINCT FB.NUMFITA
                , FB.BANCO
                , FB.DATA_CREDITO
                , FB.DATA_ENVIO
                , FB.OBS
                , FF.MES_ANO_FOLHA
                , FF.NUM_FOLHA
                , FB.FLEX_CAMPO_01
                , FB.FLEX_CAMPO_02
                , FB.FLEX_CAMPO_03
                , FB.FLEX_CAMPO_04
                , FB.FLEX_CAMPO_05
                , FB.FLEX_CAMPO_06
                , FB.FLEX_CAMPO_07
                , FB.FLEX_CAMPO_08
      FROM
        FB_FITAS_P_BANCO FB,
        FB_FITAS_FOLHAS  FF
      WHERE 
        FB.NUMFITA = FF.NUMFITA 
      AND SUBSTR(FB.OBS,1,4) <> 'SAPE'
/
