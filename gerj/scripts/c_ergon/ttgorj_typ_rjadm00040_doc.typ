BEGIN
  EXECUTE IMMEDIATE 'drop type ttgorj_typ_rjadm00040_doc_tab';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -4043 THEN
      RAISE;
    END IF;
END;
/

create or replace type ttgorj_typ_rjadm00040_doc as object
( 
ROWID_REG   VARCHAR2(100), 
NUMFUNC     NUMBER       ,
NUMVINC     NUMBER       ,
NUMPENS     NUMBER       ,
TIPOBENEF   VARCHAR2(100), 
TIPODOC     VARCHAR2(100), 
APRESENTOU  VARCHAR2(1)  
)
/
create or replace type ttgorj_typ_rjadm00040_doc_tab as table of ttgorj_typ_rjadm00040_doc
/
