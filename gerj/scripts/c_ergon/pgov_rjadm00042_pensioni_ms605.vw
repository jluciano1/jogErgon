CREATE OR REPLACE FORCE VIEW "C_ERGON"."PGOV_RJADM00042_PENSIONI_MS605" ("NUMERO", "NOME", "CPF", "FLEX_CAMPO_04", "TIPOPAG", "BANCO",
"AGENCIA", "CONTA", "FLEX_CAMPO_50", "FLEX_CAMPO_49", "NUMFUNC", "NUMVINC") AS
	SELECT numero,
        nome,
        cpf,
        flex_campo_04,
        tipopag,
        banco,
        agencia,
        conta,
        flex_campo_50,
        flex_campo_49,
        numfunc,
        numvinc
	FROM pensionistas
/
