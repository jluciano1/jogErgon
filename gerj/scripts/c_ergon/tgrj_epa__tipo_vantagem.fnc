prompt ***ATENÇÃO!!!*** Objeto TGRJ_EPA__TIPO_VANTAGEM não possui replace e deve ser mesclado manualmente com a versão existente no banco.
create 
FUNCTION "TGRJ_EPA__TIPO_VANTAGEM" (P_ROW_NEW    IN OUT NOCOPY TIPO_VANTAGEM%ROWTYPE,
                                    P_ROW_OLD    IN     TIPO_VANTAGEM%ROWTYPE,
                                    P_INSERTING  IN     BOOLEAN,
                                    P_UPDATING   IN     BOOLEAN,
                                    P_DELETING   IN     BOOLEAN,
                                    P_MENS       OUT    NOCOPY VARCHAR2) RETURN BOOLEAN IS
  --
BEGIN
  --
  IF (p_inserting OR p_updating) THEN
    IF (p_row_new.flex_campo_01 = 'S') THEN
      BEGIN
        INSERT INTO tgrj_gee (NOME, DT_CRIACAO, GEE)
        VALUES(p_row_new.nome, SYSDATE, p_row_new.vantagem);
      EXCEPTION WHEN OTHERS THEN 
        NULL;
      END;
    ELSIF (p_row_old.flex_campo_01 = 'S') AND (p_row_new.flex_campo_01 = 'N') THEN
      DECLARE
        v_tem_gee NUMBER;
      BEGIN
        SELECT 1 
          INTO v_tem_gee
          FROM tgrj_gee
         WHERE gee = p_row_old.vantagem;
         --
         p_mens := 'Alteração não permitida. Existe GEE cadastrada para este atributo.';         
         --
      EXCEPTION WHEN NO_DATA_FOUND THEN
        NULL;
      END;
    END IF;
  ELSE
    IF (p_row_old.flex_campo_01 = 'S') THEN
      p_mens := 'Existe GEE cadastrada para este atributo.';
    END IF;  
  END IF;
  --
  RETURN (TRUE);
END;
/