package gerj.archon.ergon.controller.administracao;

import org.springframework.stereotype.Service;

import techne.control.description.parameter.DropDownSelectParameters;
import techne.control.description.parameter.LinkMethodParameters;
import techne.control.description.response.DescriptionResponse;
import techne.control.description.response.ListDescriptionResponse;

@Service("Administracao.RJadm00016")
public interface RJadm00016 {
	
	public ListDescriptionResponse drpController(DropDownSelectParameters parameters, ListDescriptionResponse response);

	public ListDescriptionResponse drpControlaView(DropDownSelectParameters parameters, ListDescriptionResponse response);

	public ListDescriptionResponse drpBase(DropDownSelectParameters parameters, ListDescriptionResponse response);

	public DescriptionResponse lkmAdiciona(LinkMethodParameters parameters, DescriptionResponse response);

	public DescriptionResponse lkmRemove(LinkMethodParameters parameters, DescriptionResponse response);

}
