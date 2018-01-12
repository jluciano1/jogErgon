package gerj.archon.ergon.controller.administracao;

import org.springframework.stereotype.Service;

import gerj.archon.ergon.util.FswUtil;
import techne.control.description.parameter.IDescriptionParameters;
import techne.control.description.response.QueryDescriptionResponse;

@Service("Administracao.RJadm00043")
public class RJadm00043Impl implements RJadm00043 {
	
	@SuppressWarnings("deprecation")
	@Override
	public QueryDescriptionResponse calculaTotais(IDescriptionParameters   param, QueryDescriptionResponse resp) {
		Double somaBruto = 0.0;
		Double somaDesc = 0.0;
		Double somaLiq = 0.0;
		if (resp.isSuccess()) {
			for (Object[] rec : resp.getRecords()) {
				if (rec[3] != null && FswUtil.isNumeric(rec[6].toString())) 
					somaBruto += Double.parseDouble(rec[6].toString());
	
				if (rec[4] != null && FswUtil.isNumeric(rec[7].toString())) 
					somaDesc += Double.parseDouble(rec[7].toString());
	
				if (rec[5] != null && FswUtil.isNumeric(rec[8].toString())) 
					somaLiq += Double.parseDouble(rec[8].toString());
	
			}
		
			resp.addSetValueCommand("txbTotBruto", somaBruto);
			resp.addSetValueCommand("txbTotDesc", somaDesc);
			resp.addSetValueCommand("txbTotLiq", somaLiq);
		}
		return resp;
	}

}