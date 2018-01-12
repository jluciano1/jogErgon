create or replace PROCEDURE TGRJ_PROCESSA_OBITO(
    p_numfunc            IN NUMBER,
    p_data_obito         IN DATE,
    p_num_cartorio       IN VARCHAR2,
    p_num_registro       IN VARCHAR2,
    p_num_registro_obito IN VARCHAR2,
    p_falecimento        IN VARCHAR2,
    p_motivo             IN VARCHAR2,
    p_cpf                IN VARCHAR2,
    p_refproc            IN VARCHAR2 )
IS
  verifica_obito FUNCIONARIOS.TIPODOC_CERT_FIM%TYPE;
  verifica_falec TGRJ_SISOBI_REL.IND_VER_FAL%TYPE;
BEGIN
  BEGIN
    SELECT ind_ver_fal
    INTO verifica_falec
    FROM tgrj_sisobi_rel
    WHERE refproc  = p_refproc
    AND (cpfsisobi = p_cpf
    OR cpfrhfolha  = p_cpf);
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    ergon_erro_pack.trata_erro(99,'Problemas ao localizar funcionário: ' || p_cpf);
  WHEN OTHERS THEN
    ergon_erro_pack.trata_erro(99,'O sistema encontrou um problema: ' || sqlerrm);
  END;
  --
  BEGIN
    IF verifica_falec IS NULL OR verifica_falec = 'R' THEN
      IF p_falecimento = 'S' AND p_motivo IS NULL THEN
        --
        UPDATE FUNCIONARIOS
        SET TIPODOC_CERT_FIM = 'OBITO',
          DT_CERT_FIM        = p_data_obito,
          CARTORIO_CERT_FIM  = p_num_cartorio,
          LIVRO_CERT_FIM     = p_num_registro,
          FOLHA_CERT_FIM     = p_num_registro_obito
        WHERE NUMERO         = p_numfunc;
        COMMIT;
        --
        UPDATE TGRJ_SISOBI_REL
        SET IND_VER_FAL = p_falecimento
        WHERE refproc   = p_refproc
        AND (cpfsisobi  = p_cpf
        OR cpfrhfolha   = p_cpf);
        COMMIT;
      ELSIF p_falecimento = 'S' AND p_motivo IS NOT NULL THEN
        ergon_erro_pack.trata_erro(99,'Limpe o campo "Motivo da não confirmação".');
      ELSIF p_falecimento IS NULL AND p_motivo IS NOT NULL THEN
        ergon_erro_pack.trata_erro(99,'Necessário preencher o campo "Confirma falecimento".');
      ELSIF p_falecimento = 'N' THEN
        IF p_motivo      IS NULL THEN
          ergon_erro_pack.trata_erro(99,'Preencha o campo motivo.');
        ELSE
          UPDATE TGRJ_SISOBI_REL
          SET IND_VER_FAL = p_falecimento,
            dsc_motivo    = p_motivo
          WHERE refproc   = p_refproc
          AND (cpfsisobi  = p_cpf
          OR cpfrhfolha   = p_cpf);
          COMMIT;
        END IF;
      ELSIF p_falecimento = 'R' THEN
        ergon_erro_pack.trata_erro(99,'Escolha outra opção.');
      ELSIF p_falecimento IS NULL THEN
        ergon_erro_pack.trata_erro(99,'Campo confirmação de falecimento não pode ser nulo.');
      END IF;
    ELSE
      ergon_erro_pack.trata_erro(99,'Este funcionário já possui a opção "' || verifica_falec || '" cadastrada e não pode ser alterada por sistema');
    END IF;
  END;
END;
/