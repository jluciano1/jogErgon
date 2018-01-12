create or replace FUNCTION RETORNA_DIRETORIO_ARQUIVO(P_OPCAO varchar2,P_SUBEMPRESA varchar2, P_FUNCAO IN NUMBER DEFAULT 0, P_PRIVIL VARCHAR2, p_mens out varchar2) RETURN varchar2 IS 

-- Função para montar o endereço do arquivo para ser utilizado pela dependendo da Função.
-- P_FUNCAO = 0 para utilizar na GET_LISTA_DIRETORIO
-- P_FUNCAO = 1 para utilizar na PACK_10G.DOWNLOAD_FROM_AS

-- OBS: O endereço para buscar a lista de arquivos via banco é diferente do endereço para buscar o arquivo
-- para download via aplicação. Para isso existe o parametro P_FUNCAO.

	V_DIRETORIO_BASE 	    VARCHAR2(200);
	V_EMPRESA 				VARCHAR2(10);
	V_SUBEMPRESA 			VARCHAR2(10);

BEGIN

	IF P_FUNCAO = 0 THEN
		--V_DIRETORIO_BASE := '/home/ergon/relatoriodestino/informacoesanuais';
		V_DIRETORIO_BASE := '/nfs/relatorios/informacoesanuais';
	ELSIF P_FUNCAO = 1 THEN
		--V_DIRETORIO_BASE := '/local/archon/web/temp/relatorio_seplag/informacoesanuais';
		V_DIRETORIO_BASE := '/nfs/relatorios/informacoesanuais';
	ELSE
		p_mens := 'Falha na passagem de parametro na Função RETORNA_DIRETORIO_ARQUIVO.';
		---RAISE FORM_TRIGGER_FAILURE;
	END IF;

	V_EMPRESA    := LPAD(TO_CHAR(FLAG_PACK.GET_EMPRESA),2,'0');

	-- if's manipulando as variÃ¡veis para bater com a estrutura dos diretorios 
	IF V_EMPRESA = '01' THEN
		IF P_OPCAO = 'DIRF' AND PGOV_GET_SUBEMP_USUARIO(FLAG_PACK.GET_USUARIO) NOT IN (11,17) THEN
			IF P_PRIVIL = 'S' AND P_SUBEMPRESA IN (11,17)THEN
				V_SUBEMPRESA := LPAD(TO_CHAR(P_SUBEMPRESA),2,'0');
		  ELSE
			  V_SUBEMPRESA := '00';
			END IF;
		ELSE
			IF P_PRIVIL = 'S' THEN
				IF P_SUBEMPRESA IS NOT NULL THEN
					V_SUBEMPRESA := LPAD(TO_CHAR(P_SUBEMPRESA),2,'0');
				ELSE
					p_mens := 'É necessário escolher a secretaria.';
					RETURN (NULL);
				END IF;
			ELSE
				V_SUBEMPRESA := LPAD(TO_CHAR(PGOV_GET_SUBEMP_USUARIO(FLAG_PACK.GET_USUARIO)),2,'0');
			END IF;
		END IF;
	ELSE
		V_SUBEMPRESA := '00';
	END IF;

	-- retorna o diretorio montado
	RETURN(V_DIRETORIO_BASE||'/'||V_EMPRESA||V_SUBEMPRESA||'/'||P_OPCAO);

EXCEPTION
	WHEN OTHERS THEN
	p_mens := 'Erro na RETORNA_DIRETORIO_ARQUIVO. '||sqlerrm;
END;
/