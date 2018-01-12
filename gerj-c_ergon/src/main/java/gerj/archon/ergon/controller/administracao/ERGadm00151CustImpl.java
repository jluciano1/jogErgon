package gerj.archon.ergon.controller.administracao;

import org.springframework.stereotype.Service;

import techne.control.description.parameter.DropDownSelectParameters;
import techne.control.description.response.DescriptionResponse;
import techne.control.description.response.ListDescriptionResponse;
import techne.library.IPartialList;

@Service("Administracao.ERGadm00151Cust")
public class ERGadm00151CustImpl implements ERGadm00151Cust {

	private ListDescriptionResponse trataCampos(ListDescriptionResponse resposta, String campoAbonoConstFer,
			String campoAdiantDTerc, String campoAdiantSalFer, String campoValor, String campoEmprestFer,
			String campoParcelas, boolean limpaValorCampo) {

		// Cria lista para armazenar as respostas do controle
		IPartialList<Object[]> valoresResponse = resposta.getList();

		// Preenche variáveis com os parâmetros de contagem retornados
		String abonoConstFer = "N";
		String adiant13Fer = "N";
		String adiantSalFer = "N";
		String emprestFer = "N";

		if (valoresResponse != null) {
			Object[] paramConta = valoresResponse.get(0);
			abonoConstFer = paramConta[0].toString();
			adiant13Fer = paramConta[1].toString();
			adiantSalFer = paramConta[2].toString();
			emprestFer = paramConta[3].toString();
		}

		// Tratamento dos campos dependentes de ABONOCONSTFER
		if (abonoConstFer.equals("S")) {
			resposta.addShowCommand(campoAbonoConstFer);
		} else {
			if (limpaValorCampo)
				resposta.addSetValueCommand(campoAbonoConstFer, "N");
			resposta.addHideCommand(campoAbonoConstFer);
		}

		// Tratamento dos campos dependentes de ADIANT13FER
		if (adiant13Fer.equals("S")) {
			resposta.addShowCommand(campoAdiantDTerc);
		} else {
			if (limpaValorCampo)
				resposta.addSetValueCommand(campoAdiantDTerc, "N");
			resposta.addHideCommand(campoAdiantDTerc);
		}

		// Tratamento dos campos dependentes de ADIANTSALFER
		if (adiantSalFer.equals("S")) {
			resposta.addShowCommand(campoAdiantSalFer);
			resposta.addShowCommand(campoValor);
		} else {
			if (limpaValorCampo) {
				resposta.addSetValueCommand(campoAdiantSalFer, "N");
				resposta.addSetValueCommand(campoValor, "");
			}
			resposta.addHideCommand(campoAdiantSalFer);
			resposta.addHideCommand(campoValor);
		}

		// Tratamento dos campos dependentes de EMPRESTFER
		if (emprestFer.equals("S")) {
			resposta.addShowCommand(campoEmprestFer);
			resposta.addShowCommand(campoParcelas);
		} else {
			if (limpaValorCampo) {
				resposta.addSetValueCommand(campoEmprestFer, "N");
				resposta.addSetValueCommand(campoParcelas, "");
			}
			resposta.addHideCommand(campoEmprestFer);
			resposta.addHideCommand(campoParcelas);
		}

		return resposta;

	}

	public DescriptionResponse ddsControllerRec1V(DropDownSelectParameters param, ListDescriptionResponse resp) {

		// Chama método de tratamento dos campos
		return trataCampos(resp, "txfAbonoconst", "txfAdiantdterc", "txfAdiantsal", "txfFlex04Valor", "txfEmprest",
				"txfFlex05Parcelas", false);

	}

	public DescriptionResponse ddsControllerRec1E(DropDownSelectParameters param, ListDescriptionResponse resp) {

		// Chama método de tratamento dos campos
		return trataCampos(resp, "chkAbonoconst", "chkAdiantdterc", "chkAdiantsal", "txbFlex04Valor", "chkEmprestimo",
				"txbFlex05Parcelas", true);

	}

}
