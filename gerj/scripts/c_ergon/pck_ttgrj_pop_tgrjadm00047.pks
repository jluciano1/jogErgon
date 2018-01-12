create or replace PACKAGE pck_ttgrj_pop_tgrjadm00047 IS
  --
  FUNCTION TTGRJ_POP_TGRJADM00047 (P_NUMFUNC      IN NUMBER,
                                   P_NUMVINC      IN NUMBER,
                                   P_NUMPENS      IN NUMBER,
								   P_DTFIM_PENS   IN DATE) RETURN TTGRJ_TYP_TGRJADM00047_TAB PIPELINED;

END PCK_TTGRJ_POP_TGRJADM00047;
/