CREATE OR REPLACE
PACKAGE BODY TGRJ_PACK_CARGA_FERIAS IS
  v_chave number;
  v_numero_layout number;
  v_arquivo varchar2(200);
  v_rejeitados varchar2(200);
  v_aceitos varchar2(200);
  v_arq_erros varchar2(200);
  v_modo_carga varchar2(1);
  v_cont number;
  v_cria_grupo_eleitos varchar2(1) := 'S';
  --
  v_numero_linhas       number;
  v_numero_linhas_erro  number;
  v_numero_funcionarios number;
  v_numero_vantagens    number;
  v_erros_vantagens     number;
  v_total_valor         number;
  v_total_valor2         number;
  v_total_valor3         number;
  v_total_valor4         number;
  v_total_valor5         number;
  v_total_valor6         number;
  --
  v_texto_relatorio varchar2(2000);
  --

  --
  -- Variáveis internas para guardar o layout do arquivo de carga
  --
  -- Caractere delimitador (se for nulo, as colunas são por posição
  car_delimitador carga_layout.delimitador%type;
  -- Definições das colunas do arquivo
  col_numfunc       carga_colunas%rowtype;
  col_numvinc       carga_colunas%rowtype;
  col_chaveperaqfer carga_colunas%rowtype;
  col_dtini         carga_colunas%rowtype;
  col_dtfim         carga_colunas%rowtype;
  col_abono         carga_colunas%rowtype;
  col_adiantdterc   carga_colunas%rowtype;
  col_adiantsal     carga_colunas%rowtype;
  col_emprestimo    carga_colunas%rowtype;
  col_totdias       carga_colunas%rowtype;
  col_inifimanono   carga_colunas%rowtype;
  col_obs           carga_colunas%rowtype;
  col_mes_ano_folha carga_colunas%rowtype;
  col_numfolha      carga_colunas%rowtype;
  col_pontpubl      carga_colunas%rowtype;
  col_emp_codigo    carga_colunas%rowtype;
  col_pontlei       carga_colunas%rowtype;
  col_dtprevfim     carga_colunas%rowtype;
  col_abono_const   carga_colunas%rowtype;
  col_flex_campo_01 carga_colunas%rowtype;
  col_flex_campo_02 carga_colunas%rowtype;
  col_flex_campo_03 carga_colunas%rowtype;
  col_flex_campo_04 carga_colunas%rowtype;
  col_flex_campo_05 carga_colunas%rowtype;
  col_hora_entrada  carga_colunas%rowtype;
  col_hora_saida    carga_colunas%rowtype;
  col_id_reg        carga_colunas%rowtype;
  v_existe          varchar2(1) := null;

  /*
  *******************************************************************************
  * FUNCTION TRUNCA_SQLERRM
  *   Trunca mensagen de erro do banco.
  * Entradas: P_ERRO - mensagem de erro
  * Saída: mensagem de erro truncada.
  *******************************************************************************
  */
    FUNCTION TRUNCA_SQLERRM (P_ERRO VARCHAR2)
      RETURN VARCHAR2 IS
      STR_AUX VARCHAR2(2000);
    BEGIN
      STR_AUX := SUBSTR(REPLACE (P_ERRO, 'ORA-20000: ', ''), 1,
                     INSTR(REPLACE (P_ERRO, 'ORA-20000: ', ''), 'ORA', 2)-2);

      STR_AUX := REPLACE (STR_AUX, 'ERG--20000 :', '');

      RETURN (NVL(STR_AUX,P_ERRO));
    END;

  /*
  *******************************************************************************
  * FUNCTION GRAVA_ARQUIVO_BLOB
  * Grava no banco, um arquivo em disco.
  * Entradas:
  * P_ARQ: variável do tipo BLOB com o conteúdo do arquivo
  * P_NOME_ARQ: nome do arquivo;
  * P_DIR_LEITURA: diretório onde está o arquivo
  * Saída: mensagem de erro truncada.
  *******************************************************************************
  */
    --
/*
    PACK_HAD_DOWNLOAD.GRAVA_ARQUIVO_BLOB(VARQUIVO_BLOB, SUBSTR(PNOME, 1, INSTR(PNOME, '.', -1)-1)||'.err', PACK_HADES.GET_OPCAO('Hades','WEB','DIRTEMP_NG'));
    --
    -- INSERT DO ARQUIVO DE ERROS
    INSERT INTO HAD_ARQ_DOWNLOAD (ID_ROTINA_EXEC,
                                  DESCRICAO,
                                  NOME_ARQUIVO,
                                  MIME_TYPE,
                                  ARQUIVO,
                                  DATA_EXPIRACAO)
                          VALUES (PACK_EXEC_ROTINAS.GET_ID_ROTINA_EXEC ,
                                  'ARQUIVO DE VERIFICAÇÃO',
                                  SUBSTR(PNOME, 1, INSTR(PNOME, '.', -1)-1)||'.err',
                                  PTIPO,
                                  VARQUIVO_BLOB,
                                  TRUNC(SYSDATE)+1);
*/
  /*
  *******************************************************************************
  * PROCEDURE grava_mensagem
  *   Procedimento para cadastrar mensagens na auditoria de processos e dar o COMMIT.
  * Entradas: P_ID_EXEC - Chave da auditoria
  *           P_MENS - A mensagem a ser gravada
  * Saída:
  *******************************************************************************
  */
  PROCEDURE grava_mensagem (P_ID_EXEC IN LOG_PROCESSO_HEADER.ID_EXEC%TYPE,
                            P_MENS IN LOG_PROCESSO_DETAIL.TEXTO%TYPE)
  IS
    --
  BEGIN
    --
    log_pack.insere_log_detail(P_ID_EXEC, P_MENS ||' : '
                               ||TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS'));
    --
    COMMIT;
    --
  END grava_mensagem;
  --
  /*
  *******************************************************************************
  * PROCEDURE GERA_RELATORIOS
  *   Sub-rotina para criar os relatórios de aceitos e rejeitados.
  * Entradas: p_opcao - 'C'  relatório de carga
  *                     'V'  relatório de verificação
  * Saída:
  *******************************************************************************
  */
  Procedure gera_relatorios(P_CAMINHO         IN VARCHAR2
                            ,P_OPCAO          IN VARCHAR2
                            ,p_arq_rejeitados IN VARCHAR2
                            ,p_arq_aceitos    IN VARCHAR2
                            ,p_arq_erros      IN VARCHAR2
                            ,p_modo_carga     IN VARCHAR2
                            ,P_CHAVE          IN carga_ferias_temp.CHAVE%TYPE
                            ,P_CHAVE_LOG      IN log_processo_header.id_exec%TYPE) is
    v_file utl_file.file_type;
    v_nome_layout carga_layout.nome%type;
    v_cont_rejeitados number;
    v_cont_aceitos number;
    v_mens  varchar2(2000);
    v_existe_eleito  number;
    v_eleitos_grav   number;
    v_eleitos        grupo_eleitos.grupo%TYPE;
    v_chave          carga_ferias_temp.CHAVE%TYPE;

    v_modo_carga     VARCHAR2(1);

    cursor cur_rejeitados is
      select linha,erro,texto_linha from C_ERGON.carga_ferias_temp
      where chave=v_chave and erro is not null
      order by linha;

    cursor cur_aceitos is
      select linha,numfunc,numvinc,dtini,dtfim,
             flex_campo_01,flex_campo_02,flex_campo_03,flex_campo_04,flex_campo_05,erro,texto_linha 
      from c_ergon.carga_ferias_temp
      where chave=v_chave and erro is null
      order by linha;

  begin

    v_modo_carga := p_modo_carga;

    v_chave := P_CHAVE;
    -- pega nome do layout
    begin
      select nome into v_nome_layout
      from carga_layout
      where numero=v_numero_layout;
    exception
      when others then v_nome_layout:=null;
    end;
    --
    -- Cria arquivo de erros
    --
    grava_mensagem (P_CHAVE_LOG, 'Criando o arquivo de erros: '||p_arq_erros);
    v_file:=utl_file.fopen(P_CAMINHO, p_arq_erros,'w');
    --v_file:=FILEPACK.fopen(v_arq_erros,'w');

    -- Preenche relatório
    if p_opcao='V' then
      utl_file.put_line(v_file,'REGISTROS COM ERROS NA VERIFICAÇÃO DO ARQUIVO');
    else
      if v_modo_carga <> 'D' then 
        utl_file.put_line(v_file,'REGISTROS COM ERROS NA CARGA DE FREQUÊNCIAS');
      else
        utl_file.put_line(v_file,'REGISTROS COM ERROS AO DESFAZER A CARGA DE FREQUÊNCIAS');
      end if;
    end if;
    utl_file.put_line(v_file,'');
    utl_file.put_line(v_file,'ARQUIVO: '||upper(v_arquivo));
    utl_file.put_line(v_file,'LAYOUT: '||upper(v_nome_layout));
    if p_opcao='C' and v_modo_carga='I' then
        utl_file.put_line(v_file,'MODO DE CARGA: Somente inserir registros novos');
    elsif p_opcao='C' and v_modo_carga='A' then
        utl_file.put_line(v_file,'MODO DE CARGA: Inserir registros novos e sobrescrever os já existentes');
    elsif p_opcao='C' and v_modo_carga='D' then
        utl_file.put_line(v_file,'MODO DE CARGA: Desfazer carga');
    elsif p_opcao='C' and v_modo_carga='E' then
        utl_file.put_line(v_file,'MODO DE CARGA: Encerramento de Frequências');
    end if;
    utl_file.put_line(v_file,'DATA: '||to_char(sysdate,'dd/mm/yyyy - HH24:MI'));
    utl_file.put_line(v_file,'');
    utl_file.put_line(v_file,'');
    utl_file.put_line(v_file,'Número de linhas do arquivo: '||to_char(v_numero_linhas));
    --
    select count(*) into v_cont_rejeitados
    from carga_ferias_temp
    where chave=v_chave and erro is not null;
    --
    utl_file.put_line(v_file,'Número de registros rejeitados: '||to_char(v_cont_rejeitados));
    utl_file.put_line(v_file,'');
    utl_file.put_line(v_file,'');
    --
    if v_cont_rejeitados>0 then
      utl_file.put_line(v_file,'   LINHA - ERRO');
      for r in cur_rejeitados loop
        utl_file.put_line(v_file,to_char(r.linha,'B9999999')||'   '||r.texto_linha||chr(10)||'           '||r.erro);
      end loop;
    end if;
    utl_file.fclose(v_file);
    --FILEPACK.fclose(v_file);

    --
    -- Cria arquivo de rejeitados
    --
    -- Preenche relatório

    if p_opcao <> 'V' then

      grava_mensagem (P_CHAVE_LOG, 'Criando o arquivo de rejeitados: '||p_arq_rejeitados);

      v_file:=utl_file.fopen(P_CAMINHO, p_arq_rejeitados,'w');
      --v_file:=FILEPACK.fopen(v_rejeitados,'w');

      -- Preenche relatório
      if v_modo_carga <> 'D' then 
        utl_file.put_line(v_file,'REGISTROS REJEITADOS NA CARGA DE FREQUENCIAS');
      else
        utl_file.put_line(v_file,'REGISTROS REJEITADOS AO DESFAZER A CARGA DE FREQUÊNCIAS');
      end if;      

      for r in cur_rejeitados loop
        utl_file.put_line(v_file,r.texto_linha);
      end loop;
      utl_file.fclose(v_file);
      --FILEPACK.fclose(v_file);
    end if;

    --
    -- Cria arquivo de aceitos
    --
    grava_mensagem (P_CHAVE_LOG, 'Criando o arquivo de aceitos: '||p_arq_aceitos);

    v_file:=utl_file.fopen(P_CAMINHO, p_arq_aceitos,'w');
    --v_file:=FILEPACK.fopen(v_aceitos,'w');
    -- Preenche relatório
    if p_opcao='V' then
      utl_file.put_line(v_file,'REGISTROS ACEITOS NA VERIFICAÇÃO DO ARQUIVO');
    else
      if v_modo_carga <> 'D' then 
        utl_file.put_line(v_file,'REGISTROS ACEITOS NA CARGA DE FREQUENCIAS');
      else
        utl_file.put_line(v_file,'REGISTROS ACEITOS AO DESFAZER A CARGA DE FREQUENCIAS');
      end if;      
    end if;
    utl_file.put_line(v_file,'');
    utl_file.put_line(v_file,'ARQUIVO: '||upper(v_arquivo));
    utl_file.put_line(v_file,'LAYOUT: '||upper(v_nome_layout));
    if p_opcao='C' and v_modo_carga='I' then
        utl_file.put_line(v_file,'MODO DE CARGA: Somente inserir registros novos');
    elsif p_opcao='C' and v_modo_carga='A' then
        utl_file.put_line(v_file,'MODO DE CARGA: Inserir registros novos e sobrescrever os já existentes');
    elsif p_opcao='C' and v_modo_carga='D' then
        utl_file.put_line(v_file,'MODO DE CARGA: Desfazer carga');
    elsif p_opcao='C' and v_modo_carga='E' then
        utl_file.put_line(v_file,'MODO DE CARGA: Encerramento de Frequências');
    end if;
    utl_file.put_line(v_file,'DATA: '||to_char(sysdate,'dd/mm/yyyy - HH24:MI'));
    utl_file.put_line(v_file,'');
    utl_file.put_line(v_file,'');
    utl_file.put_line(v_file,'Número de linhas do arquivo: '||to_char(v_numero_linhas));
    --
    select count(*) into v_cont_aceitos
    from carga_fol_movimentos_temp
    where chave=v_chave and erro is null;

    utl_file.put_line(v_file,'Número de registros aceitos: '||to_char(v_cont_aceitos));

    -- Cria o grupo de eleitos somente para opcao de Inserir registros (v_modo_carga='I')
    v_eleitos := null;
    if p_opcao = 'C' and v_modo_carga='I' and v_cont_aceitos > 0 then
--       if show_alert('CONFIRMA')=alert_button1 then
          v_cria_grupo_eleitos := 'S';
--       else
--          v_cria_grupo_eleitos := 'N';
--       end if;
    end if;


    if v_cont_aceitos>0 and v_modo_carga='I' then
       if p_opcao='C' and v_cria_grupo_eleitos = 'S' then
            -- cria eleito

          BEGIN
                SELECT grupoeleitos_seq.NEXTVAL
                  INTO v_eleitos
                  FROM DUAL;
              --END IF;
            --END IF;
          EXCEPTION
            WHEN OTHERS THEN
              ERGON_ERRO_PACK.TRATA_ERRO (-1, SQLERRM);
          END;
            v_mens := 'Atenção o número grupo de eleito criado: '
                  ||to_char(v_eleitos)||'.';
            --grava_mensagem (v_chave_log, v_mens);

          INSERT
            INTO grupo_eleitos
              (
                grupo,
                datacad,
                obs
              )
              VALUES
              (
                v_eleitos,
                SYSDATE,
                'Gerado através da carga de atributo '
              ) ;

          utl_file.put_line(v_file,'');
          utl_file.put_line(v_file,' Número do Grupo de Eleitos de Aceitos: ' ||v_eleitos);

          v_mens := 'Número do Grupo de Eleitos com registros aceitos na carga: '||v_eleitos;
          grava_mensagem (P_CHAVE_LOG, v_mens);
          v_mens := null;

          -- contar qtd de servidores que deverão ser gravados no grupo de eleitos
          select count(distinct(numfunc)) into v_eleitos_grav
          from carga_ferias_temp
          where chave=v_chave and erro is null;

          utl_file.put_line(v_file,' Número de Servidores no Grupo de Eleitos: ' ||v_eleitos_grav);
          v_mens := 'Número de Servidores no Grupo de Eleitos: '||v_eleitos_grav;
          grava_mensagem (P_CHAVE_LOG, v_mens);
          v_mens := null;

      --

       end if ;

        utl_file.put_line(v_file,'');
        utl_file.put_line(v_file,'');
        utl_file.put_line(v_file,'   LINHA - REGISTRO ');

        --
        for r in cur_aceitos loop
          utl_file.put_line(v_file,to_char(r.linha,'B9999999')||'   '||r.texto_linha);

          --alerta (' insere txt - numfunc : '||r.numfunc);

           if P_opcao = 'C' and v_cria_grupo_eleitos = 'S' then

            --alerta ('insere eleitos - numfunc : '||r.numfunc);
             -- verifica se ja existe o servidor no grupo de eleitos ------
             select count(1) into v_existe_eleito
               from eleitos_ext
               where grupo   = v_eleitos
               and   numfunc = r.numfunc
               and   numvinc = r.numvinc
               and   numpens is null;
             --
             if v_existe_eleito = 0 then
                 begin
                   insert into eleitos_ext(grupo, chave,numfunc,numvinc,numpens)
                          values(v_eleitos,ELEITOS_SEQ.NEXTVAL,r.numfunc,r.numvinc,null);
                 exception when others then
                    v_mens := 'Erro de Insert na tabela ELEITOS_EXT - Erro: '||sqlerrm;
                    grava_mensagem (P_CHAVE_LOG, v_mens);
                    v_mens := null;
                 end;
                 commit;
             end if;

           end if ;


        end loop;
    end if;

    --FILEPACK.fclose(v_file);
    utl_file.fclose(v_file);
    --

    -- Atualiza tabela de auditoria da carga com grupo de eleitos para modo de Insert
    if v_modo_carga='I' and p_opcao='C' then
       begin
          update C_ERGON.pgov_auditoria_carga set GRUPO_ELEITOS = v_eleitos
            where id_exec = P_CHAVE_LOG;
       exception when others then
           null;
       end;
    end if;

    grava_mensagem (P_CHAVE_LOG, 'Fim da criação do arquivo de erros "'||upper(p_arq_erros)||
                                  '", do arquivo de rejeitados "'||upper(p_arq_rejeitados)||
                                  '" e do arquivo de aceitos "'||upper(p_arq_aceitos)||'".');

  exception
    when others then
        grava_mensagem (P_CHAVE_LOG, 'Erro na criação dos arquivo de erros, rejeitados e do arquivo de aceitos: '||
                                      trunca_sqlerrm(sqlerrm));
        utl_file.fclose(v_file);
        --FILEPACK.fclose(v_file);
  end;

  /*
  *******************************************************************************
  * FUNCTION CALCULA_TOTAIS
  *   Função para calcular totais de valores do arquivo e compará-los à
  * especificação do usuário.
  * Entradas: p_check - indica se é pra fazer a comparação c/ as especificações
  * Saída: p_relat - texto com os totais
  *        Retorna FALSE se os totais batem com a especificação
  *        Retorna TRUE  caso contrário.
  *******************************************************************************
  */
  function calcula_totais(p_relat out varchar2
                         ,p_check boolean
                         ,P_CHAVE carga_ferias_temp.CHAVE%TYPE) return boolean is
    v_texto varchar2(2000);
    v_ferias_encontrada varchar2(30);
    v_numero_funcionarios number;
    v_qtde_tipo_ferias      number;
    v_qtde_cod_ferias      number;
    v_erros_ferias    number;
    v_erro boolean;
    v_chave carga_ferias_temp.CHAVE%TYPE;
  begin

    v_chave := P_CHAVE;
    -- Conta número de funcionários na tabela temporária
    select count(distinct numfunc) into v_numero_funcionarios
    from carga_ferias_temp
    where chave=v_chave and erro is null;
    
    -- Calcula totais de valores
    select sum(valor)
    into v_total_valor
    from carga_fol_movimentos_temp
    where chave=v_chave and erro is null;

    --
    -- Verifica se os requisitos foram atendidos
    --
    v_erro:=false;
--    if (:block_carga_aux.codfreq is not null and v_erros_frequencia>0) then
--      v_erro:=true;
--    end if;

--    if (:block_carga_aux.numero_funcionarios is not null and (:block_carga_aux.numero_funcionarios<>v_numero_funcionarios)) then
--      v_erro:=true;
--    end if;

--    if (:block_carga_aux.numero_linhas is not null and (:block_carga_aux.numero_linhas<>v_numero_linhas)) then
--      v_erro:=true;
--    end if;

-- Monta texto 
    --
    if p_check=true then
      v_texto:=chr(10);
      v_texto:=v_texto||'                              Encontrado            Especificado'||chr(10);
   --   v_texto:=v_texto||'Núm. funcionários:      '||to_char(v_numero_funcionarios,'B999999999999999')||' '||to_char(:block_carga_aux.numero_funcionarios,'B9999999999999999999999')||chr(10);
   --   v_texto:=v_texto||'Número de linhas: '||to_char(v_numero_linhas,'B999999999999999999999')||' '||to_char(:block_carga_aux.numero_linhas,'B9999999999999999999999')||chr(10);
    else
      v_texto:=chr(10);
      v_texto:=v_texto||'Núm. funcionários: '||to_char(v_numero_funcionarios)||chr(10);
      v_texto:=v_texto||'Número de linhas: '||to_char(v_numero_linhas)||chr(10);
    end if;

    -- Saída da função
    p_relat:=v_texto;
    return(v_erro);
     
  end;

  /*
  *******************************************************************************
  * FUNCTION LE_ARQUIVO
  *   Função carregar o arquivo de carga para a tabela temporária carga_ferias_temp,
  * checando a integridade dos registros.
  * Entradas:
  * Saída: p_relatorio - Texto com o relatório dos erros encontrados
  *        Retorna false se arquivo OK
  *        Retorna true caso contrário
  *******************************************************************************
  */
  function Le_arquivo( p_arquivo in varchar2
                      ,p_caminho in varchar2
                      ,p_numero_layout  in number
                      ,p_chave in carga_ferias_temp.chave%type
                      ,p_chave_log in log_processo_header.id_exec%type
                      ,p_relatorio out varchar2 )
  return boolean is
    v_file utl_file.file_type;
    v_linha varchar2(2000);
    num_linha number;
    r ferias%rowtype;
    v_oper varchar2(20);
    --
    erro_layout exception;  
    erro_linha_maior_2000 exception;  
    erro_conversao exception;  
    erro_insert exception;  
    err_msg varchar2(2000);
    v_cont_erros number;
    --
    v_cont_synchr number;
    --
    v_relat_check varchar2(2000);
    v_erro_check boolean;
    v_mensagem VARCHAR2(2000);
    v_exercicio   varchar2(4);
    --
    v_existe_tmp  number;

    v_chave    carga_ferias_temp.CHAVE%TYPE;

    v_modo_carga VARCHAR2(1);

    begin

      v_modo_carga := 'V';

      grava_mensagem (p_chave_log, 'Iniciando a leitura do arquivo');

      v_chave := P_CHAVE;

      -- Carrega o layout do arquivo para a memória
      err_msg := carrega_layout(p_numero_layout, null);

      if err_msg is not null then
        v_mensagem:= trunca_sqlerrm('Erro ao carregar o layout do arquivo:'||chr(10)||err_msg);
        grava_mensagem(p_chave_log, v_mensagem);
        return(true);
      end if;

      grava_mensagem(p_chave_log, 'Layout carregado na memória.');

      -- Abre arquivo
      grava_mensagem(p_chave_log, 'Iniciando a abertura do arquivo para a leitura.');

      v_file:=utl_file.fopen(p_caminho, p_arquivo,'r');

      grava_mensagem(p_chave_log, 'O arquivo foi aberto.');

      --v_file:=FILEPACK.fopen(v_arquivo,'r');
      -- Copia os registros do arquivo para a tabela temporária

      num_linha:=0;
      v_cont_erros:=0;
      v_cont_synchr:=0;

      loop

        begin
          -- Lê a próxima linha do arquivo
          num_linha:=num_linha+1;
          v_cont_synchr:=v_cont_synchr+1;

          begin
            utl_file.get_line(v_file,v_linha);
            v_linha := REPLACE(REPLACE(v_linha,CHR(13),''),CHR(10),'');
          exception
            when no_data_found then
              num_linha := num_linha-1;
              grava_mensagem(p_chave_log, 'Chegou na última linha do arquivo: linha '||num_linha||'.' );
              exit; -- Acabou o arquivo
            when value_error then
              grava_mensagem(p_chave_log, 'Linha '||num_Linha||' do arquivo excede 2000 caracteres.' );
              raise erro_linha_maior_2000;  -- A linha do arquivo é maior que 2000 caracteres


        end;
        -- Atualiza mensagem na tela
        if v_cont_synchr>=10 then
          v_mensagem:='Verificando arquivo: linha '||to_char(num_linha);
          grava_mensagem(p_chave_log, v_mensagem);
        end if;

        -- tratar linha em branco
        if length(v_linha) is null then
           err_msg := 'Linha '||num_linha||' em branco no arquivo';
           grava_mensagem(p_chave_log, err_msg);
           raise erro_conversao;
        end if;
        --

        -- tratar linha em branco para arquivo .csv
        if substr(v_linha, 1, 1) = ( ';') then
          err_msg := 'Linha '||num_linha||' em branco no arquivo';
          grava_mensagem(p_chave_log, err_msg);
          raise erro_conversao;
        end if;
        --

        -- Converte a linha para um registro de férias
        err_msg:=conv_linha(v_linha, v_modo_carga, r,v_oper);


        if err_msg is not null then
          grava_mensagem(p_chave_log, err_msg);
          raise erro_conversao;
        end if;

        -- Insere registro na tabela temporária
        begin
          insert into carga_ferias_temp(chave,linha,
              numfunc,numvinc,dtini,dtfim,exercicio, flex_campo_01,flex_campo_02,flex_campo_03,flex_campo_04,flex_campo_05,texto_linha,obs)
          values(v_chave,num_linha,
                 r.numfunc,r.numvinc,r.dtini,r.dtfim, v_exercicio,  r.flex_campo_01,r.flex_campo_02,r.flex_campo_03,r.flex_campo_04,r.flex_campo_05,v_linha,r.obs);
        exception
          when DUP_VAL_ON_INDEX then
            err_msg:='Registro repetido no arquivo.';
            grava_mensagem(p_chave_log, err_msg);
            raise erro_insert;
          when others then
            err_msg:=sqlerrm;
            grava_mensagem(p_chave_log, err_msg);
            raise erro_insert;
        end;

      exception

          when erro_linha_maior_2000 then          
          insert into carga_ferias_temp(chave,linha,erro)
          values(v_chave,num_linha,'Linha do arquivo excede 2000 caracteres.'||chr(10)||v_linha);
          grava_mensagem(p_chave_log, 'Linha '||num_Linha||' do arquivo excede 2000 caracteres.');
          v_cont_erros:=v_cont_erros+1;


        when erro_conversao then
          err_msg := TRUNCA_SQLERRM(sqlerrm);
          insert into carga_ferias_temp(chave,linha,erro,texto_linha)
          values(v_chave,num_linha,err_msg,v_linha);
          grava_mensagem(p_chave_log, 'Erro na linha '||num_Linha||': '||err_msg);
          v_cont_erros:=v_cont_erros+1;



        when erro_insert then
          err_msg := TRUNCA_SQLERRM(err_msg);
          insert into carga_ferias_temp(chave,linha,erro,texto_linha)
          values(v_chave,num_linha,err_msg,v_linha);
          grava_mensagem(p_chave_log, 'Erro na linha '||num_Linha||': '||err_msg);
          v_cont_erros:=v_cont_erros+1;



        when others then
          err_msg := TRUNCA_SQLERRM(sqlerrm);
          insert into carga_ferias_temp(chave,linha,erro,texto_linha)
          values(v_chave,num_linha,err_msg,v_linha);
          grava_mensagem(p_chave_log, 'Erro na linha '||num_Linha||': '||err_msg);
          v_cont_erros:=v_cont_erros+1;



      end;
      commit;
    end loop;

    commit;

    grava_mensagem(p_chave_log, 'Fechando o arquivo para leitura.');

    -- Fecha o arquivo
    utl_file.fclose(v_file);
    --FILEPACK.fclose(v_file);

    grava_mensagem(p_chave_log, 'Arquivo fechado.');

    -- Guarda número de linhas e de erros para serem usados por outras funções
    v_numero_linhas:=num_linha;
    v_numero_linhas_erro:=v_cont_erros;

    grava_mensagem(p_chave_log, 'Iniciando a apuração dos totais do arquivo.');
    -- Calcula totais
    v_erro_check := Calcula_totais(v_relat_check,false, v_chave);

    grava_mensagem(p_chave_log, 'Final da apuração dos totais do arquivo.');
    --
    -- Mensagem com resultado da verificação
    --
    v_mensagem:='Arquivo com '||to_char(num_linha)||' registros.'||chr(10)||
                      'Registros sem erros: '||ltrim(to_char(num_linha-v_cont_erros))||chr(10)||
                      'Registros com erros: '||ltrim(to_char(v_cont_erros))||chr(10);

    v_mensagem:=v_mensagem||chr(10)||err_msg||chr(10);
--    if v_cont_erros=0 then
--      v_mensagem:=v_mensagem||v_relat_check;
--    end if;
    if v_cont_erros=0 then
       v_mensagem:=v_mensagem||chr(10)||'Arquivo sem erros.'||chr(10);
       grava_mensagem(p_chave_log, v_mensagem);
       grava_mensagem(p_chave_log, err_msg);
    else
       --v_mensagem:= v_mensagem||chr(10)||'ERRO: valores encontrados não conferem com os especificados.'||chr(10);
       v_mensagem:= v_mensagem||chr(10)||'ERRO: '||chr(10);

       v_mensagem:= v_mensagem||chr(10)||err_msg||chr(10);
       grava_mensagem(p_chave_log, v_mensagem);
       grava_mensagem(p_chave_log, err_msg);

    end if;
    --
    -- Retorna
    --
    if v_cont_erros=0 and v_erro_check=false then
      return(false);
    else
      return(true);
    end if;

   --
  end;



  /*
  *******************************************************************************
  * FUNCTION VERIFICA
  *   Função para verificar um arquivo de carga. Durante a verificação, abre a
  * janela DIALOG.
  * Entradas: p_arquivo    - diretório e nome do arquivo de carga
  *           p_relatorio  - diretório e nome do arquivo de relarório
  *           p_numero     - número do layout associado ao arquivo de carga
  *******************************************************************************
  */
  procedure verifica( P_ARQUIVO       VARCHAR2
                     ,P_TIPO          VARCHAR2
                     ,P_CAMINHO       VARCHAR2
                     ,P_NUMERO_LAYOUT NUMBER)
  is
    err_msg       varchar2(2000);
    v_erro        boolean;
    v_texto1      varchar2(1000);
    v_chave_log   LOG_PROCESSO_HEADER.ID_EXEC%TYPE;
    v_arq_rejeitados varchar2(200);
    v_arq_aceitos varchar2(200);
    v_arq_erros varchar2(200);

    v_chave       carga_ferias_temp.CHAVE%TYPE;

    varquivo_blob_err   BLOB;
    varquivo_blob_ac    BLOB;
    varquivo_blob_rej   BLOB;

  begin

    --Estabelecendo o nome dos arquivos
    v_arq_rejeitados := replace (P_ARQUIVO, '.txt', '.rej');
    v_arq_aceitos    := replace (P_ARQUIVO, '.txt', '.ac');
    v_arq_erros  := replace (P_ARQUIVO, '.txt', '.err');

    --
    -- Seta as variáveis internas da package
    --
    SELECT CARGA_FERIAS_SEQ.NEXTVAL
      INTO v_chave
    FROM DUAL;

    v_numero_layout:=p_numero_layout;
    v_arquivo := p_arquivo;
  --  v_arq_erros:=p_erros;
  --  v_aceitos:=p_aceitos;

    --
     v_chave_log := log_pack.insere_log_header('VERIFICANDO O ARQUIVO DE CARGA DEVOLUÇÃO PREVIDENCIÁRIA',
                                               'Arquivo = ''' || upper(v_arquivo) ||
                                                '''; ''' || CHR(10) ||
                                                '''; Usuário = ''' || FLAG_PACK.get_usuario
                                                || CHR(10) ||
                                                '''; Data = ''' || to_char(sysdate,'DD/MM/YYYY - hh24:mi') ||
                                                '''', null);

    --
    -- Carrega o arquivo para a tabela temporária e checa integridade dos registros
    --

    v_erro := le_arquivo( v_arquivo, p_caminho, p_numero_layout, v_chave, v_chave_log, v_texto1);

    --
    -- Gera relatório
    --
    Gera_relatorios(P_CAMINHO, 'V', v_arq_rejeitados, v_arq_aceitos, v_arq_erros, NULL, v_chave, v_chave_log);

    grava_mensagem (v_chave_log, 'Apagando os registros da tabela temporária carga_ferias_temp.');
    --
    -- Apaga registros da tabela temporária
    --
    LOOP
      --
      DELETE CARGA_FERIAS_TEMP
      WHERE CHAVE = v_chave
        AND ROWNUM <= 100;
      --
    EXIT WHEN SQL%ROWCOUNT = 0;
      --
      COMMIT;
      --
    END LOOP;

    --
    COMMIT;
    grava_mensagem (v_chave_log, 'Fim da exclusão dos registros da tabela temporária carga_ferias_temp.');
    --
--    EXECUTA_SQL_ERGON ('TRUNCATE TABLE CARGA_ATRIB_TEMP');

    grava_mensagem (v_chave_log, 'Iniciando o UPLOAD do arquivo de erros "'||
                                  upper(v_arq_erros) || '" para o banco de dados.');
    --
    PACK_HAD_DOWNLOAD.GRAVA_ARQUIVO_BLOB(varquivo_blob_err, v_arq_erros, P_CAMINHO);
    --
    -- INSERT DO ARQUIVO DE ERROS
    INSERT INTO HAD_ARQ_DOWNLOAD (ID_ROTINA_EXEC,
                                  DESCRICAO,
                                  NOME_ARQUIVO,
                                  MIME_TYPE,
                                  ARQUIVO,
                                  DATA_EXPIRACAO)
                          VALUES (PACK_EXEC_ROTINAS.GET_ID_ROTINA_EXEC ,
                                  'ARQUIVO DE VERIFICAÇÃO DE ERROS',
                                  v_arq_erros,
                                  P_TIPO,
                                  varquivo_blob_err,
                                  TRUNC(SYSDATE)+1);
    --
    grava_mensagem (v_chave_log, 'Fim do UPLOAD do arquivo de erros "'||
                                  upper(v_arq_erros) || '" para o banco de dados.');

    --
    grava_mensagem (v_chave_log, 'Iniciando o UPLOAD do arquivo de aceitos "'||
                                  upper(v_arq_aceitos) || '" para o banco de dados.');

    PACK_HAD_DOWNLOAD.GRAVA_ARQUIVO_BLOB(varquivo_blob_ac, v_arq_aceitos, P_CAMINHO);
    --
    -- INSERT DO ARQUIVO DE ERROS
    INSERT INTO HAD_ARQ_DOWNLOAD (ID_ROTINA_EXEC,
                                  DESCRICAO,
                                  NOME_ARQUIVO,
                                  MIME_TYPE,
                                  ARQUIVO,
                                  DATA_EXPIRACAO)
                          VALUES (PACK_EXEC_ROTINAS.GET_ID_ROTINA_EXEC ,
                                  'ARQUIVO DE VERIFICAÇÃO DE ACEITOS',
                                  v_arq_aceitos,
                                  P_TIPO,
                                  varquivo_blob_ac,
                                  TRUNC(SYSDATE)+1);
    --
    grava_mensagem (v_chave_log, 'Fim do UPLOAD do arquivo de aceitos "'||
                                  upper(v_arq_aceitos) || '" para o banco de dados.');

    --
/*
    PACK_HAD_DOWNLOAD.GRAVA_ARQUIVO_BLOB(varquivo_blob_rej, v_arq_rejeitados, P_CAMINHO);
    --
    -- INSERT DO ARQUIVO DE ERROS
    INSERT INTO HAD_ARQ_DOWNLOAD (ID_ROTINA_EXEC,
                                  DESCRICAO,
                                  NOME_ARQUIVO,
                                  MIME_TYPE,
                                  ARQUIVO,
                                  DATA_EXPIRACAO)
                          VALUES (PACK_EXEC_ROTINAS.GET_ID_ROTINA_EXEC ,
                                  'ARQUIVO DE VERIFICAÇÃO DE REJEITADOS',
                                  v_arq_rejeitados,
                                  P_TIPO,
                                  varquivo_blob_rej,
                                  TRUNC(SYSDATE)+1);
*/

    --
    grava_mensagem (v_chave_log, 'Início da exclusão dos arquivos de erros, rejeitados e aceitos do disco.');

    UTL_FILE.FREMOVE(P_CAMINHO, P_ARQUIVO);
    UTL_FILE.FREMOVE(P_CAMINHO, v_arq_erros);
    UTL_FILE.FREMOVE(P_CAMINHO, v_arq_aceitos);
--    UTL_FILE.FREMOVE(P_CAMINHO, v_arq_rejeitados);
    --

    grava_mensagem (v_chave_log, 'Conclusão da exclusão dos arquivos de erros, rejeitados e aceitos do disco.');

    if err_msg is not null then
--
--      return(true);
--    else
--
      grava_mensagem(v_chave_log, err_msg);
--      return(false);
    end if;

    grava_mensagem (v_chave_log, 'FIM DO PROCESSO DE VERIFICAÇÃO DO ARQUIVO DE CARGA DE FREQUÊNCIAS.');

   --
  end;

  /*
  *******************************************************************************
  * FUNCTION CARGA_ARQUIVO
  *   Função carregar o arquivo de carga para a tabela temporária carga_ferias_temp,
  * checando a integridade dos registros.
  * Entradas:
  * Saída: Retorna FALSE se arquivo OK
  *        Retorna TRUE caso contrário
  *******************************************************************************
  */
  FUNCTION Carga_arquivo (P_CHAVE      carga_ferias_temp.CHAVE%TYPE
                         ,P_CAMINHO    IN VARCHAR2
                         ,P_ARQUIVO    IN VARCHAR2
                         ,P_MODO_CARGA IN VARCHAR2
                         ,P_CHAVE_LOG  IN OUT LOG_PROCESSO_HEADER.ID_EXEC%TYPE
                         ,P_ID_EXEC_AUDIT LOG_PROCESSO_HEADER.ID_EXEC%TYPE DEFAULT NULL)
  return boolean
  IS
    --
    v_file                 utl_file.file_type;
    v_linha               varchar2(2000);
    num_linha             number;
    v_linhas_removidas    NUMBER := 0;
    v_linhas_alteradas    NUMBER := 0;
    v_linhas_inseridas    NUMBER := 0;
    v_mens                VARCHAR2(2000);      
    r                     ferias%rowtype;
    v_oper                varchar2(20);
    --
    erro_layout           exception;  
    erro_linha_maior_2000 exception;  
    erro_conversao        exception;  
    erro_carga            exception;  
    erro_vantagem         exception;
    erro_frequencia       exception;
    erro_insert_temporaria exception; 
    err_msg                varchar2(2000);
    v_cont_erros           number;
    v_erro_check           boolean;
    v_relat_check          varchar2(2000);
    --
    v_cont_synchr         number;  -- contador para executar synchronizes
    --
    v_chave               carga_ferias_temp.CHAVE%TYPE;
    v_chave_log_header    number; -- chave do header de autitoria
    v_chave_log           LOG_PROCESSO_HEADER.ID_EXEC%TYPE; -- chave do header de autitoria
    v_logging             varchar2(1); -- flag para indicar se deve fazer auditoria
    ra                    ferias%rowtype; -- variável auxiliar para guardar vantagens alteradas
    v_aux                 varchar2(100);
    v_sobrepoe            tipo_vantagem.sobrepoe%type;
    v_emp_codigo          empresas.empresa%type;
    v_cont_empresa        number;
    v_vantagem          number;
    --
    v_existe_tmp          number;
    --
    v_movimento           number;
    v_rubrica             number;
    v_responsavel         fol_movimentos.responsavel%type;
    v_peraqfer_chave      peraqfer.chave%type;
    v_data_execucao       date;
    v_grupo_eleitos_del   number;
    --
    v_exercicio           varchar2(4);

    v_modo_carga          VARCHAR2(1);
    --
  BEGIN

    v_chave   := P_CHAVE;
    v_arquivo := P_ARQUIVO;
    v_chave_log := P_CHAVE_LOG;

    v_modo_carga := P_MODO_CARGA;

    grava_mensagem (v_chave_log, 'Iniciando a leitura do arquivo');
    --
    -- Carrega o layout do arquivo para a memória
    --

    err_msg:=carrega_layout(v_numero_layout,v_modo_carga);
    --

    if err_msg is not null then
      --
        v_mens:= trunca_sqlerrm('Erro ao carregar o layout do arquivo:'||chr(10)||err_msg);
        grava_mensagem(v_chave_log, v_mens);
        return(true);
      --
    end if;

    grava_mensagem(p_chave_log, 'Layout carregado na memória.');

    --
    -- Verifica se deve fazer auditoria
    --
 --   select logging into v_logging from transacao
 --   where sis='C_Ergon' and trans='RJadm00018';
    --
    -- Sempre irá auditar
    --
    v_logging := 'S';

    --
--    if v_logging='S' then
--      if v_modo_carga='I' then
--        v_aux:='Somente inserir os registros novos';
--      elsif v_modo_carga='A' then
--        v_aux:='Inserir e sobrescrever';
--      elsif v_modo_carga='D' then
--        v_aux:='Desfazer Carga';
--      elsif v_modo_carga='E' then
--        v_aux:='Encerrar Frequencia';
--      end if;

--       v_aux:='Somente inserir os registros novos';
      --

--     v_chave_log := log_pack.insere_log_header('CARGA DE FREQUÊNCIAS',
--                                               'Arquivo = ' || upper(v_arquivo) ||
--                                                ';' || CHR(10) ||
--                                                ' Modo de Carga='||v_aux
--                                                || CHR(10) ||
--                                                '; Usuário = ' || FLAG_PACK.get_usuario
--                                                || CHR(10) ||
--                                                '; Máquina = ' || flag_pack.get_machine
--                                                || CHR(10) ||
--                                                '; Data = ' || to_char(sysdate,'DD/MM/YYYY - hh24:mi')
--                                                , null);
--      --
--
--      P_CHAVE_LOG := v_chave_log;

      --
--    end if;

    -- Abre arquivo
    grava_mensagem(p_chave_log, 'Iniciando a abertura do arquivo para a leitura.');

    v_file:=utl_file.fopen(p_caminho, P_ARQUIVO,'r');

    grava_mensagem(p_chave_log, 'O arquivo foi aberto.');

    --v_file:=FILEPACK.fopen(v_arquivo,'r');
    -- Atualiza a tabela FREQUÊNCIAS
    num_linha:=0;
    v_cont_erros:=0;
    v_cont_synchr:=0;

    loop

      begin
        -- Lê a próxima linha do arquivo
        num_linha:=num_linha+1;
        v_cont_synchr:=v_cont_synchr+1;

        begin
          utl_file.get_line(v_file,v_linha);
          v_linha := REPLACE(REPLACE(v_linha,CHR(13),''),CHR(10),'');
        exception
          when no_data_found then
            grava_mensagem(v_chave_log, 'Chegou na última linha do arquivo: linha '||num_linha||'.' );
            num_linha:=num_linha-1;
            exit; -- Acabou o arquivo
          when value_error then
            grava_mensagem(v_chave_log, 'Linha '||num_Linha||' do arquivo excede 2000 caracteres.' );
            raise erro_linha_maior_2000;  -- A linha do arquivo é maior que 2000 caracteres
        end;

        -- Atualiza mensagem na tela
        if v_cont_synchr>=5 then
          if v_modo_carga='D' then
--            err_msg :='Desfazendo carga: linha '||to_char(num_linha);
            grava_mensagem (v_chave_log, 'Desfazendo carga: linha '||to_char(num_linha));
          elsif v_modo_carga='E' then
--            err_msg='Encerrando frequencias: linha '||to_char(num_linha);
            grava_mensagem (v_chave_log, 'Encerrando atributos: linha '||to_char(num_linha));
          else
--            :dialog.mensagem:='Efetuando carga: linha '||to_char(num_linha);
            grava_mensagem (v_chave_log, 'Efetuando carga: linha '||to_char(num_linha));
          end if;
        end if;
        --
        -- tratar linha em branco
        if length(v_linha) is null then
           err_msg := 'Linha '||num_linha||' em branco no arquivo';
           grava_mensagem(v_chave_log, err_msg);
           raise erro_conversao;
        end if;
        --

        -- tratar linha em branco para arquivo .csv
        if substr(v_linha, 1, 1) = ( ';') then
          err_msg := 'Linha '||num_linha||' em branco no arquivo';
          grava_mensagem(p_chave_log, err_msg);
          raise erro_conversao;
        end if;
        --

        -- Converte a linha para um registro de vantagem
        err_msg:=conv_linha(v_linha, v_modo_carga, r,v_oper);

        if err_msg is not null then
          grava_mensagem(v_chave_log, err_msg);
          raise erro_conversao;
        end if;

        -- verifica se o usuário possui acesso à empresa do funcionário
        v_emp_codigo := pack_ergon.get_empresa_func(r.numfunc, r.numvinc);
        select count(*) into v_cont_empresa
          from had_usuario_empresa
          where usuario = flag_pack.get_usuario and
                empresa = v_emp_codigo;
        if nvl(v_cont_empresa, 0) = 0 then
          err_msg:='Usuário ' || flag_pack.get_usuario || ' não possui acesso à empresa ' ||
                   pack_ergon.get_nome_empresa(v_emp_codigo);
          grava_mensagem(v_chave_log, err_msg);
          raise erro_carga;
        end if;
        --

        -- Verifica se o registro ja existe para a unique key na tabela Temporaria....
        select count(1) into v_existe_tmp
           from carga_ferias_temp
           where chave = v_chave
           and   numfunc = r.numfunc
           and   numvinc = r.numvinc
           and   dtini    = r.dtini;
        --
        if v_existe_tmp > 0 then
            err_msg:='Registro repetido no arquivo.';
            raise erro_carga; 
        end if;
        --

        -- Verifica chave do arquivo PERAQFER ----------------------------------------------------------
        begin
          SELECT chave into v_peraqfer_chave
            FROM peraqfer
            WHERE numfunc = r.numfunc
            AND numvinc   = r.numvinc
            AND to_number(NVL(flex_campo_02,'9999')) = v_exercicio;
        exception 
           when no_data_found then
             v_peraqfer_chave := null;
           when others then
             v_peraqfer_chave := null; 
        end;
        --
        -- SILAS
        if v_peraqfer_chave is null then
           err_msg:='Periodo Aquisitivo não encontrado para o Funcionário: ' || r.numfunc ||'/'|| r.numvinc || ' Exercicio: '|| v_exercicio;
           raise erro_carga; 
        end if; 
        --

        -- Insere/Remove/Encerra registro da tabela FERIAS
        if v_modo_carga='I' then -- -- Insere mesmo com o registro repetido
          begin
            begin


              if v_modo_carga='I' then -- Insere mesmo com o registro repetido
              --
                insert into ferias(numfunc,numvinc,dtini,dtfim,chaveperaqfer,obs,abono,abono_const,adiantdterc,adiantsal,
                                   flex_campo_01,flex_campo_02,flex_campo_03,flex_campo_04,flex_campo_05)
                values(r.numfunc,r.numvinc,r.dtini,r.dtfim, v_peraqfer_chave, r.obs, --'Auditoria Lançamento = ' ||v_chave_log_header,
                       'N','N','N','N',r.flex_campo_01,r.flex_campo_02,r.flex_campo_03,r.flex_campo_04,r.flex_campo_05);
                --
                v_linhas_inseridas := v_linhas_inseridas + 1;
                --
                --
                if v_logging='S' then
                  --
                  -- Atualiza a mensagem a cada 500 linhas inseridas e COMMI
                  --
                  IF MOD (v_linhas_inseridas, 500) = 0 THEN
                    --
                    v_mens := 'Foram inseridas até o momento '||v_linhas_inseridas
                              ||' linhas do arquivo de carga.';
                    grava_mensagem (v_chave_log_header, v_mens);
                    --
                  END IF;
                  -- 
                    
                end if;


                --
                select to_char(sysdate,'dd/mm/yyyy hh24:mi') into v_data_execucao from dual;
                --
                if v_linhas_inseridas = 1 then -- no primeiro insert da tabela - grava a tabela de auditoria para futuramente desfazer a carga
                 begin
                  insert into C_ERGON.pgov_auditoria_carga(ID_EXEC,NUMERO_LAYOUT,PATH_CARGA,USUARIO,CARGA_DESFEITA,DATA_EXECUCAO)
                    values (v_chave_log,v_numero_layout,null,flag_pack.get_usuario(), 'N',v_data_execucao);
                 exception when others then
                    err_msg:=sqlerrm;
                    grava_mensagem(v_chave_log, err_msg);
                    raise erro_carga;
                 end;
                end if;

                --
                if v_logging='S' then
                  --
                  -- Atualiza a mensagem a cada 500 linhas inseridas e COMMI
                  --
                  IF MOD (v_linhas_inseridas, 500) = 0 THEN
                    --
                    v_mens := 'Foram inseridas até o momento '||v_linhas_inseridas
                              ||' linhas do arquivo de carga.';
                    grava_mensagem (v_chave_log, v_mens);
                    --
                  END IF;
                  --

                end if;
                --
              end if;

            end;
          exception
            when erro_frequencia then
               grava_mensagem (v_chave_log, trunca_sqlerrm(sqlerrm));
               raise erro_vantagem;
            when DUP_VAL_ON_INDEX then
              --

              --

              err_msg :='Registro já existente no banco de dados';
              grava_mensagem (v_chave_log, err_msg);

              raise erro_carga;
              --
            when others then
              --
              err_msg:=trunca_sqlerrm(sqlerrm);
              --

              --

              raise erro_carga;
              --
          end;
        end if;
        -- Insere registro na tabela carga_ferias_temp
        begin
          insert into carga_ferias_temp(chave,linha,numfunc,numvinc,dtini,dtfim,exercicio,
                                                flex_campo_01,flex_campo_02,flex_campo_03,flex_campo_04,flex_campo_05,texto_linha,obs)
          values(v_chave,num_linha, r.numfunc,r.numvinc,r.dtini,r.dtfim,v_exercicio,
                 r.flex_campo_01,r.flex_campo_02,r.flex_campo_03,r.flex_campo_04,r.flex_campo_05,v_linha,r.obs);
        exception
          when others then
            null;
        end;
      exception
        when erro_linha_maior_2000 then
          insert into carga_ferias_temp(chave,linha,erro)
          values(v_chave,num_linha,'Linha do arquivo excede 200 caracteres.'||chr(10)||v_linha);
          v_cont_erros:=v_cont_erros+1;
          grava_mensagem(v_chave_log, 'Linha '||num_Linha||' do arquivo excede 2000 caracteres.');


        when erro_conversao then
          err_msg := TRUNCA_SQLERRM(err_msg); 
          insert into carga_ferias_temp(chave,linha,erro,texto_linha)
          values(v_chave,num_linha,err_msg,v_linha);
          v_cont_erros:=v_cont_erros+1;
          grava_mensagem(v_chave_log, 'Erro na linha '||num_Linha||': '||err_msg);


        when erro_carga then
          err_msg := TRUNCA_SQLERRM(err_msg); 
          insert into carga_ferias_temp(chave,linha,erro,texto_linha)
          values(v_chave,num_linha,err_msg,v_linha);
          v_cont_erros:=v_cont_erros+1;
          grava_mensagem(v_chave_log, 'Erro na linha '||num_Linha||': '||err_msg);

        when erro_insert_temporaria then
          err_msg := TRUNCA_SQLERRM(err_msg);
          insert into carga_ferias_temp(chave,linha,erro,texto_linha)
          values(v_chave,num_linha,err_msg,v_linha);
          v_cont_erros:=v_cont_erros+1;
          grava_mensagem(v_chave_log, 'Erro na linha '||num_Linha||': '||err_msg);


        when others then
          err_msg := TRUNCA_SQLERRM(sqlerrm);
          insert into carga_ferias_temp(chave,linha,erro,texto_linha)
          values(v_chave,num_linha,err_msg,v_linha);
          v_cont_erros:=v_cont_erros+1;
          grava_mensagem(v_chave_log, 'Erro na linha '||num_Linha||': '||err_msg);

      end;
--      commit;
    end loop;
    --
    --


    if v_logging='S' then
      --
      if v_modo_carga='D' then
        --
        v_mens := 'Foram removido um total de '||v_linhas_removidas||' lançamentos da carga';
        --
      elsif v_modo_carga='E' then
        --
        v_mens := 'Foram encerrados um total de '||v_linhas_alteradas||' lançamentos da carga';
        --    

      elsif v_modo_carga='I'  then
        --
        v_mens := 'Foram carregados um total de '||v_linhas_inseridas||' lançamentos.';
        --
      elsif v_modo_carga='A' then
        --
        v_mens := 'Foram alterados um total de '||v_linhas_alteradas||' lançamentos.';
        --
      end if;

      grava_mensagem (v_chave_log, v_mens);


    else
      commit;
    end if;

    grava_mensagem(v_chave_log, 'Fechando o arquivo para leitura.');
    --
    -- Fecha o arquivo
    utl_file.fclose(v_file);

    grava_mensagem(v_chave_log, 'Arquivo fechado.');
    --FILEPACK.fclose(v_file);
    -- Guarda número de linhas e de erros para serem usados pela função CALCULA_TOTAIS
    v_numero_linhas:=num_linha;
    v_numero_linhas_erro:=v_cont_erros;

    grava_mensagem(v_chave_log, 'Iniciando a apuração dos totais do arquivo.');
    -- Calcula totais
    v_erro_check:=Calcula_totais(v_relat_check,false, v_chave);

    grava_mensagem(v_chave_log, 'Final da apuração dos totais do arquivo.');
    --
    -- Mensagem com resultado da carga
    --
    v_mens := 'Arquivo com '||to_char(num_linha)||' registros.'||chr(10)||
                      'Registros sem erros na carga: '||ltrim(to_char(num_linha-v_cont_erros))||chr(10)||
                      'Registros com erros na carga: '||ltrim(to_char(v_cont_erros))||chr(10);
    --
    if v_modo_carga='D' then
       v_mens := v_mens||'Registros Desfeitos na carga: '||v_linhas_removidas||chr(10);
    end if;
    --
    v_mens := v_mens||v_relat_check;
    if v_cont_erros=0 then
       if v_modo_carga='I'  then
         v_mens := v_mens||chr(10)||'Carga concluída sem erros.';
       end if;
    else
       v_mens := v_mens||chr(10)||'Ocorreram erros durante a carga.';
    end if;

    grava_mensagem (v_chave_log, v_mens);

    -- Exibir mensagem para solicitar a remoção dos contra-cheques do grupo de eleitos
    if v_modo_carga='D' then
      begin
       select grupo_eleitos into v_grupo_eleitos_del
         from C_ERGON.pgov_auditoria_carga
         where id_exec = v_chave_log;
      exception when others then
           v_grupo_eleitos_del := null;
      end;
      --

      if v_grupo_eleitos_del is not null then
        v_mens := 'Informamos que os contracheques originados pelo grupo de eleitos: ' || v_grupo_eleitos_del || ' devem ser removidos.';
        grava_mensagem (v_chave_log, v_mens);
      end if;
    end if;

    --
    -- Retorna
    --
    if v_cont_erros=0 then
      return(false);
    else
      return(true);
    end if;
   --
  exception
    when others then
      grava_mensagem (v_chave_log, 'Erro no final do processo: '||TRUNCA_SQLERRM(err_msg));
  end;

  /*
  *******************************************************************************
  * PROCEDURE CARGA
  *   Sub-rotina para efetuar carga. Durante a carga, abre a janela DIALOG.
  * Entradas: p_arquivo    - diretório e nome do arquivo de carga
  *           p_relatorio  - diretório e nome do arquivo de relarório
  *           p_numero     - número do layout associado ao arquivo de carga
  *           p_modo_carga - modo de carga (Inserir, alterar, desfazer carga, encerrrar frequências)
  *******************************************************************************
  */
  procedure carga( P_ARQUIVO       VARCHAR2
                  ,P_TIPO          VARCHAR2
                  ,P_CAMINHO       VARCHAR2
                  ,P_NUMERO_LAYOUT NUMBER)

  is
    err_msg varchar2(2000);
    v_erro boolean;
    v_tempo date;
    --v_chave_log    NUMBER;
    v_chave carga_ferias_temp.chave%type;
    v_chave_log log_processo_header.id_exec%type;

    --Estabelecendo o nome dos arquivos
    v_arq_rejeitados VARCHAR2(200);
    v_arq_aceitos    VARCHAR2(200);
    v_arq_erros  VARCHAR2(200);

    varquivo_blob_err  BLOB;
    varquivo_blob_ac   BLOB;
    varquivo_blob_rej  BLOB;

  begin

    --Estabelecendo o nome dos arquivos
    v_arq_rejeitados := replace (P_ARQUIVO, '.txt', '.rej');
    v_arq_aceitos    := replace (P_ARQUIVO, '.txt', '.ac');
    v_arq_erros  := replace (P_ARQUIVO, '.txt', '.err');

    -- Seta as variáveis internas da package
    select nvl(max(chave),0)+1 into v_chave from carga_ferias_temp;

    v_numero_layout:=p_numero_layout;
    v_arquivo:=p_arquivo;
    -- v_rejeitados:=p_rejeitados;
   -- V_ARQ_ERROS := P_ERROS;
   -- v_aceitos:=p_aceitos;


    --
     v_chave_log := log_pack.insere_log_header('CARGA DE FREQUÊNCIAS',
                                               'Arquivo = ' || upper(v_arquivo) ||
                                                ';' || CHR(10) ||
                                                'Usuário = ' || FLAG_PACK.get_usuario
                                                ||';'|| CHR(10) ||
                                                'Data = ' || to_char(sysdate,'DD/MM/YYYY - hh24:mi')
                                                ,null);
      --
      COMMIT;
     --
    --
    -- Carrega o arquivo para a tabela FERIAS e insere erros na tabela temporária
    --

    v_erro := carga_arquivo(v_chave ,P_CAMINHO, P_ARQUIVO, 'I', v_chave_log);

    --
    -- Gera relatório
    --
    Gera_relatorios(P_CAMINHO, 'C', v_arq_rejeitados, v_arq_aceitos, v_arq_erros, 'I', v_chave, v_chave_log);

    grava_mensagem (v_chave_log, 'Apagando os registros da tabela temporária carga_ferias_temp.');
    --
    -- Apaga registros da tabela temporária
    --
    LOOP
      --
      DELETE CARGA_FERIAS_TEMP
      WHERE CHAVE = v_chave
        AND ROWNUM <= 100;
      --
    EXIT WHEN SQL%ROWCOUNT = 0;
      --
      COMMIT;
      --
    END LOOP;

    --
    COMMIT;
    grava_mensagem (v_chave_log, 'Fim da exclusão dos registros da tabela temporária carga_ferias_temp.');
    --
--    EXECUTA_SQL_ERGON ('TRUNCATE TABLE CARGA_ATRIB_TEMP');

    grava_mensagem (v_chave_log, 'Iniciando o UPLOAD do arquivo de erros "'||
                                  upper(v_arq_erros) || '" para o banco de dados.');
    --
    PACK_HAD_DOWNLOAD.GRAVA_ARQUIVO_BLOB(varquivo_blob_err, v_arq_erros, P_CAMINHO);
    --
    -- INSERT DO ARQUIVO DE ERROS
    INSERT INTO HAD_ARQ_DOWNLOAD (ID_ROTINA_EXEC,
                                  DESCRICAO,
                                  NOME_ARQUIVO,
                                  MIME_TYPE,
                                  ARQUIVO,
                                  DATA_EXPIRACAO)
                          VALUES (PACK_EXEC_ROTINAS.GET_ID_ROTINA_EXEC ,
                                  'ARQUIVO DE ERROS NO CARGA',
                                  v_arq_erros,
                                  P_TIPO,
                                  varquivo_blob_err,
                                  TRUNC(SYSDATE)+1);
    --
    grava_mensagem (v_chave_log, 'Fim do UPLOAD do arquivo de erros "'||
                                  upper(v_arq_erros) || '" para o banco de dados.');

    --
    grava_mensagem (v_chave_log, 'Iniciando o UPLOAD do arquivo de aceitos "'||
                                  upper(v_arq_aceitos) || '" para o banco de dados.');

    PACK_HAD_DOWNLOAD.GRAVA_ARQUIVO_BLOB(varquivo_blob_ac, v_arq_aceitos, P_CAMINHO);
    --
    -- INSERT DO ARQUIVO DE ACEITOS
    INSERT INTO HAD_ARQ_DOWNLOAD (ID_ROTINA_EXEC,
                                  DESCRICAO,
                                  NOME_ARQUIVO,
                                  MIME_TYPE,
                                  ARQUIVO,
                                  DATA_EXPIRACAO)
                          VALUES (PACK_EXEC_ROTINAS.GET_ID_ROTINA_EXEC ,
                                  'ARQUIVO DE ACEITOS NA CARGA',
                                  v_arq_aceitos,
                                  P_TIPO,
                                  varquivo_blob_ac,
                                  TRUNC(SYSDATE)+1);
    --
    grava_mensagem (v_chave_log, 'Fim do UPLOAD do arquivo de aceitos "'||
                                  upper(v_arq_aceitos) || '" para o banco de dados.');

    --
    PACK_HAD_DOWNLOAD.GRAVA_ARQUIVO_BLOB(varquivo_blob_rej, v_arq_rejeitados, P_CAMINHO);
    --
    -- INSERT DO ARQUIVO DE REJEITADOS
    grava_mensagem (v_chave_log, 'Iniciando o UPLOAD do arquivo de rejeitados "'||
                                  upper(v_arq_rejeitados) || '" para o banco de dados.');

    INSERT INTO HAD_ARQ_DOWNLOAD (ID_ROTINA_EXEC,
                                  DESCRICAO,
                                  NOME_ARQUIVO,
                                  MIME_TYPE,
                                  ARQUIVO,
                                  DATA_EXPIRACAO)
                          VALUES (PACK_EXEC_ROTINAS.GET_ID_ROTINA_EXEC ,
                                  'ARQUIVO DE REJEITADOS NA CARGA',
                                  v_arq_rejeitados,
                                  P_TIPO,
                                  varquivo_blob_rej,
                                  TRUNC(SYSDATE)+1);

    --
    grava_mensagem (v_chave_log, 'Fim do UPLOAD do arquivo de rejeitados "'||
                                  upper(v_arq_rejeitados) || '" para o banco de dados.');

    --
    grava_mensagem (v_chave_log, 'Início da exclusão dos arquivos de erros, rejeitados e aceitos do disco.');

    UTL_FILE.FREMOVE(P_CAMINHO, P_ARQUIVO);
    UTL_FILE.FREMOVE(P_CAMINHO, v_arq_erros);
    UTL_FILE.FREMOVE(P_CAMINHO, v_arq_aceitos);
    UTL_FILE.FREMOVE(P_CAMINHO, v_arq_rejeitados);

    grava_mensagem (v_chave_log, 'Conclusão da exclusão dos arquivos de erros, rejeitados e aceitos do disco.');

    if err_msg is not null then
--
--      return(true);
--    else
--
      grava_mensagem(v_chave_log, err_msg);
--      return(false);
    end if;

    grava_mensagem (v_chave_log, 'FIM DO PROCESSO DE CARGA DO ARQUIVO DE FREQUÊNCIAS.');

 exception
    when others then
      grava_mensagem (v_chave_log, 'Erro no processo: '||trunca_sqlerrm(sqlerrm));
 end;

  PROCEDURE DESFAZ_CARGA( P_ARQUIVO       VARCHAR2
                         ,P_TIPO          VARCHAR2
                         ,P_CAMINHO       VARCHAR2
                         ,P_NUMERO_LAYOUT NUMBER
                         ,P_ID_EXEC_AUDIT LOG_PROCESSO_HEADER.ID_EXEC%TYPE)
  IS
    err_msg varchar2(2000);
    v_erro boolean;
    v_tempo date;
    --v_chave_log    NUMBER;
    v_chave carga_ferias_temp.chave%type;
    v_chave_log log_processo_header.id_exec%type;
    
    --Estabelecendo o nome dos arquivos
    v_arq_rejeitados VARCHAR2(200);
    v_arq_aceitos    VARCHAR2(200);
    v_arq_erros  VARCHAR2(200);
    
    varquivo_blob_err  BLOB;
    varquivo_blob_ac   BLOB;
    varquivo_blob_rej  BLOB;
    
  BEGIN
    
    --Estabelecendo o nome dos arquivos
    v_arq_rejeitados := replace (P_ARQUIVO, '.txt', '.rej');
    v_arq_aceitos    := replace (P_ARQUIVO, '.txt', '.ac');
    v_arq_erros  := replace (P_ARQUIVO, '.txt', '.err');    

    -- Seta as variáveis internas da package
    select nvl(max(chave),0)+1 into v_chave from carga_ferias_temp;

    v_numero_layout:=p_numero_layout;
    v_arquivo:=p_arquivo;
    --v_rejeitados:=p_rejeitados;
    ---V_ARQ_ERROS := P_ERROS;
    --v_aceitos:=p_aceitos;

    --                                              
     v_chave_log := log_pack.insere_log_header('DESFAZENDO A CARGA DE FREQUÊNCIAS',
                                               'Arquivo = ' || upper(v_arquivo) ||
                                                ';' || CHR(10) ||
                                                'Usuário = ' || FLAG_PACK.get_usuario
                                                ||';'|| CHR(10) ||
                                                'Data = ' || to_char(sysdate,'DD/MM/YYYY - hh24:mi')
                                                ||';'|| CHR(10) ||
                                                'Chave de auditoria do process de carga anterior = ' || P_ID_EXEC_AUDIT                                                
                                                ,null);        
      --
      COMMIT;                                                
     --
    --
    -- Carrega o arquivo para a tabela FREQUÊNCIAS e insere erros na tabela temporária
    --

    v_erro := carga_arquivo(v_chave ,P_CAMINHO, P_ARQUIVO, 'D', v_chave_log, P_ID_EXEC_AUDIT);

    --
    -- Gera relatório
    --
    Gera_relatorios(P_CAMINHO, 'C', v_arq_rejeitados, v_arq_aceitos, v_arq_erros, 'D', v_chave, v_chave_log);

    grava_mensagem (v_chave_log, 'Apagando os registros da tabela temporária carga_ferias_temp.');
    --
    -- Apaga registros da tabela temporária
    --
    LOOP
      --
      DELETE carga_ferias_temp
      WHERE CHAVE = v_chave
        AND ROWNUM <= 100;
      --
    EXIT WHEN SQL%ROWCOUNT = 0;
      --
      COMMIT;
      --
    END LOOP;

    --
    COMMIT;
    grava_mensagem (v_chave_log, 'Fim da exclusão dos registros da tabela temporária carga_ferias_temp.');    
    --
--    EXECUTA_SQL_ERGON ('TRUNCATE TABLE CARGA_ATRIB_TEMP');

    grava_mensagem (v_chave_log, 'Iniciando o UPLOAD do arquivo de erros "'||
                                  upper(v_arq_erros) || '" para o banco de dados.'); 
    --
    PACK_HAD_DOWNLOAD.GRAVA_ARQUIVO_BLOB(varquivo_blob_err, v_arq_erros, P_CAMINHO);
    --
    -- INSERT DO ARQUIVO DE ERROS
    INSERT INTO HAD_ARQ_DOWNLOAD (ID_ROTINA_EXEC,
                                  DESCRICAO,
                                  NOME_ARQUIVO,
                                  MIME_TYPE,
                                  ARQUIVO,
                                  DATA_EXPIRACAO)
                          VALUES (PACK_EXEC_ROTINAS.GET_ID_ROTINA_EXEC ,
                                  'ARQUIVO DE ERROS NO CARGA',
                                  v_arq_erros,
                                  P_TIPO,
                                  varquivo_blob_err,
                                  TRUNC(SYSDATE)+1);
    --  
    grava_mensagem (v_chave_log, 'Fim do UPLOAD do arquivo de erros "'||
                                  upper(v_arq_erros) || '" para o banco de dados.'); 
    
    --
    grava_mensagem (v_chave_log, 'Iniciando o UPLOAD do arquivo de aceitos "'||
                                  upper(v_arq_aceitos) || '" para o banco de dados.');
                                  
    PACK_HAD_DOWNLOAD.GRAVA_ARQUIVO_BLOB(varquivo_blob_ac, v_arq_aceitos, P_CAMINHO);
    --
    -- INSERT DO ARQUIVO DE ACEITOS
    INSERT INTO HAD_ARQ_DOWNLOAD (ID_ROTINA_EXEC,
                                  DESCRICAO,
                                  NOME_ARQUIVO,
                                  MIME_TYPE,
                                  ARQUIVO,
                                  DATA_EXPIRACAO)
                          VALUES (PACK_EXEC_ROTINAS.GET_ID_ROTINA_EXEC ,
                                  'ARQUIVO DE ACEITOS NA CARGA',
                                  v_arq_aceitos,
                                  P_TIPO,
                                  varquivo_blob_ac,
                                  TRUNC(SYSDATE)+1);
    -- 
    grava_mensagem (v_chave_log, 'Fim do UPLOAD do arquivo de aceitos "'||
                                  upper(v_arq_aceitos) || '" para o banco de dados.');     
    
    --
    PACK_HAD_DOWNLOAD.GRAVA_ARQUIVO_BLOB(varquivo_blob_rej, v_arq_rejeitados, P_CAMINHO);
    --
    -- INSERT DO ARQUIVO DE REJEITADOS
    grava_mensagem (v_chave_log, 'Iniciando o UPLOAD do arquivo de rejeitados "'||
                                  upper(v_arq_rejeitados) || '" para o banco de dados.');
                                  
    INSERT INTO HAD_ARQ_DOWNLOAD (ID_ROTINA_EXEC,
                                  DESCRICAO,
                                  NOME_ARQUIVO,
                                  MIME_TYPE,
                                  ARQUIVO,
                                  DATA_EXPIRACAO)
                          VALUES (PACK_EXEC_ROTINAS.GET_ID_ROTINA_EXEC ,
                                  'ARQUIVO DE REJEITADOS NA CARGA',
                                  v_arq_rejeitados,
                                  P_TIPO,
                                  varquivo_blob_rej,
                                  TRUNC(SYSDATE)+1);
    
    --
    grava_mensagem (v_chave_log, 'Fim do UPLOAD do arquivo de rejeitados "'||
                                  upper(v_arq_rejeitados) || '" para o banco de dados.');

    --   
    grava_mensagem (v_chave_log, 'Início da exclusão dos arquivos de erros, rejeitados e aceitos do disco.');
    
    UTL_FILE.FREMOVE(P_CAMINHO, P_ARQUIVO);
    UTL_FILE.FREMOVE(P_CAMINHO, v_arq_erros);
    UTL_FILE.FREMOVE(P_CAMINHO, v_arq_aceitos);
    UTL_FILE.FREMOVE(P_CAMINHO, v_arq_rejeitados);
    
    grava_mensagem (v_chave_log, 'Conclusão da exclusão dos arquivos de erros, rejeitados e aceitos do disco.');

    if err_msg is not null then
--
--      return(true);
--    else
--
      grava_mensagem(v_chave_log, err_msg);
--      return(false);
    end if;
    
    grava_mensagem (v_chave_log, 'FIM DO PROCESSO DE DESFAZER A CARGA DO ARQUIVO DE FREQUÊNCIAS.');    
 
 exception
    when others then
      grava_mensagem (v_chave_log, 'Erro no processo: '||trunca_sqlerrm(sqlerrm));
  END DESFAZ_CARGA;

  /***********************************************************************************************/
  /***************************** CARREGA LAYOUT DO ARQUIVO ***************************************/
  /***********************************************************************************************/

  /************************************************************************************
   * FUNCTION FORMATO_NUMERICO
   * Função para checar o formato numérico usado em TO_NUMBER
   * Entrada: p_formato - formato a ser checado (pode ser NULL)
   * Retorna um formato válido
   ************************************************************************************/
  function formato_numerico(p_formato in varchar2) return varchar2 is
    v_formato varchar2(30);
    v_aux varchar2(30);
    car varchar2(1);
    v_achou boolean;
    i number;
  begin
    if p_formato is null then
      v_formato:='999999999999999D999999';
    else
      -- Tira todos os pontos e vírgulas do formato, menos o último
      v_aux:=replace(p_formato,'Ggd,.','DDDDD');
      v_formato:='';
      i:=length(v_aux);
      v_achou:=false;
      loop
        car:=substr(v_aux,i,1);
        if car='D' then
          if v_achou=false then
            v_achou:=true;
          else
            car:='';
          end if;
        end if;
        v_formato:=car||v_formato;
        i:=i-1;
        if i=0 then
          exit;
        end if;
      end loop;
    end if;
    return(v_formato);
  end;

  /************************************************************************************
   * PROCEDURE LIMPA_LAYOUT
   * Sub-rotina para limpar o layout já carregado. Atribui NULL para todas as variáveis
   * internas desta package
   ************************************************************************************/
  procedure Limpa_layout is
  begin
      col_numfunc.numero:=null;
    col_numvinc.numero:=null;
    col_chaveperaqfer.numero:=null;
    col_dtini.numero:=null;
    col_dtfim.numero:=null;
    col_abono.numero:=null;
    col_adiantdterc.numero:=null;
    col_adiantsal.numero:=null;
    col_emprestimo.numero:=null;
    col_totdias.numero:=null;
    col_inifimanono.numero:=null;
    col_obs.numero:=null;
    col_mes_ano_folha.numero:=null;
    col_numfolha.numero:=null;
    col_pontpubl.numero:=null;
    col_emp_codigo.numero:=null;
    col_pontlei.numero:=null;
    col_dtprevfim.numero:=null;
    col_abono_const.numero:=null;
    col_flex_campo_01.numero:=null;
    col_flex_campo_02.numero:=null;
    col_flex_campo_03.numero:=null;
    col_flex_campo_04.numero:=null;
    col_flex_campo_05.numero:=null;
    col_hora_entrada.numero:=null;
    col_hora_saida.numero:=null;
    col_id_reg.numero:=null;

        col_numfunc.coluna:=null;
    col_numvinc.coluna:=null;
    col_chaveperaqfer.coluna:=null;
    col_dtini.coluna:=null;
    col_dtfim.coluna:=null;
    col_abono.coluna:=null;
    col_adiantdterc.coluna:=null;
    col_adiantsal.coluna:=null;
    col_emprestimo.coluna:=null;
    col_totdias.coluna:=null;
    col_inifimanono.coluna:=null;
    col_obs.coluna:=null;
    col_mes_ano_folha.coluna:=null;
    col_numfolha.coluna:=null;
    col_pontpubl.coluna:=null;
    col_emp_codigo.coluna:=null;
    col_pontlei.coluna:=null;
    col_dtprevfim.coluna:=null;
    col_abono_const.coluna:=null;
    col_flex_campo_01.coluna:=null;
    col_flex_campo_02.coluna:=null;
    col_flex_campo_03.coluna:=null;
    col_flex_campo_04.coluna:=null;
    col_flex_campo_05.coluna:=null;
    col_hora_entrada.coluna:=null;
    col_hora_saida.coluna:=null;
    col_id_reg.coluna:=null;


        col_numfunc.valor:=null;
    col_numvinc.valor:=null;
    col_chaveperaqfer.valor:=null;
    col_dtini.valor:=null;
    col_dtfim.valor:=null;
    col_abono.valor:=null;
    col_adiantdterc.valor:=null;
    col_adiantsal.valor:=null;
    col_emprestimo.valor:=null;
    col_totdias.valor:=null;
    col_inifimanono.valor:=null;
    col_obs.valor:=null;
    col_mes_ano_folha.valor:=null;
    col_numfolha.valor:=null;
    col_pontpubl.valor:=null;
    col_emp_codigo.valor:=null;
    col_pontlei.valor:=null;
    col_dtprevfim.valor:=null;
    col_abono_const.valor:=null;
        col_flex_campo_01.valor:=null;
    col_flex_campo_02.valor:=null;
    col_flex_campo_03.valor:=null;
    col_flex_campo_04.valor:=null;
    col_flex_campo_05.valor:=null;
    col_hora_entrada.valor:=null;
    col_hora_saida.valor:=null;
    col_id_reg.valor:=null;

       col_numfunc.formato:=null;
    col_numvinc.formato:=null;
    col_chaveperaqfer.formato:=null;
    col_dtini.formato:=null;
    col_dtfim.formato:=null;
    col_abono.formato:=null;
    col_adiantdterc.formato:=null;
    col_adiantsal.formato:=null;
    col_emprestimo.formato:=null;
    col_totdias.formato:=null;
    col_inifimanono.formato:=null;
    col_obs.formato:=null;
    col_mes_ano_folha.formato:=null;
    col_numfolha.formato:=null;
    col_pontpubl.formato:=null;
    col_emp_codigo.formato:=null;
    col_pontlei.formato:=null;
    col_dtprevfim.formato:=null;
    col_abono_const.formato:=null;
        col_flex_campo_01.formato:=null;
    col_flex_campo_02.formato:=null;
    col_flex_campo_03.formato:=null;
    col_flex_campo_04.formato:=null;
    col_flex_campo_05.formato:=null;
    col_hora_entrada.formato:=null;
    col_hora_saida.formato:=null;
    col_id_reg.formato:=null;

    col_numfunc.ordem:=null;
    col_numvinc.ordem:=null;
    col_chaveperaqfer.ordem:=null;
    col_dtini.ordem:=null;
    col_dtfim.ordem:=null;
    col_abono.ordem:=null;
    col_adiantdterc.ordem:=null;
    col_adiantsal.ordem:=null;
    col_emprestimo.ordem:=null;
    col_totdias.ordem:=null;
    col_inifimanono.ordem:=null;
    col_obs.ordem:=null;
    col_mes_ano_folha.ordem:=null;
    col_numfolha.ordem:=null;
    col_pontpubl.ordem:=null;
    col_emp_codigo.ordem:=null;
    col_pontlei.ordem:=null;
    col_dtprevfim.ordem:=null;
    col_abono_const.ordem:=null;
        col_flex_campo_01.ordem:=null;
    col_flex_campo_02.ordem:=null;
    col_flex_campo_03.ordem:=null;
    col_flex_campo_04.ordem:=null;
    col_flex_campo_05.ordem:=null;
    col_hora_entrada.ordem:=null;
    col_hora_saida.ordem:=null;
    col_id_reg.ordem:=null;

  end;

  /************************************************************************************
   * FUNCTION CARREGA_LAYOUT
   * Sub-rotina para carregar o layout do arquivo nas variáveis internas da package
   * Retorna NULL se conversão OK, retorna mensagem em caso de erro.
   ************************************************************************************/
  function Carrega_layout(p_numero number, p_modo_carga varchar2) return varchar2 is
    cursor cur_colunas is
      select ordem, upper(coluna) coluna from carga_colunas
      where numero=p_numero and ordem is not null
      order by ordem;
    i binary_integer;
    err_msg varchar2(100);
  begin
    -- Primeiro limpa o layout já existente
    Limpa_layout;
    -- Pega o Delimitador
    begin
      select delimitador into car_delimitador from carga_layout
      where numero=p_numero;
    exception
      when no_data_found then
         err_msg:='Não foi definido layout com este número.';
         return err_msg;
      when others then
         err_msg:='Erro ao buscar o layout com este número: '||trunca_sqlerrm(sqlerrm);
         return err_msg;
    end;
    --
    --
    -- Colunas
    --

    begin
      select * into col_numfunc from carga_colunas
      where numero=p_numero and upper(coluna)='NUMFUNC';
    exception
      when no_data_found then
--         err_msg:='Falta a coluna NUMFUNC no layout do arquivo.';
--         raise;
           COL_NUMFUNC := NULL;
      when others then raise;
    end;
    begin
      select * into col_numvinc from carga_colunas
      where numero=p_numero and upper(coluna)='NUMVINC';
    exception
      when no_data_found then
--         err_msg:='Falta a coluna NUMVINC no layout do arquivo.';
--         raise;
           COL_NUMVINC := NULL;
      when others then raise;
    end;
    --

    if col_numfunc.coluna is null then
         err_msg:='Falta a coluna NUMFUNC no layout do arquivo.';
         return err_msg;
    end if;

    if col_numvinc.coluna is null then
         err_msg:='Falta a coluna NUMVINC no layout do arquivo.';
         return err_msg;
    end if;
    --
    
    -- CHAVEPERAQFER
    begin
      select * into col_chaveperaqfer from carga_colunas
      where numero=p_numero and upper(coluna)='CHAVEPERAQFER';
      if col_chaveperaqfer.formato is null then
        err_msg:='Falta o formato de CHAVEPERAQFER no layout do arquivo.';
        raise value_error;
      else
        col_chaveperaqfer.formato:=formato_numerico(col_chaveperaqfer.formato);
      end if;
    exception
      when no_data_found then
        if p_modo_carga<>'E' then
          err_msg:='Falta a coluna CHAVEPERAQFER no layout do arquivo.';
          raise;
        end if;
      when others then raise;
    end;
    --
    -- DTINI
    begin
      select * into col_dtini from carga_colunas
      where numero=p_numero and upper(coluna)='DTINI';
      if col_dtini.formato is null then
        err_msg:='Falta o formato de DTINI no layout do arquivo.';
        raise value_error;
      else
        col_dtini.formato:=replace(col_dtini.formato,'aA','yY');
      end if;
    exception
      when no_data_found then
        if p_modo_carga<>'E' then
          err_msg:='Falta a coluna DTINI no layout do arquivo.';
          raise;
        end if;
      when others then raise;
    end;

    -- DTFIM
    begin
      select * into col_dtfim from carga_colunas
      where numero=p_numero and upper(coluna)='DTFIM';
      if col_dtfim.formato is null then
        err_msg:='Falta o formato de DTFIM no layout do arquivo.';
        raise value_error;
      else
        col_dtfim.formato:=replace(col_dtfim.formato,'aA','yY');
      end if;
      tem_dtfim:=true;
    exception
      when no_data_found then
        if p_modo_carga='E' then
          err_msg:='Falta a coluna DTFIM no layout do arquivo.';
          raise;
        else
          col_dtfim.numero:=null;
          tem_dtfim:=false;
        end if;
      when others then raise;
    end;

    --
    -- ABONO
    begin
      select * into col_abono from carga_colunas
      where numero=p_numero and upper(coluna)='ABONO';
      --col_valor2.formato:=formato_numerico(col_valor2.formato);
      tem_abono:=true;
    exception
      when no_data_found then 
        col_abono.numero:=null;
        tem_abono:=false;
      when others then raise;
    end;
    --
    -- ADIANTDTERC
    begin
      select * into col_adiantdterc from carga_colunas
      where numero=p_numero and upper(coluna)='ADIANTDTERC';
      tem_adiantdterc:=true;
    exception
      when no_data_found then 
        col_adiantdterc.numero:=null;
        tem_adiantdterc:=false;
      when others then raise;
    end;
    --
    -- ADIANTSAL
    begin
      select * into col_adiantsal from carga_colunas
      where numero=p_numero and upper(coluna)='ADIANTSAL';
      tem_adiantsal:=true;
    exception
      when no_data_found then 
        col_adiantsal.numero:=null;
        tem_adiantsal:=false;
      when others then raise;
    end;
    --
    -- EMPRESTIMO
    begin
      select * into col_emprestimo from carga_colunas
      where numero=p_numero and upper(coluna)='EMPRESTIMO';
      tem_emprestimo:=true;
    exception
      when no_data_found then 
        col_emprestimo.numero:=null;
        tem_emprestimo:=false;
      when others then raise;
    end;
    --
    -- TOTDIAS
    begin
      select * into col_totdias from carga_colunas
      where numero=p_numero and upper(coluna)='TOTDIAS';
      if col_totdias.formato is null then
        err_msg:='Falta o formato de TOTDIAS no layout do arquivo.';
        raise value_error;
      else
        col_totdias.formato:=formato_numerico(col_totdias.formato);
      end if;
    exception
      when no_data_found then
        if p_modo_carga<>'E' then
          err_msg:='Falta a coluna TOTDIAS no layout do arquivo.';
          raise;
        end if;
      when others then raise;
    end;
    --
    -- INIFIMABONO
    begin
      select * into col_inifimanono from carga_colunas
      where numero=p_numero and upper(coluna)='INIFIMABONO';
      tem_inifimanono:=true;
    exception
      when no_data_found then 
        col_inifimanono.numero:=null;
        tem_inifimanono:=false;
      when others then raise;
    end;
    --
    -- OBS
    begin
      select * into col_obs from carga_colunas
      where numero=p_numero and upper(coluna)='OBS';
      tem_obs:=true;
    exception
      when no_data_found then 
        col_obs.numero:=null;
        tem_obs:=false;
      when others then raise;
    end;
    --
    -- MES_ANO_FOLHA
    begin
      select * into col_mes_ano_folha from carga_colunas
      where numero=p_numero and upper(coluna)='MES_ANO_FOLHA';
      if col_mes_ano_folha.formato is null then
        err_msg:='Falta o formato de MES_ANO_FOLHA no layout do arquivo.';
        raise value_error;
      else
        col_mes_ano_folha.formato:=replace(col_mes_ano_folha.formato,'aA','yY');
      end if;
      tem_mes_ano_folha:=true;
    exception
      when no_data_found then
        if p_modo_carga='E' then
          err_msg:='Falta a coluna MES_ANO_FOLHA no layout do arquivo.';
          raise;
        else
          col_mes_ano_folha.numero:=null;
          tem_mes_ano_folha:=false;
        end if;
      when others then raise;
    end;
    --
    -- NUMFOLHA
    begin
      select * into col_numfolha from carga_colunas
      where numero=p_numero and upper(coluna)='NUMFOLHA';
      if col_numfolha.formato is null then
        err_msg:='Falta o formato de NUMFOLHA no layout do arquivo.';
        raise value_error;
      else
        col_numfolha.formato:=formato_numerico(col_numfolha.formato);
      end if;
    exception
      when no_data_found then
        if p_modo_carga<>'E' then
          err_msg:='Falta a coluna NUMFOLHA no layout do arquivo.';
          raise;
        end if;
      when others then raise;
    end;
    --
    -- PONTPUBL
    begin
      select * into col_pontpubl from carga_colunas
      where numero=p_numero and upper(coluna)='PONTPUBL';
      if col_pontpubl.formato is null then
        err_msg:='Falta o formato de PONTPUBL no layout do arquivo.';
        raise value_error;
      else
        col_pontpubl.formato:=formato_numerico(col_pontpubl.formato);
      end if;
    exception
      when no_data_found then
        if p_modo_carga<>'E' then
          err_msg:='Falta a coluna PONTPUBL no layout do arquivo.';
          raise;
        end if;
      when others then raise;
    end;
    --
    -- EMP_CODIGO
    begin
      select * into col_emp_codigo from carga_colunas
      where numero=p_numero and upper(coluna)='EMP_CODIGO';
      tem_emp_codigo:=true;
    exception
      when no_data_found then 
        col_emp_codigo.numero:=null;
        tem_emp_codigo:=false;
      when others then raise;
    end;
    --
-- PONTLEI
    begin
      select * into col_pontlei from carga_colunas
      where numero=p_numero and upper(coluna)='PONTLEI';
      if col_pontlei.formato is null then
        err_msg:='Falta o formato de PONTLEI no layout do arquivo.';
        raise value_error;
      else
        col_pontlei.formato:=formato_numerico(col_pontlei.formato);
      end if;
    exception
      when no_data_found then
        if p_modo_carga<>'E' then
          err_msg:='Falta a coluna PONTLEI no layout do arquivo.';
          raise;
        end if;
      when others then raise;
    end;
    --    
    -- DTPREVFIM
    begin
      select * into col_dtprevfim from carga_colunas
      where numero=p_numero and upper(coluna)='DTPREVFIM';
      if col_dtprevfim.formato is null then
        err_msg:='Falta o formato de DTPREVFIM no layout do arquivo.';
        raise value_error;
      else
        col_dtprevfim.formato:=replace(col_dtprevfim.formato,'aA','yY');
      end if;
      tem_dtprevfim:=true;
    exception
      when no_data_found then
        if p_modo_carga='E' then
          err_msg:='Falta a coluna DTPREVFIM no layout do arquivo.';
          raise;
        else
          col_dtprevfim.numero:=null;
          tem_dtprevfim:=false;
        end if;
      when others then raise;
    end;

    --
    -- FLEX_CAMPO_01
    begin
      select * into col_flex_campo_01 from carga_colunas
      where numero=p_numero and upper(coluna)='FLEX_CAMPO_01';
      tem_flex_campo_01:=true;
    exception
      when no_data_found then 
        col_flex_campo_01.numero:=null;
        tem_flex_campo_01:=false;
      when others then raise;
    end;
    --
    -- FLEX_CAMPO_02
    begin
      select * into col_flex_campo_02 from carga_colunas
      where numero=p_numero and upper(coluna)='FLEX_CAMPO_02';
      tem_flex_campo_02:=true;
    exception
      when no_data_found then 
        col_flex_campo_02.numero:=null;
        tem_flex_campo_02:=false;
      when others then raise;
    end;
    --
    -- FLEX_CAMPO_03
    begin
      select * into col_flex_campo_03 from carga_colunas
      where numero=p_numero and upper(coluna)='FLEX_CAMPO_03';
      tem_flex_campo_03:=true;
    exception
      when no_data_found then 
        col_flex_campo_03.numero:=null;
        tem_flex_campo_03:=false;
      when others then raise;
    end;
    --
    -- FLEX_CAMPO_04
    begin
      select * into col_flex_campo_04 from carga_colunas
      where numero=p_numero and upper(coluna)='FLEX_CAMPO_04';
      tem_flex_campo_04:=true;
    exception
      when no_data_found then 
        col_flex_campo_04.numero:=null;
        tem_flex_campo_04:=false;
      when others then raise;
    end;
    --
    -- FLEX_CAMPO_05
    begin
      select * into col_flex_campo_05 from carga_colunas
      where numero=p_numero and upper(coluna)='FLEX_CAMPO_05';
      tem_flex_campo_05:=true;
    exception
      when no_data_found then 
        col_flex_campo_05.numero:=null;
        tem_flex_campo_05:=false;
      when others then raise;
    end;


    -- Checa consistência do layout
    if col_numfunc.valor is null and
       col_numfunc.coluna is not null and
         ((car_delimitador is null and (col_numfunc.inicio is null or col_numfunc.fim is null))
          or (car_delimitador is not null and col_numfunc.ordem is null)) then
        err_msg:='O valor/posição da coluna NUMFUNC não está definido corretamente no layout.';
        raise value_error;
    end if;
    if col_numvinc.valor is null and
       col_numvinc.coluna is not null and
         ((car_delimitador is null and (col_numvinc.inicio is null or col_numvinc.fim is null))
          or (car_delimitador is not null and col_numvinc.ordem is null)) then
        err_msg:='O valor/posição da coluna NUMVINC não está definido corretamente no layout.';
        raise value_error;
      end if;
    --

    --
    if col_dtini.numero is not null and col_dtini.valor is null and 
       ((car_delimitador is null and (col_dtini.inicio is null or col_dtini.fim is null))
        or (car_delimitador is not null and col_dtini.ordem is null)) then
      err_msg:='O valor/posição da coluna DTINI não está definido corretamente no layout.';
      raise value_error;
    end if; 
    --
    if col_dtfim.numero is not null and col_dtfim.valor is null and 
       ((car_delimitador is null and (col_dtfim.inicio is null or col_dtfim.fim is null))
        or (car_delimitador is not null and col_dtfim.ordem is null)) then
      err_msg:='O valor/posição da coluna DTFIM não está definido corretamente no layout.';
      raise value_error;
    end if;


    --
    if col_obs.numero is not null and col_obs.valor is null and 
       ((car_delimitador is null and (col_obs.inicio is null or col_obs.fim is null))
        or (car_delimitador is not null and col_obs.ordem is null)) then
      err_msg:='O valor/posição da coluna OBSERVACAO não está definido corretamente no layout.';
      raise value_error;
    end if; 
    --
    if col_emp_codigo.numero is not null and col_emp_codigo.valor is null and 
       ((car_delimitador is null and (col_emp_codigo.inicio is null or col_emp_codigo.fim is null))
        or (car_delimitador is not null and col_emp_codigo.ordem is null)) then
      err_msg:='O valor/posição da coluna EMP_CODIGO não está definido corretamente no layout.';
      raise value_error;
    end if; 
    -- Se chegou até aqui, o layout está OK. A função retorna NULL
    return(NULL);
  exception
    when others then
      if err_msg is not null then
        return(err_msg);
      else

        return(sqlerrm);
      end if;
  end Carrega_layout;

  /************************************************************************************
   * FUNCTION CONV_LINHA
   * Função para converter uma linha do arquivo em um registro da tabela VANTAGENS
   *
   * Parâmetro de entrada: P_LINHA - linha do arquivo
   * Parâmetro de saída: P_REC - registro de frequências
   *                     P_OPER - caractere da operacao(I,U,D)
   * Retorna NULL se conversão OK, retorna mensagem em caso de erro.
   ************************************************************************************/
   function conv_linha(p_linha in varchar2, p_modo_carga in varchar2, p_rec out ferias%rowtype, p_oper out varchar2) return varchar2 is
     err_msg          varchar2(500);
     v_linha          varchar2(4000);
     v_numfunc        varchar2(100);
     v_numvinc        varchar2(100);
     v_chaveperaqfer  number;
     v_dtini          varchar2(100);
   v_dtfim          varchar2(100);
   v_abono       varchar2(100);
   v_adiantdterc        varchar2(200);
   v_adiantsal     varchar2(200);
   v_emprestimo     varchar2(200);
   v_totdias     varchar2(200);
   v_inifimanono     varchar2(200);
   v_obs            varchar2(2000);
   v_flex_campo_01  varchar2(2000);
   v_flex_campo_02  varchar2(2000);
   v_flex_campo_03  varchar2(2000);
   v_flex_campo_04  varchar2(2000);
   v_flex_campo_05  varchar2(2000);
   v_mes_ano_folha            varchar2(2000);
   v_numfolha            varchar2(2000);
   v_pontpubl           varchar2(2000);
   v_emp_codigo     varchar2(20);
   v_pontlei        varchar2(100);
   v_dtprevfim        varchar2(100);
   v_abono_const        varchar2(100);
   v_hora_entrada   varchar2(100);
   v_hora_saida     varchar2(100);
   v_id_reg         varchar2(100);


     v_operacao       varchar2(60);
     v_existe_freq    number;
     v_setor          hsetor.setor%type;
     v_empresa        vinculos.emp_codigo%type;
     --
     v_bloqueia_dupl  char(1);
     v_existe_lanc    number := 0;
     v_existe_dupl    number := 0;
     v_existe_freq_numfunc number := 0;

   begin
     -- Copia os registros da linha do arquivo para as variáveis auxiliares
     flag_pack.set_empresa(flag_pack.get_empresa); -- 13/05/2015
     if car_delimitador is null then
       --
       -- Rotina de cópia para o caso SEM delimitador
       --
       begin

         --
         if col_numfunc.coluna is not null and
            col_numvinc.coluna is not null then
           -- NUMFUNC
           if col_numfunc.valor is null then
             v_numfunc:=substr(p_linha,col_numfunc.inicio,col_numfunc.fim-col_numfunc.inicio+1);
           else
             v_numfunc:=col_numfunc.valor;
           end if;
           -- NUMVINCGera_relatorios(
           if col_numvinc.valor is null then
             v_numvinc:=substr(p_linha,col_numvinc.inicio,col_numvinc.fim-col_numvinc.inicio+1);
           else
             v_numvinc:=col_numvinc.valor;
           end if;
           begin
             select numfunc, numero into v_numfunc, v_numvinc
             from vinculos
             where numfunc = v_numfunc and numero = v_numvinc;
           exception
             when no_data_found then
               err_msg := 'Vínculo não cadastrado no sistema.';
               return (err_msg);
           end;
         end if;

         -- DTINI
         if col_dtini.numero is not null then
           if col_dtini.valor is null then
             v_dtini:=substr(p_linha,col_dtini.inicio,col_dtini.fim-col_dtini.inicio+1);
           else
             v_dtini:=col_dtini.valor;
           end if;
         end if;
         -- DTFIM
         if col_dtfim.numero is not null then
           if col_dtfim.valor is null then
             v_dtfim:=substr(p_linha,col_dtfim.inicio,col_dtfim.fim-col_dtfim.inicio+1);
           else 
             v_dtfim:=col_dtfim.valor;
           end if;
         end if;

         -- OBS
         if col_obs.numero is not null then
           if col_obs.valor is null then
             v_obs:=substr(p_linha,col_obs.inicio,col_obs.fim-col_obs.inicio+1);
           else
             v_obs:=col_obs.valor;
           end if;
         end if;
         -- EMP_CODIGO
         if col_emp_codigo.numero is not null then
           if col_emp_codigo.valor is null then
             v_emp_codigo:=substr(p_linha,col_emp_codigo.inicio,col_emp_codigo.fim-col_emp_codigo.inicio+1);
           else
             v_emp_codigo:=col_emp_codigo.valor;
           end if;
         end if;
         -- FLEX_CAMPO_01
         if col_flex_campo_01.numero is not null then
           if col_flex_campo_01.valor is null then
             v_flex_campo_01:=substr(p_linha,col_flex_campo_01.inicio,col_flex_campo_01.fim-col_flex_campo_01.inicio+1);
           else 
             v_flex_campo_01:=col_flex_campo_01.valor;
           end if;
         end if;
         -- FLEX_CAMPO_02
         if col_flex_campo_02.numero is not null then
           if col_flex_campo_02.valor is null then
             v_flex_campo_02:=substr(p_linha,col_flex_campo_02.inicio,col_flex_campo_02.fim-col_flex_campo_02.inicio+1);
           else 
             v_flex_campo_02:=col_flex_campo_02.valor;
           end if;
         end if;
         -- FLEX_CAMPO_03
         if col_flex_campo_03.numero is not null then
           if col_flex_campo_03.valor is null then
             v_flex_campo_03:=substr(p_linha,col_flex_campo_03.inicio,col_flex_campo_03.fim-col_flex_campo_03.inicio+1);
           else 
             v_flex_campo_03:=col_flex_campo_03.valor;
           end if;
         end if;
         -- FLEX_CAMPO_04
         if col_flex_campo_04.numero is not null then
           if col_flex_campo_04.valor is null then
             v_flex_campo_04:=substr(p_linha,col_flex_campo_04.inicio,col_flex_campo_04.fim-col_flex_campo_04.inicio+1);
           else 
             v_flex_campo_04:=col_flex_campo_04.valor;
           end if;
         end if;
         -- FLEX_CAMPO_05
         if col_flex_campo_05.numero is not null then
           if col_flex_campo_05.valor is null then
             v_flex_campo_05:=substr(p_linha,col_flex_campo_05.inicio,col_flex_campo_05.fim-col_flex_campo_05.inicio+1);
           else 
             v_flex_campo_05:=col_flex_campo_05.valor;
           end if;
         end if;


       exception
         when others then
           err_msg:='Erro em Posicionamento de Colunas.';
           return(err_msg);
       end;
     else
       --
       -- Rotina de cópia para o caso COM delimitador
       --
       declare
--         TYPE tipocampo IS TABLE OF varchar2(60) INDEX BY BINARY_INTEGER;
         TYPE tipocampo IS TABLE OF varchar2(2000) INDEX BY BINARY_INTEGER;
         t_campo tipocampo;
         pos_ini number;
         pos_fim number;
         i binary_integer;
       begin
         --break;
         -- Primeiro, preenche um vetor com os campos achados na linha
         begin
           v_linha:=p_linha;
           i:=1;
           pos_ini:=1;
           t_campo(0):=null;
           loop
             pos_fim:=instr(v_linha,car_delimitador,pos_ini,1);

             if pos_fim=0 then
               t_campo(i):=substr(v_linha,pos_ini);
               exit;
             end if;
             t_campo(i):=substr(v_linha,pos_ini,pos_fim-pos_ini);
             i:=i+1;

             pos_ini:=pos_fim+1;

           end loop;
         exception
           when value_error then
--             err_msg:='O tamanho do campo '||to_char(i)||' é maior que 60 caracteres';
             err_msg:='O tamanho do campo '||to_char(i)||' é maior que 2000 caracteres';
             return(err_msg);
         end;
         -- Depois, copia os valores do vetor para as variáveis auxiliares
         begin
           --

           if col_numfunc.coluna is not null and
              col_numvinc.coluna is not null then  
             v_numfunc:=nvl(col_numfunc.valor, t_campo(nvl(col_numfunc.ordem,0)));
             v_numvinc:=nvl(col_numvinc.valor, t_campo(nvl(col_numvinc.ordem,0)));
             v_emp_codigo:=nvl(col_emp_codigo.valor,t_campo(nvl(col_emp_codigo.ordem,0)));
             --


             ---
             --- Verifica Id Funcional e Vinculo
             Begin
               select 'S'
                  into v_existe
                  from funcionarios
                  where numero = v_numfunc;

               exception
                    when no_data_found then
                          err_msg := 'Id Funcional não cadastrado no sistema.'||v_numfunc;
                          return(err_msg);
                    when others then
                          err_msg := 'Id Funcional não contem somente numeros.'||v_numfunc;
                          return(err_msg);
             End;
             --
             --
             if v_numfunc is null then
                err_msg := 'Id Funcional inválido - Nulo.';
                return(err_msg);
             end if;
             --
             if v_numfunc = 0 then
                err_msg := 'Id Funcional inválido - Zerado.';
                return(err_msg);
             end if;
             --
             --
             --
             begin
               select numfunc, numero, emp_codigo into v_numfunc, v_numvinc, v_empresa
               from vinculos
               where numfunc = v_numfunc and numero = v_numvinc;

             exception
               when no_data_found then
                 err_msg := 'Vínculo inválido no sistema.';
                 return (err_msg);
             end;
             --
             
             --
             -- critica da empresa do vinculo do servidor, nao pode ser diferente da empresa no txt
             --
             if v_empresa != v_emp_codigo then
                err_msg := 'Código da Empresa '||v_emp_codigo||' do arquivo txt é diferente da empresa '||v_empresa||' que pertence ao Vinculo: '||v_numvinc||' do Servidor.';
                return(err_msg);
             end if;             
             --
             -- Pega setor do funcionário
             v_setor := pack_ergon.get_setor_func(v_numfunc,v_numvinc, sysdate);
             --
             if v_setor is not null then
                --
                -- Verifica se o usuário tem acesso ao setor do funcionário
                --

                if PACK_HADES.mostra_setor (flag_pack.get_usuario, v_setor, v_empresa) = 0 then
                   err_msg := 'Usuário '||flag_pack.get_usuario||' não tem permissão de'||
                              ' acesso ao setor deste funcionário(' || v_setor || ')';

                   return(err_msg);
                end if;
             end if;
             --
           end if;
           --

           v_dtini:=nvl(col_dtini.valor, t_campo(nvl(col_dtini.ordem,0)));
           v_dtfim:=nvl(col_dtfim.valor,t_campo(nvl(col_dtfim.ordem,0)));
           v_chaveperaqfer:=nvl(col_chaveperaqfer.valor,t_campo(nvl(col_chaveperaqfer.ordem,0)));
           v_obs:=nvl(col_obs.valor,t_campo(nvl(col_obs.ordem,0)));
           v_flex_campo_01:=nvl(col_flex_campo_01.valor,t_campo(nvl(col_flex_campo_01.ordem,0)));
           v_flex_campo_02:=nvl(col_flex_campo_02.valor,t_campo(nvl(col_flex_campo_02.ordem,0)));
           v_flex_campo_03:=nvl(col_flex_campo_03.valor,t_campo(nvl(col_flex_campo_03.ordem,0)));
           v_flex_campo_04:=nvl(col_flex_campo_04.valor,t_campo(nvl(col_flex_campo_04.ordem,0)));
           v_flex_campo_05:=nvl(col_flex_campo_05.valor,t_campo(nvl(col_flex_campo_05.ordem,0)));


           ------------------------------------------------------------------------------

         exception
           when no_data_found then
             err_msg:='O número de delimitadores da linha é menor que o especificado no layout';
             return(err_msg);
           when others then
             err_msg:=sqlerrm;
             return(err_msg);
         end;
       exception
         when others then
           err_msg:='Erro nos delimitadores da coluna';
           return(err_msg);
       end;
     end if;
     -- Converte os registro para os datatypes apropriados e copia-os para o registro de
     -- frequências.

     begin
       p_rec.numfunc:=to_number(v_numfunc);
     exception
       when others then return('Valor inválido para NUMFUNC');
     end;
     begin
       p_rec.numvinc:=to_number(v_numvinc);
     exception
       when others then return('Valor inválido para NUMVINC');
     end;
     
     begin
       p_rec.dtini:=to_date(ltrim(rtrim(v_dtini)),col_dtini.formato);
     exception
       when others then return('Data inválida em DTINI');
     end;
     begin
       p_rec.dtfim:=to_date(ltrim(rtrim(v_dtfim)),col_dtfim.formato);
     exception
       when others then return('Data inválida em DTFIM');
     end;
     begin
       v_chaveperaqfer := REPLACE(REPLACE(v_chaveperaqfer,CHR(13),''),CHR(10),'');
    --   p_rec.valor:=to_number(v_chaveperaqfer);  --col_valor.formato);
     exception
       when others then return('Valor inválido para VALOR');
     end;
     begin
       p_rec.obs:=ltrim(rtrim(v_obs));
     exception
       when others then return('Valor inválido para OBSERVACAO');
     end;
     begin
       p_rec.emp_codigo:=ltrim(rtrim(v_emp_codigo));
     exception
       when others then return('Valor inválido para EMP_CODIGO');
     end;
     begin
       p_rec.flex_campo_01:=ltrim(rtrim(v_flex_campo_01));
     exception
       when others then return('Valor inválido para FLEX_CAMPO_01');
     end;
     begin
       p_rec.flex_campo_02:=ltrim(rtrim(v_flex_campo_02));
     exception
       when others then return('Valor inválido para FLEX_CAMPO_02');
     end;
     begin
       p_rec.flex_campo_03:=ltrim(rtrim(v_flex_campo_03));
     exception
       when others then return('Valor inválido para FLEX_CAMPO_03');
     end;
     begin
       p_rec.flex_campo_04:=ltrim(rtrim(v_flex_campo_04));
     exception
       when others then return('Valor inválido para FLEX_CAMPO_04');
     end;
     begin
       p_rec.flex_campo_05:=ltrim(rtrim(v_flex_campo_05));
     exception
       when others then return('Valor inválido para FLEX_CAMPO_05');
     end;
     begin
       p_oper:=v_operacao;
     exception
       when others then return('Erro no valor da OPERACAO.');
     end;

     -- Se chegou até aqui, tudo OK
     return(NULL);


   end conv_linha;


END TGRJ_PACK_CARGA_FERIAS;
/
