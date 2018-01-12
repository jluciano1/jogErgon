package gerj.archon.ergon.controller.administracao;

import java.text.Format;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

import org.springframework.stereotype.Service;

import techne.control.description.parameter.DropDownSelectParameters;
import techne.control.description.response.DescriptionResponse;
import techne.control.description.response.ListDescriptionResponse;
import techne.library.IPartialList;

@Service("Administracao.RJadm00039")
public class RJadm00039Impl implements RJadm00039 {
	
	@Override
	public DescriptionResponse ddsProcurarCPF(DropDownSelectParameters param, ListDescriptionResponse response)
	{
		response.addSetValueCommand("srcNumFuncPens", "");
		return PreencherCampos(param, response);
	}
	
	@Override
	public DescriptionResponse ddsProcurarDependente(DropDownSelectParameters param, ListDescriptionResponse response)
	{				
		return PreencherCampos(param, response);
	}

	private DescriptionResponse PreencherCampos(DropDownSelectParameters param, ListDescriptionResponse response)
	{
		IPartialList<Object[]> listResponse = response.getList();
		SimpleDateFormat fmt = new SimpleDateFormat("yyyy-MM-dd");    
		Format formatter = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss"); 
		
		if (listResponse != null) {
			Object[] receDados = listResponse.get(0); 

			if(ValidarDados(String.valueOf(receDados[0])))	{ response.addSetValueCommand("txtCPF",String.valueOf(receDados[0]));             } else {        response.addSetValueCommand("txtCPF","");                                       }
			if(ValidarDados(String.valueOf(receDados[1])))	{ response.addSetValueCommand("txtPessoa",String.valueOf(receDados[1]));          } else {           response.addSetValueCommand("txtPessoa","");                                 }
			if(ValidarDados(String.valueOf(receDados[3])))	{ response.addSetValueCommand("drpSexo",String.valueOf(receDados[3]));            } else {         response.addSetValueCommand("drpSexo","");                                     }
			if(ValidarDados(String.valueOf(receDados[4])))	{ response.addSetValueCommand("drpEstCivil",String.valueOf(receDados[4]));        } else {             response.addSetValueCommand("drpEstCivil","");                             }
			if(ValidarDados(String.valueOf(receDados[5])))	{ response.addSetValueCommand("drpTpLogradouro",String.valueOf(receDados[5]));    } else {                 response.addSetValueCommand("drpTpLogradouro","");                     }
			if(ValidarDados(String.valueOf(receDados[6])))	{ response.addSetValueCommand("txtLogradouro",String.valueOf(receDados[6]));      } else {               response.addSetValueCommand("txtLogradouro","");                         }
			if(ValidarDados(String.valueOf(receDados[7])))	{ response.addSetValueCommand("txtNumerolog",String.valueOf(receDados[7]));       } else {              response.addSetValueCommand("txtNumerolog","");                           }
			if(ValidarDados(String.valueOf(receDados[8])))	{ response.addSetValueCommand("txtComplemento",String.valueOf(receDados[8]));     } else {                response.addSetValueCommand("txtComplemento","");                       }
			if(ValidarDados(String.valueOf(receDados[9])))	{ response.addSetValueCommand("txtCEP",String.valueOf(receDados[9]));             } else {        response.addSetValueCommand("txtCEP","");                                       }
			if(ValidarDados(String.valueOf(receDados[10])))	{ response.addSetValueCommand("drpUF",String.valueOf(receDados[10]));             } else {        response.addSetValueCommand("drpUF","");                                        }
			if(ValidarDados(String.valueOf(receDados[11])))	{ response.addSetValueCommand("srcCidade",String.valueOf(receDados[11]));         } else {            response.addSetValueCommand("srcCidade","");                                }
			if(ValidarDados(String.valueOf(receDados[12])))	{ response.addSetValueCommand("txtBairro",String.valueOf(receDados[12]));         } else {            response.addSetValueCommand("txtBairro","");                                }
			if(ValidarDados(String.valueOf(receDados[13])))	{ response.addSetValueCommand("txbEmail",String.valueOf(receDados[13]));          } else {           response.addSetValueCommand("txbEmail","");                                  }
			if(ValidarDados(String.valueOf(receDados[14])))	{ response.addSetValueCommand("txtTelefone",String.valueOf(receDados[14]));       } else {              response.addSetValueCommand("txtTelefone","");                            }
			if(ValidarDados(String.valueOf(receDados[15])))	{ response.addSetValueCommand("txtTelefone2",String.valueOf(receDados[15]));      } else {               response.addSetValueCommand("txtTelefone2","");                          }
			if(ValidarDados(String.valueOf(receDados[16])))	{ response.addSetValueCommand("txbNomeMae",String.valueOf(receDados[16]));        } else {             response.addSetValueCommand("txbNomeMae","");                              }
			if(ValidarDados(String.valueOf(receDados[17])))	{ response.addSetValueCommand("txbNomePai",String.valueOf(receDados[17]));        } else {             response.addSetValueCommand("txbNomePai","");                              }
			try {
				Date data = fmt.parse(receDados[2].toString());
				String dataNasc = formatter.format(data);
				
				if(ValidarDados(dataNasc)) { response.addSetValueCommand("dtbNasc", dataNasc, true); } else { response.addSetValueCommand("dtbNasc", "", true); }
			} catch (ParseException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
				response.addSetValueCommand("dtbNasc", "", true); 
			}
		}
	
		return response;
	}

	private boolean ValidarDados(String texto) {
		if(texto.equalsIgnoreCase("null") || texto == null)
			return false;
				
		return true;
	}
}
