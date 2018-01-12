CREATE OR REPLACE 
PROCEDURE TGRJ_CARREGA_ATRIB_FINAN(P_ARQ IN BLOB, --default fileUpload
                                   P_NOME IN VARCHAR2, --default fileUpload
                                   P_TIPO IN VARCHAR2, --default fileUpload
                                   P_LAYOUT IN NUMBER, --layout
                                   P_DELIMITADOR IN VARCHAR2,
                                   P_ACAO IN NUMBER,
                                   P_ID_EXEC_AUDIT LOG_PROCESSO_HEADER.ID_EXEC%TYPE,
                                   P_MENS OUT VARCHAR2,
                                   P_NOME_RETORNO OUT VARCHAR2,
                                   P_ID_ROTINA_EXEC OUT HAD_ROTINA_EXEC.ID_ROTINA_EXEC%TYPE)
IS
  V_ARQ clob:= null;
  V_ID_TIPO_ROT varchar2(32);
  V_NOME VARCHAR2(100);
  V_REMOVE_ARQ UTL_FILE.FILE_TYPE;
  P_CAMINHO  varchar2(100):= pack_hades.get_opcao('Hades','WEB','DIRTEMP_NG'); --caminho
  --P_NOME_RETORNO VARCHAR2(200);
  --P_ID_ROTINA_EXEC HAD_ROTINA_EXEC.ID_ROTINA_EXEC%TYPE;
  v_checar_antes VARCHAR2(1);
  v_delimitador VARCHAR2(100);
  p_modo_carga VARCHAR2(1);
  
  PROCEDURE VERIFICA_NOME_ARQUIVO (P_ARQUIVO VARCHAR2) is
  begin
    -- Aqui o sistema é executado via Web
    -- Somente deve ser entrado o nome do arquivo.
    -- Se houver um diretório, será dado uma mensagem de erro
    IF INSTR(p_arquivo,'\') > 0 or INSTR(p_arquivo,'/')> 0 then
      ERGON_ERRO_PACK.TRATA_ERRO (99,'Na execução via Web do sistema somente deve ser informado o nome do arquivo, sem diretório. '||
             '"'||p_arquivo||'"' );
    end if;
  end VERIFICA_NOME_ARQUIVO ;  

  function VERIFICA_LAYOUT_ARQUIVOS(P_LAYOUT NUMBER, P_CAMINHO VARCHAR2, P_NOME VARCHAR2, v_checar_antes VARCHAR2) return BOOLEAN is
      v_file utl_file.file_type;
      v_file_name varchar2(100);
      v_tipo varchar2(30);
      v_result varchar2(10);
  BEGIN

    --
    -- Verifica se o layout foi escolhido
    --
    -- P_LAYOUT - numero do drpLayout
    if P_LAYOUT is null then
      ERGON_ERRO_PACK.TRATA_ERRO (99,'Escolha o layout.');
    end if;
    begin

      --v_file_name := NOME_ARQUIVO(p_nome);
      v_file_name := p_nome;

      V_TIPO      := 'de Carga';       
      v_file      := utl_file.fopen (p_caminho,v_file_name,'r');     
      --
      UTL_FILE.fclose(v_file);
      --
      v_file_name := substr(P_NOME, 1, instr(P_NOME, '.', -1)-1)||'.rej';
      V_TIPO      := 'de Rejeitados';
      v_file      := utl_file.fopen (p_caminho,v_file_name,'w');
      --
      -- Colocando espaço para o arquivo ter mais ZERO bytes se não ocorre erro no Forms 10g ao fazer UPLOAD
      --
      utl_file.put_line ( v_file, ' ' );
      --
      utl_file.fclose(v_file);
      --
      -- Colocando espaço para o arquivo ter mais ZERO bytes se não ocorre erro no Forms 10g ao fazer UPLOAD
      --
       v_file_name := substr(P_NOME, 1, instr(P_NOME, '.', -1)-1)||'.ac';
      V_TIPO      := 'de Rejeitados';
      v_file      := utl_file.fopen (p_caminho,v_file_name,'w');
      --
      -- Colocando espaço para o arquivo ter mais ZERO bytes se não ocorre erro no Forms 10g ao fazer UPLOAD
      --
      utl_file.put_line ( v_file, ' ' );
      --
      utl_file.fclose(v_file);
      if v_checar_antes = 'S' then
        v_file_name := substr(P_NOME, 1, instr(P_NOME, '.', -1)-1)||'.err';
        V_TIPO      := 'de Erros';
        v_file      := utl_file.fopen (p_caminho,v_file_name,'w');
        --
        -- Colocando espaço para o arquivo ter mais ZERO bytes se não ocorre erro no Forms 10g ao fazer UPLOAD
        --
        utl_file.put_line ( v_file, ' ' );
        --
        UTL_FILE.fclose(v_file);
        --
      end if;
    --
    return true;
    --
--    exception when others then
--       UTL_FILE.fclose(v_file);
--        ergon_erro_pack.trata_erro (99,'Erro para abrir o arquivo '||v_tipo||' '''||v_file_name||'''.');
--        return false;
    end;
  END VERIFICA_LAYOUT_ARQUIVOS;


BEGIN


  IF P_ACAO = 1 THEN
    v_checar_antes := 'S';
  END IF;

  IF P_LAYOUT IS NULL THEN
    p_mens := 'O layout do arquivo deve ser informado';
    RETURN;
  END IF;


  IF p_acao IS NULL THEN
    p_mens := 'A ação deve ser informada';
    RETURN;
  ELSIF p_acao NOT IN (1, 2, 3) THEN
    p_mens := 'Valor inválido informado para a ação';
    RETURN;
  END IF;
  
  
  IF p_acao = 3 AND P_ID_EXEC_AUDIT IS NULL THEN
    p_mens := 'Para desfazer a carga, o número da auditoria do processo de carga deve ser fornecido.';
    RETURN;
  END IF;


  v_nome:= pack_had_upload.gera_nomearq_temp(p_nome);

  p_nome_retorno:= v_nome;

  pack_had_upload.grava_blob_arquivo(p_arq,v_nome,p_tipo,p_caminho);

  begin

    select ID_TIPO_ROT
      into V_ID_TIPO_ROT
      from HAD_TIPO_ROTINA_EXEC
     WHERE SIGLA = 'Importação atributos financ';

  EXCEPTION
    when no_data_found then
      insert into HAD_TIPO_ROTINA_EXEC (SIGLA,DESCRICAO) values ('Importação atributos financ','Importação atributos financ');

      commit;

      select ID_TIPO_ROT
        into V_ID_TIPO_ROT
        from HAD_TIPO_ROTINA_EXEC
       WHERE SIGLA = 'Importação atributos financ';

  end;
  --
  VERIFICA_NOME_ARQUIVO(v_nome); 
  --
  -- Verifica layout e existencia de arquivos
  --
  if not VERIFICA_LAYOUT_ARQUIVOS(P_LAYOUT,P_CAMINHO,v_nome,v_checar_antes) then
   ergon_erro_pack.trata_erro (99,'Arquivo nao está no layout correto');
  end if;


  IF p_delimitador IS NULL THEN
    v_delimitador := 'NULL';
  ELSE
    v_delimitador := '''' || p_delimitador || '''';
  END IF;

  --
  -- VERIFICA CONSIGNATARIA
  --

  if p_acao = 1 then

    v_arq:= 'DECLARE'||chr(10)||
            'BEGIN'||chr(10)||
              'TGRJ_PACK_CARGA_ATRIB.VERIFICA(''' ||
                                                 v_nome            || ''',''' ||
                                                 p_tipo            || ''',''' ||
                                                 P_CAMINHO         || ''',' ||
                                                 P_LAYOUT          || ');' ||CHR(10)||

             'END;';

    --
    -- Checa o arquivo de carga
    --

  end if;

  --
  -- CARREGAR CONSIGNATARIA
  --

  if p_acao = 2 then

    v_arq:= 'DECLARE'||chr(10)||
            'BEGIN'||chr(10)||
              'TGRJ_PACK_CARGA_ATRIB.CARGA(''' ||
                                              v_nome            || ''',''' ||
                                              p_tipo            || ''',''' ||
                                              P_CAMINHO         || ''',' ||
                                              P_LAYOUT          || ');' ||CHR(10)||

             'END;';

  end if;

  --
  -- CARREGAR CONSIGNATARIA PENSIONISTA
  --

  if p_acao = 3 then

    v_arq:= 'DECLARE'||chr(10)||
            'BEGIN'||chr(10)||
              'TGRJ_PACK_CARGA_ATRIB.DESFAZ_CARGA(''' ||
                                                    v_nome            || ''',''' ||
                                                    p_tipo            || ''',''' ||                                                    
                                                    P_CAMINHO         || ''',' ||
                                                    P_LAYOUT          || ',' ||
                                                    P_ID_EXEC_AUDIT   || ');' ||CHR(10)||

             'END;';

  end if;


  PACK_EXEC_ROTINAS.AGENDA_EXECUCAO(V_ID_TIPO_ROT,
                                    SYSDATE,
                                    V_ARQ,
                                    FLAG_PACK.GET_USUARIO,
                                    FLAG_PACK.GET_ROLE ,
                                    FLAG_PACK.GET_EMPRESA ,
                                    FLAG_PACK.GET_SIS ,
                                    FLAG_PACK.GET_TRANSACAO ,
                                    null,
                                    null,
                                    null,
                                    p_id_rotina_exec);

end;
/