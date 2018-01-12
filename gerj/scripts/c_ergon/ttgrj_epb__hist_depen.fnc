CREATE OR REPLACE FUNCTION TTGRJ_EPB__HIST_DEPEN (
    P_ROW_NEW    IN OUT NOCOPY HIST_DEPEN%ROWTYPE,
    P_ROW_OLD    IN     HIST_DEPEN%ROWTYPE,
    P_INSERTING  IN     BOOLEAN,
    P_UPDATING   IN     BOOLEAN,
    P_DELETING   IN     BOOLEAN,
    P_MENS       OUT    NOCOPY VARCHAR2) RETURN BOOLEAN IS

    V_DEPENDENTES  DEPENDENTES%ROWTYPE;
    V_DEPENDENCIAS DEPENDENCIAS%ROWTYPE;

BEGIN
       
  IF P_UPDATING THEN

    BEGIN
      SELECT *
        INTO V_DEPENDENTES
        FROM DEPENDENTES D
       WHERE D.NUMFUNC = P_ROW_NEW.NUMFUNC
         AND D.NUMERO = P_ROW_NEW.NUMDEP;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        P_MENS := NULL;
        RETURN(TRUE);
    END;
    --

    BEGIN
      SELECT *
        INTO V_DEPENDENCIAS
        FROM DEPENDENCIAS DE
       WHERE DE.NUMFUNC = P_ROW_NEW.NUMFUNC
         AND DE.NUMDEP = P_ROW_NEW.NUMDEP
         AND DE.TIPODEPEN = 'IR'
         AND P_ROW_NEW.DTINI BETWEEN DE.DTINI AND nvl(DE.DTFIM, pack_hades.DATA_MAXIMA);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        P_MENS := NULL;
        RETURN(TRUE);
    END;
    --
    IF upper(V_DEPENDENTES.PARENTESCO) IN ('BISNETO','ENTEADO(A)','FILHO(A)','IRMAO','NETO','IRMÃO','MENOR POBRE') THEN
      IF ( upper(P_ROW_OLD.INVALIDO) = 'S' AND upper(P_ROW_NEW.INVALIDO) = 'N') THEN
        P_MENS := 'Não é possível alterar o campo "Inválido?" pois o dependente possui dependência de IR.';
        RETURN(TRUE);
      END IF;
        --
      IF ( upper(P_ROW_OLD.EXCEPCIONAL) = 'S' AND upper(P_ROW_NEW.EXCEPCIONAL) = 'N') THEN
        P_MENS := 'Não é possível alterar o campo "Deficiente?" pois o dependente possui dependência de IR.';
        RETURN(TRUE);
      END IF;

      IF ( upper(P_ROW_OLD.ESTUDANTE) = 'S' AND upper(P_ROW_NEW.ESTUDANTE) = 'N') THEN
        P_MENS := 'Não é possível alterar o campo "Estudante?" pois o dependente possui dependência de IR.';
        RETURN(TRUE);
      END IF;
      
      IF ( upper(P_ROW_OLD.UNIVERSITARIO) = 'S' AND upper(P_ROW_NEW.UNIVERSITARIO) = 'N') THEN
        P_MENS := 'Não é possível alterar o campo "Universitário?" pois o dependente possui dependência de IR.';
        RETURN(TRUE);
      END IF;
      
    END IF;
  
  END IF;

  RETURN (TRUE);

END;
/