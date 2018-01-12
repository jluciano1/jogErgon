BEGIN
  EXECUTE IMMEDIATE 'drop type UTIL_TYP_PARAM_CONTA_TAB';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -4043 THEN
      RAISE;
    END IF;
END;
/

CREATE OR REPLACE TYPE UTIL_TYP_PARAM_CONTA AS OBJECT (
REGJUR                       VARCHAR2(20),
TIPOVINC                     VARCHAR2(20),
CATEGORIA                    VARCHAR2(20),
SUBCATEGORIA                 VARCHAR2(20),
DTINI                        DATE,
DTFIM                        DATE,
TEMAPOS                      VARCHAR2(1),
ANOSAPOSMASC                 NUMBER(2),
ANOSAPOSFEM                  NUMBER(2),
IDADEAPOSMASC                NUMBER(2),
IDADEAPOSFEM                 NUMBER(2),
TEMTEMPOSERV                 VARCHAR2(1),
ANOS1TEMPOSERV               NUMBER(2),
ANOS2TEMPOSERV               NUMBER(2),
ANOS3TEMPOSERV               NUMBER(2),
ANOS4TEMPOSERV               NUMBER(2),
TEMLICESP                    CHAR(1),
ANOSLICESP                   NUMBER(2),
MESESLICESPPER               NUMBER(2),
TEMPROGRESSAO                CHAR(1),
TEMTEMPOCHEFIA               CHAR(1),
ANOSTEMPOCHEFIA              NUMBER(2),
TEMFERIAS                    VARCHAR2(1),
TOTDIASFER                   NUMBER(2),
MAXPERFER                    NUMBER(2),
MINPERFER                    NUMBER(1),
MAXDIASPERFER                NUMBER(2),
MINDIASPERFER                NUMBER(2),
TEMSEXTAPARTE                CHAR(1),
ANOSSEXTAPARTE               NUMBER(2),
ANOS_PROGRESSAO              NUMBER(2),
PERMITE_FER_PER_INC          CHAR(1),
ABONO_DIR_GOZO               CHAR(1),
ABONOCONSTFER                VARCHAR2(1),
ADIANT13FER                  VARCHAR2(1),
ADIANTSALFER                 VARCHAR2(1),
EMPRESTFER                   VARCHAR2(1),
MAXDIASVENDFER               NUMBER(2),
MINDIASPVENDFER              NUMBER(2),
NUMDIASABONOFER              NUMBER,
DENDIASABONOFER              NUMBER(5),
CONTDOBROLICESP              VARCHAR2(1),
MAXDIASCONTDOBLICESP         NUMBER(3),
MINDIASPCONTDOBLICESP        NUMBER(3),
VENDLICESP                   VARCHAR2(1),
ABONODIRGOZOLICESP           VARCHAR2(1),
MAXDIASVENDLICESP            NUMBER(3),
MINDIASPVENDLICESP           NUMBER(3),
NUMDIASABONOLICESP           NUMBER,
DENDIASABONOLICESP           NUMBER(5),
ANOS2PROGRESSAO              NUMBER(2),
ANOS3PROGRESSAO              NUMBER(2),
ANOS4PROGRESSAO              NUMBER(2),
PONTLEI_PROGRESSAO           NUMBER(10),
PONTLEI_APOSENT              NUMBER(10),
PONTLEI_TEMPOSERV            NUMBER(10),
PONTLEI_TEMPOCHEFIA          NUMBER(10),
PONTLEI_SEXTAPARTE           NUMBER(10),
PERMITE_FER_PRIM_PER         CHAR(1),
PERMITE_FER_SEGUN_PER        CHAR(1),
ANOSXPROGRESSAO              VARCHAR2(100),
EMP_CODIGO                   NUMBER(2),
PERMITE_FER_TERC_PER         CHAR(1),
FLEX_CAMPO_01                VARCHAR2(2000),
FLEX_CAMPO_02                VARCHAR2(2000),
FLEX_CAMPO_03                VARCHAR2(2000),
FLEX_CAMPO_04                VARCHAR2(2000),
FLEX_CAMPO_05                VARCHAR2(2000),
FLEX_CAMPO_06                VARCHAR2(2000),
FLEX_CAMPO_07                VARCHAR2(2000),
FLEX_CAMPO_08                VARCHAR2(2000),
FLEX_CAMPO_09                VARCHAR2(2000),
FLEX_CAMPO_10                VARCHAR2(2000),
FLEX_CAMPO_11                VARCHAR2(2000),
FLEX_CAMPO_12                VARCHAR2(2000),
FLEX_CAMPO_13                VARCHAR2(2000),
FLEX_CAMPO_14                VARCHAR2(2000),
FLEX_CAMPO_15                VARCHAR2(2000),
FLEX_CAMPO_16                VARCHAR2(2000),
FLEX_CAMPO_17                VARCHAR2(2000),
FLEX_CAMPO_18                VARCHAR2(2000),
FLEX_CAMPO_19                VARCHAR2(2000),
FLEX_CAMPO_20                VARCHAR2(2000),
FLEX_CAMPO_21                VARCHAR2(2000),
FLEX_CAMPO_22                VARCHAR2(2000),
FLEX_CAMPO_23                VARCHAR2(2000),
FLEX_CAMPO_24                VARCHAR2(2000),
FLEX_CAMPO_25                VARCHAR2(2000),
FLEX_CAMPO_26                VARCHAR2(2000),
FLEX_CAMPO_27                VARCHAR2(2000),
FLEX_CAMPO_28                VARCHAR2(2000),
FLEX_CAMPO_29                VARCHAR2(2000),
FLEX_CAMPO_30                VARCHAR2(2000),
FLEX_CAMPO_31                VARCHAR2(2000),
FLEX_CAMPO_32                VARCHAR2(2000),
FLEX_CAMPO_33                VARCHAR2(2000),
FLEX_CAMPO_34                VARCHAR2(2000),
FLEX_CAMPO_35                VARCHAR2(2000),
FLEX_CAMPO_36                VARCHAR2(2000),
FLEX_CAMPO_37                VARCHAR2(2000),
FLEX_CAMPO_38                VARCHAR2(2000),
FLEX_CAMPO_39                VARCHAR2(2000),
FLEX_CAMPO_40                VARCHAR2(2000),
FLEX_CAMPO_41                VARCHAR2(2000),
FLEX_CAMPO_42                VARCHAR2(2000),
FLEX_CAMPO_43                VARCHAR2(2000),
FLEX_CAMPO_44                VARCHAR2(2000),
FLEX_CAMPO_45                VARCHAR2(2000),
FLEX_CAMPO_46                VARCHAR2(2000),
FLEX_CAMPO_47                VARCHAR2(2000),
FLEX_CAMPO_48                VARCHAR2(2000),
FLEX_CAMPO_49                VARCHAR2(2000),
FLEX_CAMPO_50                VARCHAR2(2000),
FLEX_CAMPO_51                VARCHAR2(2000),
FLEX_CAMPO_52                VARCHAR2(2000),
FLEX_CAMPO_53                VARCHAR2(2000),
FLEX_CAMPO_54                VARCHAR2(2000),
FLEX_CAMPO_55                VARCHAR2(2000),
FLEX_CAMPO_56                VARCHAR2(2000),
FLEX_CAMPO_57                VARCHAR2(2000),
FLEX_CAMPO_58                VARCHAR2(2000),
FLEX_CAMPO_59                VARCHAR2(2000),
FLEX_CAMPO_60                VARCHAR2(2000),
FLEX_CAMPO_61                VARCHAR2(2000),
FLEX_CAMPO_62                VARCHAR2(2000),
FLEX_CAMPO_63                VARCHAR2(2000),
FLEX_CAMPO_64                VARCHAR2(2000),
FLEX_CAMPO_65                VARCHAR2(2000),
CONTDOBROFERIAS              VARCHAR2(1),
MIN_DIAS_PERAQFER            NUMBER,
MAX_DIAS_PERAQFER            NUMBER,
EXIGE_EXERCICIO              VARCHAR2(1),
SEM_PGTO_MULTA               VARCHAR2(1),
PERMITE_GOZO_ANTES_PAFER     VARCHAR2(1),
PERMITE_LANC_CONC_PA         VARCHAR2(1),
PERMITE_GOZO_APOS_PRESCRICAO VARCHAR2(1),
FLEX_NCAMPO_01               NUMBER,
FLEX_NCAMPO_02               NUMBER,
FLEX_NCAMPO_03               NUMBER,
FLEX_NCAMPO_04               NUMBER,
FLEX_NCAMPO_05               NUMBER)
/

CREATE OR REPLACE TYPE UTIL_TYP_PARAM_CONTA_TAB
AS TABLE OF UTIL_TYP_PARAM_CONTA
/

