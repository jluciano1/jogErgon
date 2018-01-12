CREATE OR REPLACE
PACKAGE TGRJ_PACK_CARGA_FREQ IS

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
  tem_quantidade boolean;
  tem_tipofreq boolean;
	tem_codfreq boolean;
	tem_pontpubl boolean;
	tem_obs boolean;
	tem_pontlei boolean;
	tem_emp_codigo boolean;
	tem_hora_entrada boolean;
	tem_hora_saida boolean;
	tem_id_reg boolean;
  
  tem_operacao  boolean;
  --
  function carrega_layout(p_numero number,p_modo_carga varchar2) return varchar2;
  --
  function conv_linha(p_linha in varchar2, p_modo_carga in varchar2, p_rec out frequencias%rowtype, p_oper out varchar2) return varchar2;                         

END TGRJ_PACK_CARGA_FREQ;
/