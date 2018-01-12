create or replace FUNCTION ttgrj_rjadm00048(
    p_opcao in varchar2,
    p_secretaria in number)
  RETURN ttgrj_typ_rjadm00048_tab PIPELINED
  IS
    p_ResultSet  sys_refcursor;
    x_filename char(100);
    x_data_arq char(50);
    x_tam_arquivo char(50);
BEGIN
                open p_ResultSet FOR SELECT case when SUBSTR(FILENAME,-10) = 'Não EXISTE' then 'Erro na estrura de arquivos no servidor.' else FILENAME end as FILENAME, 
                               TO_CHAR(DATA_ARQ,'DD/MM/YYYY HH24:MI:SS') as DATA_ARQ, 
                               TO_CHAR(TAM_ARQUIVO,'999G999G999G999') as TAM_ARQUIVO 
                          FROM LISTA_ARQUIVO;
    POPULA_ARQUIVO(p_opcao, p_secretaria, p_ResultSet);
    LOOP
        fetch p_ResultSet into x_filename,x_data_arq,x_tam_arquivo;
        exit when p_ResultSet%notfound;
        pipe row ( ttgrj_typ_rjadm00048(x_filename,x_data_arq,x_tam_arquivo) ) ;
    END LOOP;
    CLOSE p_ResultSet;
RETURN;
END;
/