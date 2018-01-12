create or replace PROCEDURE TGRJ_AGENDA_ROT_PROC

  (P_GRUPO          IN PARAMETROS_ROTINAS.GRUPO%TYPE,
   P_SIS            IN PARAMETROS_ROTINAS.SIS%TYPE,
   P_ROTINA         IN ROTINAS.ROTINA%TYPE,
   P_ARQUIVO        IN ROTINAS.ARQUIVO%TYPE,
   P_DIAS_EXPIRACAO IN NUMBER,
   P_PERIDIOCIDADE  IN NUMBER,
   P_AGENDAMENTO    IN DATE,
   P_HORA           IN DATE,
   P_REPETICAO      IN NUMBER,
   P_MENS           OUT VARCHAR2
   )
IS

  V_ID            NUMBER;
  V_EMPRESA       pgov_agenda_rot_param.VALOR%TYPE;
  V_REG           PARAMETROS_ROTINAS%ROWTYPE;
  I               NUMBER;
  V_TIPO          PARAMETROS_ROTINAS.TIPO%TYPE;
  V_DATA_HORA     DATE;

  CURSOR C_PARAM IS
    SELECT *
      FROM PARAMETROS_ROTINAS
     WHERE SIS = P_SIS
       AND GRUPO = P_GRUPO
       AND ROTINA = P_ROTINA
     ORDER BY SEQ;

BEGIN

    SELECT TO_DATE(TO_CHAR(P_AGENDAMENTO, 'DD/MM/YYYY')||' '|| HORA, 'DD/MM/YYYY HH24:MI') INTO V_DATA_HORA
   FROM(
   SELECT TO_CHAR(P_HORA, 'HH24:MI') HORA FROM DUAL);

  FOR V_REPETICAO IN 1 .. P_REPETICAO LOOP

    SELECT SEQ_ROTINAS.NEXTVAL INTO V_ID FROM DUAL;


    SELECT DISTINCT TIPO INTO V_TIPO
      FROM PARAMETROS_ROTINAS
     WHERE SIS = P_SIS
       AND GRUPO = P_GRUPO
       AND ROTINA = P_ROTINA;

    BEGIN
      INSERT INTO PGOV_AGENDA_ROTINA (
          ID, 
          USUARIO, 
          GRUPO, 
          SIS, 
          ROTINA,
          DATA_HORA, 
          STATUS, 
          EMP_CODIGO, 
          DIAS_EXPIRACAO, 
          ARQUIVO, 
          TIPO)
      VALUES (
          V_ID, 
          FLAG_PACK.GET_USUARIO, 
          P_GRUPO, 
          P_SIS, 
          P_ROTINA, 
          V_DATA_HORA + (P_REPETICAO - 1) * P_PERIDIOCIDADE, 
          'EM FILA', 
          FLAG_PACK.GET_EMPRESA, 
          P_DIAS_EXPIRACAO,
          P_ARQUIVO, 
          V_TIPO );
          COMMIT;
    EXCEPTION
      WHEN OTHERS THEN 
        P_MENS := 'ERRO NA INSERCAO PGOV_AGENDA_ROTINA 12' || sqlerrm;
        RETURN;
    END;
  END LOOP;

   FOR V_REG IN C_PARAM LOOP
    BEGIN
          IF UPPER(V_REG.DESCRICAO) = 'DESNAME' THEN
            INSERT INTO pgov_agenda_rot_param (
                ID, 
                PARAMETRO, 
                VALOR,
                SEQ_PARAM) 
            VALUES (
                V_ID, 
                V_REG.DESCRICAO, 
                flag_pack.get_usuario||'_'||P_ROTINA||'_'||TO_CHAR(SYSDATE,'DDMMYYYYHH24MISS'), 
                V_REG.SEQ);

       ELSIF UPPER(V_REG.DESCRICAO) = 'USUARIO' THEN
            INSERT INTO pgov_agenda_rot_param (
                ID, 
                PARAMETRO, 
                VALOR,
                SEQ_PARAM) 
            VALUES (
                V_ID, 
                V_REG.DESCRICAO, 
                flag_pack.get_usuario, 
                V_REG.SEQ);
        ELSE            
            INSERT INTO pgov_agenda_rot_param (
                ID, 
                PARAMETRO, 
                VALOR,
                SEQ_PARAM) 
            VALUES (
                V_ID, 
                V_REG.DESCRICAO, 
                V_REG.VALOR, 
                V_REG.SEQ);        
          END IF;

      EXCEPTION
      WHEN OTHERS THEN
        P_MENS := 'ERRO NA INSERÇÃO pgov_agenda_rot_param' || sqlerrm;
        RETURN;
      END;
  END LOOP;
END;
/