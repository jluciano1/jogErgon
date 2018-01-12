BEGIN
  EXECUTE IMMEDIATE 'drop type ttgrj_typ_rjadm00048_tab';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -4043 THEN
      RAISE;
    END IF;
END;
/

create or replace TYPE ttgrj_typ_rjadm00048
AS
  OBJECT
  (
    filename char(100),
    data_arq char(50),
    tam_arquivo char(50));
/
	
create or replace TYPE ttgrj_typ_rjadm00048_tab
AS
  TABLE OF ttgrj_typ_rjadm00048;
/