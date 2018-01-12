CREATE OR REPLACE
PACKAGE BODY TGRJ_PACK_CARGA_ATRIB IS
  --v_chave number;
  v_numero_layout number;
  v_arquivo varchar2(200);
  v_cont number;
--  v_chave_grupo_eleito number := null;
  v_cria_grupo_eleitos varchar2(1) := 'S';
  --
  v_numero_linhas       number;
  v_numero_linhas_erro  number;

  --
  v_texto_relatorio varchar2(2000);
  --

  --
  -- Variáveis internas para guardar o layout do arquivo de carga
  --
  -- Caractere delimitador (se for nulo, as colunas são por posição
  car_delimitador carga_layout.delimitador%type;
  -- Definições das colunas do arquivo
  col_numfunc   carga_colunas%rowtype;
  col_numvinc   carga_colunas%rowtype;
  col_matric    carga_colunas%rowtype;
  col_vantagem  carga_colunas%rowtype;
  col_rubrica   carga_colunas%rowtype;
  col_dtini     carga_colunas%rowtype;
  col_dtfim     carga_colunas%rowtype;
  col_valor     carga_colunas%rowtype;
  col_info      carga_colunas%rowtype;
  col_valor2    carga_colunas%rowtype;
  col_info2     carga_colunas%rowtype;
  col_valor3    carga_colunas%rowtype;
  col_info3     carga_colunas%rowtype;
  col_valor4    carga_colunas%rowtype;
  col_info4     carga_colunas%rowtype;
  col_valor5    carga_colunas%rowtype;
  col_info5     carga_colunas%rowtype;
  col_valor6    carga_colunas%rowtype;
  col_info6     carga_colunas%rowtype;
  col_obs       carga_colunas%rowtype;
  col_operacao  carga_colunas%rowtype;
  v_existe      varchar2(1) := null;

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
    log_pack.insere_log_detail(P_ID_EXEC, P_MENS ||' : '||TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS'));
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
                            ,P_CHAVE          IN CARGA_ATRIB_TEMP.CHAVE%TYPE
                            ,P_CHAVE_LOG      IN log_processo_header.id_exec%TYPE) is
    
    v_file utl_file.file_type;
    v_nome_layout carga_layout.nome%type;
    v_cont_rejeitados number;
    v_cont_aceitos number;
    v_mens  varchar2(2000);
    v_existe_eleito  number;
    v_eleitos_grav   number;
    v_eleitos        grupo_eleitos.grupo%TYPE;
    v_chave          CARGA_ATRIB_TEMP.CHAVE%TYPE;

    v_modo_carga     VARCHAR2(1);

    cursor cur_rejeitados is
      select linha,erro,texto_linha from CARGA_ATRIB_TEMP
      where chave=v_chave and erro is not null
      order by linha;

    cursor cur_aceitos is
      select * from CARGA_ATRIB_TEMP
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
    from CARGA_ATRIB_TEMP
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
    from CARGA_ATRIB_TEMP
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
          from CARGA_ATRIB_TEMP
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
  FUNCTION CALCULA_TOTAIS(p_relat OUT VARCHAR2
                         ,p_check boolean
                         ,p_vantagem IN VARCHAR2 ) return boolean is
    
    v_texto varchar2(2000);
    v_vantagem_encontrada varchar2(30);
    v_erro boolean := FALSE;
  BEGIN
    if not (p_check) THEN
     return false;
    END IF; 
    -- -- Conta número de funcionários na tabela temporária
    -- SELECT COUNT(DISTINCT numfunc) INTO v_numero_funcionarios
    -- FROM   carga_atrib_temp
    -- WHERE  chave = v_chave AND erro IS NULL;

    -- -- Calcula totais de valores
    -- SELECT SUM(valor), SUM(valor2), SUM(valor3), SUM(valor4), SUM(valor5), SUM(valor6)
    -- INTO   v_total_valor, v_total_valor2, v_total_valor3, v_total_valor4, v_total_valor5, v_total_valor6
    -- FROM   carga_atrib_temp
    -- WHERE  chave = v_chave AND erro IS NULL;

    -- -- Conta tipos de vantagens
    -- SELECT COUNT(DISTINCT vantagem) INTO v_numero_vantagens
    -- FROM carga_atrib_temp
    -- WHERE chave = v_chave AND erro IS NULL;

    -- -- Se houver só um tipo de vantagem, lê o tipo
    -- IF v_numero_vantagens = 1 THEN
    --   SELECT DISTINCT vantagem INTO v_vantagem_encontrada
    --   FROM carga_atrib_temp
    --   WHERE chave=v_chave AND erro IS NULL;
    -- END IF;

    -- -- Conta tipos de vantagens diferentes da especificada
    -- SELECT COUNT(DISTINCT vantagem) INTO v_erros_vantagens
    -- FROM   carga_atrib_temp
    -- WHERE  chave = v_chave 
    -- AND    vantagem <> p_vantagem
    -- AND    erro IS NULL;
    --
    -- Verifica se os requisitos foram atendidos
    --
    -- v_erro := false;
    -- if (p_vantagem is not NULL and v_erros_vantagens > 0) then
    --   v_erro := true;
    -- end if;
    -- if (:block_carga_aux.numero_funcionarios is not NULL and (:block_carga_aux.numero_funcionarios<>v_numero_funcionarios)) then
    --   v_erro := true;
    -- end if;
    -- if (:block_carga_aux.numero_linhas is not NULL and (:block_carga_aux.numero_linhas<>v_numero_linhas)) then
    --   v_erro := true;
    -- end if;
    -- if (:block_carga_aux.total_valor is not NULL and 
    --     (v_total_valor is NULL or :block_carga_aux.total_valor <> v_total_valor)) then
    --   v_erro := true;
    -- end if;
    -- if (:block_carga_aux.total_valor2 is not NULL and 
    --     (v_total_valor2 is NULL or :block_carga_aux.total_valor2 <> v_total_valor2)) then
    --   v_erro := true;
    -- end if;
    -- if (:block_carga_aux.total_valor3 is not null and 
    --     (v_total_valor3 is null or :block_carga_aux.total_valor3 <> v_total_valor3)) then
    --   v_erro := true;
    -- end if;
    -- if (:block_carga_aux.total_valor4 is not null and 
    --     (v_total_valor4 is null or :block_carga_aux.total_valor4 <> v_total_valor4)) then
    --   v_erro := true;
    -- end if;
    -- if (:block_carga_aux.total_valor5 is not null and 
    --     (v_total_valor5 is null or :block_carga_aux.total_valor5 <> v_total_valor5)) then
    --   v_erro := true;
    -- end if;
    -- if (:block_carga_aux.total_valor6 is not null and 
    --     (v_total_valor6 is null or :block_carga_aux.total_valor6 <> v_total_valor6)) then
    --   v_erro := true;
    -- end if;
    -- --
    -- -- Monta texto 
    -- --
    -- if p_check=true then
    --   v_texto:=chr(10);
    --   v_texto:=v_texto||'                              Encontrado            Especificado'||chr(10);
    --   if v_numero_vantagens>1 then
    --     v_texto:=v_texto||'Atributo:         '||lpad('('||ltrim(to_char(v_numero_vantagens))||' tipos diferentes)',22)||'  '||lpad(:block_carga_aux.vantagem,22)||chr(10);
    --   else
    --     v_texto:=v_texto||'Atributo:         '||lpad(v_vantagem_encontrada,22)||'  '||lpad(:block_carga_aux.vantagem,22)||chr(10);
    --   end if;
    --   v_texto:=v_texto||'Núm. funcionários:      '||to_char(v_numero_funcionarios,'B999999999999999')||' '||to_char(:block_carga_aux.numero_funcionarios,'B9999999999999999999999')||chr(10);
    --   v_texto:=v_texto||'Número de linhas: '||to_char(v_numero_linhas,'B999999999999999999999')||' '||to_char(:block_carga_aux.numero_linhas,'B9999999999999999999999')||chr(10);
    --   v_texto:=v_texto||'Total de Valor : '||nvl(to_char(v_total_valor ,'B999999999999999.999999'),lpad(' ',23))||' '||nvl(to_char(:block_carga_aux.total_valor ,'B999999999999999.999999'),lpad(' ',23))||chr(10);
    --   v_texto:=v_texto||'Total de Valor2: '||nvl(to_char(v_total_valor2,'B999999999999999.999999'),lpad(' ',23))||' '||nvl(to_char(:block_carga_aux.total_valor2,'B999999999999999.999999'),lpad(' ',23))||chr(10);
    --   v_texto:=v_texto||'Total de Valor3: '||nvl(to_char(v_total_valor3,'B999999999999999.999999'),lpad(' ',23))||' '||nvl(to_char(:block_carga_aux.total_valor3,'B999999999999999.999999'),lpad(' ',23))||chr(10);
    --   v_texto:=v_texto||'Total de Valor4: '||nvl(to_char(v_total_valor4,'B999999999999999.999999'),lpad(' ',23))||' '||nvl(to_char(:block_carga_aux.total_valor4,'B999999999999999.999999'),lpad(' ',23))||chr(10);
    --   v_texto:=v_texto||'Total de Valor5: '||nvl(to_char(v_total_valor5,'B999999999999999.999999'),lpad(' ',23))||' '||nvl(to_char(:block_carga_aux.total_valor5,'B999999999999999.999999'),lpad(' ',23))||chr(10);
    --   v_texto:=v_texto||'Total de Valor6: '||nvl(to_char(v_total_valor6,'B999999999999999.999999'),lpad(' ',23))||' '||nvl(to_char(:block_carga_aux.total_valor6,'B999999999999999.999999'),lpad(' ',23))||chr(10);
    -- else
    --   v_texto:=chr(10);
    --   v_texto:=v_texto||'Núm. funcionários: '||to_char(v_numero_funcionarios)||chr(10);
    --   v_texto:=v_texto||'Número de linhas: '||to_char(v_numero_linhas)||chr(10);
    --   if v_numero_vantagens>1 then
    --     v_texto:=v_texto||'Atributo: ('||ltrim(to_char(v_numero_vantagens))||' tipos diferentes)'||chr(10);
    --   else
    --     v_texto:=v_texto||'Atributo: '||v_vantagem_encontrada||chr(10);
    --   end if;
    --   v_texto:=v_texto||'Total de Valor : '||ltrim(to_char(v_total_valor ,'999999999999999.999999'))||chr(10);
    --   v_texto:=v_texto||'Total de Valor2: '||ltrim(to_char(v_total_valor2,'999999999999999.999999'))||chr(10);
    --   v_texto:=v_texto||'Total de Valor3: '||ltrim(to_char(v_total_valor3,'999999999999999.999999'))||chr(10);
    --   if nvl(v_total_valor4,0) > 0 then
    --      v_texto:=v_texto||'Total de Valor4: '||ltrim(to_char(v_total_valor4,'999999999999999.999999'))||chr(10);
    --   end if;
    --   --
    --   if nvl(v_total_valor5,0) > 0 then
    --      v_texto:=v_texto||'Total de Valor5: '||ltrim(to_char(v_total_valor5,'999999999999999.999999'))||chr(10);
    --   end if;
    --   --
    --   if nvl(v_total_valor6,0) > 0 then
    --      v_texto:=v_texto||'Total de Valor6: '||ltrim(to_char(v_total_valor6,'999999999999999.999999'))||chr(10);
    --   end if;
    -- end if;

    -- Saída da função
    p_relat:=v_texto;
    return(v_erro);
     

  end;

  /*
  *******************************************************************************
  * FUNCTION LE_ARQUIVO
  *   Função carregar o arquivo de carga para a tabela temporária CARGA_ATRIB_TEMP,
  * checando a integridade dos registros.
  * Entradas:
  * Saída: p_relatorio - Texto com o relatório dos erros encontrados
  *        Retorna false se arquivo OK
  *        Retorna true caso contrário
  *******************************************************************************
  */
  FUNCTION LE_ARQUIVO(p_arquivo IN VARCHAR2
                      ,p_caminho in varchar2
                      ,p_numero_layout  in number
                      ,p_chave in carga_atrib_temp.chave%type
                      ,p_chave_log in log_processo_header.id_exec%type
                      ,p_relatorio out varchar2 )
  return boolean is
    v_file utl_file.file_type;
    v_linha varchar2(2000);
    num_linha number;
    r vantagens%rowtype;
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

    v_chave    CARGA_ATRIB_TEMP.CHAVE%TYPE;

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

        -- Converte a linha para um registro de frequencia
        err_msg:=conv_linha(v_linha, v_modo_carga, r, v_oper);


        if err_msg is not null then
          grava_mensagem(p_chave_log, err_msg);
          raise erro_conversao;
        end if;
        -- Insere registro na tabela temporária
        begin

          insert into carga_atrib_temp(chave,linha,numfunc,numvinc,vantagem,dtini,dtfim,valor,info,valor2,info2,valor3,info3,valor4,info4,valor5,info5,valor6,info6,obs,texto_linha)
          values(v_chave,num_linha,r.numfunc,r.numvinc,r.vantagem,r.dtini,r.dtfim,r.valor,r.info,r.valor2,r.info2,r.valor3,r.info3,r.valor4,r.info4,r.valor5,r.info5,r.valor6,r.info6,r.obs,v_linha);

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
         insert into carga_atrib_temp(chave,linha,vantagem,erro)
         values(v_chave,num_linha,to_char(num_Linha),'Linha do arquivo excede 2000 caracteres.'||chr(10)||v_linha);
          grava_mensagem(p_chave_log, 'Linha '||num_Linha||' do arquivo excede 2000 caracteres.');
          v_cont_erros:=v_cont_erros+1;

        when erro_conversao then
          err_msg := TRUNCA_SQLERRM(sqlerrm);
          insert into carga_atrib_temp(chave,linha,vantagem,erro,texto_linha)
          values(v_chave,num_linha,to_char(num_Linha),err_msg,v_linha);
          grava_mensagem(p_chave_log, 'Erro na linha '||num_Linha||': '||err_msg);
          v_cont_erros:=v_cont_erros+1;

        when erro_insert then
          err_msg := TRUNCA_SQLERRM(err_msg);
          insert into carga_atrib_temp(chave,linha,vantagem,erro,texto_linha)
          values(v_chave,num_linha,to_char(num_Linha),err_msg,v_linha);
          grava_mensagem(p_chave_log, 'Erro na linha '||num_Linha||': '||err_msg);
          v_cont_erros:=v_cont_erros+1;

        when others then
          err_msg := TRUNCA_SQLERRM(sqlerrm);
          insert into carga_atrib_temp(chave,linha,vantagem,erro,texto_linha)
          values(v_chave,num_linha,to_char(num_Linha),err_msg,v_linha);
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
    if v_cont_erros = 0 and v_erro_check = false then
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
  PROCEDURE VERIFICA(P_ARQUIVO       VARCHAR2
                    ,P_TIPO          VARCHAR2
                    ,P_CAMINHO       VARCHAR2
                    ,P_NUMERO_LAYOUT NUMBER)
  is
    err_msg          varchar2(2000);
    v_erro           boolean;
    v_texto1         varchar2(1000);
    v_chave_log      LOG_PROCESSO_HEADER.ID_EXEC%TYPE;
    v_arq_rejeitados varchar2(200);
    v_arq_aceitos    varchar2(200);
    v_arq_erros      varchar2(200);

    v_chave          CARGA_ATRIB_TEMP.CHAVE%TYPE;

    varquivo_blob_err  BLOB;
    varquivo_blob_ac   BLOB;
    varquivo_blob_rej  BLOB;

  begin

    --Estabelecendo o nome dos arquivos
    v_arq_rejeitados := replace (P_ARQUIVO, '.txt', '.rej');
    v_arq_aceitos    := replace (P_ARQUIVO, '.txt', '.ac');
    v_arq_erros  := replace (P_ARQUIVO, '.txt', '.err');

    --
    -- Seta as variáveis internas da package
    --
    SELECT CARGA_ATRIB_SEQ.NEXTVAL
      INTO v_chave
    FROM DUAL;

    v_numero_layout:=p_numero_layout;
    v_arquivo := p_arquivo;
    --v_arq_erros:=p_erros;
    --v_aceitos:=p_aceitos;

    --
     v_chave_log := log_pack.insere_log_header('VERIFICANDO O ARQUIVO DE IMPORTAÇÃO DE ATRIBUTOS FINANCEIROS',
                                               'Arquivo = ''' || upper(v_arquivo) ||
                                                '''; ''' || CHR(10) ||
                                                '''; Usuário = ''' || FLAG_PACK.get_usuario
                                                || CHR(10) ||
                                                '''; Data = ''' || to_char(sysdate,'DD/MM/YYYY - hh24:mi') ||
                                                '''', null);

    --
    -- Carrega o arquivo para a tabela temporária e checa integridade dos registros
    --

    v_erro := le_arquivo(v_arquivo, p_caminho, p_numero_layout, v_chave, v_chave_log, v_texto1);

    --
    -- Gera relatório
    --
    gera_relatorios(P_CAMINHO, 'V', v_arq_rejeitados, v_arq_aceitos, v_arq_erros, NULL, v_chave, v_chave_log);

    grava_mensagem (v_chave_log, 'Apagando os registros da tabela temporária CARGA_ATRIB_TEMP.');
    --
    -- Apaga registros da tabela temporária
    --
    LOOP
      --
      DELETE CARGA_ATRIB_TEMP
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
    grava_mensagem (v_chave_log, 'Fim da exclusão dos registros da tabela temporária CARGA_ATRIB_TEMP.');
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
  *   Função carregar o arquivo de carga para a tabela temporária CARGA_ATRIB_TEMP,
  * checando a integridade dos registros.
  * Entradas:
  * Saída: Retorna FALSE se arquivo OK
  *        Retorna TRUE caso contrário
  *******************************************************************************
  */
  FUNCTION Carga_arquivo (P_CHAVE      CARGA_ATRIB_TEMP.CHAVE%TYPE
                         ,P_CAMINHO    IN VARCHAR2
                         ,P_ARQUIVO    IN VARCHAR2
                         ,P_MODO_CARGA IN VARCHAR2
                         ,P_CHAVE_LOG  IN OUT LOG_PROCESSO_HEADER.ID_EXEC%TYPE
                         ,P_ID_EXEC_AUDIT LOG_PROCESSO_HEADER.ID_EXEC%TYPE DEFAULT NULL)
  return boolean
  IS
    --
    v_file                 utl_file.file_type;
    v_linha                varchar2(2000);
    num_linha              number;
    v_linhas_removidas     NUMBER := 0;
    v_linhas_alteradas     NUMBER := 0;
    v_linhas_inseridas     NUMBER := 0;
    v_mens                 VARCHAR2(2000);
    r                      vantagens%rowtype;
    v_oper                 varchar2(20);
    --
    erro_layout            exception;
    erro_linha_maior_2000  exception;
    erro_conversao         exception;
    erro_carga             exception;
    erro_vantagem          exception;
    erro_insert_temporaria exception;
    err_msg                varchar2(2000);
    v_cont_erros           number;
    v_erro_check           boolean;
    v_relat_check          varchar2(2000);
    --
    v_cont_synchr         number;  -- contador para executar synchronizes
    --
    v_chave               CARGA_ATRIB_TEMP.CHAVE%TYPE;
    v_chave_log           LOG_PROCESSO_HEADER.ID_EXEC%TYPE; -- chave do header de autitoria

    v_logging             varchar2(1); -- flag para indicar se deve fazer auditoria
    ra                    vantagens%rowtype; -- variável auxiliar para guardar vantagens alteradas
    v_aux                 varchar2(100);
    v_emp_codigo          empresas.empresa%type;
    v_cont_empresa        number;
    v_frequencia          number;
    v_sobrepoe            tipo_vantagem.sobrepoe%type;
    --
    v_existe_tmp          number;
    --
    v_grupo_eleitos_del   number;
    v_data_execucao       varchar2(20);
    v_vantagem            vantagens.vantagem%type;

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

        -- Insere/Remove/Encerra registro da tabela VANTAGENS
        if v_modo_carga='E' then
          declare
            v_cont number;
          begin
            update vantagens
            set dtfim=r.dtfim,
                obs  = obs||chr(10)||r.obs
            where numfunc=r.numfunc and numvinc=r.numvinc and vantagem=r.vantagem and
                  dtfim is null and to_char(dtini, 'yyyymmdd')<=to_char(r.dtfim, 'yyyymmdd');
            if sql%rowcount <> 0 then
              --
              -- Insere registro de auditoria
              --
              v_linhas_alteradas := v_linhas_alteradas + sql%rowcount;
              --
              -- Insere registro de auditoria
              --
              if v_logging='S' then
                --
                -- Atualiza a mensagem a cada 500 linhas alteradas e COMMIT
                --
                IF MOD (v_linhas_inseridas, 500) = 0 THEN
                  --
                  v_mens := 'Foram encerrados até o momento '||v_linhas_alteradas
                            ||' atributos';
                  grava_mensagem (v_chave_log, v_mens);
                  --
                END IF;
                --

              end if;
            else
              SELECT count(*) INTO v_cont 
              FROM   vantagens
              WHERE  numfunc  = r.numfunc 
              AND    numvinc  = r.numvinc 
              AND    vantagem = r.vantagem;
              
              if v_cont=0 then
                err_msg:='Registro inexistente no banco de dados.';
                raise erro_carga;
              end if;

              select count(*) into v_cont 
              from vantagens
              where numfunc=r.numfunc and numvinc=r.numvinc and vantagem=r.vantagem and
                    dtfim is null;
              if v_cont=0 then
                err_msg:='Registro com DTFIM não nula, não pode ser encerrado.';

                raise erro_carga;
              end if;
              err_msg:='Registro com DTINI maior que a data de encerramento. Não pode ser encerrado.';

              raise erro_carga;
            end if;

          exception
            when erro_carga then

              raise;
            when others then
              err_msg:=sqlerrm;
          end;
        elsif v_modo_carga='I' or v_modo_carga='A' then
          begin
            begin
              --
              select count(*) into v_cont 
                from vantagens
                where numfunc=r.numfunc and numvinc=r.numvinc and vantagem=r.vantagem and
                      to_char(dtini,'ddmmyyyy')=to_char(r.dtini,'ddmmyyyy');
              --
              -- Verificar se a frequencia do arquivo texto foi cadastrado no sistema -----
              select count(1) into v_vantagem
                from tipo_vantagem
                where vantagem = r.vantagem;

              --
              if v_vantagem = 0 then
                err_msg:='Atributo : '||r.vantagem||' Não cadastrado no SIGRH';
                grava_mensagem(v_chave_log, err_msg);
                raise erro_vantagem;
              end if;
              --
              begin
               select sobrepoe
                into v_sobrepoe
                from tipo_vantagem
                where vantagem=r.vantagem;
              exception when no_data_found then
                err_msg:='Tipo de Vantagem não cadastrada para o Atributo: '||r.vantagem;
                raise erro_vantagem;
              end;
              
              if (v_sobrepoe='S' or v_cont=0) and v_modo_carga='I' then
              -- if v_cont=0 or v_modo_carga='I' then
                insert into vantagens(numfunc,numvinc,vantagem,dtini,dtfim,
                  valor,info,valor2,info2,valor3,info3,valor4,info4,valor5,info5,valor6,info6,obs,flex_campo_03)
                values(r.numfunc,r.numvinc,r.vantagem,r.dtini,r.dtfim,r.valor,r.info,r.valor2,r.info2,
                   r.valor3,r.info3,r.valor4,r.info4,r.valor5,r.info5,r.valor6,r.info6,r.obs,v_chave_log);
--
                --
                v_linhas_inseridas := v_linhas_inseridas + 1;
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
              elsif v_modo_carga='A' then
                  -- Guarda registro anterior para auditoria
                  if v_cont > 1 then
                    err_msg := 'Mais de 1 registro no banco de dados para a data de início.';
                    grava_mensagem(v_chave_log, err_msg);
                    raise erro_carga;
                  else

                    -- Atualiza registro na tabela VANTAGENS
                    update vantagens
                    set dtfim = r.dtini - 1,
                        obs   = obs||chr(10)||r.obs
                    where numfunc=r.numfunc 
                    and   numvinc=r.numvinc 
                    and   vantagem=r.vantagem 
                    and   dtfim is null;
                    --
                    insert into vantagens(numfunc,numvinc,vantagem,dtini,dtfim,
                                          valor,info,valor2,info2,valor3,info3,valor4,info4,valor5,info5,valor6,info6,obs,flex_campo_03)
                                   values(r.numfunc,r.numvinc,r.vantagem,r.dtini,r.dtfim,r.valor,r.info,r.valor2,r.info2,
                                          r.valor3,r.info3,r.valor4,r.info4,r.valor5,r.info5,r.valor6,r.info6,r.obs,v_chave_log);
                    
                    v_linhas_alteradas := v_linhas_alteradas + 1;
                    --
                    -- Insere registro de auditoria
                    --
                    if v_logging='S' then
                      --
                      -- Atualiza a mensagem a cada 500 linhas alteradas e COMMIT
                      --
                      IF MOD (v_linhas_alteradas, 500) = 0 THEN
                        --
                        v_mens := 'Foram alterados até o momento '||v_linhas_alteradas
                                  ||' frequências já existentes';
                        grava_mensagem (v_chave_log, v_mens);
                        --
                      END IF;
                      --

                    end if;
                  end if;
              end if;

            end;
          exception
            when erro_vantagem then
               grava_mensagem (v_chave_log, trunca_sqlerrm(sqlerrm));
               raise erro_carga;
            when DUP_VAL_ON_INDEX then
              --
              if v_logging='S' then
                --
                v_mens := 'Erro na linha '||to_char(num_linha)||'. '||
                          'O atributo '||r.vantagem || ' para o funcionário '
                           ||pack_ergon.get_ident_func(r.numfunc,r.numvinc)
                           ||' válido no período de ' || to_char(r.dtini,'dd/mm/yyyy')||
                           NVL (' até '||to_char(r.dtfim,'dd/mm/yyyy'), ' em diante')
                           ||' já existe no banco de dados';
                grava_mensagem (v_chave_log, v_mens);
                --
              end if;
              --

              err_msg :='Registro já existente no banco de dados';
              grava_mensagem (v_chave_log, err_msg);

              raise erro_carga;
              --
            when others then
              --
              err_msg := trunca_sqlerrm(sqlerrm);
              --
              if v_logging='S' then
                --
                v_mens := 'Erro na linha '||to_char(num_linha)||'. '||
                          'Erro ao inserir o atributo '||r.vantagem || ' para o funcionário '
                           ||pack_ergon.get_ident_func(r.numfunc,r.numvinc)
                           ||' válido no perído de ' || to_char(r.dtini,'dd/mm/yyyy')||
                           NVL (' até '||to_char(r.dtfim,'dd/mm/yyyy'), ' em diante')
                           ||': '||SUBSTR (err_msg, 1, 300);
                grava_mensagem (v_chave_log, v_mens);
                --
              end if;
              --

              raise erro_carga;
              --
          end;
        elsif v_modo_carga = 'D' then
          declare
            v_cont number;
          begin
            --   Contador de registros para o caso de duplicidade de frequência
            select count(*) into v_cont 
            from vantagens
            where numfunc  = r.numfunc 
            and   numvinc  = r.numvinc 
            and   vantagem = r.vantagem 
            and   to_char(dtini,'ddmmyyyy') = to_char(r.dtini,'ddmmyyyy');
            if v_cont = 0 then
              err_msg := 'Registro inexistente no banco de dados.';
              grava_mensagem (v_chave_log, err_msg);
              raise erro_carga;
            else
                delete from vantagens
                where numfunc=r.numfunc and numvinc=r.numvinc and vantagem=r.vantagem and
                      to_char(dtini,'ddmmyyyy')=to_char(r.dtini, 'ddmmyyyy') and 
                      flex_campo_03 = P_ID_EXEC_AUDIT  and
                      ((dtfim is null and r.dtfim is null) or (dtfim=r.dtfim)) and 
                      ((valor is null and r.valor is null) or (valor=r.valor)) and 
                      ((valor2 is null and r.valor2 is null) or (valor2=r.valor2)) and
                      ((valor3 is null and r.valor3 is null) or (valor3=r.valor3)) and
                      ((valor4 is null and r.valor4 is null) or (valor4=r.valor4)) and
                      ((valor5 is null and r.valor5 is null) or (valor5=r.valor5)) and
                      ((valor6 is null and r.valor6 is null) or (valor6=r.valor6)) and
                      ((info is null and r.info is null) or (info=r.info)) and
                      ((info2 is null and r.info2 is null) or (info2=r.info2)) and
                      ((info3 is null and r.info3 is null) or (info3=r.info3)) and
                      ((info4 is null and r.info4 is null) or (info4=r.info4)) and
                      ((info5 is null and r.info5 is null) or (info5=r.info5)) and
                      ((info6 is null and r.info6 is null) or (info6=r.info6)) and
                      ((obs   is null and r.obs   is null) or (obs  =r.obs));
                v_linhas_removidas := sql%rowcount + v_linhas_removidas;
                --
                --
                if sql%rowcount = 0 then
                  select count(*) into v_cont 
                  from vantagens
                  where numfunc=r.numfunc and numvinc=r.numvinc and vantagem=r.vantagem and
                       to_char(dtini, 'ddmmyyyy')= to_char(r.dtini, 'ddmmyyyy');
                  if v_cont > 0 then
                    err_msg:='Registro no banco de dados com valor diferente do arquivo. Registro não removido';
                    grava_mensagem (v_chave_log, err_msg);
                    raise erro_carga;
                  end if;
                else
                  -- Insere registro de auditoria
                  if v_logging = 'S' then
                    IF MOD (v_linhas_removidas, 500) = 0 THEN
                      v_mens := 'Foram removidos até o momento '||v_linhas_removidas
                                ||' atributos da carga';
                      grava_mensagem (v_chave_log, v_mens);
                    END IF;
                    --
                  end if;
                end if;
              --end if;
            end if;
          exception
            when erro_carga then
              grava_mensagem (v_chave_log, trunca_sqlerrm(sqlerrm));
              raise;
            when others then
              err_msg := trunca_sqlerrm(sqlerrm);
              grava_mensagem (v_chave_log, err_msg);
          end;
        end if;
        -- Insere registro na tabela CARGA_ATRIB_TEMP
        begin
          insert into carga_atrib_temp(chave,linha,numfunc,numvinc,vantagem,dtini,dtfim,
              valor,info,valor2,info2,valor3,info3,valor4,info4,valor5,info5,valor6,info6,obs,texto_linha)
          values(v_chave,num_linha,
                 r.numfunc,r.numvinc,r.vantagem,r.dtini,r.dtfim,r.valor,r.info,r.valor2,r.info2,
                 r.valor3,r.info3,r.valor4,r.info4,r.valor5,r.info5,r.valor6,r.info6,r.obs,v_linha);
        exception
          when others then
            null;
        end;
      exception
        when erro_linha_maior_2000 then
          insert into carga_atrib_temp(chave,linha,vantagem,erro)
          values(v_chave,num_linha,to_char(num_Linha),'Linha do arquivo excede 2000 caracteres.'||chr(10)||v_linha);
          v_cont_erros:=v_cont_erros+1;
          grava_mensagem(v_chave_log, 'Linha '||num_Linha||' do arquivo excede 2000 caracteres.');


        when erro_conversao then
          err_msg := TRUNCA_SQLERRM(err_msg); 
          insert into carga_atrib_temp(chave,linha,vantagem,erro,texto_linha)
          values(v_chave,num_linha,to_char(num_Linha),err_msg,v_linha);
          v_cont_erros:=v_cont_erros+1;
          grava_mensagem(v_chave_log, 'Erro na linha '||num_Linha||': '||err_msg);


        when erro_carga then
          err_msg := TRUNCA_SQLERRM(err_msg); 
          insert into carga_atrib_temp(chave,linha,vantagem,erro,texto_linha)
          values(v_chave,num_linha,to_char(num_Linha),err_msg,v_linha);
          v_cont_erros:=v_cont_erros+1;
          grava_mensagem(v_chave_log, 'Erro na linha '||num_Linha||': '||err_msg);

        when erro_insert_temporaria then
          insert into carga_atrib_temp(chave,linha,vantagem,erro,texto_linha)
          values(v_chave,num_linha,to_char(num_Linha),err_msg,v_linha);
          v_cont_erros:=v_cont_erros+1;
          grava_mensagem(v_chave_log, 'Erro na linha '||num_Linha||': '||err_msg);


        when others then
          err_msg := TRUNCA_SQLERRM(sqlerrm); 
          insert into carga_atrib_temp(chave,linha,vantagem,erro,texto_linha)
          values(v_chave,num_linha,to_char(num_Linha),err_msg,v_linha);
          v_cont_erros:=v_cont_erros+1;
          grava_mensagem(v_chave_log, 'Erro na linha '||num_Linha||': '||err_msg);

      end;
--      commit;
    end loop;
    --
    --

    if v_logging = 'S' then
      if v_modo_carga = 'D' then
        v_mens := 'Foram removidos um total de '||v_linhas_removidas||' atributos da carga';
        --
      elsif v_modo_carga='E' then
        --
        v_mens := 'Foram encerrados um total de '||v_linhas_alteradas||' atributos da carga';
        --
      elsif v_modo_carga = 'I' or v_modo_carga = 'A' then
        --
        v_mens := 'Foram carregados um total de '||v_linhas_inseridas||' atributos e '
                  ||'alterados um total de '||v_linhas_alteradas||' atributos';
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
    v_numero_linhas := num_linha;
    v_numero_linhas_erro := v_cont_erros;
    grava_mensagem(v_chave_log, 'Iniciando a apuração dos totais do arquivo.');
    -- Calcula totais
    v_erro_check := Calcula_totais(v_relat_check,false, v_chave);
    grava_mensagem(v_chave_log, 'Final da apuração dos totais do arquivo.');
    --
    -- Mensagem com resultado da carga
    --
    v_mens := 'Arquivo com '||to_char(num_linha)||' registros.'||chr(10)||
                      'Registros sem erros na carga: '||ltrim(to_char(num_linha-v_cont_erros))||chr(10)||
                      'Registros com erros na carga: '||ltrim(to_char(v_cont_erros))||chr(10);
    --
    if v_modo_carga = 'D' then
       v_mens := v_mens||'Registros Desfeitos na carga: '||v_linhas_removidas||chr(10);
    end if;
    --
    v_mens := v_mens||v_relat_check;
    if v_cont_erros = 0 then
       if v_modo_carga = 'D' then
         v_mens := v_mens||chr(10)||'Carga removida sem erros.';
       elsif v_modo_carga = 'E' then
         v_mens := v_mens||chr(10)||'Encerramento de frequências concluído sem erros.';
       elsif v_modo_carga = 'I' or v_modo_carga = 'A' then
         v_mens := v_mens||chr(10)||'Carga concluída sem erros.';
       end if;
    else
       v_mens := v_mens||chr(10)||'Ocorreram erros durante a carga.';
    end if;
    grava_mensagem (v_chave_log, v_mens);

    -- Exibir mensagem para solicitar a remoção dos contra-cheques do grupo de eleitos
    if v_modo_carga = 'D' then
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
    if v_cont_erros = 0 then
      return(false);
    else
      return(true);
    end if;
   --
  exception
    when others then
      grava_mensagem (v_chave_log, 'Erro no final do processo: '||TRUNCA_SQLERRM(err_msg));
            return(true);
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
    err_msg     varchar2(2000);
    v_erro      boolean;
    v_tempo     date;
    --v_chave_log    NUMBER;
    v_chave     CARGA_ATRIB_TEMP.chave%type;
    v_chave_log log_processo_header.id_exec%type;

    --Estabelecendo o nome dos arquivos
    v_arq_rejeitados VARCHAR2(200);
    v_arq_aceitos    VARCHAR2(200);
    v_arq_erros      VARCHAR2(200);

    varquivo_blob_err  BLOB;
    varquivo_blob_ac   BLOB;
    varquivo_blob_rej  BLOB;

  begin

    --Estabelecendo o nome dos arquivos
    v_arq_rejeitados := replace (P_ARQUIVO, '.txt', '.rej');
    v_arq_aceitos    := replace (P_ARQUIVO, '.txt', '.ac');
    v_arq_erros      := replace (P_ARQUIVO, '.txt', '.err');

    -- Seta as variáveis internas da package
    select nvl(max(chave),0)+1 into v_chave from CARGA_ATRIB_TEMP;

    v_numero_layout := p_numero_layout;
    v_arquivo := p_arquivo;
    --v_rejeitados:=p_rejeitados;
    ---V_ARQ_ERROS := P_ERROS;
    --v_aceitos:=p_aceitos;

    --
     v_chave_log := log_pack.insere_log_header('IMPORTAÇÃO DE ATRIBUTOS FINANCEIROS',
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
    -- Carrega o arquivo para a tabela FREQUÊNCIAS e insere erros na tabela temporária
    --

    v_erro := carga_arquivo(v_chave ,P_CAMINHO, P_ARQUIVO, 'I', v_chave_log);

    --
    -- Gera relatório
    --
    Gera_relatorios(P_CAMINHO, 'C', v_arq_rejeitados, v_arq_aceitos, v_arq_erros, 'I', v_chave, v_chave_log);

    grava_mensagem (v_chave_log, 'Apagando os registros da tabela temporária CARGA_ATRIB_TEMP.');
    --
    -- Apaga registros da tabela temporária
    --
    LOOP
      --
      DELETE CARGA_ATRIB_TEMP
      WHERE  CHAVE  = v_chave
      AND    ROWNUM <= 100;
      --
    EXIT WHEN SQL%ROWCOUNT = 0;
      --
      COMMIT;
      --
    END LOOP;

    --
    COMMIT;
    grava_mensagem (v_chave_log, 'Fim da exclusão dos registros da tabela temporária CARGA_ATRIB_TEMP.');
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
      grava_mensagem (v_chave_log, 'Erro no processo CARGA: '||trunca_sqlerrm(sqlerrm));
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
    v_chave CARGA_ATRIB_TEMP.chave%type;
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
    select nvl(max(chave),0)+1 into v_chave from CARGA_ATRIB_TEMP;
    v_numero_layout:=p_numero_layout;
    v_arquivo:=p_arquivo;
    --v_rejeitados:=p_rejeitados;
    ---V_ARQ_ERROS := P_ERROS;
    --v_aceitos:=p_aceitos;
    --                                              
     v_chave_log := log_pack.insere_log_header('DESFAZENDO A IMPORTAÇÃO DE ATRIBUTOS FINANCEIROS',
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
    Gera_relatorios(P_CAMINHO, 'C', v_arq_rejeitados, v_arq_aceitos, v_arq_erros, 'D', P_ID_EXEC_AUDIT, v_chave_log);
    grava_mensagem (v_chave_log, 'Apagando os registros da tabela temporária CARGA_ATRIB_TEMP.');
    --
    -- Apaga registros da tabela temporária
    --
    LOOP
      --
      DELETE CARGA_ATRIB_TEMP
      WHERE CHAVE = v_chave
        AND ROWNUM <= 100;
      --
    EXIT WHEN SQL%ROWCOUNT = 0;
      --
      COMMIT;
    END LOOP;
    --
    COMMIT;
    grava_mensagem (v_chave_log, 'Fim da exclusão dos registros da tabela temporária CARGA_ATRIB_TEMP.');    
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
    grava_mensagem (v_chave_log, 'Fim do UPLOAD do arquivo de erros "'||
                                  upper(v_arq_erros) || '" para o banco de dados.'); 
    
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
    grava_mensagem (v_chave_log, 'Fim do UPLOAD do arquivo de aceitos "'||
                                  upper(v_arq_aceitos) || '" para o banco de dados.');     
    --
    PACK_HAD_DOWNLOAD.GRAVA_ARQUIVO_BLOB(varquivo_blob_rej, v_arq_rejeitados, P_CAMINHO);
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
      grava_mensagem (v_chave_log, 'Erro no processo DESFAZ_CARGA: '||trunca_sqlerrm(sqlerrm));
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
  PROCEDURE LIMPA_LAYOUT IS
  BEGIN
    col_numfunc.numero   :=null;
    col_numvinc.numero   :=null;
    col_matric.numero    :=null;
    col_vantagem.numero  :=null;
    col_rubrica.numero   :=null;
    col_dtini.numero     :=null;
    col_dtfim.numero     :=null;
    col_valor.numero     :=null;
    col_info.numero      :=null;
    col_valor2.numero    :=null;
    col_info2.numero     :=null;
    col_valor3.numero    :=null;
    col_info3.numero     :=null;
    col_valor4.numero    :=null;
    col_info4.numero     :=null;
    col_valor5.numero    :=null;
    col_info5.numero     :=null;
    col_valor6.numero    :=null;
    col_info6.numero     :=null;
    col_obs.numero       :=null;
    col_operacao.numero  :=null;

    col_numfunc.coluna   :=null;
    col_numvinc.coluna   :=null;
    col_matric.coluna    :=null;
    col_vantagem.coluna  :=null;
    col_rubrica.coluna   :=null;
    col_dtini.coluna     :=null;
    col_dtfim.coluna     :=null;
    col_valor.coluna     :=null;
    col_info.coluna      :=null;
    col_valor2.coluna    :=null;
    col_info2.coluna     :=null;
    col_valor3.coluna    :=null;
    col_info3.coluna     :=null;
    col_valor4.coluna    :=null;
    col_info4.coluna     :=null;
    col_valor5.coluna    :=null;
    col_info5.coluna     :=null;
    col_valor6.coluna    :=null;
    col_info6.coluna     :=null;
    col_obs.coluna       :=null;
    col_operacao.coluna  :=null;

    col_numfunc.valor    :=null;
    col_numvinc.valor    :=null;
    col_matric.valor     :=null;
    col_vantagem.valor   :=null;
    col_rubrica.valor    :=null;
    col_dtini.valor      :=null;
    col_dtfim.valor      :=null;
    col_valor.valor      :=null;
    col_info.valor       :=null;
    col_valor2.valor     :=null;
    col_info2.valor      :=null;
    col_valor3.valor     :=null;
    col_info3.valor      :=null;
    col_valor4.valor     :=null;
    col_info4.valor      :=null;
    col_valor5.valor     :=null;
    col_info5.valor      :=null;
    col_valor6.valor     :=null;
    col_info6.valor      :=null;
    col_obs.valor        :=null;
    col_operacao.valor   :=null;
    
    col_numfunc.formato  :=null;
    col_numvinc.formato  :=null;
    col_matric.formato   :=null;
    col_vantagem.formato :=null;
    col_rubrica.formato  :=null;
    col_dtini.formato    :=null;
    col_dtfim.formato    :=null;
    col_valor.formato    :=null;
    col_info.formato     :=null;
    col_valor2.formato   :=null;
    col_info2.formato    :=null;
    col_valor3.formato   :=null;
    col_info3.formato    :=null;
    col_valor4.formato   :=null;
    col_info4.formato    :=null;
    col_valor5.formato   :=null;
    col_info5.formato    :=null;
    col_valor6.formato   :=null;
    col_info6.formato    :=null;
    col_obs.formato      :=null;
    col_operacao.formato :=null;

    col_numfunc.ordem    :=null;
    col_numvinc.ordem    :=null;
    col_matric.ordem     :=null;
    col_vantagem.ordem   :=null;
    col_rubrica.ordem    :=null;
    col_dtini.ordem      :=null;
    col_dtfim.ordem      :=null;
    col_valor.ordem      :=null;
    col_info.ordem       :=null;
    col_valor2.ordem     :=null;
    col_info2.ordem      :=null;
    col_valor3.ordem     :=null;
    col_info3.ordem      :=null;
    col_valor4.ordem     :=null;
    col_info4.ordem      :=null;
    col_valor5.ordem     :=null;
    col_info5.ordem      :=null;
    col_valor6.ordem     :=null;
    col_info6.ordem      :=null;
    col_obs.ordem        :=null;
    col_operacao.ordem   :=null;

  END LIMPA_LAYOUT;

  /************************************************************************************
   * FUNCTION CARREGA_LAYOUT
   * Sub-rotina para carregar o layout do arquivo nas variáveis internas da package
   * Retorna NULL se conversão OK, retorna mensagem em caso de erro.
   ************************************************************************************/
  FUNCTION CARREGA_LAYOUT(p_numero NUMBER, p_modo_carga VARCHAR2) RETURN VARCHAR2 IS
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
      where numero = p_numero and upper(coluna) = 'NUMFUNC';
    exception
      when no_data_found then COL_NUMFUNC := NULL;
      when others then raise;
    end;

    begin
      select * into col_numvinc from carga_colunas
      where numero = p_numero and upper(coluna) = 'NUMVINC';
    exception
      when no_data_found then COL_NUMVINC := NULL;
      when others then raise;
    end;

    begin
      select * into col_matric from carga_colunas
      where numero = p_numero and upper(coluna) = 'MATRICULA';
    exception
      when no_data_found then
        if p_modo_carga <> 'E' then
          err_msg := 'Falta a coluna MATRICULA no layout do arquivo.';
          return err_msg;
        end if;
      when others then raise;
    end;

    if (col_numfunc.coluna is null or col_numvinc.coluna is null) and col_matric.coluna is null then 
      err_msg:='Falta a coluna NUMFUNC, NUMVINC ou MATRICULA no layout do arquivo.';
      return err_msg;
    end if;

    begin
      select * into col_dtini from carga_colunas
      where numero = p_numero and upper(coluna) = 'DTINI';
      if col_dtini.formato is null then
        err_msg:='Falta o formato de DTINI no layout do arquivo.';
        return err_msg;
      else
        col_dtini.formato := replace(col_dtini.formato,'aA','yY');
      end if;
    exception
      when no_data_found then
        if p_modo_carga <> 'E' then
          err_msg:='Falta a coluna DTINI no layout do arquivo.';
          return err_msg;
        end if;
      when others then raise;
    end;

    begin
      select * into col_dtfim from carga_colunas
      where numero = p_numero and upper(coluna) = 'DTFIM';
      if col_dtfim.formato is null then
        err_msg:='Falta o formato de DTFIM no layout do arquivo.';
        return err_msg;
      else
        col_dtfim.formato := replace(col_dtfim.formato,'aA','yY');
      end if;
      tem_dtfim := true;
    exception
      when no_data_found then
        if p_modo_carga = 'E' then
          err_msg := 'Falta a coluna DTFIM no layout do arquivo.';
          return err_msg;
        else
          col_dtfim.numero := null;
          tem_dtfim := false;
        end if;
      when others then raise;
    end;

    begin
      select * into col_vantagem from carga_colunas
      where numero = p_numero and upper(coluna) = 'VANTAGEM';
    exception
      when no_data_found then
        begin
          select * into col_rubrica from carga_colunas
          where numero = p_numero and upper(coluna) = 'RUBRICA';
        exception when no_data_found then
          err_msg:='Falta a coluna VANTAGEM no layout do arquivo.';
          return err_msg;
        end;
      when others then raise;
    end;

    begin
      select * into col_obs from carga_colunas
      where numero = p_numero and upper(coluna) = 'OBS';
      tem_obs:=true;
    exception
      when no_data_found then
        col_obs.numero := null;
        tem_obs := false;
      when others then raise;
    end;

/*    if col_obs.coluna is null then
      err_msg:='Falta a coluna OBS no layout do arquivo.';
      return err_msg;
    end if;*/

    begin
      select * into col_info from carga_colunas
      where numero=p_numero and upper(coluna)='INFO';
      tem_info:=true;
    exception
      when no_data_found then 
        col_info.numero:=null;
        tem_info:=false;
      when others then raise;
    end;

    begin
      select * into col_valor from carga_colunas
      where numero=p_numero and upper(coluna)='VALOR';
      tem_valor:=true;
    exception
      when no_data_found then 
        col_valor.numero:=null;
        tem_valor:=false;
      when others then raise;
    end;

    begin
      select * into col_info2 from carga_colunas
      where numero = p_numero and upper(coluna)='INFO2';
      tem_info2 := true;
    exception
      when no_data_found then 
        col_info2.numero := null;
        tem_info2 := false;
      when others then raise;
    end;
    
    begin
      select * into col_valor2 from carga_colunas
      where numero = p_numero and upper(coluna) = 'VALOR2';
      tem_valor2 := true;
    exception
      when no_data_found then 
        col_valor2.numero := null;
        tem_valor2 := false;
      when others then raise;
    end;

    begin
      select * into col_info3 from carga_colunas
      where numero = p_numero and upper(coluna)='INFO3';
      tem_info3 := true;
    exception
      when no_data_found then 
        col_info3.numero := null;
        tem_info3 := false;
      when others then raise;
    end;
    
    begin
      select * into col_valor3 from carga_colunas
      where numero = p_numero and upper(coluna) = 'VALOR3';
      tem_valor3 := true;
    exception
      when no_data_found then 
        col_valor3.numero := null;
        tem_valor3 := false;
      when others then raise;
    end;

    begin
      select * into col_info4 from carga_colunas
      where numero = p_numero and upper(coluna)='INFO4';
      tem_info4 := true;
    exception
      when no_data_found then 
        col_info4.numero := null;
        tem_info4 := false;
      when others then raise;
    end;
    
    begin
      select * into col_valor4 from carga_colunas
      where numero = p_numero and upper(coluna) = 'VALOR4';
      tem_valor4 := true;
    exception
      when no_data_found then 
        col_valor4.numero := null;
        tem_valor4 := false;
      when others then raise;
    end;

    begin
      select * into col_info5 from carga_colunas
      where numero = p_numero and upper(coluna)='INFO5';
      tem_info5 := true;
    exception
      when no_data_found then 
        col_info5.numero := null;
        tem_info5 := false;
      when others then raise;
    end;
    
    begin
      select * into col_valor5 from carga_colunas
      where numero = p_numero and upper(coluna) = 'VALOR5';
      tem_valor5 := true;
    exception
      when no_data_found then 
        col_valor5.numero := null;
        tem_valor5 := false;
      when others then raise;
    end;

    begin
      select * into col_info6 from carga_colunas
      where numero = p_numero and upper(coluna)='INFO6';
      tem_info6 := true;
    exception
      when no_data_found then 
        col_info6.numero := null;
        tem_info6 := false;
      when others then raise;
    end;
    
    begin
      select * into col_valor6 from carga_colunas
      where numero = p_numero and upper(coluna) = 'VALOR6';
      tem_valor6 := true;
    exception
      when no_data_found then 
        col_valor6.numero := null;
        tem_valor6 := false;
      when others then raise;
    end;

    begin
      select * into col_operacao from carga_colunas
      where numero = p_numero and upper(coluna)='OPERACAO';
      tem_operacao := true;
    exception
      when no_data_found then
        col_operacao.numero := null;
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
    if col_matric.valor is null and 
       col_matric.coluna is not null and
         ((car_delimitador is null and (col_matric.inicio is null or col_matric.fim is null))
          or (car_delimitador is not null and col_matric.ordem is null)) then
        err_msg:='O valor/posição da coluna MATRICULA não está definido corretamente no layout.';
        raise value_error;
    end if; 
    --
    if col_vantagem.numero is not null and col_vantagem.valor is null and 
       ((car_delimitador is null and (col_vantagem.inicio is null or col_vantagem.fim is null))
        or (car_delimitador is not null and col_vantagem.ordem is null)) then
      err_msg:='O valor/posição da coluna VANTAGEM não está definido corretamente no layout.';
      raise value_error;
    end if; 
    --
    if col_rubrica.numero is not null and col_rubrica.valor is null and 
       ((car_delimitador is null and (col_rubrica.inicio is null or col_rubrica.fim is null))
        or (car_delimitador is not null and col_rubrica.ordem is null)) then
      err_msg:='O valor/posição da coluna RUBRICA não está definido corretamente no layout.';
      raise value_error;
    end if; 
    --
    if col_dtini.numero is not null and col_dtini.valor is null and 
       ((car_delimitador is null and (col_dtini.inicio is null or col_dtini.fim is null))
        or (car_delimitador is not null and col_dtini.ordem is null)) then
      err_msg:='O valor/posição da coluna DTINI não está definido corretamente no layout.';
      raise value_error;
    end if; 
    if col_dtfim.numero is not null and col_dtfim.valor is null and 
       ((car_delimitador is null and (col_dtfim.inicio is null or col_dtfim.fim is null))
        or (car_delimitador is not null and col_dtfim.ordem is null)) then
      err_msg:='O valor/posição da coluna DTFIM não está definido corretamente no layout.';
      raise value_error;
    end if; 
    if col_valor.numero is not null and col_valor.valor is null and 
       ((car_delimitador is null and (col_valor.inicio is null or col_valor.fim is null))
        or (car_delimitador is not null and col_valor.ordem is null)) then
      err_msg:='O valor/posição da coluna VALOR não está definido corretamente no layout.';
      raise value_error;
    end if; 
    if col_info.numero is not null and col_info.valor is null and 
       ((car_delimitador is null and (col_info.inicio is null or col_info.fim is null))
        or (car_delimitador is not null and col_info.ordem is null)) then
      err_msg:='O valor/posição da coluna INFO não está definido corretamente no layout.';
      raise value_error;
    end if; 
    if col_valor2.numero is not null and col_valor2.valor is null and 
       ((car_delimitador is null and (col_valor2.inicio is null or col_valor2.fim is null))
        or (car_delimitador is not null and col_valor2.ordem is null)) then
      err_msg:='O valor/posição da coluna VALOR2 não está definido corretamente no layout.';
      raise value_error;
    end if; 
    if col_info2.numero is not null and col_info2.valor is null and 
       ((car_delimitador is null and (col_info2.inicio is null or col_info2.fim is null))
        or (car_delimitador is not null and col_info2.ordem is null)) then
      err_msg:='O valor/posição da coluna INFO2 não está definido corretamente no layout.';
      raise value_error;
    end if; 
    if col_valor3.numero is not null and col_valor3.valor is null and 
       ((car_delimitador is null and (col_valor3.inicio is null or col_valor3.fim is null))
        or (car_delimitador is not null and col_valor3.ordem is null)) then
      err_msg:='O valor/posição da coluna VALOR3 não está definido corretamente no layout.';
      raise value_error;
    end if; 
    if col_info3.numero is not null and col_info3.valor is null and 
       ((car_delimitador is null and (col_info3.inicio is null or col_info3.fim is null))
        or (car_delimitador is not null and col_info3.ordem is null)) then
      err_msg:='O valor/posição da coluna INFO3 não está definido corretamente no layout.';
      raise value_error;
    end if; 
    if col_valor4.numero is not null and col_valor4.valor is null and 
       ((car_delimitador is null and (col_valor4.inicio is null or col_valor4.fim is null))
        or (car_delimitador is not null and col_valor4.ordem is null)) then
      err_msg:='O valor/posição da coluna VALOR4 não está definido corretamente no layout.';
      raise value_error;
    end if; 
    if col_info4.numero is not null and col_info4.valor is null and 
       ((car_delimitador is null and (col_info4.inicio is null or col_info4.fim is null))
        or (car_delimitador is not null and col_info4.ordem is null)) then
      err_msg:='O valor/posição da coluna INFO4 não está definido corretamente no layout.';
      raise value_error;
    end if; 
    if col_valor5.numero is not null and col_valor5.valor is null and 
       ((car_delimitador is null and (col_valor5.inicio is null or col_valor5.fim is null))
        or (car_delimitador is not null and col_valor5.ordem is null)) then
      err_msg:='O valor/posição da coluna VALOR5 não está definido corretamente no layout.';
      raise value_error;
    end if; 
    if col_info5.numero is not null and col_info5.valor is null and 
       ((car_delimitador is null and (col_info5.inicio is null or col_info5.fim is null))
        or (car_delimitador is not null and col_info5.ordem is null)) then
      err_msg:='O valor/posição da coluna INFO5 não está definido corretamente no layout.';
      raise value_error;
    end if; 
    if col_valor6.numero is not null and col_valor6.valor is null and 
       ((car_delimitador is null and (col_valor6.inicio is null or col_valor6.fim is null))
        or (car_delimitador is not null and col_valor6.ordem is null)) then
      err_msg:='O valor/posição da coluna VALOR6 não está definido corretamente no layout.';
      raise value_error;
    end if; 
    if col_info6.numero is not null and col_info6.valor is null and 
       ((car_delimitador is null and (col_info6.inicio is null or col_info6.fim is null))
        or (car_delimitador is not null and col_info6.ordem is null)) then
      err_msg:='O valor/posição da coluna INFO6 não está definido corretamente no layout.';
      raise value_error;
    end if; 
    if col_obs.numero is not null and col_obs.valor is null and 
       ((car_delimitador is null and (col_obs.inicio is null or col_obs.fim is null))
        or (car_delimitador is not null and col_obs.ordem is null)) then
      err_msg:='O valor/posição da coluna OBS não está definido corretamente no layout.';
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
  FUNCTION conv_linha(p_linha      IN  VARCHAR2,
                                        p_modo_carga IN  VARCHAR2,
                                        p_rec        OUT vantagens%ROWTYPE,
                                        p_oper       OUT VARCHAR2)
    RETURN VARCHAR2
  IS

    err_msg               VARCHAR2(500);
    v_linha               VARCHAR2(4000);
    v_numfunc             VARCHAR2(100);
    v_numvinc             VARCHAR2(100);
    v_matric              VARCHAR2(100);
    v_vantagem            VARCHAR2(20);
    v_rubrica             VARCHAR2(100);
    v_dtini               VARCHAR2(100);
    v_dtfim               VARCHAR2(100);
    v_valor               VARCHAR2(100);
    v_info                VARCHAR2(60);
    v_valor2              VARCHAR2(100);
    v_info2               VARCHAR2(60);
    v_valor3              VARCHAR2(100);
    v_info3               VARCHAR2(60);
    v_valor4              VARCHAR2(100);
    v_info4               VARCHAR2(60);
    v_valor5              VARCHAR2(100);
    v_info5               VARCHAR2(60);
    v_valor6              VARCHAR2(100);
    v_info6               VARCHAR2(60);
    v_obs                 VARCHAR2(2000);

    v_operacao            VARCHAR2(60);
    v_existe_vant         NUMBER;
    v_setor               hsetor.setor%TYPE;
    v_empresa             vinculos.emp_codigo%TYPE;
    --
    v_bloqueia_dupl       CHAR(1);
    v_existe_lanc         NUMBER := 0;
    v_existe_dupl         NUMBER := 0;
    v_existe_vant_numfunc NUMBER := 0;

    BEGIN
      -- Copia os registros da linha do arquivo para as variáveis auxiliares
      flag_pack.set_empresa(flag_pack.get_empresa); -- 13/05/2015
      IF car_delimitador IS NULL THEN
        --
        -- Rotina de cópia para o caso SEM delimitador
        --
        BEGIN

          IF col_matric.coluna IS NOT NULL THEN
            v_numfunc := NULL;
            v_numvinc := NULL;

            IF col_matric.valor IS NULL THEN
              BEGIN
                SELECT numfunc, numero
                INTO   v_numfunc, v_numvinc
                FROM   vinculos
                WHERE  matricula = EP__MATRICULA(RTRIM(LTRIM(substr(p_linha, col_matric.inicio, col_matric.fim - col_matric.inicio + 1))));
                --
              EXCEPTION WHEN no_data_found THEN
                -- TAREFAS (11972, 11987, 11926)
                err_msg := 'Matrícula não cadastrada no sistema. MATRICULA1:'||EP__MATRICULA(RTRIM(LTRIM(substr(p_linha, col_matric.inicio, col_matric.fim - col_matric.inicio + 1))));
                v_numfunc := NULL;
                v_numvinc := NULL;
                RETURN (err_msg);
              END;
            ELSE
              BEGIN
                SELECT numfunc, numero
                INTO   v_numfunc, v_numvinc
                FROM   vinculos
                WHERE  matricula = EP__MATRICULA(col_matric.valor);
                --
              EXCEPTION WHEN no_data_found THEN
                err_msg := 'Matrícula não cadastrada no sistema. MATRICULA2:'||EP__MATRICULA(col_matric.valor);
                v_numfunc := NULL;
                v_numvinc := NULL;
                RETURN (err_msg);
              END;
            END IF;
          END IF;
          --
          IF col_numfunc.coluna IS NOT NULL AND col_numvinc.coluna IS NOT NULL THEN
            -- NUMFUNC
            IF col_numfunc.valor IS NULL THEN
              v_numfunc := substr(p_linha, col_numfunc.inicio, col_numfunc.fim - col_numfunc.inicio + 1);
            ELSE
              v_numfunc := col_numfunc.valor;
            END IF;
            -- NUMVINC
            IF col_numvinc.valor IS NULL THEN
              v_numvinc := substr(p_linha, col_numvinc.inicio, col_numvinc.fim - col_numvinc.inicio + 1);
            ELSE
              v_numvinc := col_numvinc.valor;
            END IF;

            BEGIN
              SELECT numfunc, numero
              INTO   v_numfunc, v_numvinc
              FROM   vinculos
              WHERE  numfunc = v_numfunc AND numero = v_numvinc;
            EXCEPTION
              WHEN no_data_found THEN
                err_msg := 'Vínculo não cadastrado no sistema.';
                RETURN (err_msg);
            END;
          END IF;
          
          -- DTINI
          IF col_dtini.numero IS NOT NULL THEN
            IF col_dtini.valor IS NULL THEN
              v_dtini := substr(p_linha, col_dtini.inicio, col_dtini.fim - col_dtini.inicio + 1);
            ELSE
              v_dtini := col_dtini.valor;
            END IF;
          END IF;
          
          -- DTFIM
          IF col_dtfim.numero IS NOT NULL THEN
            IF col_dtfim.valor IS NULL THEN
              v_dtfim := substr(p_linha, col_dtfim.inicio, col_dtfim.fim - col_dtfim.inicio + 1);
            ELSE
              v_dtfim := col_dtfim.valor;
            END IF;
          END IF;

          -- VANTAGEM / RUBRICA
          IF col_vantagem.numero IS NOT NULL THEN
            IF col_vantagem.valor IS NULL THEN
              v_vantagem := substr(p_linha,col_vantagem.inicio,col_vantagem.fim-col_vantagem.inicio+1);
            ELSE
              v_vantagem := col_vantagem.valor;
            END IF;
          ELSIF col_rubrica.numero IS NOT NULL THEN
            IF col_rubrica.valor IS NULL THEN
              v_rubrica := substr(p_linha,col_rubrica.inicio,col_rubrica.fim-col_rubrica.inicio+1);
            ELSE
              v_rubrica := col_rubrica.valor;
            END IF;
            --
            BEGIN
              SELECT vantagem INTO v_vantagem
              FROM   tipo_vantagem
              WHERE rubrica = to_number(v_rubrica);
             --
            EXCEPTION
              WHEN no_data_found THEN
                err_msg := 'Rubrica '||v_rubrica||' não possui atributo associado.';
                RETURN (err_msg); 
              WHEN too_many_rows THEN
                err_msg := 'Rubrica '||v_rubrica||' possui mais de um atributo associado.';
                RETURN (err_msg); 
              WHEN others THEN
                err_msg := 'Erro no cadastro de Atributo para Rubrica '||v_rubrica||'.';
                RETURN (err_msg); 
            END;
          ELSE
            err_msg := 'Campo VANTAGEM ou RUBRICA devem ser fornecidos.';
            RETURN (err_msg); 
          END IF;

          -- OBS
          IF col_obs.numero IS NOT NULL THEN
            IF col_obs.valor IS NULL THEN
              v_obs := substr(p_linha, col_obs.inicio, col_obs.fim - col_obs.inicio + 1);
            ELSE
              v_obs := col_obs.valor;
            END IF;
          END IF; 

          -- INFO
          IF col_info.numero IS NOT NULL THEN
            IF col_info.valor IS NULL THEN
              v_info := substr(p_linha, col_info.inicio, col_info.fim - col_info.inicio + 1);
            ELSE
              v_info := col_info.valor;
            END IF;
          END IF;   
          -- VALOR
          IF col_valor.numero IS NOT NULL THEN
            IF col_valor.valor IS NULL THEN
              v_valor := substr(p_linha, col_valor.inicio, col_valor.fim - col_valor.inicio + 1);
            ELSE
              v_valor := col_valor.valor;
            END IF;
          END IF;  

          -- INFO2
          IF col_info2.numero IS NOT NULL THEN
            IF col_info2.valor IS NULL THEN
              v_info2 := substr(p_linha, col_info2.inicio, col_info2.fim - col_info2.inicio + 1);
            ELSE
              v_info2 := col_info2.valor;
            END IF;
          END IF;   
          -- VALOR2
          IF col_valor2.numero IS NOT NULL THEN
            IF col_valor2.valor IS NULL THEN
              v_valor := substr(p_linha, col_valor2.inicio, col_valor2.fim - col_valor2.inicio + 1);
            ELSE
              v_valor2 := col_valor2.valor;
            END IF;
          END IF;  

          -- INFO3
          IF col_info3.numero IS NOT NULL THEN
            IF col_info3.valor IS NULL THEN
              v_info3 := substr(p_linha, col_info3.inicio, col_info3.fim - col_info3.inicio + 1);
            ELSE
              v_info3 := col_info3.valor;
            END IF;
          END IF;   
          -- VALOR3
          IF col_valor3.numero IS NOT NULL THEN
            IF col_valor3.valor IS NULL THEN
              v_valor := substr(p_linha, col_valor3.inicio, col_valor3.fim - col_valor3.inicio + 1);
            ELSE
              v_valor3 := col_valor3.valor;
            END IF;
          END IF;  

          -- INFO4
          IF col_info4.numero IS NOT NULL THEN
            IF col_info4.valor IS NULL THEN
              v_info4 := substr(p_linha, col_info4.inicio, col_info4.fim - col_info4.inicio + 1);
            ELSE
              v_info4 := col_info4.valor;
            END IF;
          END IF;   
          -- VALOR4
          IF col_valor4.numero IS NOT NULL THEN
            IF col_valor4.valor IS NULL THEN
              v_valor := substr(p_linha, col_valor4.inicio, col_valor4.fim - col_valor4.inicio + 1);
            ELSE
              v_valor4 := col_valor4.valor;
            END IF;
          END IF;  

          -- INFO5
          IF col_info5.numero IS NOT NULL THEN
            IF col_info5.valor IS NULL THEN
              v_info5 := substr(p_linha, col_info5.inicio, col_info5.fim - col_info5.inicio + 1);
            ELSE
              v_info5 := col_info5.valor;
            END IF;
          END IF;   
          -- VALOR5
          IF col_valor5.numero IS NOT NULL THEN
            IF col_valor5.valor IS NULL THEN
              v_valor := substr(p_linha, col_valor5.inicio, col_valor5.fim - col_valor5.inicio + 1);
            ELSE
              v_valor5 := col_valor5.valor;
            END IF;
          END IF;  

          -- INFO6
          IF col_info6.numero IS NOT NULL THEN
            IF col_info6.valor IS NULL THEN
              v_info6 := substr(p_linha, col_info6.inicio, col_info6.fim - col_info6.inicio + 1);
            ELSE
              v_info6 := col_info6.valor;
            END IF;
          END IF;   
          -- VALOR6
          IF col_valor6.numero IS NOT NULL THEN
            IF col_valor6.valor IS NULL THEN
              v_valor := substr(p_linha, col_valor6.inicio, col_valor6.fim - col_valor6.inicio + 1);
            ELSE
              v_valor6 := col_valor6.valor;
            END IF;
          END IF;  

          -- OPERACAO
          IF col_operacao.numero IS NOT NULL THEN
            IF col_operacao.valor IS NULL THEN
              v_operacao := substr(p_linha, col_operacao.inicio, col_operacao.fim - col_operacao.inicio + 1);
            ELSE
              v_operacao := col_operacao.valor;
            END IF;
          END IF; 

        EXCEPTION
          WHEN OTHERS THEN
            err_msg := 'Erro em Posicionamento de Colunas.';
            RETURN (err_msg);
        END;

      ELSE
        --
        -- Rotina de cópia para o caso COM delimitador
        --
        DECLARE
          TYPE TIPOCAMPO IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
          t_campo TIPOCAMPO;
          pos_ini NUMBER;
          pos_fim NUMBER;
          i       BINARY_INTEGER;
        BEGIN
          --break;
          -- Primeiro, preenche um vetor com os campos achados na linha
          BEGIN
            v_linha := p_linha;
            i := 1;
            pos_ini := 1;
            t_campo(0) := NULL;
            LOOP
              pos_fim := instr(v_linha, car_delimitador, pos_ini, 1);

              IF pos_fim = 0 THEN
                t_campo(i) := substr(v_linha, pos_ini);
                EXIT;
              END IF;
              t_campo(i) := substr(v_linha, pos_ini, pos_fim - pos_ini);
              i := i + 1;

              pos_ini := pos_fim + 1;

            END LOOP;
          EXCEPTION
            WHEN value_error THEN
              err_msg := 'O tamanho do campo ' || to_char(i) || ' é maior que 2000 caracteres';
              RETURN (err_msg);
          END;
          
          -- Depois, copia os valores do vetor para as variáveis auxiliares
          BEGIN

            IF col_matric.coluna IS NOT NULL THEN

              v_matric := nvl(col_matric.valor, RTRIM ( LTRIM (t_campo(nvl(col_matric.ordem, 0)))));
              
              BEGIN
                SELECT numfunc, numero
                INTO   v_numfunc, v_numvinc
                FROM   vinculos
                WHERE  matricula = EP__MATRICULA(v_matric);
                
              EXCEPTION WHEN no_data_found THEN
                err_msg := 'Matrícula não cadastrada no sistema. MATRICULA3:'||EP__MATRICULA(v_matric);
                RETURN (err_msg);
                v_numfunc := 0;
                v_numvinc := 0;
              END;
            END IF;

            IF col_numfunc.coluna IS NOT NULL AND col_numvinc.coluna IS NOT NULL THEN
              v_numfunc := nvl(col_numfunc.valor, t_campo(nvl(col_numfunc.ordem, 0)));
              v_numvinc := nvl(col_numvinc.valor, t_campo(nvl(col_numvinc.ordem, 0)));
              --
              ---
              --- Verifica Id Funcional e Vinculo
              BEGIN
                SELECT 'S' INTO v_existe
                FROM   funcionarios
                WHERE  numero = v_numfunc;
              EXCEPTION
                WHEN no_data_found THEN
                  err_msg := 'Id Funcional não cadastrado no sistema.' || v_numfunc;
                  RETURN (err_msg);
                WHEN OTHERS THEN
                  err_msg := 'Id Funcional não contem somente numeros.' || v_numfunc;
                  RETURN (err_msg);
              END;

              IF v_numfunc IS NULL THEN
                err_msg := 'Id Funcional inválido - Nulo.';
                RETURN (err_msg);
              END IF;

              IF v_numfunc = 0 THEN
                err_msg := 'Id Funcional inválido - Zerado.';
                RETURN (err_msg);
              END IF;

              BEGIN
                SELECT numfunc, numero, emp_codigo
                INTO   v_numfunc, v_numvinc, v_empresa
                FROM   vinculos
                WHERE  numfunc = v_numfunc 
                AND    numero = v_numvinc;

              EXCEPTION
                WHEN no_data_found THEN
                  err_msg := 'Vínculo inválido no sistema.';
                  RETURN (err_msg);
              END;
              --
              -- Pega setor do funcionário
              v_setor := pack_ergon.get_setor_func(v_numfunc, v_numvinc, sysdate);
              --
              IF v_setor IS NOT NULL THEN
                --
                -- Verifica se o usuário tem acesso ao setor do funcionário
                --
                IF PACK_HADES.mostra_setor(flag_pack.get_usuario, v_setor, v_empresa) = 0 THEN
                  err_msg := 'Usuário ' || flag_pack.get_usuario || ' não tem permissão de' ||' acesso ao setor deste funcionário(' || v_setor || ')';
                  RETURN (err_msg);
                END IF;

              END IF;
            END IF;

            IF col_vantagem.numero IS NOT NULL THEN
              BEGIN
                v_vantagem := nvl(col_vantagem.valor, ltrim(rtrim(t_campo(nvl(col_vantagem.ordem, 0)))));
              EXCEPTION
                WHEN value_error THEN
                  err_msg := 'O tamanho do campo VANTAGEM é maior que 20 caracteres';
                  RETURN (err_msg);
              END;

              -- Verificar se existe o tipo de vantagem ---------------
              SELECT count(1) INTO v_existe_vant
              FROM   tipo_vantagem
              WHERE  vantagem = v_vantagem;
              --
              IF v_existe_vant = 0 THEN
                err_msg:='Tipo de vantagem não cadastrado para o Atributo: ('||v_vantagem||')';
                RETURN (err_msg);
              END IF;
            
            ELSIF col_rubrica.numero IS NOT NULL THEN
              
              BEGIN
                v_rubrica:=nvl(col_rubrica.valor, ltrim(rtrim(t_campo(nvl(col_rubrica.ordem,0)))));
                SELECT vantagem INTO v_vantagem
                FROM   tipo_vantagem 
                WHERE  rubrica = v_rubrica;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  err_msg := 'Rubrica '||v_rubrica||' não possui atributo associado.';
                  RETURN (err_msg); 
                WHEN TOO_MANY_ROWS THEN
                  err_msg := 'Rubrica '||v_rubrica||' possui mais de um atributo associado.';
                  RETURN (err_msg); 
                WHEN OTHERS THEN
                  err_msg := 'Erro no cadastro de Atributo para Rubrica '||v_rubrica||'.';
                  RETURN (err_msg); 
              END;
            
            END IF;

           v_dtini    :=nvl(col_dtini.valor, t_campo(nvl(col_dtini.ordem,0)));
           v_dtfim    :=nvl(col_dtfim.valor,t_campo (nvl(col_dtfim.ordem,0)));
           v_valor    :=nvl(col_valor.valor,t_campo (nvl(col_valor.ordem,0)));
           v_info     :=nvl(col_info.valor,t_campo  (nvl(col_info.ordem,0)));
           v_valor2   :=nvl(col_valor2.valor,t_campo(nvl(col_valor2.ordem,0)));
           v_info2    :=nvl(col_info.valor,t_campo  (nvl(col_info2.ordem,0)));
           v_valor3   :=nvl(col_valor3.valor,t_campo(nvl(col_valor3.ordem,0)));
           v_info3    :=nvl(col_info3.valor,t_campo (nvl(col_info3.ordem,0)));
           v_valor4   :=nvl(col_valor4.valor,t_campo(nvl(col_valor4.ordem,0)));
           v_info4    :=nvl(col_info4.valor,t_campo (nvl(col_info4.ordem,0)));
           v_valor5   :=nvl(col_valor5.valor,t_campo(nvl(col_valor5.ordem,0)));
           v_info5    :=nvl(col_info5.valor,t_campo (nvl(col_info5.ordem,0)));
           v_valor6   :=nvl(col_valor6.valor,t_campo(nvl(col_valor6.ordem,0)));
           v_info6    :=nvl(col_info6.valor,t_campo (nvl(col_info6.ordem,0)));
           v_obs      :=nvl(col_obs.valor,t_campo   (nvl(col_obs.ordem,0)));
           v_operacao :=t_campo(nvl(col_operacao.ordem,0));


            IF p_modo_carga <> 'D' THEN

              --
              ------------------------------------------------------------------------------                                             --
              -- Verifica se ja existe na tabela vantagens o registro a ser inserido caso --
              -- o parametro Bloqueia Duplicidade estiver 'S'        
              ------------------------------------------------------------------------------
              BEGIN
               SELECT SUBSTR(flex_campo_03,1,1) INTO v_bloqueia_dupl
               FROM   tipo_vantagem
               WHERE  vantagem = v_vantagem;
              EXCEPTION WHEN OTHERS THEN
                 v_bloqueia_dupl := 'N';
              END;


              IF NVL(v_bloqueia_dupl,'N') = 'S' THEN
                BEGIN
                  v_existe_lanc := PGOV_DUPLICIDADE_ATRIBUTO(v_numfunc,
                                                             v_numvinc,
                                                             v_vantagem,
                                                             to_date(v_dtini,'dd/mm/yyyy'),
                                                             to_date(v_dtfim,'dd/mm/yyyy'),
                                                             v_info,
                                                             v_obs,
                                                             v_info2,
                                                             v_info4,
                                                             v_info5);
                EXCEPTION 
                  WHEN OTHERS THEN
                    err_msg:='Erro no retorno da verificação de Duplicidade - Erro: '||sqlerrm;
                    return(err_msg);
                END; 

                IF v_existe_lanc > 0 THEN
                  err_msg := 'Este lançamento não poderá ser inserido pois está em Duplicidade.';
                  RETURN (err_msg);
                END IF;

              END IF;

            END IF; --if p_modo_carga <> 'D' then
            ------------------------------------------------------------------------------

          EXCEPTION
            WHEN no_data_found THEN
              err_msg := 'O número de delimitadores da linha é menor que o especificado no layout';
              RETURN (err_msg);
            WHEN OTHERS THEN
              err_msg := sqlerrm;
              RETURN (err_msg);
          END;
        EXCEPTION
          WHEN OTHERS THEN
            err_msg := 'Erro nos delimitadores da coluna';
            RETURN (err_msg);
        END;
      END IF;
      -- Converte os registro para os datatypes apropriados e copia-os para o registro de
      -- frequências.

      BEGIN
        p_rec.numfunc := to_number(v_numfunc);
      EXCEPTION
        WHEN OTHERS THEN RETURN ('Valor inválido para NUMFUNC');
      END;

      BEGIN
        p_rec.numvinc := to_number(v_numvinc);
      EXCEPTION
        WHEN OTHERS THEN RETURN ('Valor inválido para NUMVINC');
      END;

      BEGIN
        p_rec.vantagem := ltrim(rtrim(v_vantagem));
      EXCEPTION
        WHEN OTHERS THEN RETURN ('Valor inválido para VANTAGEM');
      END;
      
      BEGIN
        p_rec.dtini := to_date(ltrim(rtrim(v_dtini)), col_dtini.formato);
        EXCEPTION
        WHEN OTHERS THEN RETURN ('Data inválida em DTINI');
      END;
      
      BEGIN
        p_rec.dtfim := to_date(ltrim(rtrim(v_dtfim)), col_dtfim.formato);
      EXCEPTION
        WHEN OTHERS THEN RETURN ('Data inválida em DTFIM');
      END;

      BEGIN
        p_rec.obs := ltrim(rtrim(v_obs));
      EXCEPTION
        WHEN OTHERS THEN RETURN ('Valor inválido para OBS');
      END;

      BEGIN
        p_rec.info := ltrim(rtrim(v_info));
      EXCEPTION
        WHEN OTHERS THEN RETURN ('Valor inválido para INFO: '||ltrim(rtrim(v_info)));
      END;

      BEGIN
        v_valor := REPLACE(REPLACE(v_valor,CHR(13),''),CHR(10),'');
        p_rec.valor:=to_number(v_valor);
      EXCEPTION
        WHEN OTHERS THEN RETURN('Valor inválido para VALOR: '||REPLACE(REPLACE(v_valor,CHR(13),''),CHR(10),''));
      END;

      BEGIN
        p_rec.info2 := ltrim(rtrim(v_info2));
      EXCEPTION
        WHEN OTHERS THEN RETURN ('Valor inválido para INFO2');
      END;

      BEGIN
        v_valor2 := REPLACE(REPLACE(v_valor2,CHR(13),''),CHR(10),'');
        p_rec.valor2 := to_number(v_valor2);
      EXCEPTION
        WHEN OTHERS THEN RETURN('Valor inválido para VALOR2');
      END;

      BEGIN
        p_rec.info3 := ltrim(rtrim(v_info3));
      EXCEPTION
        WHEN OTHERS THEN RETURN ('Valor inválido para INFO3');
      END;

      BEGIN
        v_valor3 := REPLACE(REPLACE(v_valor3,CHR(13),''),CHR(10),'');
        p_rec.valor3 := to_number(v_valor3);
      EXCEPTION
        WHEN OTHERS THEN RETURN('Valor inválido para VALOR3');
      END;

      BEGIN
        p_rec.info4 := ltrim(rtrim(v_info4));
      EXCEPTION
        WHEN OTHERS THEN RETURN ('Valor inválido para INFO4');
      END;

      BEGIN
        v_valor4 := REPLACE(REPLACE(v_valor4,CHR(13),''),CHR(10),'');
        p_rec.valor4 := to_number(v_valor4);
      EXCEPTION
        WHEN OTHERS THEN RETURN('Valor inválido para VALOR4');
      END;

      BEGIN
        p_rec.info5 := ltrim(rtrim(v_info5));
      EXCEPTION
        WHEN OTHERS THEN RETURN ('Valor inválido para INFO5');
      END;

      BEGIN
        v_valor5 := REPLACE(REPLACE(v_valor5,CHR(13),''),CHR(10),'');
        p_rec.valor5 := to_number(v_valor5);
      EXCEPTION
        WHEN OTHERS THEN RETURN('Valor inválido para VALOR5');
      END;

      BEGIN
        p_rec.info6 := ltrim(rtrim(v_info6));
      EXCEPTION
        WHEN OTHERS THEN RETURN ('Valor inválido para INFO6');
      END;

      BEGIN
        v_valor6 := REPLACE(REPLACE(v_valor6,CHR(13),''),CHR(10),'');
        p_rec.valor6 := to_number(v_valor6);
      EXCEPTION
        WHEN OTHERS THEN RETURN('Valor inválido para VALOR6');
      END;

      BEGIN
        p_oper:=v_operacao;
      EXCEPTION
        WHEN OTHERS THEN RETURN ('Erro no valor OPERACAO');
      END;

      -- Se chegou até aqui, tudo OK
      RETURN (NULL);

    END conv_linha;

END TGRJ_PACK_CARGA_ATRIB;
/