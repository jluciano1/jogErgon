CREATE OR REPLACE
PACKAGE TGRJ_PACK_CARGA_CAP IS

  PROCEDURE VERIFICA( P_ARQUIVO       VARCHAR2
                     ,P_TIPO          VARCHAR2
                     ,P_CAMINHO       VARCHAR2
                     ,P_NUMERO_LAYOUT NUMBER);

    PROCEDURE CARGA( P_ARQUIVO       VARCHAR2
                  ,P_TIPO          VARCHAR2
                  ,P_CAMINHO       VARCHAR2
                  ,P_NUMERO_LAYOUT NUMBER);

  PROCEDURE DESFAZ_CARGA( P_ARQUIVO       VARCHAR2
                         ,P_TIPO          VARCHAR2
                         ,P_CAMINHO       VARCHAR2
                         ,P_NUMERO_LAYOUT NUMBER
                         ,P_ID_EXEC_AUDIT LOG_PROCESSO_HEADER.ID_EXEC%TYPE);

    -- variáveis que indicam quais colunas estão presente no layout
  
  tem_chave         boolean;
  tem_numfunc       boolean;
  tem_linha         boolean;
  tem_curso         boolean;
  tem_data          boolean;
  tem_cargahor      boolean;
  tem_obs           boolean;
  tem_automatico    boolean;
  tem_instit        boolean;
  tem_dt_inicio     boolean;
  tem_dt_fim        boolean;
  tem_erro          boolean;
  tem_texto_linha   boolean;
  tem_nome          boolean;
  tem_obs_pub       boolean;
  tem_documento     boolean;
  tem_obs_pub_2     boolean;
  tem_id_reg  		boolean;
  tem_flex_campo_01 boolean;
  tem_flex_campo_02 boolean;
  tem_flex_campo_03 boolean;
  tem_flex_campo_04 boolean;
  tem_flex_campo_05 boolean;
  tem_flex_campo_06 boolean;
  tem_flex_campo_07 boolean;
  tem_flex_campo_08 boolean;
  tem_flex_campo_09 boolean;
  tem_flex_campo_10 boolean;
  tem_flex_campo_11 boolean;
  tem_flex_campo_12 boolean;
  tem_flex_campo_13 boolean;
  tem_flex_campo_14 boolean;
  tem_flex_campo_15 boolean;


  function carrega_layout(p_numero number,p_modo_carga varchar2) return varchar2;
  --
  function conv_linha(p_linha in varchar2, p_modo_carga in varchar2, p_rec out capacitacoes%rowtype, p_oper out varchar2) return varchar2;                         

END TGRJ_PACK_CARGA_CAP;

/