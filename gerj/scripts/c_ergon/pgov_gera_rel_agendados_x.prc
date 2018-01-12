prompt ***ATENÇÃO!!!*** Objeto PGOV_GERA_REL_AGENDADOS_X não possui replace e deve ser mesclado manualmente com a versão existente no banco.
CREATE
PROCEDURE "PGOV_GERA_REL_AGENDADOS_X" IS

  v_conection VARCHAR2(4000);    
  v_url        VARCHAR2(4000);
  v_dir_relat  VARCHAR2(32000);
  v_user_http_authentication VARCHAR2(4000);
  v_pass_http_authentication VARCHAR2(4000);  
  
  v_repserver  VARCHAR2(2000);
  v_clrf       VARCHAR2(100) := chr(13) || chr(10);
  v_agenda     HAD_AGENDA_RELAT%ROWTYPE;
  v_param      HAD_AGENDA_RELAT_PARAM%ROWTYPE;
  V_SERVER_HOST VARCHAR2(500);
  v_achou      BOOLEAN;
  v_mens       VARCHAR2(2000);
  v_retorno    VARCHAR2(2000);
  v_arquivo    VARCHAR2(2000);
  v_inicio     DATE;
  v_fim        DATE;
  v_proximo    BOOLEAN;
  v_conta_erro NUMBER:= 0;
  v_contador   NUMBER:=0;
  v_parametros VARCHAR2(4000);
  v_procedure  VARCHAR2(4000);
  v_valor_sequencia NUMBER;
  v_name_database VARCHAR(500);
  v_ver_while     BOOLEAN:=TRUE;
  v_existe VARCHAR2(100);
  v_nm_arquivo VARCHAR2(4000);
  v_usuario VARCHAR(500);
  v_seq_email NUMBER; 
  v_email     USUARIO.MAIL%TYPE;
  
  CURSOR cur_agenda IS
    SELECT *
      FROM had_agenda_relat r
     WHERE status = 'EM FILA'
       AND data_hora <= SYSDATE
       AND not exists (  --pimentel - 18/12/2017 - leitura somente dos agendamentos gerados sem lote.
              select null
              from TGRJ_LOTE_REPORT l
              where l.id_agenda = r.id
                      )
      -- AND rownum <= 3
     ORDER BY usuario, data_hora, id;

  CURSOR relatorio (p_id IN NUMBER, p_nome IN VARCHAR2) IS
    SELECT re.arquivo, re.nome
      FROM grupo_relatorios gr, relatorios re, had_agenda_relat ar
     WHERE re.sistema = gr.sistema
       AND re.grupo_codigo = gr.codigo
       AND re.nome = p_nome
       AND ar.relatorio = re.nome
       AND ar.id = p_id
     ORDER BY nome;

  CURSOR param_relatorio (p_id IN NUMBER, p_nome IN VARCHAR2, p_dir_relat IN VARCHAR2) IS
    SELECT usuario, arquivo ds_local , --parametro ||'='|| DECODE(parametro,'DESNAME','/local/archon/web/temp/'||valor,valor) parametros, har.dtiniexec
                                       parametro ||'='|| DECODE(parametro,'DESNAME', p_dir_relat||valor,valor) parametros, har.dtiniexec
      FROM had_agenda_relat har, had_agenda_relat_param hap
     WHERE har.id = hap.id
       AND har.relatorio = p_nome
       AND har.id = p_id;

  CURSOR param_procedure (p_id IN NUMBER, p_nome IN VARCHAR2) IS
    SELECT usuario, arquivo ds_local , parametro ||'='|| valor parametros , parametro, valor, har.dtiniexec
      FROM had_agenda_relat har, had_agenda_relat_param hap
     WHERE har.id = hap.id
       AND har.relatorio = p_nome
       AND hap.parametro NOT IN ('DESFORMAT','DESNAME','DESTYPE','P_TITULO')
       AND har.id = p_id;

  PROCEDURE atualiza_status(p_id IN NUMBER, p_status IN VARCHAR2, p_mens IN VARCHAR2) IS
  BEGIN
    UPDATE had_agenda_relat SET status = p_status, mensagem = p_mens
     WHERE id = p_id;
  END;

BEGIN
  
  --flag_pack.set_empresa(1);

    select seq_relatorios.nextval
      into v_seq_email
      from dual;
      
    FOR v_agenda IN cur_agenda  LOOP
        v_usuario := v_agenda.USUARIO;
        v_parametros := null;
        v_procedure := null;

        v_mens := 'Execucao numero : ' || v_agenda.ID || chr(10);
        v_mens := v_mens || 'Usuario : ' || v_agenda.USUARIO || chr(10);
        v_mens := v_mens || 'Relatorio : ' || v_agenda.RELATORIO;
        v_inicio  := SYSDATE;
        v_mens := 'Execucao numero : ' || v_agenda.ID || chr(10);
        v_mens := v_mens || 'Inicio : ' || to_char(v_inicio, 'DD/MM/YYYY HH24:MI:SS') || ' / Termino : ' || to_char(v_fim, 'DD/MM/YYYY HH24:MI:SS') || chr(10);

        BEGIN
          ATUALIZA_STATUS(v_agenda.ID, 'EM EXECUCAO', NULL);
          commit;

        EXCEPTION
          WHEN OTHERS THEN
            v_mens := v_mens || 'Status : INTERROMPIDO' || chr(10);
        END;

        UPDATE had_agenda_relat SET dtiniexec = SYSDATE
         WHERE id = v_agenda.id;

        v_inicio  := SYSDATE;

        SELECT PACK_HADES.GET_OPCAO('Hades','WEB','REPORTSSERVER')
          INTO v_repserver
          FROM DUAL;


        FOR rel IN relatorio ( v_agenda.id,  v_agenda.relatorio ) LOOP
--producao //10.9.44.20
--homologacao //10.9.43.9

          select SYS_CONTEXT ('USERENV', 'SERVER_HOST') 
          into V_SERVER_HOST 
          from dual; 
          
          /** Alterado para executar no ambiente do banco 192.168.0.145 **/

/*
          IF V_SERVER_HOST = 'tauoca11g' THEN
            v_url := 'http://10.9.44.20:7778/reports/rwservlet?Eserver='||v_repserver||'Eparamform=noEmodule='||rel.arquivo||'Euserid=hades/hades@ergon';
          ELSIF V_SERVER_HOST = 'tururim' THEN
            v_url := 'http://10.9.43.9:7778/reports/rwservlet?Eserver='||v_repserver||'Eparamform=noEmodule='||rel.arquivo||'Euserid=hades/hades@ergon';          
          END IF;
*/          
      
          --pimentel - 18/12/2017 - uso da package tgrj_relat_util para estabelecer a url
          -- Precisa verificar essa configuração no ambiente do Rio Previdência.
          v_url := tgrj_relat_util.get_url_report;
          v_conection := tgrj_relat_util.get_conection;
    
          v_url := v_url ||CHR(38)||'paramform=no'||CHR(38)||'module='||rel.arquivo||CHR(38)||'userid=' || v_conection;
               

          FOR proc IN param_procedure(v_agenda.ID, v_agenda.relatorio) LOOP
              v_parametros := v_parametros||proc.parametros||';';
              IF proc.parametro = 'P_SEQUENCIA' THEN
                v_valor_sequencia := TO_NUMBER(proc.valor);
              END IF;
          END LOOP;
          
          v_parametros := substr(v_parametros,1,length(v_parametros)-1);

          v_procedure := 'BEGIN PGOV_PRC_'||rel.arquivo||'('''||v_parametros||''' ); END;';
          dbms_output.put_line(v_procedure);
          EXECUTE IMMEDIATE(v_procedure);

          --pimentel - 18/12/2017 - uso da package tgrj_relat_util para obter o diretório temporário de geração do relatórios
          v_dir_relat := tgrj_relat_util.get_dir_relat_agenda;
      
          FOR param IN param_relatorio(v_agenda.ID, v_agenda.relatorio, v_dir_relat) LOOP

            IF param.parametros LIKE 'DESNAME=%' THEN
              v_contador := v_contador + 1;

              --v_nm_arquivo := REPLACE(param.parametros,'DESNAME=/local/archon/web/temp/','');
              v_nm_arquivo := REPLACE(param.parametros,'DESNAME=' || v_dir_relat,'');
              
              begin
                select mail
                  into v_email
                  from usuario
                 where usuario = v_agenda.usuario;  

                insert into itemtabela ( item, tab, descr, item1, item2 )
                values ( v_contador||TO_NUMBER(TO_CHAR(SYSDATE,'DDMMYYYYHH24MISS')), 'PGOV_EMAIL_REPORT_AG', v_email, v_nm_arquivo, v_seq_email );
                                
              exception
                when no_data_found then 
                  null;
              end;        

            END IF;  
            
            commit;
            
            V_URL:= V_URL || 'E' || REPLACE(param.parametros,' ','+');
             

          END LOOP;
         
          v_arquivo := rel.arquivo;

        END LOOP;
        dbms_output.put_line(v_url); 

        v_fim     := SYSDATE;

        UPDATE had_agenda_relat SET data_expiracao = SYSDATE + dias_expiracao,
                                    dtfimexec = SYSDATE
         WHERE id = v_agenda.id;

          v_mens := v_mens || 'Status : CONCLUIDO' || chr(10);
          v_mens := v_mens || 'Execucao completada com sucesso. Gerado o arquivo : ' || v_arquivo;

          INSERT INTO PGOV_DADOS_URL values ( V_URL, SYSDATE, v_agenda.usuario, v_agenda.id, v_mens, v_valor_sequencia );

          COMMIT;

      END LOOP;

      COMMIT;
      
      --pimentel - 18/12/2017 - uso da package tgrj_relat_util para obter os dados de autenticação via http ao servidor de relatórios
      -- Precisa verificar essa configuração no ambiente do Rio Previdência.      
      v_user_http_authentication := tgrj_relat_util.get_user_http_authentication();
      v_pass_http_authentication := tgrj_relat_util.get_pass_http_authentication();      

      for i in ( select valor1 , ID_AGENDA, MENSAGEM, SEQUENCIA
                   from PGOV_DADOS_URL 
                   )

               loop
                 BEGIN
                   
                   v_ver_while := TRUE;
                   WHILE v_ver_while LOOP
                     begin
                       --PGOV_SHOW_URL(i.valor1,'HADES','HADES', v_retorno);
                       PGOV_SHOW_URL(i.valor1,v_user_http_authentication,v_pass_http_authentication, v_retorno);
                       dbms_output.put_line(i.valor1);
                       dbms_output.put_line('retorno=> '||v_retorno);
                     exception
                       when others then
                         v_ver_while := true;  
                     end;      

                     IF v_Retorno IS NULL THEN
                       v_ver_while := FALSE;
                     ELSE
                       v_ver_while := TRUE;  
                     END IF;
  
                   end loop;
 
                   ATUALIZA_STATUS(I.Id_AGENDA, 'CONCLUIDO', I.MENSAGEM);
                   commit;

                   DELETE FROM PGOV_DADOS_RELATORIOS 
                   WHERE SEQUENCIA = i.sequencia;
                   commit;
                   
                   DELETE FROM PGOV_DADOS_URL 
                   WHERE SEQUENCIA =  i.sequencia;                     
                   commit;

                 EXCEPTION
                   WHEN OTHERS THEN
                     -- MANDAR EMAIL
                     NULL;
                 END;
               end loop;

            /* PROCEDIMENTO QUE ENVIA EMAIL PROPORCIONAL */
            FOR I IN ( SELECT DISTINCT DESCR 
                         FROM ITEMTABELA 
                        WHERE TAB = 'PGOV_EMAIL_REPORT_AG' 
                          AND ITEM2 = v_seq_email )
              LOOP
                v_nm_arquivo := NULL;
                
                FOR J IN ( SELECT ITEM1 
                             FROM ITEMTABELA 
                            WHERE TAB = 'PGOV_EMAIL_REPORT_AG' 
                              AND ITEM2 = v_seq_email 
                              AND DESCR = I.DESCR )
                              LOOP
                                v_nm_arquivo := v_nm_arquivo||J.ITEM1|| v_clrf || v_clrf ;
                              END LOOP;

                PCK_SEND_EMAIL.p_sendmail('proc_agendamento@sigrh.rj.gov.br',
                                          I.DESCR,
                                          'Agendamento de Relatórios',
                                          'Relatório(s) agendado(s) com sucesso!' 
                                          || v_clrf || v_clrf || '  Segue abaixo o(s) arquivo(s) gerado(s) para download.  ' 
                                          || v_clrf || v_clrf || v_nm_arquivo
                                          || v_clrf || v_clrf || 'Es
                                          ta é uma mensagem enviada pelo SIGRH.');

              END LOOP;
              
              DELETE FROM ITEMTABELA WHERE TAB= 'PGOV_EMAIL_REPORT_AG' AND ITEM2 = v_seq_email;
              COMMIT;
               
END;
/