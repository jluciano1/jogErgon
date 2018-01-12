create or replace procedure TGRJ_CALCULA_RATEIO_PENS_ASYNC (
	P_NUMFUNC  IN number,
	P_NUMVINC IN NUMBER
) is 
pragma autonomous_transaction;
begin
	TGRJ_CALCULA_RATEIO_PENSAO (P_NUMFUNC, P_NUMVINC, NULL);
end;
/