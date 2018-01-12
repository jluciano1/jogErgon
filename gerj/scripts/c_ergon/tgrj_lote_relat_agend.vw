CREATE OR REPLACE VIEW tgrj_lote_relat_agend AS
SELECT rowidtochar(h.rowid) AS rowid_reg,
    h.id,
    l.id_lote,
    l.trans,
    h.data_hora,
    h.relatorio,
    h.status,
    h.dtiniexec,
    h.dtfimexec,
    h.arquivo
  FROM tgrj_lote_report l,
    had_agenda_relat h
  WHERE l.id_agenda = h.id
/