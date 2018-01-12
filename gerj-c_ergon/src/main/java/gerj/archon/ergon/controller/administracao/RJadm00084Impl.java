package gerj.archon.ergon.controller.administracao;

import java.text.DecimalFormat;
import java.util.List;

import org.springframework.stereotype.Service;

import techne.control.description.parameter.DropDownSelectParameters;
import techne.control.description.response.ListDescriptionResponse;

@Service("Administracao.RJadm00084")
public class RJadm00084Impl implements RJadm00084 {

	public ListDescriptionResponse drpTem(DropDownSelectParameters parameters,
			ListDescriptionResponse response) {

		List<Object[]> obj = response.getList();

		response.addHideCommand("lkmAposentar");
		response.addHideCommand("lkmReabrir_apos");
		response.addHideCommand("lkmReverter_apos");
		response.addHideCommand("lkmRemove_apos");
		response.addHideCommand("btnExecA");
		response.addHideCommand("btnExecAP");

		if (obj != null) {
			if (Integer.parseInt(obj.get(0)[0].toString()) > 0) {
				response.addHideCommand("lkmAposentar");
				response.addShowCommand("lkmReabrir_apos");
				response.addShowCommand("lkmReverter_apos");
				response.addShowCommand("lkmRemove_apos");
				response.addShowCommand("btnExecA");
				response.addShowCommand("btnExecAP");
			} else {
				response.addShowCommand("lkmAposentar");
				response.addHideCommand("lkmReabrir_apos");
				response.addHideCommand("lkmReverter_apos");
				response.addHideCommand("lkmRemove_apos");
				response.addHideCommand("btnExecA");
				response.addHideCommand("btnExecAP");
			}
		}
		return response;

	}

	public ListDescriptionResponse drpLink(DropDownSelectParameters parameters,
			ListDescriptionResponse response) {

		List<Object[]> objetos = response.getList();

		if (objetos != null) {
			if (objetos.get(0)[0] != null) { // Tem aposentadoria
				if (objetos.get(0)[1] != null) { // Aposentadoria finalizada
					if (Integer.parseInt(objetos.get(0)[2].toString()) > 0) { // Tem
																				// outro
																				// registro
																				// de
																				// aposentadoria
						response.addHideCommand("lkmAposentar");
						response.addHideCommand("lkmReabrir_apos");
						response.addHideCommand("lkmReverter_apos");
						response.addHideCommand("lkmRemove_apos");
						response.addShowCommand("btnExecA");
						response.addHideCommand("btnExecAP");
					} else {
						response.addShowCommand("lkmAposentar");
						response.addShowCommand("lkmReabrir_apos");
						response.addHideCommand("lkmReverter_apos");
						response.addShowCommand("lkmRemove_apos");
						response.addShowCommand("btnExecA");
						response.addShowCommand("btnExecAP");
					}
				} else {
					response.addHideCommand("lkmAposentar");
					response.addHideCommand("lkmReabrir_apos");
					response.addShowCommand("lkmReverter_apos");
					response.addShowCommand("lkmRemove_apos");
					response.addShowCommand("btnExecA");
					response.addShowCommand("btnExecAP");
				}
			} else {
				response.addShowCommand("lkmAposentar");
				response.addHideCommand("lkmReabrir_apos");
				response.addHideCommand("lkmReverter_apos");
				response.addHideCommand("lkmRemove_apos");
				response.addHideCommand("btnExecA");
				response.addHideCommand("btnExecAP");
			}
		}
		return response;
	}

	public ListDescriptionResponse drpAposentadoria(
			DropDownSelectParameters parameters,
			ListDescriptionResponse response) {
		

		List<Object[]> obj = response.getList();

		response.addHideCommand("pnlDias");
		response.addSetValueCommand("txtAnoTrab", null);
		response.addSetValueCommand("txtDiasTrab", null);
		response.addSetValueCommand("txtAnoapos", null);

		response.addHideCommand("pnlFracao");
		response.addSetValueCommand("txtFracao1", null);
		response.addSetValueCommand("drpFracao1", null);
		response.addSetValueCommand("txtFracao2", null);
		response.addSetValueCommand("hidFracao1", null);

		if (obj != null) {
			if (obj.get(0)[0] != null) {
				if (obj.get(0)[1] != null) {
					if (obj.get(0)[1].toString().equalsIgnoreCase("A")) {
						response.addShowCommand("pnlDias");

						response.addHideCommand("pnlFracao");
						response.addSetValueCommand("drpFracao1", null);
						response.addSetValueCommand("txtFracao1", null);
						response.addSetValueCommand("hidFracao1", null);
						response.addSetValueCommand("txtFracao2", null);

					} else if (obj.get(0)[1].toString().equalsIgnoreCase("F")) {
						response.addHideCommand("pnlDias");
						response.addSetValueCommand("txtAnoTrab", null);
						response.addSetValueCommand("txtDiasTrab", null);
						response.addSetValueCommand("txtAnoapos", null);

						response.addShowCommand("pnlFracao");

						if (obj.get(0)[2] != null) {
							response.addShowCommand("drpFracao1");
							response.addHideCommand("txtFracao1");
							response.addSetValueCommand("txtFracao1", null);
						} else {
							response.addShowCommand("txtFracao1");
							response.addHideCommand("drpFracao1");
							response.addSetValueCommand("drpFracao1", null);
						}
					}
				}
			}
		}
		return response;
	}

	public ListDescriptionResponse drpAposentadoria2(
			DropDownSelectParameters parameters,
			ListDescriptionResponse response) {

		List<Object[]> obj = response.getList();

		response.addHideCommand("txtAnostrabA");
		response.addHideCommand("txtDiastrabA");
		response.addHideCommand("txtAnosaposA");
		response.addHideCommand("txtFracao1A");
		response.addHideCommand("drpFracao1A");
		response.addHideCommand("txtFracao2A");
		response.addHideCommand("txtRazao2");

		if (obj != null) {
			if (obj.get(0)[0] != null) {
				if (obj.get(0)[1] != null) {
					if (obj.get(0)[1].toString().equalsIgnoreCase("A")) {
						response.addShowCommand("txtAnostrabA");
						response.addShowCommand("txtDiastrabA");
						response.addShowCommand("txtAnosaposA");

						response.addHideCommand("txtFracao1A");
						response.addHideCommand("drpFracao1A");
						response.addHideCommand("txtFracao2A");
						response.addHideCommand("txtRazao2");
						response.addSetValueCommand("txtFracao1A", null);
						response.addSetValueCommand("drpFracao1A", null);
						response.addSetValueCommand("txtFracao2A", null);
						response.addSetValueCommand("txtRazao2", null);

					} else if (obj.get(0)[1].toString().equalsIgnoreCase("F")) {
						response.addHideCommand("txtAnostrabA");
						response.addHideCommand("txtDiastrabA");
						response.addHideCommand("txtAnosaposA");
						response.addSetValueCommand("txtAnostrabA", null);
						response.addSetValueCommand("txtDiastrabA", null);
						response.addSetValueCommand("txtAnosaposA", null);

						response.addShowCommand("txtFracao2A");
						response.addShowCommand("txtRazao2");

						if (obj.get(0)[2] != null) {
							response.addShowCommand("drpFracao1A");
							response.addHideCommand("txtFracao1A");
							response.addSetValueCommand("txtFracao1A", null);
						} else {
							response.addShowCommand("txtFracao1A");
							response.addHideCommand("drpFracao1A");
							response.addSetValueCommand("drpFracao1A", null);
						}
					}
				}
			}
		}

		return response;

	}

	public ListDescriptionResponse drpAposentadoria3(
			DropDownSelectParameters parameters,
			ListDescriptionResponse response) {

		List<Object[]> obj = response.getList();

		response.addHideCommand("txtAnostrabAP");
		response.addHideCommand("txtDiastrabAP");
		response.addHideCommand("txtAnosaposAP");
		response.addHideCommand("txtFracao1AP");
		response.addHideCommand("drpFracao1AP");
		response.addHideCommand("txtFracao2AP");
		response.addHideCommand("txtRazao2AP");

		if (obj != null) {
			if (obj.get(0)[0] != null) {
				if (obj.get(0)[1] != null) {
					if (obj.get(0)[1].toString().equalsIgnoreCase("A")) {
						response.addShowCommand("txtAnostrabAP");
						response.addShowCommand("txtDiastrabAP");
						response.addShowCommand("txtAnosaposAP");

						response.addHideCommand("txtFracao1AP");
						response.addHideCommand("drpFracao1AP");
						response.addHideCommand("txtFracao2AP");
						response.addHideCommand("txtRazao2AP");
						response.addSetValueCommand("txtFracao1AP", null);
						response.addSetValueCommand("drpFracao1AP", null);
						response.addSetValueCommand("txtFracao2AP", null);
						response.addSetValueCommand("txtRazao2AP", null);

					} else if (obj.get(0)[1].toString().equalsIgnoreCase("F")) {
						response.addHideCommand("txtAnostrabAP");
						response.addHideCommand("txtDiastrabAP");
						response.addHideCommand("txtAnosaposAP");
						response.addSetValueCommand("txtAnostrabAP", null);
						response.addSetValueCommand("txtDiastrabAP", null);
						response.addSetValueCommand("txtAnosaposAP", null);

						response.addShowCommand("txtFracao2AP");
						response.addShowCommand("txtRazao2AP");

						if (obj.get(0)[2] != null) {
							response.addShowCommand("drpFracao1AP");
							response.addHideCommand("txtFracao1AP");
							response.addSetValueCommand("txtFracao1AP", null);
						} else {
							response.addShowCommand("txtFracao1AP");
							response.addHideCommand("drpFracao1AP");
							response.addSetValueCommand("drpFracao1AP", null);
						}
					}
				}
			}
		}
		return response;
	}

	public ListDescriptionResponse drpRz(DropDownSelectParameters parameters,
			ListDescriptionResponse response) {
		List<Object[]> obj = response.getList();
		DecimalFormat df = new DecimalFormat("###,###,###.###");

		response.addSetValueCommand("txtRazao", "0");

		if (obj != null) {
			if (obj.get(0)[0] != null) {
				response.addSetValueCommand("txtRaz�o",
						df.format(Double.parseDouble(obj.get(0)[0].toString())));
				response.addRefreshCommand("txtRaz�o", true);
			}
		}
		return response;
	}

	public ListDescriptionResponse drpRzA(DropDownSelectParameters parameters,
			ListDescriptionResponse response) {
		List<Object[]> obj = response.getList();
		DecimalFormat df = new DecimalFormat("###,###,###.###");

		response.addSetValueCommand("txtRazao2", "0");

		if (obj != null) {
			if (obj.get(0)[0] != null) {
				response.addSetValueCommand("txtRazao2",
						df.format(Double.parseDouble(obj.get(0)[0].toString())));
				response.addRefreshCommand("txtRazao2", true);
			}
		}
		return response;
	}

	public ListDescriptionResponse drpRzAP(DropDownSelectParameters parameters,
			ListDescriptionResponse response) {
		List<Object[]> obj = response.getList();
		DecimalFormat df = new DecimalFormat("###,###,###.###");

		response.addSetValueCommand("txtRazao2AP", "0");

		if (obj != null) {
			if (obj.get(0)[0] != null) {
				response.addSetValueCommand("txtRazao2AP",
						df.format(Double.parseDouble(obj.get(0)[0].toString())));
				response.addRefreshCommand("txtRazao2AP", true);
			}
		}
		return response;
	}

}
