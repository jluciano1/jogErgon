create or replace PROCEDURE tgrj_desbloq_regra_de_pensao(
        P_FLEGADO     IN HAD_TYP_ARRAY_VARCHAR2
       
)
IS
cont        NUMBER      := p_flegado.count;
BEGIN
  FOR i IN 1..cont
  LOOP
      BEGIN
       UPDATE REGRAS_PENSAO SET flex_campo_13 = 'N' WHERE nvl(flex_campo_13, 'S') = 'S' AND rowid = rowidtochar(p_flegado(i));  
      END;
   
  END LOOP;
END;
/