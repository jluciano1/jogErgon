BEGIN
  EXECUTE IMMEDIATE 'drop type ttgorj_typ_rjadm00042_tab';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -4043 THEN
      RAISE;
    END IF;
END;
/

create or replace type ttgorj_typ_rjadm00042 as object(
    numpens number,
    nome varchar2(300),
    tipo_benef varchar2(30),
    cota_valor varchar2(1),
    cota_percentual varchar2(1),
    cota_salminimo varchar2(1),
    dtini date,
    dtfim date,
    percentual number(7,4),
    valor number(15,2),
    valor_base number(15,2),
    diverge varchar2(1),
    valor_info number(15,2),
    percentual_info number(7,4),
    numfunc number,
    numvinc number,
    decisao_judicial varchar2(1),
    info varchar2(60)
)
/



create or replace type ttgorj_typ_rjadm00042_tab as table of ttgorj_typ_rjadm00042
/
