CREATE OR REPLACE 
FUNCTION EP__PROM_PERMITE_CAD_FICHARESP(P_REG PROM_RESPOSTAS_FICHA%ROWTYPE)
RETURN NUMBER IS

  v_count NUMBER;

BEGIN

  SELECT COUNT(*)
  INTO   v_count
  FROM   PROM_PROCESSO
  WHERE  PROCESSO = P_REG.PROCESSO
  AND    EMP_CODIGO = P_REG.EMP_CODIGO
  AND    FASE IN ('Avaliação', 'Recurso', 'Reconsideração');

  RETURN CASE WHEN v_count = 0 THEN 0 ELSE 1 END;

END;
/