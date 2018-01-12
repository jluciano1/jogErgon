CREATE OR REPLACE FORCE VIEW TTGRJ_RJADM00068_REGRAS_PENSAO
AS 
  SELECT  rp.NUMFUNC
			,rp.NUMVINC
			,rp.NUMPENS
			,rp.TIPOPENS
			,rp.DTINI
			,rp.DTFIM
			,rp.PERCENTUAL
			,rp.ISENTO_IR
			,rp.OBS
			,rp.FLEX_CAMPO_01
			,rp.FLEX_CAMPO_02
			,rp.FLEX_CAMPO_03
			,rp.FLEX_CAMPO_04
			,rp.FLEX_CAMPO_05
			,rp.EMP_CODIGO
			,rp.PONTPUBL
			,rp.PONTLEI
			,rp.FLEX_CAMPO_06
			,rp.FLEX_CAMPO_07
			,rp.FLEX_CAMPO_08
			,rp.FLEX_CAMPO_09
			,rp.FLEX_CAMPO_10
			,rp.ID_PROC_PES
			,rp.FLEX_CAMPO_11
			,rp.FLEX_CAMPO_12
			,rp.FLEX_CAMPO_13
			,rp.FLEX_CAMPO_14
			,rp.FLEX_CAMPO_15
			,rp.FLEX_CAMPO_16
			,rp.FLEX_CAMPO_17
			,rp.FLEX_CAMPO_18
			,rp.FLEX_CAMPO_19
            ,rp.FLEX_CAMPO_20
			,rp.FLEX_CAMPO_21
            ,rp.FLEX_CAMPO_22
            ,rp.FLEX_CAMPO_23
			,rp.FLEX_CAMPO_24
			,rp.FLEX_CAMPO_25
			,rp.FLEX_CAMPO_26
			,rp.FLEX_CAMPO_27
			,rp.FLEX_CAMPO_28
			,rp.FLEX_CAMPO_29
			,rp.FLEX_CAMPO_30
			,rp.ID_REG
            ,pens.NOME
            ,pens.numdep
            ,msb.DTATUALIZACAO
            ,msb.VL_SALDO
			,rowidtochar(rp.ROWID) "ROWID_REG"
			,HAD_FORMATA_PUBLICACOES(rp.PONTPUBL) TEXTO_PUBL
			,(pens.NUMERO || ' - ' || pens.NOME) PENS_DESCR
			,(tp.TIPO || ' - ' || tp.NOME) TIPOPENS_DESCR
			,decode(tp.BASE ,'QUANTIDADE',TO_CHAR(rp.PERCENTUAL,'FM999999990')
							,'VALOR',TO_CHAR(rp.PERCENTUAL,'FM999G999G990D00')
							,TO_CHAR(rp.PERCENTUAL,'FM999G999G990D009999')) VALOR_DESCR
  FROM regras_pensao rp
  inner join tipo_pensao tp on rp.TIPOPENS = tp.TIPO
  inner join pensionistas pens on pens.NUMFUNC = rp.NUMFUNC 
                            AND pens.NUMVINC = rp.NUMVINC 
                            AND pens.NUMERO = rp.NUMPENS
  left join pgov_saldo_bloq_ms605 msb on msb.numpens = rp.numpens 
                                AND msb.numfunc = rp.numfunc 
                                AND msb.numvinc = rp.numvinc
								AND msb.nome_beneficio = rp.tipopens
/