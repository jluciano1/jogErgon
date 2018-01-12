CREATE OR REPLACE VIEW tgrj_rjadm00077_vw
AS
  SELECT x.rowid_reg,
    x.cpfrhfolha,
    x.nomerhfolha,
    x.dtnascrhfolha,
    x.valorvan,
    x.valorliq,
    x.dtobito,
    x.nrregistroobito,
    x.nrcartorio,
    x.nrfolharegistroobito,
    x.numfunc,
    x.numvinc,
    x.mes_ano,
    x.setor,
    (SELECT h.flex_campo_03
    FROM hsetor_ h
    WHERE h.setor                                                          = x.setor
    AND pack_hades.eh_concomitante(h.dataini, h.datafim, sysdate, sysdate) = 1
    ) AS frequencia,
    setor_desc(pack_ergon.GET_SETOR_FUNC(x.numfunc, x.numvinc, x.dtobito), x.dtobito, flag_pack.get_empresa) nome_setor,
    setor
    || ' - '
    || setor_desc(x.setor, sysdate, flag_pack.get_empresa) AS desc_setor,
    x.orgao,
    x.dsd,
    orgao
    || ' - '
    || dsd AS desc_orgao,
    x.matricula_sape,
    x.situacao_func,
    x.banco,
    x.agencia,
    x.conta,
    x.cpfsisobi,
    x.refproc,
    x.nomesisobi,
    x.nomemaesisobi,
    x.nomemaerhfolha,
    x.dtnascsisobi,
    x.tiporel,
    x.dsc_motivo,
    x.ind_ver_fal,
    CASE
      WHEN x.cpfsisobi           = x.cpfrhfolha
      AND UPPER(x.nomesisobi)    = UPPER(x.nomerhfolha)
      AND UPPER(x.nomemaesisobi) = UPPER(x.nomemaerhfolha)
      AND UPPER(x.dtnascsisobi)  = UPPER(x.dtnascrhfolha)
      THEN 'S'
      ELSE 'N'
    END coincidente
  FROM
    (SELECT rowidtochar(fb.rowid) rowid_reg,
      s.cpfrhfolha,
      s.nomerhfolha,
      s.dtnascrhfolha,
      fb.valorvan,
      fb.valorliq,
      s.dtobito,
      s.nrregistroobito,
      s.nrcartorio,
      s.nrfolharegistroobito,
      s.numfunc,
      s.numvinc,
      fb.mes_ano,
      pack_ergon.GET_SETOR_FUNC(s.numfunc, s.numvinc, sysdate) AS setor,
      s.orgao,
      s.dsd,
      v.matricula matricula_sape,
      PACK_ERGON.GET_SITUACAO_FUNC(v.numfunc, v.numero, NULL, s.dtobito) situacao_func,
      fb.banco,
      fb.agencia,
      fb.conta,
      s.cpfsisobi,
      s.refproc,
      s.nomesisobi,
      s.nomemaesisobi,
      s.nomemaerhfolha,
      s.dtnascsisobi,
      s.tiporel,
      s.dsc_motivo,
      s.ind_ver_fal
    FROM tgrj_sisobi_rel s
    LEFT JOIN vinculos v
    ON s.numfunc  = v.numfunc
    AND s.numvinc = v.numero
    LEFT JOIN fitabanco fb
    ON fb.numfunc  = v.numfunc
    AND fb.numvinc = v.numero
    AND fb.numero  = 1
      /*tgrj_sisobi_rel s,
      vinculos v,
      fitabanco fb
      WHERE v.numfunc = fb.numfunc
      AND v.numero    = fb.numvinc
      AND v.numfunc   = s.numfunc
      AND v.numero    = s.numvinc
      AND fb.numero   = 1*/
    ) x
/