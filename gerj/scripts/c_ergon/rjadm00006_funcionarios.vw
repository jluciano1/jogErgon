CREATE OR REPLACE FORCE 
VIEW rjadm00006_funcionarios AS
SELECT a.numero
     , a.nome
     , a.sexo
     , DECODE(a.sexo,'M', 'M - Masculino','F','F - Feminino') nome_sexo
     , a.dtnasc
     , a.ufnasc
     ,(select u.sigla||' - '||u.nome from uf u where u.sigla = A.ufnasc) ufnascdesc
     , a.cidnasc
     , a.cidnasc CIDADENASCDESC
     , a.g_sanguineo
     ,(select nvl(i.descr,i.item) from itemtabela i where i.tab = 'ERG_G_SANG' and i.item =a.g_sanguineo) g_sanguineodesc
     , a.pai
     , a.mae
     , a.estcivil
     , a.escolaridade
     ,(SELECT i.item||' - '||i.descr FROM itemtabela i WHERE i.tab = 'ERG_ESCOLA' AND i.item = a.escolaridade) nome_escolaridade
     , a.nacionalidade
     ,(SELECT i.item||' - '||i.descr FROM itemtabela i WHERE i.tab = 'ERG_NACIONALIDADE' AND i.item = a.nacionalidade) nome_nacional
     , a.chegbrasil
     , a.ufempant
     , (select u.sigla||' - '||u.nome from uf u where u.sigla = a.ufempant) ufempantdesc
     , a.anoprimemp
     , a.numrg
     , a.tiporg
     ,(select i.item||' - '||i.descr descr from itemtabela i where i.tab = 'TIPO_RG' and i.item =A.tiporg) tiporgdesc
     , a.orgaorg
     ,(select i.item||' - '||i.descr descr from itemtabela i where i.tab = 'ORGAO RG' and i.item = A.orgaorg) orgaorgdesc
     , a.ufrg
     ,(select u.sigla||' - '||u.nome from uf u where u.sigla = A.ufrg) ufrgdesc
     , lpad(a.cpf,11,'0') cpf
     , a.numcartpro
     , a.sercartpro
     , a.ufcartpro
     ,(select u.sigla||' - '||u.nome from uf u where u.sigla = a.ufcartpro) ufcartprodesc
     , a.numtitel
     , a.zonatitel
     , a.sectitel
     , a.uftitel
     ,(select u.sigla||' - '||u.nome 
         from uf u 
        where u.sigla = a.uftitel
      ) uftiteldesc
     , a.numdocmili
     , a.serdocmili
     , a.catmili
     , a.cnh
     , a.catcnh
     , a.validcnh
     , a.ufcnh
     ,(select u.sigla||' - '||u.nome 
         from uf u 
        where u.sigla = a.ufcnh
      ) ufcnhdesc
     , a.pispasep
     , a.datapis
     , a.bancopis
     , (SELECT bc.banco||' - '||bc.nome 
        FROM bancos bc 
     where bc.banco = a.bancopis) NOME_BANCOPIS
     , a.informarbb
     , DECODE(A.informarbb,'N','Não','S','Sim')informarbbdesc
     , a.identprof
     , a.tipoidprof  
     ,(SELECT i.item || ' - ' || i.descr descr
       FROM itemtabela i 
    where i.tab = 'ERG_TIPOIDPROF' 
      and i.item = a.tipoidprof
      )tipoidprofdesc
     , a.tipologender
     ,(select i.item || ' - ' || i.descr descr
       from itemtabela i 
    where i.tab='Logradouros' 
      and i.item = a.tipologender
      ) tipologenderdescr
     , a.nomelogender
     , a.numender
     , a.complender
     , a.bairroender
     , a.cidadeender
      ,a.cidadeender CIDADEENDERDESC
     , a.ufender
     , (select u.sigla||' - '||u.nome 
          from uf u 
         where u.sigla = A.ufender
       ) ufenderdesc
     , lpad(a.cepender,8,'0') cepender
     , a.telefone
     , a.banco
     , b.banco||' - '||b.nome NOME_BANCO
     , a.agencia
     , ag.nome  NOME_AGENCIA
     , a.conta
     , a.tipopag
     ,(SELECT i.item || ' - ' || i.descr descr  
       FROM ITEMTABELA i 
    WHERE i.TAB = 'ERG_TIPO_PAG'
      and i.item =A.tipopag 
      ) TIPOPAGdesc
     , get_foto_func(a.numero) foto
     , a.pontpubl
     , a.num_cert
     , a.livro_a_cert
     , a.folha_cert
     , a.cartorio_cert
     , a.ramal
     , a.tratamento
     , a.dt_recadast
     , a.e_mail
     , a.numtel_celular
     , a.raca
     , DECODE(a.raca,1,'1 - Indígena',
                   2,'2 - Branca',
           4,'4 - Preta',
           6,'6 - Amarela',
           8,'8 - Parda',
           9,'9 - Não Informado') NOME_RACA
     , a.deficiente
     , decode(A.deficiente,'N','Não',
                         'S','Sim')deficientedesc
     , a.flag_web
     , a.uf_cart
     , (select u.sigla||' - '||u.nome from uf u where u.sigla = a.uf_cart) uf_cartdesc
     , a.municipio_cart
     ,a.municipio_cart municipio_cartdesc
     , a.tipodoc_cert
     ,(SELECT i.item||' - '||i.descr descr FROM itemtabela i where i.tab = 'TIPO_DOC_CERT' and i.item = a.tipodoc_cert) tipodoc_certdesc
     , a.uf_identprof
     ,(select u.sigla||' - '||u.nome from uf u where u.sigla = a.uf_identprof) uf_identprofdesc
     , a.tipodoc_cert_fim
     ,(SELECT i.item||' - '||i.descr FROM itemtabela i where i.tab = 'TIPO_DOC_CERT_FIM' and i.item = a.tipodoc_cert_fim) tipodoc_cert_fimdesc
     , a.dt_cert_fim
     , a.num_cert_fim
     , a.livro_cert_fim
     , a.folha_cert_fim
     , a.cartorio_cert_fim
     , a.uf_cart_fim
     , (select u.sigla||' - '||u.nome from uf u where u.sigla = A.uf_cart_fim) uf_cart_fimdesc
     , a.municipio_cart_fim
     , a.municipio_cart_fim municipio_cart_fimdesc
     , a.expedrg
     , a.orgaomili
     ,(SELECT i.item||' - '||i.descr descr FROM ITEMTABELA i WHERE i.TAB = 'ORGAO MILIT' and i.item = A.orgaomili) orgaomilidesc
     , a.ufdocmili
     , (select u.sigla||' - '||u.nome from uf u where u.sigla = A.ufdocmili) ufdocmilidesc
     , a.tipodefic
     , (SELECT item||' - '||descr FROM itemtabela WHERE tab = 'ERG_TIPO_DEFIC' AND item = a.tipodefic) NOME_DEFIC
     , a.gera_pasep
     , decode( A.gera_pasep,'S','Sim','N','Não') gera_pasepdesc
     , a.id_reg
     , a.us
     , a.matricula_cert
     , a.matricula_cert_fim
     , a.id_pessoa
     , a.flex_campo_01
     , a.flex_campo_02
     , a.flex_campo_03
     , a.flex_campo_04
     , a.flex_campo_05
     , a.flex_campo_06
     , a.flex_campo_07
     , a.flex_campo_08
     , a.flex_campo_09
     , a.flex_campo_10
     , a.flex_campo_11
     , a.flex_campo_12
     , a.flex_campo_13
     , a.flex_campo_14
     , a.flex_campo_15
     , a.flex_campo_16
     , a.flex_campo_17
     , a.flex_campo_18
     , a.flex_campo_19
     , a.flex_campo_20
     , a.flex_campo_21
     , a.flex_campo_22
     , a.flex_campo_23
     , a.flex_campo_24
     , a.flex_campo_25
     , a.flex_campo_26
     , a.flex_campo_27
     , a.flex_campo_28
     , a.flex_campo_29
     , a.flex_campo_30
     , a.flex_campo_31
     , a.flex_campo_32
     , a.flex_campo_33
     , a.flex_campo_34
     , a.flex_campo_35
     , a.flex_campo_36
     , a.flex_campo_37
     , a.flex_campo_38
     , a.flex_campo_39
     , a.flex_campo_40
     , a.flex_campo_41
     , a.flex_campo_42
     , a.flex_campo_43
     , a.flex_campo_44
     , a.flex_campo_45
     , a.flex_campo_46
     , a.flex_campo_47
     , a.flex_campo_48
     , a.flex_campo_49
     , a.flex_campo_50
     , a.flex_campo_51
     , a.flex_campo_52
     , a.flex_campo_53
     , a.flex_campo_54
     , a.flex_campo_55
     , a.flex_campo_56
     , a.flex_campo_57
     , a.flex_campo_58
     , a.flex_campo_59
     , a.flex_campo_60
     , a.flex_campo_61
     , a.flex_campo_62
     , a.flex_campo_63
     , a.flex_campo_64
     , a.flex_campo_65
     , a.flex_campo_66
     , a.flex_campo_67
     , a.flex_campo_68
     , a.flex_campo_69
     , a.flex_campo_70
     , a.flex_campo_71
     , a.flex_campo_72
     , a.flex_campo_73
     , a.flex_campo_74
     , a.flex_campo_75
     , a.flex_campo_76
     , a.flex_campo_77
     , a.flex_campo_78
     , a.flex_campo_79
     , a.flex_campo_80
     , a.flex_campo_81
     , a.flex_campo_82
     , a.flex_campo_83
     , a.flex_campo_84
     , a.flex_campo_85
     , a.flex_campo_86
     , a.flex_campo_87
     , a.flex_campo_88
     , a.flex_campo_89
     , a.flex_campo_90
     , a.flex_campo_91
     , a.flex_campo_92
     , a.flex_campo_93
     , a.flex_campo_94
     , a.flex_campo_95
     , a.flex_campo_96
     , a.flex_campo_97
     , a.flex_campo_98
     , a.flex_campo_99
     , a.flex_campo_100
     , rowidtochar(a.ROWID) ROWID_REG
     , municipio_cart_cod
     , pack_had_util.get_municipio_desc(municipio_cart_cod) municipio_cart_cod_desc
     , municipio_cart_fim_cod
     , pack_had_util.get_municipio_desc(municipio_cart_fim_cod) municipio_cart_fim_cod_desc
     , cidadeender_cod
     , pack_had_util.get_municipio_desc(cidadeender_cod) cidadeender_cod_desc
     , cidnasc_cod
     , pack_had_util.get_municipio_desc(cidnasc_cod) cidnasc_cod_desc
  FROM funcionarios a,
       bancos b,
       agencias ag
 WHERE a.banco   = b.banco(+)
   AND a.banco   = ag.banco(+)
   AND a.agencia = ag.agencia(+)
/ 