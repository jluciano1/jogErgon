BEGIN
  EXECUTE IMMEDIATE 'drop type ttgorj_typ_rjadm00007_tab';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -4043 THEN
      RAISE;
    END IF;
END;
/

create or replace type ttgorj_typ_rjadm00007 as object
( numfunc          number,
  nome             varchar2(2000),
  numero           number,
  id_func          varchar2(100),
  dtexerc          date, 
  orgao_ext_req    varchar2(2000), 
  funcao_req       varchar2(2000),  
  tipoorg_req      varchar2(2000),  
  tipo_req         varchar2(2000),  
  tipo_onus_req    varchar2(2000), 
  tipo_ressarc_req varchar2(2000), 
  emp_codigo       number, 
  flex_campo_08    varchar2(2000))
/
create or replace type ttgorj_typ_rjadm00007_tab as table of ttgorj_typ_rjadm00007
/
