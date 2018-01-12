create or replace procedure tgrj_dmlvw_tgrj_gee
  (
    p_oper in varchar2,
    p_rowid_reg in out varchar2,
    p_lista_col in had_typ_array_varchar2 default null,
    pb_dt_criacao in tgrj_gee.dt_criacao%type default null,
    pb_gee in tgrj_gee.gee%type default null,
    pb_nome in tgrj_gee.nome%type default null,
    p_mens out varchar2
)
is
  --
  /* Procedure de DML gerada automaticamente */
  --
  c_tabela          constant varchar2(100) := upper('TGRJ_GEE');
  c_prefixo_base    constant varchar2(3) := 'pb_';
  c_prefixo_publ    constant varchar2(3) := 'pp_';
  --
  cursor_name       pls_integer;
  v_pontpubl        had_publicacoes.pont%type := null;
  v_ind             number := 0;
  tab_dml           dbms_sql.varchar2a;
  tab_col_base      dbms_sql.varchar2s;
  v_comando         varchar2(4000);
  v_rowid_reg       rowid := chartorowid (p_rowid_reg);
  v_reg_publicacoes had_publicacoes%rowtype;
  v_reg_publx       had_publx%rowtype;
  v_lista_col       had_typ_array_varchar2;
  ve                varchar2(4000);
  vc                number;
  exc_reg_pend      exception;
  --
  pragma exception_init (exc_reg_pend, -20000);
  --
  function extrai_msg_erro (p_erro in varchar2, p_code_erro in number) return varchar2 is
    v_erro     varchar2(4000) := p_erro;
    v_erro_aux varchar2(4000);
    v_pos_ini  number;
    v_pos_fim  number;
    v_msg    varchar2(2000);
  begin
    -- Retira stack de erros Oracle
    loop
      v_pos_ini := instr(v_erro, 'ORA-06512', -1);
      exit when v_pos_ini = 0;
      v_erro := substr(v_erro, 1, v_pos_ini-1);
    end loop;
    -- Retira trechos referentes ao erro ORA-06550
    loop
      v_pos_ini := instr(v_erro, 'ORA-06550');
      exit when v_pos_ini = 0;
      v_pos_fim := instr(v_erro, 'PLS-', v_pos_ini+1);
      if v_pos_fim = 0 then
        v_pos_fim := instr(v_erro, 'ORA-', v_pos_ini+1);
      end if;
      if v_pos_fim = 0 then
        v_pos_fim := length(v_erro);
      end if;
      v_erro_aux := substr(v_erro, v_pos_fim);
      v_erro     := substr(v_erro, 1, v_pos_ini-1);
      v_erro     := v_erro || v_erro_aux;
    end loop;
    -- Troca ocorrências de ORA-XXXXX por ORACLE-XXXXX
    v_erro := replace(v_erro,'ORA-','ORACLE-');
    -- Retira trecho antes de erro Archon
    v_pos_ini := instr(v_erro, 'HAD-');
    if v_pos_ini = 0 then
      v_pos_ini :=  instr(v_erro, 'CHAD-');
    end if;
    if v_pos_ini = 0 then
      v_pos_ini :=  instr(v_erro, 'ERG-');
    end if;
    if v_pos_ini = 0 then
      v_pos_ini :=  instr(v_erro, 'CERG-');
    end if;
    if v_pos_ini = 0 then
      v_msg := had_trata_erro(p_code_erro,v_erro,c_tabela, null);
    end if;
    v_erro := nvl(v_msg,substr(v_erro, v_pos_ini));
    return v_erro;
  end;
  --
  procedure monta_comando (p_comando in varchar2) is
  begin
  v_ind := v_ind + 1;
  tab_dml(v_ind) := p_comando;
  end;
  --
  function pos_coluna (p_param in varchar2) return number is
  begin
    for x in 1..tab_col_base.count loop
      if upper(tab_col_base(x)) = substr(upper(p_param), length(c_prefixo_base)+1) then
        return x;
      end if;
    end loop;
    return null;
  end;
  --
  procedure gera_dml (p_dml in varchar2) is
    v_qtd number := 0;
  begin
    if p_dml in ('I', 'U') then
      if v_lista_col.count > 0 then
        for x in 1..v_lista_col.count loop
          if instr(upper(v_lista_col(x)), upper(c_prefixo_base)) = 1 then
            v_comando := substr(v_lista_col(x), length(upper(c_prefixo_base))+1);
            if p_dml = 'U' then
              v_comando := v_comando || ' = :'||pos_coluna(v_lista_col(x));
            end if;
            if v_qtd >= 1 then
              monta_comando (','||v_comando);
            else
              monta_comando (v_comando);
            end if;
            v_qtd := v_qtd + 1;
          end if;
        end loop;
      else
        for x in 1..tab_col_base.count loop
          v_comando := tab_col_base(x);
          if p_dml = 'U' then
            v_comando := v_comando || ' = :'||x;
          end if;
          if v_qtd >= 1 then
            monta_comando (','||v_comando);
          else
            monta_comando (v_comando);
          end if;
          v_qtd := v_qtd + 1;
        end loop;
      end if;
      v_qtd := 0;
      if p_dml = 'I' then
        monta_comando (') values (');
        if v_lista_col.count > 0 then
          for x in 1..v_lista_col.count loop
            if instr(upper(v_lista_col(x)), upper(c_prefixo_base)) = 1 then
              if v_qtd >= 1 then
                monta_comando (', :'||pos_coluna(v_lista_col(x)));
              else
                monta_comando (':'||pos_coluna(v_lista_col(x)));
              end if;
              v_qtd := v_qtd + 1;
            end if;
          end loop;
        else
          for x in 1..tab_col_base.count loop
            v_comando := ':'||x;
            if v_qtd >= 1 then
              monta_comando (','||v_comando);
            else
              monta_comando (v_comando);
            end if;
            v_qtd := v_qtd + 1;
          end loop;
        end if;
--
        -- Tarefa 97942 - Silas - v6.60 - 17/11/2017
        -- Returando a clausula "returning rowid into :r;" não funciona para VIEW
        --
        -- monta_comando (') returning rowid into :r;');
        monta_comando(');');
      else
        monta_comando (' where rowid = :r;');
        monta_comando (' if sql%rowcount = 0 then ');
        monta_comando ('   raise_application_error (-20000,''Registro não encontrado para atualização''); ');
        monta_comando (' end if; ');
      end if;
    elsif p_dml = 'D' then
      -- Monta comando DELETE do registro base
      monta_comando ('delete from '||c_tabela);
      monta_comando (' where rowid = :r;');
      monta_comando (' if sql%rowcount = 0 then ');
      monta_comando ('   raise_application_error (-20000,''Registro não encontrado para remoção''); ');
      monta_comando (' end if; ');
    else
      return;
    end if;
  end;
  --

    -- Tarefa Silas
  procedure executa_dml is
    execution_val  pls_integer;
    v_erro         varchar2(4000);
    v_rowid_reg_view  ROWID;
  begin

-- Tarefa 97942 - SILAS - v6.60 - 17/11/2017
    -- O rowid é da tabela TGRJ_GEE_
    -- Mas o Update ou Delete será feito na view TGRJ_GEE.
    -- Então é necessário obter o ROWID da view, porque, não é garantido que seja igual ao ROWID da tabela TGRJ_GEE_
    -- Por isso, o SQL abaixo será executado
    --


  if p_oper IN ('U', 'D') Then

      DECLARE
        v_gee_old TGRJ_GEE_.GEE%TYPE;
      BEGIN

        SELECT GEE
          INTO v_gee_old
        FROM TGRJ_GEE_
        WHERE ROWID = v_rowid_reg;

        SELECT ROWID
          INTO v_rowid_reg_view
        FROM TGRJ_GEE
        WHERE GEE = v_gee_old;

      EXCEPTION
        WHEN OTHERS THEN
          ergon_erro_pack.trata_erro(0, 'O cadastro não foi realizado porque o sistema não consegue identificar o novo registro.');
      END;

    end if;


    cursor_name := dbms_sql.open_cursor;
    dbms_sql.parse (cursor_name, tab_dml, tab_dml.first, tab_dml.last, false, Dbms_sql.Native);
    dbms_sql.bind_variable_rowid (cursor_name, ':r', v_rowid_reg_view   ); --passando a varáivel v_rowid_reg_view ao invés da v_rowid_reg
    dbms_sql.bind_variable       (cursor_name, ':1', pb_dt_criacao);
    dbms_sql.bind_variable       (cursor_name, ':2', pb_gee);
    dbms_sql.bind_variable       (cursor_name, ':3', pb_nome);
    execution_val := Dbms_sql.Execute(cursor_name);


    if p_oper IN ('I', 'U') then
      --
      -- dbms_sql.variable_value (cursor_name, ':r', v_rowid_reg);
      --
      -- Tarefa 97942 - Silas - v6.60 - 17/11/2017
      -- Adcionando o SQL para pegar o ROWID da tabela, já que a clausula
      -- "returning rowid into :r;" não funciona para VIEW
      -- Também é válido para o UPDATE, caso a chave primária seja alterada, o ROWID também será alterado.
      -- Usando a PK do novo registro
      --
      BEGIN

      SELECT ROWID
        INTO v_rowid_reg
      FROM TGRJ_GEE_
      WHERE GEE = pb_gee;

      EXCEPTION
        WHEN OTHERS THEN
          ergon_erro_pack.trata_erro(0, 'O cadastro não foi realizado porque o sistema não consegue identificar o novo registro.');
      END;

      p_rowid_reg := rowidtochar(v_rowid_reg);
    elsif p_oper = 'D' then
      p_rowid_reg := null;
    end if;
    dbms_sql.close_cursor (cursor_name);
  end;
  --
begin
  p_mens := null;
  pack_hades.executa_sql ('alter session set nls_sort = binary');
  --
  -- Inicializa ARRAY
  --
  if p_lista_col is not null then
    v_lista_col := p_lista_col;
  else
    v_lista_col := had_typ_array_varchar2();
  end if;
  --
  -- Preenche lista de colunas da tabela base
  --
  select column_name
    bulk collect into tab_col_base
    from user_tab_columns
   where table_name            = c_tabela
     and column_name      not in ('ID_REG')
     and upper(data_type) not in ('LONG','LONG RAW','RAW')
  order by decode (substr(column_name, 1, 11), 'FLEX_CAMPO_', 2, 1), column_name;
  --
  -- Monta bloco PL/SQL que executará o comando DML no banco de dados.
  -- O código abaixo, que atribui cada bind variable a uma coluna dos registros V1 e V2, embora não seja utilizado para o comando DML, é necessário
  -- porque o Oracle exige que a quantidade de valores passados para a execução do comando seja exatamente igual à quantidade de bind variables definida
  -- no código dinâmico. Assim, monta-se o bloco PL/SQL de forma a que ele referencie todas as bind variables possíveis nas atribuições, mas o comando
  -- DML em si utiliza apenas as bind variables referentes aos parâmetros passados e informados em P_LISTA_COL
  --
  monta_comando ('declare');
  monta_comando ('  v1 tgrj_gee%rowtype;');
  monta_comando ('  v2 had_publicacoes%rowtype;');
  monta_comando ('  rw rowid := :r;');
  monta_comando ('begin');
  monta_comando ('  v1.dt_criacao  := :1;');
  monta_comando ('  v1.gee  := :2;');
  monta_comando ('  v1.nome  := :3;');
  if p_oper = 'I' then
    -- Monta comando INSERT do registro base
    monta_comando ('insert into '||c_tabela|| '(');
    gera_dml ('I');
  elsif p_oper = 'U' then
    -- Monta comando UPDATE do registro base
    monta_comando ('update '||c_tabela);
    monta_comando ('   set ');
    gera_dml ('U');
  else
    -- Monta comando DELETE do registro base
    gera_dml ('D');
  end if;
  monta_comando ('end;');
  begin
    executa_dml;
    commit;
  exception
    when exc_reg_pend then
    begin
      vc := sqlcode;
      ve := extrai_msg_erro(sqlerrm, vc);
      if dbms_sql.is_open (cursor_name) then
        dbms_sql.close_cursor (cursor_name);
      end if;
      if vc = -20000 and instr(upper(ve), 'INSERIDO COMO REGISTRO PENDENTE') > 0 then
        commit;
        if p_oper = 'I' then
          p_mens := 'Inserção registrada como pendente';
        elsif p_oper = 'U' then
          p_mens := 'Alteração registrada como pendente';
        elsif p_oper = 'D' then
          p_mens := 'Remoção registrada como pendente';
        end if;
      else
        rollback;
        raise_application_error (-20000, ve);
      end if;
    end;
  end;
end;

/
