create or replace procedure tgrj_atualiza_foto_dependente(p_numfunc   in number,
                            p_numdep    in number,
                            p_foto      in blob,
                            p_nome_arq  in varchar2,
                            p_mime_type in varchar2) is

  /**************** INICIO_HELP: ****************
  ----------------------------------------------------
  Nome:
    PROCEDURE atualiza_foto_dep
  Propósito:
    Rotina para inserir ou atualizar foto de dependente.
  Parâmetros:
    p_numfunc: IN number
      Parâmetro que indica o número funcional do funcionário.
    p_numdep: IN number
      Parâmetro que indica o número do dependente do funcionário.
    p_foto: IN blob
      Parâmetro com a imagem da foto do dependente.
    p_nome_arq: IN varchar2
      Parâmetro que indica o nome do arquivo com a foto do dependente.
    p_mime_type: IN varchar2
      Parâmetro que indica o tipo do arquivo com a foto do dependente.
  Utilização:
    Utilizado na página Pessoas vinculadas ao servidor/magistrado - ERGadm00217.
  ----------------------------------------------------
  **************** FINAL_HELP: ****************/
  c_sigla_pessoa erg_doc_pessoa.tipo_pessoa%type := 'PESSOA';
  c_sigla_depen  erg_doc_pessoa.tipo_pessoa%type := 'DEPEN';
  c_sigla_foto   had_documentos.tipo_documento%TYPE := '648032A576C446798DACE232988062D4';

  v_typeJPEG       had_documentos_dados.mime_type%TYPE := 'image/jpeg';
  v_typePNG        had_documentos_dados.mime_type%TYPE := 'image/png';
  v_typePNG_IE     had_documentos_dados.mime_type%TYPE := 'image/x-png';
  v_typePJPEG      had_documentos_dados.mime_type%TYPE := 'image/pjpeg';
  v_typeGIF        had_documentos_dados.mime_type%TYPE := 'image/gif';
  v_typeBMP        had_documentos_dados.mime_type%TYPE := 'image/bmp';
  v_id_doc_pessoa  erg_doc_pessoa.id_doc_pessoa%type := null;
  v_id_doc         erg_doc_pessoa.id_doc%type := null;
  v_tipo_pessoa    erg_doc_pessoa.tipo_pessoa%type := null;
  v_id_pessoa      erg_doc_pessoa.id_pessoa%type := null;
  v_tam_foto       integer := pack_hades.get_opcao_number('Hades', 'HADES', 'MAX_TAMANHO_FOTO');
  v_tam_foto_receb integer;
  --
begin
  if p_numfunc is null then
    ergon_erro_pack.trata_erro(99, 'É necessário informar um funcionário para carregar uma foto.');
  end if;
  if p_numdep is null then
    ergon_erro_pack.trata_erro(99, 'É necessário informar um dependente para carregar uma foto.');
  end if;

  begin
    select id_pessoa
      into v_id_pessoa
      from dependentes
     where numfunc = p_numfunc
       and numero = p_numdep;

  exception
    when no_data_found then
      ergon_erro_pack.trata_erro(99, 'Dependente não encontrado');
  end;

  if nvl(v_tam_foto, 0) < 1 then
    ergon_erro_pack.trata_erro(99, 'Opção genérica de tamanho de foto não está preenchida.');
  end if;

  if p_foto is not null then
    v_tam_foto_receb := DBMS_Lob.GetLength(p_foto) / 1024;
    if v_tam_foto_receb > v_tam_foto then
      ergon_erro_pack.trata_erro(99, 'O tamanho do arquivo de foto não deve ultrapassar ' || v_tam_foto || ' KBytes.');
    end if;

    if p_mime_type <> v_typeJPEG  and
     p_mime_type <> v_typePNG   and
     p_mime_type <> v_typePJPEG and
     p_mime_type <> v_typeGIF   and
     p_mime_type <> v_typeBMP   and
     p_mime_type <> v_typePNG_IE then
      ergon_erro_pack.trata_erro(99, 'Arquivo selecionado não é do tipo IMAGEM.');
    end if;
  end if;

  -- Verifica se já existe registro de FOTO em ERG_DOC_PESSOA para o dependente
  if v_id_pessoa is not null then
    begin
      select a.id_doc_pessoa, b.id_documento, a.tipo_pessoa
        into v_id_doc_pessoa, v_id_doc, v_tipo_pessoa
        from erg_doc_pessoa a, had_documentos b
       where a.id_doc = b.id_documento
         and a.id_pessoa = v_id_pessoa
         and a.tipo_pessoa = c_sigla_pessoa
         and b.tipo_documento = c_sigla_foto
         and rownum = 1;
    exception
      when no_data_found then
        begin
          v_id_doc_pessoa := null;
          v_tipo_pessoa   := nvl(v_tipo_pessoa, c_sigla_pessoa);
        end;
    end;
  else
    begin
      select a.id_doc_pessoa, b.id_documento, a.tipo_pessoa
        into v_id_doc_pessoa, v_id_doc, v_tipo_pessoa
        from erg_doc_pessoa a, had_documentos b
       where a.id_doc = b.id_documento
         and a.id_pessoa is null
         and a.tipo_pessoa = c_sigla_depen
         and b.tipo_documento = c_sigla_foto
         and a.numfunc = p_numfunc
         and a.numvinc is null
         and a.numpens is null
         and a.numdep = p_numdep
         and a.numrep is null
         and rownum = 1;
    exception
      when no_data_found then
        begin
          v_id_doc_pessoa := null;
          v_tipo_pessoa   := nvl(v_tipo_pessoa, c_sigla_depen);
        end;
    end;
  end if;
  -- Se já existe registro de FOTO, atualiza foto. Senão, cria novo registro
  if v_id_doc_pessoa is not null then
    update had_documentos_dados
       set documento_blob = p_foto,
           nome_arq       = p_nome_arq,
           mime_type      = p_mime_type,
           oculto         = 'S'
     where id_documento = v_id_doc;

    if sql%rowcount = 0 then
      insert into had_documentos_dados (id_documento, documento_blob, nome_arq, mime_type, oculto)
      values (v_id_doc, p_foto, p_nome_arq, p_mime_type, 'S');
    end if;

    if v_id_pessoa is not null then
      update erg_doc_pessoa
         set id_pessoa = v_id_pessoa, numfunc = null, numdep = null
       where id_doc_pessoa = v_id_doc_pessoa
         and id_pessoa is null
         and numfunc is not null
         and numdep is not null;
    end if;
  else
    insert into had_documentos (tipo_documento, descricao)
    values (c_sigla_foto, 'Documento de fotografia do servidor gerado pela rotina ATUALIZA_FOTO_DEP')
   return id_documento into v_id_doc;

    insert into had_documentos_dados (id_documento, documento_blob, nome_arq, mime_type, oculto)
    values (v_id_doc, p_foto, p_nome_arq, p_mime_type, 'S');

    if v_id_pessoa is not null then
      insert into erg_doc_pessoa (id_doc, tipo_pessoa, numfunc, numdep, id_pessoa)
      values (v_id_doc, v_tipo_pessoa, null, null, v_id_pessoa);
    else
      insert into erg_doc_pessoa (id_doc, tipo_pessoa, numfunc, numdep, id_pessoa)
      values (v_id_doc, v_tipo_pessoa, p_numfunc, p_numdep, null);
    end if;
  end if;
  commit;
end tgrj_atualiza_foto_dependente;
/
 