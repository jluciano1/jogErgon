BEGIN
  EXECUTE IMMEDIATE 'drop type ttgrj_typ_rjadm00073_tab';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -4043 THEN
      RAISE;
    END IF;
END;
/

CREATE OR REPLACE TYPE ttgrj_typ_rjadm00073
AS
  OBJECT
  (
    transacao VARCHAR2(60),
    tabela    VARCHAR(30),
    inclusao  NUMBER,
    alteracao NUMBER,
    exclusao  NUMBER,
    total     NUMBER);
/
  -----
CREATE OR REPLACE TYPE ttgrj_typ_rjadm00073_tab
AS
  TABLE OF ttgrj_typ_rjadm00073;
/