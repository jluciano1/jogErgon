package gerj.archon.ergon.controller.administracao;

import java.util.List;

import org.springframework.stereotype.Service;

import techne.control.description.parameter.LinkMethodParameters;
import techne.control.description.response.DescriptionResponse;
import techne.control.description.response.ExecMethodResponse;

@Service("Administracao.RJadm00027")
public class RJadm00027Impl implements RJadm00027 {

	@Override
	public DescriptionResponse lkmExecRel(LinkMethodParameters param, ExecMethodResponse resp) {

		// TODO Auto-generated method stub

		List<Object[]> outParameters = resp.getValues();   //.getOutParameters();

		// Sai do controller se o outParameters for nulo
		if (outParameters == null) {
			return resp;
		}
		
		if (outParameters.get(0) == null) {
			return resp;
		}		

		if (outParameters.get(0)[1] != null){
			resp.addSetValueCommand("txbIdAgenda", outParameters.get(0)[1].toString());
		}
		
		if (outParameters.get(0)[2] != null){
			resp.addSetValueCommand("txbIdLote", outParameters.get(0)[2].toString());
		}		

		//resp.addRefreshCommand("txtIdRotina");

		return resp;
	}

}
