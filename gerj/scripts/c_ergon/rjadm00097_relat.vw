CREATE OR REPLACE
VIEW RJADM00097_RELAT  AS
  SELECT rowidtochar(h.rowid) rowid_reg
       , h.id
       , t.id_agenda
       , t.id_lote
       , t.sis
       , t.trans
       , h.usuario
       , h.relatorio
       , h.data_hora
       , to_char(h.data_hora, 'dd/mm/yyyy hh24:mi:ss') data_hora_f
       , h.status
       , h.mensagem
       , h.emp_codigo
       , to_char(h.data_expiracao, 'dd/mm/yyyy hh24:mi:ss') data_expiracao_f
       , h.dias_expiracao
       , h.pid
       , h.dtiniexec
       , to_char(h.dtiniexec, 'dd/mm/yyyy hh24:mi:ss') dtiniexec_f
       , h.dtfimexec
       , to_char(dtfimexec, 'dd/mm/yyyy hh24:mi:ss') dtfimexec_f
       , h.dtcancel
       , to_char(h.dtcancel, 'dd/mm/yyyy hh24:mi:ss') dtcancel_f
       , h.dtcadastro
       , to_char(h.dtcadastro, 'dd/mm/yyyy hh24:mi:ss') dtcadastro_f
       , h.arquivo
       , h.msg_usu
       , h.msg_gestor
       , h.mime_type
       , TGRJ_RELAT_UTIL.GET_MENSAGEM_REPORT(h.ID) MENSAGEM_REPORT
  FROM  had_agenda_relat h, TGRJ_LOTE_REPORT t
  WHERE h.id    = t.ID_AGENDA (+)
  AND   usuario = NVL(flag_pack.get_usuario(), usuario)
/