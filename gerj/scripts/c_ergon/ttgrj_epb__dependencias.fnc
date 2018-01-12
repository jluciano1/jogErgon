CREATE OR REPLACE FUNCTION TTGRJ_EPB__DEPENDENCIAS(
      P_ROW_NEW   IN OUT DEPENDENCIAS%ROWTYPE,
      P_ROW_OLD   IN DEPENDENCIAS%ROWTYPE,
      P_INSERTING IN BOOLEAN,
      P_UPDATING  IN BOOLEAN,
      P_DELETING  IN BOOLEAN,
      P_MENS OUT nocopy VARCHAR2 ) RETURN BOOLEAN IS

  V_HIS_DEPEN    HIST_DEPEN%ROWTYPE;
  V_DEPENDENTES  DEPENDENTES%ROWTYPE;
  
  V_IDADE NUMBER := 0;

BEGIN
  
  IF P_INSERTING OR P_UPDATING then
    
    BEGIN
      SELECT *
        INTO V_HIS_DEPEN
        FROM HIST_DEPEN H
       WHERE H.NUMFUNC = P_ROW_NEW.NUMFUNC
         AND H.NUMDEP = P_ROW_NEW.NUMDEP
         AND PACK_HADES.EH_CONCOMITANTE(H.DTINI, H.DTFIM, SYSDATE, SYSDATE) =1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      P_MENS := 'Esse dependente não possui Histórico.';
      RETURN(TRUE);
    END;
    --
    --
    BEGIN
      SELECT *
        INTO V_DEPENDENTES
        FROM DEPENDENTES D
       WHERE D.NUMFUNC = P_ROW_NEW.NUMFUNC
         AND D.NUMERO = P_ROW_NEW.NUMDEP;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      P_MENS := 'Dependente '||P_ROW_NEW.NUMDEP||' do servidor '||P_ROW_NEW.NUMFUNC||' não foi encontrado';
      RETURN(TRUE);      
    END;
    
    IF upper(V_DEPENDENTES.PARENTESCO) IN ('BISNETO','ENTEADO(A)','FILHO(A)','IRMAO','NETO','IRMÃO','MENOR POBRE') THEN
                      
      IF NVL(upper(P_ROW_NEW.TIPODEPEN),'N') = 'IR' AND (P_ROW_NEW.DTFIM IS NULL OR TRUNC(P_ROW_NEW.DTFIM) >= TRUNC(SYSDATE)) THEN
          
        IF NVL( upper(V_HIS_DEPEN.INVALIDO),'N') = 'N' AND  NVL( upper(V_HIS_DEPEN.EXCEPCIONAL),'N') = 'N' THEN
            
          IF NVL( upper(V_HIS_DEPEN.ESTUDANTE),'N') = 'N' AND NVL( upper(V_HIS_DEPEN.UNIVERSITARIO),'N')  = 'N' THEN
            V_IDADE := to_number(Trunc((months_between(sysdate, V_DEPENDENTES.DTNASC))/12));
               
            IF V_IDADE >= 21 THEN
              P_MENS := 'Dependente maior ou igual a 21 anos, não pode ter dependência de IR.';
              RETURN(TRUE);
            END IF;
          ELSE
            V_IDADE := to_number(Trunc((months_between(sysdate, V_DEPENDENTES.DTNASC))/12));
            IF V_IDADE >= 24 THEN
              P_MENS := 'Dependente maior ou igual a 24 anos, não pode ter dependência de IR.';
              RETURN(TRUE);
            END IF;     
            
          END IF;
          
        END IF;
        
      END IF;
      
    END IF;

  END IF;
  
  RETURN(TRUE);
      
END;
/