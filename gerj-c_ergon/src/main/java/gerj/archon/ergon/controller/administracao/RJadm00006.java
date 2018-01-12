package gerj.archon.ergon.controller.administracao;

import techne.control.description.parameter.DropDownSelectParameters;
import techne.control.description.parameter.QuerySelectParameters;
import techne.control.description.response.ListDescriptionResponse;
import techne.control.description.response.QueryDescriptionResponse;

public interface RJadm00006 {

	public ListDescriptionResponse drpControllerCEP(DropDownSelectParameters param, ListDescriptionResponse resp);

	public ListDescriptionResponse drpCidade(DropDownSelectParameters param, ListDescriptionResponse resp);

	public QueryDescriptionResponse grdServidor(QuerySelectParameters param, QueryDescriptionResponse resp);

}
