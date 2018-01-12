create or replace PROCEDURE POPULA_ARQUIVO 
 (p_opcao      varchar2,
  p_secretaria number,
  p_ResultSet  OUT sys_refcursor) IS
    
	V_DIR  		VARCHAR2(500);
	V_COUNT 	NUMBER;
	V_PRIVIL 	VARCHAR2(1);
    V_ARQ_NOME 	VARCHAR2(50); 
    V_ARQ_TAM 	VARCHAR2(50);
    V_ARQ_DTA 	VARCHAR2(50);
    p_mens   varchar2(1000);
BEGIN

	SELECT PRIVIL
      INTO V_PRIVIL
      FROM USUARIO
     WHERE USUARIO = FLAG_PACK.GET_USUARIO;

	IF  FLAG_PACK.GET_EMPRESA = 1 
    AND PGOV_GET_SUBEMP_USUARIO(FLAG_PACK.GET_USUARIO) = 0 
	AND V_PRIVIL = 'N' THEN
		p_mens := 'Usuário com setor não cadastrado na Tela de Cadastro de Usuarios. Favor solicitar correção.';
	ELSE

		V_DIR := RETORNA_DIRETORIO_ARQUIVO(p_opcao, p_secretaria, 0, V_PRIVIL, p_mens);

		IF V_DIR IS NOT NULL THEN
			GET_LISTA_DIRETORIO(V_DIR);

          SELECT COUNT(*) INTO V_COUNT FROM LISTA_ARQUIVO;

		  IF V_COUNT > 0 THEN  

                open p_ResultSet FOR SELECT case when SUBSTR(FILENAME,-10) = 'Não EXISTE' then 'Erro na estrura de arquivos no servidor.' else FILENAME end as FILENAME, 
                               TO_CHAR(DATA_ARQ,'DD/MM/YYYY HH24:MI:SS') as DATA_ARQ, 
                               TO_CHAR(TAM_ARQUIVO,'999G999G999G999') as TAM_ARQUIVO 
                          FROM LISTA_ARQUIVO;
            
                DELETE FROM LISTA_ARQUIVO;
                
			ELSE
				p_mens := 'O diretório não possui arquivos.';
			END IF;
		END IF;
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		p_mens := 'Falha na POPULA_ARQUIVO. '||SQLERRM;
END;
/