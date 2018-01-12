create or replace FUNCTION TGRJ_EPB__PENSIONISTAS_2 (
    P_ROW_NEW    IN OUT NOCOPY PENSIONISTAS%ROWTYPE,
    P_ROW_OLD    IN     PENSIONISTAS%ROWTYPE,
    P_INSERTING  IN     BOOLEAN,
    P_UPDATING   IN     BOOLEAN,
    P_DELETING   IN     BOOLEAN,
    P_MENS       OUT    NOCOPY VARCHAR2
  ) 
    RETURN BOOLEAN IS
    V_CONTA           VARCHAR2(80);
    V_NUMFUNC          NUMBER;
  BEGIN
  --
  -- arnaldo.oliveira MF inicio
  --
  IF FLAG_PACK.GET_USUARIO = 'migra' THEN
    RETURN (TRUE);
  END IF;

	IF (HADES.FLAG_PACK.GET_TRANSACAO <> 'RJadm00039') THEN
		RETURN (TRUE);
	END IF;
  
      IF P_INSERTING OR P_UPDATING THEN
        --- Data de nascimento deve ser anterior à data de hoje
        IF P_ROW_NEW.DTNASC > SYSDATE THEN
            P_MENS := 'Data de nascimento deve ser anterior à data de hoje';
        END IF;
        --- Pensionista com Idade Superior à Permitida (120) Anos
        IF ADD_MONTHS(P_ROW_NEW.DTNASC, 1440) < SYSDATE THEN
            P_MENS := 'Pensionista com Idade Superior à Permitida (120) Anos';
        END IF;
        --- Atenção! Não é permitido informar código de banco diferente de 237
        IF P_ROW_NEW.BANCO <> '237' THEN
            P_MENS := 'Atenção! Não é permitido informar código de banco diferente de 237';
        END IF;
        --- Só pode ter conta se tiver agência bancária
        IF P_ROW_NEW.CONTA IS NOT NULL AND P_ROW_NEW.AGENCIA IS NULL THEN
            P_MENS := 'Só pode ter conta se tiver agência bancária';
        END IF;

        -- Verifica se o FUNCIONARIO já existe no cadastro
        BEGIN
            SELECT NUMERO INTO V_NUMFUNC FROM FUNCIONARIOS WHERE CPF = P_ROW_NEW.CPF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
            V_NUMFUNC := NULL;
        END;

        --- Regra caso 1 - Se o CPF já existe vai ser preenchido na tela pelo controller
        
        --- Regra caso 2 - O CPF não existe no cadatro vai ser cadastrado aqui na sequencia
        IF V_NUMFUNC IS NULL THEN
            --- CAMPOS SOLICITADOS    
            --                                   CPF,           NOME, DATA DE NASCIMENTO          ,           SEXO,       ESTADO CIVIL    ,           FONE    ,           EMAIL        ,           NATURALIDADE ,           NACIONALIDADE,           MÃE,           PAI, CAMPOS DO ENDEREÇO                                                                                                                                                              ,          #PAÍS         , DADOS DO REGISTRO GERAL                        , TÍTULO DE ELEITOR.
            --- Campos P_ROW_NEW    
            -- C                                 CPF,           NOME,           DTNASC            ,           SEXO,           ESTCIVIL    ,           TELEFONE,           FLEX_CAMPO_03,           FLEX_CAMPO_21,           FLEX_CAMPO_25,           MAE,           PAI,           TIPOLOGENDER,           NOMELOGENDER,           NUMENDER,           COMPLENDER,           CEPENDER,                  UF,                CIDADE,               BAIRRO ,           #FLEX_CAMPO_02,          TIPORG,           NUMRG, DESCORGAORG, DESCRUFRG, EXPEDRG ,NUMTITEL, ZONATITEL, SECTITEL, UFTITEL
            -- Campos da tabela funcionarios
            --                                   CPF,           NOME,           DTNASC            ,           SEXO,           ESTCIVIL    ,           TELEFONE,           ?=EMAIL      ,           ?            ,           ?            ,           MAE,           PAI,           TIPOLOGENDER,           NOMELOGENDER,           NUMENDER,           COMPLENDER,           ?         ,                              CIDADEENDER,           BAIRROENDER,           #?            ,          TIPORG,           NUMRG, DESCORGAORG, DESCRUFRG, EXPEDRG ,NUMTITEL, ZONATITEL, SECTITEL, UFTITEL
            INSERT INTO FUNCIONARIOS (           CPF,           NOME,           DTNASC            ,           SEXO,           ESTCIVIL    ,           TELEFONE,           E_MAIL       ,           CIDNASC      ,           NACIONALIDADE,           MAE,           PAI,           TIPOLOGENDER,           NOMELOGENDER,           NUMENDER,           COMPLENDER,           CEPENDER  ,           UFENDER,           CIDADEENDER,           BAIRROENDER                          ,           TIPORG,           NUMRG,            EXPEDRG ,          NUMTITEL,           ZONATITEL,           SECTITEL,           UFTITEL)
                              VALUES ( P_ROW_NEW.CPF, P_ROW_NEW.NOME, P_ROW_NEW.DTNASC            , P_ROW_NEW.SEXO, P_ROW_NEW.ESTCIVIL    , P_ROW_NEW.TELEFONE, P_ROW_NEW.FLEX_CAMPO_03, P_ROW_NEW.FLEX_CAMPO_21, P_ROW_NEW.FLEX_CAMPO_25, P_ROW_NEW.MAE, P_ROW_NEW.PAI, P_ROW_NEW.TIPOLOGENDER, P_ROW_NEW.NOMELOGENDER, P_ROW_NEW.NUMENDER, P_ROW_NEW.COMPLENDER, P_ROW_NEW.CEPENDER  ,      P_ROW_NEW.UF     , P_ROW_NEW.CIDADE     , P_ROW_NEW.BAIRRO                          , P_ROW_NEW.TIPORG, P_ROW_NEW.NUMRG,  P_ROW_NEW.EXPEDRG ,P_ROW_NEW.NUMTITEL, P_ROW_NEW.ZONATITEL, P_ROW_NEW.SECTITEL, P_ROW_NEW.UFTITEL);
        END IF; 
        --- Regra caso 3 - O pensionista não existe no cadastro de pessoas e já existe no cadastro de dependentes para a finalidade pensão alimentícia.
            -- essas regras são da tela.
            
      END IF;
      
    RETURN (TRUE);
  END;
/