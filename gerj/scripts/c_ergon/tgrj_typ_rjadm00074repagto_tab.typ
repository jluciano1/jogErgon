BEGIN
  EXECUTE IMMEDIATE 'drop type TGRJ_TYP_RJADM00074REPAGTO_TAB';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -4043 THEN
      RAISE;
    END IF;
END;
/

CREATE OR REPLACE 
TYPE TGRJ_TYP_RJADM00074REPAGTO
AS OBJECT  (
              NUMFUNC	NUMBER(9,0)
             ,NUMVINC	NUMBER(8,0)
             ,NUMDEPEN	NUMBER(2,0)
             ,NUMPENS	NUMBER(2,0)
             ,NUMREP	NUMBER(8,0)
             ,VALORLIQ	NUMBER(11,2)
             ,EMP_CODIGO	NUMBER(2,0)
             ,SUBEMP_CODIGO	NUMBER(4,0)
             ,VALOR	NUMBER(11,2)
             ,PERCENTUAL	NUMBER(5,2)
             ,NUMFITA	NUMBER
             ,LANCAMENTO	NUMBER(11,0)
             ,MES_ANO	DATE
             ,NUMERO	NUMBER(8,0)
             ,AGENCIA_SALARIO	VARCHAR2(2000)
             ,CONTA_SALARIO	VARCHAR2(2000)
             ,AGENCIA	VARCHAR2(7)
             ,CONTA	VARCHAR2(20)
             ,NOME	VARCHAR2(300)
             ,SITUACAO	VARCHAR2(7)
)
/

CREATE OR REPLACE
TYPE TGRJ_TYP_RJADM00074REPAGTO_TAB AS TABLE OF TGRJ_TYP_RJADM00074REPAGTO
/
