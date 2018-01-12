package gerj.archon.ergon.controller.administracao;

import techne.control.description.parameter.DropDownSelectParameters;
import techne.control.description.response.DescriptionResponse;
import techne.control.description.response.ListDescriptionResponse;

public interface RJadm00039 {

	public DescriptionResponse ddsProcurarCPF(DropDownSelectParameters param, ListDescriptionResponse response);
	public DescriptionResponse ddsProcurarDependente(DropDownSelectParameters param, ListDescriptionResponse response);
}
