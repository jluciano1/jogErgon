package gerj.archon.ergon.controller.administracao;

import org.springframework.stereotype.Service;

import gerj.archon.ergon.util.FswUtil;
import techne.control.description.parameter.IDescriptionParameters;
import techne.control.description.response.QueryDescriptionResponse;

@Service("Administracao.ERGadm00269Cust")
public class ERGadm00269CustImpl implements ERGadm00269Cust {
	
	@SuppressWarnings("deprecation")
	@Override
	public QueryDescriptionResponse calculaTotais(IDescriptionParameters   param, QueryDescriptionResponse resp) {
		Integer somaPontos = 0;
		Integer somaRecons = 0;
		Integer somaRecurso = 0;
		if (resp.isSuccess()) {
			for (Object[] rec : resp.getRecords()) {
				if (rec[3] != null && FswUtil.isNumeric(rec[3].toString())) 
					somaPontos += Integer.parseInt(rec[3].toString());
	
				if (rec[4] != null && FswUtil.isNumeric(rec[4].toString())) 
					somaRecons += Integer.parseInt(rec[4].toString());
	
				if (rec[5] != null && FswUtil.isNumeric(rec[5].toString())) 
					somaRecurso += Integer.parseInt(rec[5].toString());
	
			}
		
			resp.addSetValueCommand("txbTotPontos", somaPontos);
			resp.addSetValueCommand("txbTotRecons", somaRecons);
			resp.addSetValueCommand("txbTotRecurso", somaRecurso);
			resp.addSetValueCommand("txbTotPontuacao", somaPontos + somaRecons + somaRecurso);
		}
		return resp;
	}

}