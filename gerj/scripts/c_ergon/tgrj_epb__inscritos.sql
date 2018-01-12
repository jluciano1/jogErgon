CREATE OR REPLACE FUNCTION TGRJ_EPB__INSCRITOS(
    p_row_new   IN OUT INSCRITOS%rowtype,
    p_row_old   IN INSCRITOS%rowtype,
    p_inserting IN BOOLEAN,
    p_updating  IN BOOLEAN,
    p_deleting  IN BOOLEAN,
    p_mens OUT VARCHAR2 )
  RETURN BOOLEAN
IS
  --
BEGIN
  --
  IF p_inserting OR p_updating THEN
    IF p_row_new.flex_campo_08 < p_row_new.data_nascimento THEN
      p_mens                  := 'Data perícia médica deve ser posterior à data de nascimento.';
      RETURN (true);
    END IF;
  END IF;
RETURN (true);
--
END TGRJ_EPB__INSCRITOS;
/