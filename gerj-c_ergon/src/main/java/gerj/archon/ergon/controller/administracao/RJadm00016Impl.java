package gerj.archon.ergon.controller.administracao;

import java.util.List;

import org.springframework.stereotype.Service;

import techne.control.description.parameter.DropDownSelectParameters;
import techne.control.description.parameter.LinkMethodParameters;
import techne.control.description.response.DescriptionResponse;
import techne.control.description.response.ListDescriptionResponse;

@Service("Administracao.RJadm00016")
public class RJadm00016Impl implements RJadm00016 {
	
	@Override
	public ListDescriptionResponse drpController(DropDownSelectParameters parameters,
			ListDescriptionResponse response) {

		/*
		 * REGRA O campo valor é acompanhado de títulos prefixo e sufixo. O
		 * campo valor tem dois comportamentos: ? Default ? apresenta um titulo
		 * (prefixo) - ?valor? e sufixo em branco. ? Parametrizado na tabela
		 * regras de PA ? consultar os títulos de prefixo e sufixo na tabela de
		 * regras de PA conforme a regra base selecionada. Os títulos devem ser
		 * apresentados no formato: xxxx 9,99 yyyy. Exemplo: percentual 9,99 %.
		 * Onde prefixo=percentual e sufixo=%.
		 * 
		 * 
		 * Campos apresentados: Valor ou percentual
		 * 
		 * Campo obrigatório; Tipo do campo: NUMERO; Se a base de pensão estiver
		 * parametrizada como "Valor Fixo" = S, então, o título deste campo deve
		 * ser: "Valor"; Se a base de pensão estiver parametrizada como
		 * "Valor Fixo" = N, então, o título deste campo deve ser: "Percentual";
		 * Se a base de pensão estiver parametrizada com "Prefixo" preenchido,
		 * então, o título deste campo deve ser o prefixo informado; Se a base
		 * de pensão estiver parametrizada com "Sufixo" preenchido, então, o
		 * sufixo informado deve aparecer após o campo.
		 */

		List<Object[]> objetos = response.getList();

		if (objetos != null) {

			if ("S".equals(objetos.get(0)[1])) {
				response.addHideCommand("txtSufixo");
				response.addSetCaptionCommand("txtValor", "Valor");
				response.addSetMaskCommand("txtValor", "decimal09d02");

			} else {
				response.addHideCommand("txtSufixo");
				response.addSetCaptionCommand("txtValor", "Percentual");
				response.addSetMaskCommand("txtValor", "decimal09d06");

			}

			if (objetos.get(0)[2] != null) {
				response.addSetCaptionCommand("txtValor", objetos.get(0)[2].toString());

			}

			if (objetos.get(0)[3] != null) {
				response.addShowCommand("txtSufixo");
				// comentado tarefa 60556
				// response.addSetCaptionCommand("txtSufixo",
				// objetos.get(0)[2].toString());
				response.addSetValueCommand("txtSufixo", objetos.get(0)[3].toString());
			}

		} else {
			response.addHideCommand("txtSufixo");
		}

		return response;
	}
	
	@Override
	public ListDescriptionResponse drpControlaView(DropDownSelectParameters parameters,
			ListDescriptionResponse response) {
		List<Object[]> objetos = response.getList();

		if (objetos != null) {

			if (objetos.get(0)[1].toString().equalsIgnoreCase("S") && (objetos.get(0)[3] == null)) {
				response.addSetCaptionCommand("txfPercentual", "Valor");
				response.addSetFormatCommand("txfPercentual", "decimal09d02");
			}

			if (objetos.get(0)[1].toString().equalsIgnoreCase("N") && (objetos.get(0)[3] == null)) {
				response.addSetCaptionCommand("txfPercentual", "Percentual");
				response.addSetFormatCommand("txfPercentual", "decimal09d06");
			}

			if ((objetos.get(0)[1].toString().equalsIgnoreCase("S")
					|| objetos.get(0)[1].toString().equalsIgnoreCase("N")) && (objetos.get(0)[3] != null)) {
				response.addSetCaptionCommand("txfPercentual", objetos.get(0)[3].toString());
			}

			if (objetos.get(0)[2] != null) {
				response.addSetCaptionCommand("txfSufixo", objetos.get(0)[2].toString());
				response.addShowCommand("txfSufixo");
			} else {
				response.addHideCommand("txfSufixo");
			}

		} else {
			response.addHideCommand("txfSufixo");
		}

		return response;

	}

	@Override
	public ListDescriptionResponse drpBase(DropDownSelectParameters parameters, ListDescriptionResponse response) {
		response.addHideCommand("txtSufixo");
		return response;
	}

	@Override
	public DescriptionResponse lkmAdiciona(LinkMethodParameters parameters, DescriptionResponse response) {

		response.addRefreshCommand("grdLista", true);
		response.addRefreshCommand("grdMesesreajuste", true);

		return response;
	}

	@Override
	public DescriptionResponse lkmRemove(LinkMethodParameters parameters, DescriptionResponse response) {

		response.addRefreshCommand("grdLista", true);
		response.addRefreshCommand("grdMesesreajuste", true);

		return response;
	}

}
