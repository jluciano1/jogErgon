BEGIN
  EXECUTE IMMEDIATE 'drop type ttgrj_typ_tgrjadm00047_tab';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -4043 THEN
      RAISE;
    END IF;
END;
/

CREATE OR REPLACE TYPE ttgrj_typ_tgrjadm00047
AS
  object
  (
    TIPO      VARCHAR2(30),
    DESCRICAO VARCHAR2(100) )
/

CREATE OR REPLACE TYPE ttgrj_typ_tgrjadm00047_tab
IS
  TABLE OF TTGRJ_TYP_TGRJADM00047
/