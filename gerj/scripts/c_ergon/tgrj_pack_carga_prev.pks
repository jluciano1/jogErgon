CREATE OR REPLACE
PACKAGE TGRJ_PACK_CARGA_PREV IS

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
  tem_dtfim boolean;
  tem_valor boolean;
  tem_info  boolean;
  tem_emp_codigo boolean;
  tem_valor2 boolean;
  tem_info2  boolean;
  tem_valor3 boolean;
  tem_info3  boolean;
  tem_valor4 boolean;
  tem_info4  boolean;
  tem_valor5 boolean;
  tem_info5  boolean;
  tem_valor6 boolean;
  tem_info6  boolean;
  tem_observacao boolean;
  tem_tipo   boolean;
  tem_flex_campo_01 boolean;
  tem_flex_campo_02 boolean;
  tem_flex_campo_03 boolean;
  tem_flex_campo_04 boolean;
  tem_flex_campo_05 boolean;


  tem_complemento boolean;

  tem_operacao  boolean;
  --
  function carrega_layout(p_numero number,p_modo_carga varchar2) return varchar2;
  --
  function conv_linha(p_linha in varchar2, p_modo_carga in varchar2, p_rec out fol_movimentos%rowtype, p_oper out varchar2) return varchar2;                         

END TGRJ_PACK_CARGA_PREV;
/