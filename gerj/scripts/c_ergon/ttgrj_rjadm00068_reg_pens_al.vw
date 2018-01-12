CREATE OR REPLACE FORCE VIEW TTGRJ_RJADM00068_REG_PENS_AL
AS 
  SELECT  rp.NUMFUNC
			,rp.NUMVINC
			,rp.DTINI
			,rp.DTFIM
			,rp.PERCENTUAL
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
            ,de.NOME
            ,rp.numdep
            ,rp.BASE
			,rowidtochar(rp.ROWID) "ROWID_REG"
			,HAD_FORMATA_PUBLICACOES(rp.PONTPUBL) TEXTO_PUBL
            ,rp.BASE || '  -  ' || bp.DESCRICAO base_desc
            ,rp.numdep || ' - ' || de.nome dependente  
            ,msb.DTATUALIZACAO
            ,msb.VL_SALDO
  FROM regras_pensao_al rp
  inner join base_pensao bp on bp.base = rp.base
  inner join dependentes de on de.numfunc = rp.numfunc
                           and de.numero = rp.numdep
  left join pgov_saldo_bloq_ms605 msb on msb.numdep = rp.numdep 
                                AND msb.numfunc = rp.numfunc 
                                AND msb.numvinc = rp.numvinc
								AND msb.nome_beneficio = rp.base
/