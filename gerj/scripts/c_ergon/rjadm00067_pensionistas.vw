CREATE OR REPLACE FORCE 
VIEW RJADM00067_PENSIONISTAS 
AS 
    SELECT
        NUMFUNC ,
        NUMVINC ,
        NUMERO ,
        NOME ,
        SEXO ,
        CASE WHEN SEXO = 'F' THEN 'Feminino'
            WHEN SEXO = 'M' THEN 'Masculino'
            ELSE SEXO
            END AS SEXO_DESCR ,
        DTNASC ,
        PARENTESCO ,
        TIPOLOGENDER ,
        NOMELOGENDER ,
        NUMENDER ,
        COMPLENDER ,
        BAIRRO ,
        CIDADE ,
        UF ,
        lpad(TO_CHAR(CEPENDER),8,'0') CEPENDER ,
        TELEFONE ,
        CPF ,
        BANCO ,
        (SELECT bc.banco||' - '||bc.nome FROM bancos bc where bc.banco = p.banco) NOME_BANCO,
        AGENCIA ,
        (SELECT ag.agencia ||' - '||ag.nome agencia FROM agencias ag WHERE ag.agencia = p.agencia AND ag.banco = p.banco) NOME_AGENCIA,
        CONTA ,
        TIPOPAG ,
        OBS ,
        EMP_CODIGO ,
        REPRESENTANTE_LEGAL ,
        NUM_REPR_LEGAL ,
        NUMDEP ,
        (select d.numero||' - '||d.nome
        from dependentes d
        where d.numfunc   = p.numfunc
            and d.numero    = p.numdep) as DESCDEP,
        NUMRG ,
        TIPORG ,
        ORGAORG ,
        UFRG ,
        (select u.sigla ||' - ' || u.nome from uf  u where u.sigla = ufrg) descrufrg,
        TIPODOC_CERT ,
        NUM_CERT ,
        LIVRO_A_CERT ,
        FOLHA_CERT ,
        CARTORIO_CERT ,
        UF_CART ,
        (select u.sigla ||' - ' || u.nome from uf  u where u.sigla = uf_cart) descrufcart,
        MUNICIPIO_CART ,
        CIDADE_COD,
        PACK_HAD_UTIL.GET_MUNICIPIO_DESC(CIDADE_COD) AS CIDADE_COD_DESC,
        MUNICIPIO_CART_COD,
        PACK_HAD_UTIL.GET_MUNICIPIO_DESC(MUNICIPIO_CART_COD) AS MUNICIPIO_CART_COD_DESC,
        MUNICIPIO_CART_FIM_COD,
        PACK_HAD_UTIL.GET_MUNICIPIO_DESC(MUNICIPIO_CART_FIM_COD) AS MUNICIPIO_CART_FIM_COD_DESC,
        TIPODOC_CERT_FIM ,
        DT_CERT_FIM ,
        NUM_CERT_FIM ,
        LIVRO_CERT_FIM ,
        FOLHA_CERT_FIM ,
        CARTORIO_CERT_FIM ,
        UF_CART_FIM ,
        MUNICIPIO_CART_FIM ,
        NUMTITEL ,
        ZONATITEL ,
        SECTITEL ,
        UFTITEL ,
        EXPEDRG ,
        ESTCIVIL ,
        MATRICULA_CERT ,
        MATRICULA_CERT_FIM ,
        ID_PESSOA ,
        ROWIDTOCHAR(ROWID) ROWID_REG,
        dt_recadast
        ,FLEX_CAMPO_01
        ,FLEX_CAMPO_02
        ,flex_campo_03
        ,flex_campo_04 
        ,(select f.numero||' - '||f.nome
          from funcionarios f
          where f.numero   = to_number(p.flex_campo_04)) idfunc_pens_desc
        ,FLEX_CAMPO_05
        ,FLEX_CAMPO_06
        ,FLEX_CAMPO_07
        ,FLEX_CAMPO_08
        ,FLEX_CAMPO_09
        ,FLEX_CAMPO_10
        ,FLEX_CAMPO_11
        ,FLEX_CAMPO_12
        ,FLEX_CAMPO_13
        ,FLEX_CAMPO_14
        ,FLEX_CAMPO_15
        ,FLEX_CAMPO_16
        ,FLEX_CAMPO_17
        ,FLEX_CAMPO_18
        ,FLEX_CAMPO_19
        ,FLEX_CAMPO_20
        ,FLEX_CAMPO_21
        ,FLEX_CAMPO_22
        ,FLEX_CAMPO_23
        ,FLEX_CAMPO_24
        ,FLEX_CAMPO_25
        ,FLEX_CAMPO_26
        ,FLEX_CAMPO_27
        ,FLEX_CAMPO_28
        ,FLEX_CAMPO_29
        ,FLEX_CAMPO_30
        ,FLEX_CAMPO_31
        ,FLEX_CAMPO_32
        ,flex_campo_33
        ,FLEX_CAMPO_34
        ,FLEX_CAMPO_35
        ,FLEX_CAMPO_36
        ,FLEX_CAMPO_37
        ,FLEX_CAMPO_38
        ,FLEX_CAMPO_39
        ,FLEX_CAMPO_40
        ,FLEX_CAMPO_41
        ,FLEX_CAMPO_42
        ,FLEX_CAMPO_43
        ,FLEX_CAMPO_44
        ,FLEX_CAMPO_45
        ,FLEX_CAMPO_46
        ,FLEX_CAMPO_47
        ,FLEX_CAMPO_48
        ,FLEX_CAMPO_49
        ,FLEX_CAMPO_50
    FROM PENSIONISTAS P
/