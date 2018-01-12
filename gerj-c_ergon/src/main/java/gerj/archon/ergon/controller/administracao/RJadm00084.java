package gerj.archon.ergon.controller.administracao;

import techne.control.description.parameter.DropDownSelectParameters;
import techne.control.description.response.ListDescriptionResponse;

public interface RJadm00084 {

	public ListDescriptionResponse drpTem(DropDownSelectParameters parameters,
			ListDescriptionResponse response);

	public ListDescriptionResponse drpLink(DropDownSelectParameters parameters,
			ListDescriptionResponse response);

	public ListDescriptionResponse drpAposentadoria(
			DropDownSelectParameters parameters,
			ListDescriptionResponse response);

	public ListDescriptionResponse drpAposentadoria2(
			DropDownSelectParameters parameters,
			ListDescriptionResponse response);

	public ListDescriptionResponse drpAposentadoria3(
			DropDownSelectParameters parameters,
			ListDescriptionResponse response);

	public ListDescriptionResponse drpRz(DropDownSelectParameters parameters,
			ListDescriptionResponse response);

	public ListDescriptionResponse drpRzA(DropDownSelectParameters parameters,
			ListDescriptionResponse response);

	public ListDescriptionResponse drpRzAP(DropDownSelectParameters parameters,
			ListDescriptionResponse response);

}
