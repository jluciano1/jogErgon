package gerj.archon.ergon.controller.administracao;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;

import techne.Globals;
import techne.control.description.command.ShowMessageCommand;
import techne.control.description.parameter.DropDownSelectParameters;
import techne.control.description.parameter.QuerySelectParameters;
import techne.control.description.response.ListDescriptionResponse;
import techne.control.description.response.QueryDescriptionResponse;

@Service("Administracao.RJadm00006")
public class RJadm00006Impl implements RJadm00006 {

	@Override
	public ListDescriptionResponse drpControllerCEP(DropDownSelectParameters param, ListDescriptionResponse resp) {
		List<Object[]> objetos = resp.getList();

		if (objetos != null) {
			resp.addSetValueCommand("drpTipologender", objetos.get(0)[0].toString());
			resp.addSetValueCommand("txtNomelogender", objetos.get(0)[1].toString());
			resp.addSetValueCommand("txtBairro", objetos.get(0)[2].toString());
			resp.addSetValueCommand("drpCidadeender", objetos.get(0)[3].toString());
			resp.addSetValueCommand("drpUfender", objetos.get(0)[4].toString());
			return resp;
		}

		return resp;
	}

	@Override
	public ListDescriptionResponse drpCidade(DropDownSelectParameters param, ListDescriptionResponse resp) {
		String cidade = (String) param.getAttribute("cidade");
		if (cidade != null) {
			resp.addSetValueCommand("drpCidade", cidade);
			return resp;
		}
		return resp;
	}

	private Map<String, Object> messageWindow(String msg, String title, String icon){
		Map<String, Object> messageMap = new HashMap<String, Object>();
		messageMap.put("msg", msg);
		messageMap.put("title", title);
		messageMap.put("icon", icon);
		return messageMap;
	}
	
	@Override
	public QueryDescriptionResponse grdServidor(QuerySelectParameters param, QueryDescriptionResponse resp) {
		
		for (Object[] rec : resp.getRecords()) {

			String msg = "Favor orientar nos termos da Resolução SEPLAG 1.047/2013, alertando acerca da obrigatoriedade, prazo e possibilidade de suspensão de pagamento.";
			String title = "Servidor(a) não cadastrado(a) biometricamente.";
			String statBio;
			String dtBio;
			if (rec[0] != null && !rec[0].toString().trim().isEmpty()) {

				statBio = rec[0].toString().substring(0, 1).toUpperCase();
				dtBio = rec[0].toString().substring(2, 12);
				switch (statBio) {
				case "N":
					resp.addSetValueCommand("txfSituacaoBio", "NÃO CADASTRADO");
					resp.addSetValueCommand("txfDtCadBio", dtBio);
					resp.addShowMessageCommand(messageWindow(msg, title, ShowMessageCommand.WARNING_ICON));
				case "R":
					resp.addSetValueCommand("txfSituacaoBio", "REPROVADO");
					resp.addSetValueCommand("txfDtCadBio", dtBio);
					resp.addShowMessageCommand(messageWindow(msg, title, ShowMessageCommand.WARNING_ICON));
					break;
				case "G":
					resp.addSetValueCommand("txfSituacaoBio", "NÃO CADASTRADO");
					resp.addSetValueCommand("txfDtCadBio", dtBio);
					resp.addShowMessageCommand(messageWindow(msg, title, ShowMessageCommand.WARNING_ICON));
					break;
				case "A":
					resp.addSetValueCommand("txfSituacaoBio", "CADASTRADO");
					resp.addSetValueCommand("txfDtCadBio", dtBio);
					break;
				case "S":
					resp.addSetValueCommand("txfSituacaoBio", "NÃO CADASTRADO");
					resp.addSetValueCommand("txfDtCadBio", dtBio);
					resp.addShowMessageCommand(messageWindow(msg, title, ShowMessageCommand.WARNING_ICON));
					break;
				case "X":
					resp.addSetValueCommand("txfSituacaoBio", "NÃO CADASTRADO");
					resp.addSetValueCommand("txfDtCadBio", dtBio);
					resp.addShowMessageCommand(messageWindow(msg, title, ShowMessageCommand.WARNING_ICON));
					break;
				default:
					resp.addSetValueCommand("txfSituacaoBio", "Status da biometria não disponível");
					resp.addSetValueCommand("txfDtCadBio", "");
					break;

				}

			}
			
			if (rec[1] != null && !rec[0].toString().trim().isEmpty()){
				if (Globals.getRequestPrincipal().isPrivilegiado() == true){
					resp.addSetValueCommand("txfFlex60Aux", rec[1].toString());
				}
			}

		}
		return resp;
	}

}
