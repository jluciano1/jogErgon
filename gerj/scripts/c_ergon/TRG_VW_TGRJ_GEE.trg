prompt ***ATENÇÃO!!!*** Objeto TRG_VW_TGRJ_GEE não possui replace e deve ser mesclado manualmente com a versão existente no banco.
CREATE TRIGGER "C_ERGON"."TRG_VW_TGRJ_GEE"
instead of
insert or update or delete
on tgrj_gee
referencing old as old new as new
for each row
begin
  if (inserting) then
    --
    begin
      insert into tgrj_gee_
        (nome,dt_criacao,gee)
      values
        (:new.nome,:new.dt_criacao,:new.gee);
    exception
      --
      -- em caso de duplica???#o de chaves, apenas inserir o registro do seu nome para a empresa logada (pr??ximo passo)
      --
      when dup_val_on_index then
        null;
    end;
    --
    -- tentar inserir na tabela de empresas
    --
    begin
      insert into tgrj_gee_empresa
        (gee,empresa)
      values
        (:new.gee,flag_pack.get_empresa);
    exception
      --
      -- se o nome da empresa j?! existir, acusar erro
      --
      when dup_val_on_index then
        null;
    end;
  elsif (updating) then
    --
    -- caso a chave prim?!ria da tabela tgrj_gee_ seja alterada, ser?! necess?!rio
    -- fazer um delete do registro corresponde na tabela tgrj_gee_empresa
    -- e repetir o procedimento de insert
    --
    if :new.gee                       <> :old.gee                      then
      --
      -- repetindo o procedimento de insert
      --
      --
      begin
        insert into tgrj_gee_
          (nome,dt_criacao,gee)
        values
          (:new.nome,:new.dt_criacao,:new.gee);
      exception
        --
        -- em caso de duplica???#o de chaves, apenas inserir o registro do seu nome para a empresa logada (pr??ximo passo)
        --
        when dup_val_on_index then
          null;
      end;
      --
      -- tentar inserir na tabela de empresas
      --
      begin
        insert into tgrj_gee_empresa
          (gee,empresa)
        values
          (:new.gee,flag_pack.get_empresa);
      exception
        --
        -- se o nome da empresa j?! existir, acusar erro
        --
        when dup_val_on_index then
          null;
      end;
      --
      -- ao mudar a chave prim?!ria da tabela ?? necess?!rio remover a associa???#o entre tgrj_gee_ e a empresa
      --
      delete tgrj_gee_empresa
       where gee                       = :old.gee
         and empresa                   = flag_pack.get_empresa;
      --
      -- se n?#o existir nenhum filho de tgrj_gee_, remov??-lo tamb??m. sen?#o, n?#o fazer nada.
      --
      delete tgrj_gee_
       where gee                       = :old.gee
         and not exists (select null from tgrj_gee_empresa
                         where gee                       = :old.gee);
      --
    else
      --
      -- caso contr?!rio, executa o update padr?#o
      -- atualizar os campos da tabela tgrj_gee_
      --
      update tgrj_gee_
         set gee                       = :new.gee                      ,
             dt_criacao                = :new.dt_criacao               ,
             nome                      = :new.nome
       where gee                       = :old.gee                      ;
       --
    end if;
    --
  elsif (deleting) then
    --
    -- remover a associa???#o entre tgrj_gee_ e a empresa
    --
    delete tgrj_gee_empresa
     where gee = :old.gee
       and empresa  = flag_pack.get_empresa;

    --
    -- se n?#o existir nenhum filho de tgrj_gee_, remov??-lo tamb??m. sen?#o, n?#o fazer nada.
    --
    delete tgrj_gee_
     where gee                       = :old.gee
       and not exists (select null from tgrj_gee_empresa
                       where gee                       = :old.gee);
    --
  end if;
end trg_vw_tgrj_gee;
/

