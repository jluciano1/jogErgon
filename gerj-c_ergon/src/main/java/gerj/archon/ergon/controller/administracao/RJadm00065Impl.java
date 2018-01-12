package gerj.archon.ergon.controller.administracao;

import java.util.Map;

import org.springframework.stereotype.Service;

import techne.control.description.parameter.FileUploadParameters;
import techne.control.description.response.DescriptionResponse;
import techne.control.description.response.FileUploadDescriptionResponse;

@Service("Administracao.RJadm00065")
public class RJadm00065Impl implements RJadm00065 {

	@Override
	public DescriptionResponse fluArqErros(FileUploadParameters para,
			FileUploadDescriptionResponse resp) {
		// TODO Auto-generated method stub

		Map<String, Object> outParameters = resp.getOutParameters();
		
		//Sai do controller se o outParameters for nulo
		if (outParameters == null){
			return resp;
		}

		resp.addSetValueCommand("txtIdRotina",
				outParameters.get("P_ID_ROTINA_EXEC"));
		resp.addSetValueCommand("txtNomeArq",
				outParameters.get("P_NOME_RETORNO"));
		resp.addRefreshCommand("txtIdRotina");

		return resp;
	}

}
