CREATE OR REPLACE PROCEDURE PGOV_ASSOCIA_CARGO_DISCIP (p_disciplina in varchar2, p_categoria in varchar2, p_subcategoria in varchar2, p_erro out varchar2, p_mens out varchar2) IS
/**************** INICIO_HELP: ****************
----------------------------------------------------
Nome:
  PGOV_ASSOCIA_CARGO_DISCIP
Propósito:
  Esta procedure tem por finalidade a geração de 
  combinações das categorias e subcategorias das 
  Disciplinas, segundo parametros informados.
  Tendo como campo obrigatório a Disciplina a ser 
  considerada.
Parâmetros:
  p_disciplina:
    Disciplina - varchar2(20);
  p_categoria:
    Categoria - varchar2(20);
  p_subcategoria:
    Subcategoria - varchar2(20);
Utilização:
  Botão gerar validade, no objeto das Disciplinas.
----------------------------------------------------
***************** FINAL_HELP: ****************/
  n_reg_1 number;

  BEGIN
    p_erro := 'N';
    
    IF p_disciplina IS null THEN
      p_erro := 'S';
      p_mens := 'Disciplina deve ser fornecida.';
    END IF;
   
    INSERT INTO RH_DISCIP_CARGO (COD_DISCIPLINA, NOMECARGO, CATEGORIA, SUBCATEGORIA, CARGO)
    SELECT p_disciplina, C.NOME, C.CATEGORIA, C.SUBCATEGORIA, C.CARGO
    FROM CARGOS C
    WHERE (C.CATEGORIA = p_categoria OR p_categoria IS NULL) AND
          (C.SUBCATEGORIA = p_subcategoria OR p_subcategoria IS NULL)
    MINUS
    SELECT COD_DISCIPLINA, NOMECARGO, CATEGORIA, SUBCATEGORIA, CARGO
    FROM RH_DISCIP_CARGO
    WHERE COD_DISCIPLINA = p_disciplina;

    n_reg_1 := sql%rowcount;

    COMMIT;

    IF nvl(n_reg_1,0) = 0 THEN
      p_mens := 'Não foram cadastrados novos registros.';
      p_erro := 'S';
    ELSIF nvl(n_reg_1,0) = 1 THEN
      p_mens := 'Foi cadastrado 1 novo registro.';
    ELSE
      p_mens := 'Foram gerados '||n_reg_1||' novos registros.';
    END IF;
  END;
/