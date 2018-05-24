(function($app) {
	angular.module('page.controllers', []);

	app
			.controller(
					'trpv0056',
[                   '$scope',
                    '$sce',
                    '$http', 
                    '$rootScope', 
                    '$state', 
                    '$location', 
                    '$translate', 
                    '$timeout',
                    'Notification', 
                    'stripBarsFilter',
                    'GenericService',
                    'ReportService',
							function($scope, $sce, $http, $rootScope, $state, $location, $translate, $timeout, Notification, stripBarsFilter, GenericService, ReportService) {

								//Seta o ponteiro de publicação do registro corrente
                //Utilizado como callback na diretiva blkPont
                $scope.blkRefresh = function(pont, tipoPonteiro){
                  if(tipoPonteiro == "pontpubl")
                    listInativos.row.pontpubl = pont;
                  else if(tipoPonteiro == "pontlei")
                    listInativos.row.pontlei = pont;
                }
                
								
								
								//Array que ordena dinamicamente os parametros para a LOV
								$scope.ParamsLista            = new Array(12);
								$scope.organizaParamsLista    = organizaParamsLista;
								$scope.contarDiv              = contarDiv;
								$scope.setVantagem            = setVantagem;
								
								$scope.minutosHora            = minutosHora;
								$scope.horasMinutos           = horasMinutos;
								$scope.resetValues            = resetValues;
								$scope.sendTRPV0056           = sendTRPV0056;
								
								$scope.numfunc                = null;
                $scope.numvinc                = null;
								
								// DataSets das listas dinamicas
								$scope.listaValor1            = { data: [] };
								$scope.listaInfo1             = { data: [] };
								$scope.listaValor2            = { data: [] };
								$scope.listaInfo2             = { data: [] };
								$scope.listaValor3            = { data: [] };
								$scope.listaInfo3             = { data: [] };
								$scope.listaValor4            = { data: [] };
								$scope.listaInfo4             = { data: [] };
								$scope.listaValor5            = { data: [] };
								$scope.listaInfo5             = { data: [] };
								$scope.listaValor6            = { data: [] };
								$scope.listaInfo6             = { data: [] };
                
                
                // Watchers
                $scope.$watch(function() {
                  return $scope.blkVinc;
                }.bind($scope), function(blkVinc) {
                  if (blkVinc && typeof(blkVinc)==='object' && !angular.equals(blkVinc,{})) {
                    
                    $scope.numfunc              =  blkVinc.numfunc;
                    $scope.numvinc              =  blkVinc.numvinc; 
                  } 
                  
                });
                
               
								$scope.$watch(function() {
									return listInativos.active;
								}.bind($scope), function(blkVinc) {
								  if(listInativos.active.vantagens != null || listInativos.active.vantagens != undefined ){
								    atualizarListasValores();
								  }
								}, true);
                
                $scope.clearFilter = function() {
                  $scope.searchFilters.pdtini = null;
                  $scope.searchFilters.pdtfim = null;
                  $scope.searchFilters.patributo = null;
                }
                
                // Inicializa variáveis de filtro para que elas possam ser associadas a ui-selects encapsulados por directives
								$scope.searchFilters = function() {

									var pnumfunc              = null;
									var pchavevant            = null;
									var pnumvinc              = null;
									var pvantagens            = null;
									var pempresas             = null;
									var pdtini                = null;
									var pdtfim                = null;

									return this;
								}

								function minutosHora() {
									// converte minutos em horas minuto
									var converterHHMM = function minutoHora(
											dado) {

										var tempo = parseInt(dado);
										var hora = (tempo / 60);
										var minuto = tempo % 60;
										var resultado = parseInt(hora) + ":"
												+ minuto;
										if (resultado.length < 5) {
											var total = '0' + resultado;
										} else {
											var total = resultado;
										}

										dado = total;
										return dado;

									}
									// condições para que seja convertido valor hora para minuto e passado para o valor
            			if (listInativos.active.atributosValor !== null && listInativos.active.atributosValor !== undefined
            					&& listInativos.active.atributosValor.tipoValor === 'Horas_minutos') {
            				listInativos.active.valor = converterHHMM(listInativos.active.valor);
            			}
            			if (listInativos.active.atributosValor2 !== null && listInativos.active.atributosValor2 !== undefined
            					&& listInativos.active.atributosValor2.tipoValor === 'Horas_minutos') {
            				listInativos.active.valor2 = converterHHMM(listInativos.active.valor2);
            			}
            			if (listInativos.active.atributosValor3 !== null && listInativos.active.atributosValor3 !== undefined
            					&& listInativos.active.atributosValor3.tipoValor === 'Horas_minutos') {
            				listInativos.active.valor3 = converterHHMM(listInativos.active.valor3);
            			}
            			if (listInativos.active.atributosValor4 !== null && listInativos.active.atributosValor4 !== undefined
            					&& listInativos.active.atributosValor4.tipoValor === 'Horas_minutos') {
            				listInativos.active.valor4 = converterHHMM(listInativos.active.valor4);
            			}
            			if (listInativos.active.atributosValor5 !== null && listInativos.active.atributosValor5 !== undefined
            					&& listInativos.active.atributosValor5.tipoValor === 'Horas_minutos') {
            				listInativos.active.valor5 = converterHHMM(listInativos.active.valor5);
            			}
            			if (listInativos.active.atributosValor6 !== null && listInativos.active.atributosValor6 !== undefined
            					&& listInativos.active.atributosValor6.tipoValor === 'Horas_minutos') {
            				listInativos.active.valor6 = converterHHMM(listInativos.active.valor6);
            			}
								}

                function sendTRPV0056(form, datasource, attrEmpresa, blockVinc){
                    if (typeof(datasource.active.vantagens) === "undefined" || datasource.active.vantagens === null)
                    {
                      form.$valid = false;
                      form.$invalid = true;
                      
                      form.vantagens.$valid = false;
                      form.vantagens.$invalid = true;
                      form.vantagens.$error["required"] = true;
                    }
                    datasource.env = true;
                    blockVincEmpresa = null;
                    numvinc = {};
                    numfunc = {};
            
                    if((form.$valid)&&(!form.$pristine)){
                      if(blockVinc != null){
                        
                        numfunc.numero = blockVinc.numfunc;
                        numvinc.numero = blockVinc.numvinc;
                        
                        numvinc.numfunc = numfunc;
                        blockVincEmpresa = blockVinc.empresa;
            
                        datasource.active.numvinc = numvinc.numero;
                      }
                      
                      if(attrEmpresa != null) {
                        var empresa = {};
                        
                        // Se há empresa selecionada na página, inclui o código no header da requisição        
                        if (!((typeof Empresas === "undefined") || (typeof Empresas.active === "undefined") || (typeof Empresas.active.empresa === "undefined"))) {
                          empresa = Empresas.active;
                        } 
                        // Se há empresa específica selecionada na página, inclui o código no header da requisição        
                        else if (!((typeof EmpresasOpt === "undefined") || (typeof EmpresasOpt.active === "undefined") || (typeof EmpresasOpt.active.empresa === "undefined") || (EmpresasOpt.active.empresa === 0))) {
                          empresa = EmpresasOpt.active;
                        }
                        // Se há vínculo selecionado na página, inclui o código no header da requisição                
                        else if (blockVincEmpresa != null) {
                          empresa.empresa = parseInt(blockVincEmpresa);
                        }
                        // Se nenhuma empresa local à transação for encontrada, usa a empresa do usuário logado
                        else {
                          empresa = JSON.parse(sessionStorage.getItem("empresaUsuario"));
                        }
                        
                        datasource.active[attrEmpresa] = empresa.empresa;
                      }
                      horasMinutos(); 
                      datasource.post();
                      minutosHora();
                      datasource.env = false;
                    };
                  };
                
								// função de converter valor hora em minutos
								function horasMinutos(){
                  
									// converte horas minuto em minutos
									var converter = function conversao(valor) {
                    if( valor !== undefined && valor !== NaN ){
  										str = valor;
										  
										  if (str !== null && str !== undefined)
										  {
										    if(typeof(str) !== "number")
										    {
										      if( str.indexOf(":") > -1 ){ //Se há fração de horas
    										    res1 = str.split(":");
    										    data = new Date(0, 0, 0, res1[0],
      												res1[1], 0, 0);
      										  var resultado = parseInt( res1[0] ) * 60 + parseInt(  res1[1] );
      										  valor = resultado;
    										  }
      										else{ //Se não há fração de minutos, converte o valor de string a inteiro de minutos.
      										  var resultado = parseInt( str ) * 60 ;
      										  valor = resultado;
      										} 
										    }
										    else
										    {
										      valor = str;
										    }
										  }
  										return valor;
                    }
									}

            			// condições para que seja convertido valor hora para minuto e passado para o valor
            			if (listInativos.active.atributosValor !== null && listInativos.active.atributosValor !== undefined
            					&& listInativos.active.atributosValor.tipoValor === 'Horas_minutos') {
            				listInativos.active.valor = converter(listInativos.active.valor);
            			} 
            			if (listInativos.active.atributosValor2 !== null && listInativos.active.atributosValor2 !== undefined
            					&& listInativos.active.atributosValor2.tipoValor === 'Horas_minutos') {
            				listInativos.active.valor2 = converter(listInativos.active.valor2);
            			} 
            			if (listInativos.active.atributosValor3 !== null && listInativos.active.atributosValor3 !== undefined
            					&& listInativos.active.atributosValor3.tipoValor === 'Horas_minutos') {
            				listInativos.active.valor3 = converter(listInativos.active.valor3);
            			} 
            			if (listInativos.active.atributosValor4 !== null && listInativos.active.atributosValor4 !== undefined
            					&& listInativos.active.atributosValor4.tipoValor === 'Horas_minutos') {
            				listInativos.active.valor4 = converter(listInativos.active.valor4);
            			}
            			if (listInativos.active.atributosValor5 !== null && listInativos.active.atributosValor5 !== undefined
            					&& listInativos.active.atributosValor5.tipoValor === 'Horas_minutos') {
            				listInativos.active.valor5 = converter(listInativos.active.valor5);
            			}
            			if (listInativos.active.atributosValor6 !== null && listInativos.active.atributosValor6 !== undefined
            					&& listInativos.active.atributosValor6.tipoValor === 'Horas_minutos') {
            				listInativos.active.valor6 = converter(listInativos.active.valor6);
            			}
								}

								// função para limpar dados assim que o formulário é alterado ou atribuir valor default
								function resetValues() {

									if (listInativos.active.atributosInfo !== undefined && listInativos.active.atributosInfo !== null) {
										if (listInativos.active.atributosInfo.atributosInfo === null || listInativos.active.atributosInfo.atributosInfo === undefined) {
											listInativos.active.info = null;
										} else {
											listInativos.active.info = listInativos.active.atributosInfo.atributosInfo.defaultValorInfo;
										}
										if (listInativos.active.atributosInfo.atributosValor === null || listInativos.active.atributosInfo.atributosValor === undefined) {
											listInativos.active.valor = null;
										} else {
											listInativos.active.valor = listInativos.active.atributosInfo.atributosValor.defaultValorInfo;
										}
										if (listInativos.active.atributosInfo.atributosInfo2 === null || listInativos.active.atributosInfo.atributosInfo2 === undefined) {
											listInativos.active.info2 = null;
										} else {
											listInativos.active.info2 = listInativos.active.atributosInfo.atributosInfo2.defaultValorInfo;
										}
										if (listInativos.active.atributosInfo.atributosValor2 === null || listInativos.active.atributosInfo.atributosValor2 === undefined) {
											listInativos.active.valor2 = null;
										} else {
											listInativos.active.valor2 = listInativos.active.atributosInfo.atributosValor2.defaultValorInfo;
										}
										if (listInativos.active.atributosInfo.atributosInfo3 === null || listInativos.active.atributosInfo.atributosInfo3 === undefined) {
											listInativos.active.info3 = null;
										} else {
											listInativos.active.info3 = listInativos.active.atributosInfo.atributosInfo3.defaultValorInfo;
										}
										if (listInativos.active.atributosInfo.atributosValor3 === null || listInativos.active.atributosInfo.atributosValor3 === undefined) {
											listInativos.active.valor3 = null;
										} else {
											listInativos.active.valor3 = listInativos.active.atributosInfo.atributosValor3.defaultValorInfo;
										}

										if (listInativos.active.atributosInfo.atributosInfo4 === null || listInativos.active.atributosInfo.atributosInfo4 === undefined) {
											listInativos.active.info4 = null;
										} else {
											listInativos.active.info4 = listInativos.active.atributosInfo.atributosInfo4.defaultValorInfo;
										}
										if (listInativos.active.atributosInfo.atributosValor4 === null || listInativos.active.atributosInfo.atributosValor4 === undefined) {
											listInativos.active.valor4 = null;
										} else {
											listInativos.active.valor4 = listInativos.active.atributosInfo.atributosValor4.defaultValorInfo;
										}
										if (listInativos.active.atributosInfo.atributosInfo5 === null || listInativos.active.atributosInfo.atributosInfo5 === undefined) {
											listInativos.active.info5 = null;
										} else {
											listInativos.active.info5 = listInativos.active.atributosInfo.atributosInfo5.defaultValorInfo;
										}
										if (listInativos.active.atributosInfo.atributosValor5 === null || listInativos.active.atributosInfo.atributosValor5 === undefined) {
											listInativos.active.valor5 = null;
										} else {
											listInativos.active.valor5 = listInativos.active.atributosInfo.atributosValor5.defaultValorInfo;
										}
										if (listInativos.active.atributosInfo.atributosInfo6 === null || listInativos.active.atributosInfo.atributosInfo6 === undefined) {
											listInativos.active.info6 = null;
										} else {
											listInativos.active.info6 = listInativos.active.atributosInfo.atributosInfo.defaultValorInfo;
										}
										if (listInativos.active.atributosInfo.atributosValor6 === null || listInativos.active.atributosInfo.atributosValor6 === undefined) {
											listInativos.active.valor6 = null;
										} else {
											listInativos.active.valor6 = listInativos.active.atributosInfo.atributosValor6.defaultValorInfo;
										}
									}
									listInativos.active.dtini = null;
									listInativos.active.dtfim = null;
									listInativos.active.obs = null;

								}

								//função que ordena div de acordo com o número de contagem do menor para o maior
								$scope.ordenarValores = function() {

									$(".infoval")
											.each(
													function() {
														var contagemThis = $(
																this).attr(
																"contagem");
														var teste = $(this)
																.attr("elista");

														if (teste === "S"
																|| teste === "N") {

															var contagemFirst = $(
																	this)
																	.parent()
																	.find(
																			'.infoval:first')
																	.attr(
																			"contagem");
															var contagemFirstNext = $(
																	this)
																	.parent()
																	.find(
																			'.infoval:first')
																	.next()
																	.attr(
																			"contagem");

															if (parseInt(contagemFirst) > parseInt(contagemThis)) {
																$(this)
																		.parent()
																		.find(
																				'.infoval:first')
																		.before(
																				$(this));
															}

															if (parseInt(contagemFirst) < parseInt(contagemThis)
																	&& parseInt(contagemFirstNext) > parseInt(contagemThis)) {
																$(this)
																		.parent()
																		.find(
																				'.infoval:first')
																		.next()
																		.before(
																				$(this));
															}
														}

													});

								}	
                //Atribui a estrutura de vantagens na raiz do escopo.
                function setVantagem(vantagem){
                  //configura como o active do datasource o atributo selecionado
                  if (typeof(listInativos.active) !== "undefined" && listInativos.active !== null
                  && typeof(vantagem) !== "undefined" && vantagem !== null)
                  {
                    listInativos.active.atributosInfo     = vantagem.atributosInfo;
                    listInativos.active.atributosInfo2    = vantagem.atributosInfo2;
                    listInativos.active.atributosInfo3    = vantagem.atributosInfo3;
                    listInativos.active.atributosInfo4    = vantagem.atributosInfo4;
                    listInativos.active.atributosInfo5    = vantagem.atributosInfo5;
                    listInativos.active.atributosInfo6    = vantagem.atributosInfo6;
                    
                    listInativos.active.atributosValor    = vantagem.atributosValor;
                    listInativos.active.atributosValor2   = vantagem.atributosValor2;
                    listInativos.active.atributosValor3   = vantagem.atributosValor3;
                    listInativos.active.atributosValor4   = vantagem.atributosValor4;
                    listInativos.active.atributosValor5   = vantagem.atributosValor5;
                    listInativos.active.atributosValor6   = vantagem.atributosValor6; 
                  }
                }

								// conta quantidade de div e coloca dentro do atributo lista do html
								function contarDiv() {

									// criando lista para condição
									var quantidades = document
											.querySelectorAll("#pai .infoval .condiction");

									for (var b = 0; b < quantidades.length; b++) {

										var quantidade = quantidades[b];

										quantidade.setAttribute('lista', b + 1);

									}

									// colocar resultado em variavel
									if (document
											.getElementsByName("informacao")[0] != null) {
										if (typeof(document.getElementsByName("informacao")[0]) !== "undefined")
										{
										  var info1 = document
												.getElementsByName("informacao")[0]
												.getAttribute("lista");  
										}
									}
									if (document
											.getElementsByName("informacao")[0] != null) {
										if (typeof(document.getElementsByName("valor")[0]) !== "undefined")
										{
										  var val1 = document
												.getElementsByName("valor")[0]
												.getAttribute("lista");
										}
									}
									if (document
											.getElementsByName("informacao2")[0] != null) {
										if (typeof(document.getElementsByName("informacao2")[0]) !== "undefined")
										{
										  var info2 = document
												.getElementsByName("informacao2")[0]
												.getAttribute("lista");
										}
									}
									if (document.getElementsByName("valor2")[0] != null) {
										if (typeof(document.getElementsByName("valor2")[0]) !== "undefined")
										{
										  var val2 = document
												.getElementsByName("valor2")[0]
												.getAttribute("lista");
										}
									}
									if (document
											.getElementsByName("informacao3")[0] != null) {
										if (typeof(document.getElementsByName("informacao3")[0]) !== "undefined")
										{
										  var info3 = document
												.getElementsByName("informacao3")[0]
												.getAttribute("lista");
										}
									}
									if (document.getElementsByName("valor3")[0] != null) {
										if (typeof(document.getElementsByName("valor3")[0]) !== "undefined")
										{
										  var val3 = document
												.getElementsByName("valor3")[0]
												.getAttribute("lista");
										}
									}
									if (document
											.getElementsByName("informacao4")[0] != null) {
										if (typeof(document.getElementsByName("informacao4")[0]) !== "undefined")
										{
										  var info4 = document
												.getElementsByName("informacao4")[0]
												.getAttribute("lista");
										}
									}
									if (document.getElementsByName("valor4")[0] != null) {
										if (typeof(document.getElementsByName("valor4")[0]) !== "undefined")
										{
										  var val4 = document
												.getElementsByName("valor4")[0]
												.getAttribute("lista");
										}
									}
									if (document
											.getElementsByName("informacao5")[0] != null) {
										if (typeof(document.getElementsByName("informacao5")[0]) !== "undefined")
										{
										  var info5 = document
												.getElementsByName("informacao5")[0]
												.getAttribute("lista");
										}
									}
									if (document.getElementsByName("valor5")[0] != null) {
										if (typeof(document.getElementsByName("valor5")[0]) !== "undefined")
										{
										  var val5 = document
												.getElementsByName("valor5")[0]
												.getAttribute("lista");
										}
									}
									if (document
											.getElementsByName("informacao6")[0] != null) {
										if (typeof(document.getElementsByName("informacao6")[0]) !== "undefined")
										{
										  var info6 = document
												.getElementsByName("informacao6")[0]
												.getAttribute("lista");
										}
									}
									if (document.getElementsByName("valor6")[0] != null) {
										if (typeof(document.getElementsByName("valor6")[0]) !== "undefined")
										{
										  var val6 = document
												.getElementsByName("valor6")[0]
												.getAttribute("lista");
										}
									}

									// acrescentando resultado no atributo para REST
									listInativos.active.seqDivInfo1 = info1;
									listInativos.active.seqDivVal1 = val1;
									listInativos.active.seqDivInfo2 = info2;
									listInativos.active.seqDivVal2 = val2;
									listInativos.active.seqDivInfo3 = info3;
									listInativos.active.seqDivVal3 = val3;
									listInativos.active.seqDivInfo4 = info4;
									listInativos.active.seqDivVal4 = val4;
									listInativos.active.seqDivInfo5 = info5;
									listInativos.active.seqDivVal5 = val5;
									listInativos.active.seqDivInfo6 = info6;
									listInativos.active.seqDivVal6 = val6;

									

								}

								//organiza em uma array os parametros para serem passados na LOV
								function organizaParamsLista() {

									$scope.ParamsLista = new Array(12);

                  $scope.ParamsLista[listInativos.active.seqDivInfo1 - 1] = (listInativos.active.info === undefined) ? null : listInativos.active.info;
									$scope.ParamsLista[listInativos.active.seqDivInfo2 - 1] = (listInativos.active.info2 === undefined) ? null : listInativos.active.info2;
									$scope.ParamsLista[listInativos.active.seqDivInfo3 - 1] = (listInativos.active.info3 === undefined) ? null : listInativos.active.info3;
									$scope.ParamsLista[listInativos.active.seqDivInfo4 - 1] = (listInativos.active.info4 === undefined) ? null : listInativos.active.info4;
									$scope.ParamsLista[listInativos.active.seqDivInfo5 - 1] = (listInativos.active.info5 === undefined) ? null : listInativos.active.info5;
									$scope.ParamsLista[listInativos.active.seqDivInfo6 - 1] = (listInativos.active.info6 === undefined) ? null : listInativos.active.info6;

									$scope.ParamsLista[listInativos.active.seqDivVal1 - 1] = (listInativos.active.valor === undefined) ? null : listInativos.active.valor;
									$scope.ParamsLista[listInativos.active.seqDivVal2 - 1] = (listInativos.active.valor2 === undefined) ? null : listInativos.active.valor2;
									$scope.ParamsLista[listInativos.active.seqDivVal3 - 1] = (listInativos.active.valor3 === undefined) ? null : listInativos.active.valor3;
									$scope.ParamsLista[listInativos.active.seqDivVal4 - 1] = (listInativos.active.valor4 === undefined) ? null : listInativos.active.valor4;
									$scope.ParamsLista[listInativos.active.seqDivVal5 - 1] = (listInativos.active.valor5 === undefined) ? null : listInativos.active.valor5;
									$scope.ParamsLista[listInativos.active.seqDivVal6 - 1] = (listInativos.active.valor6 === undefined) ? null : listInativos.active.valor6;
									
									
									//Limpa a array tirando os undefined para n~ão passar valor errado para a procedure.
									
									$scope.ParamsLista[0] = ($scope.ParamsLista[0] === undefined) ? null : $scope.ParamsLista[0];
									$scope.ParamsLista[1] = ($scope.ParamsLista[1] === undefined) ? null : $scope.ParamsLista[1];
									$scope.ParamsLista[2] = ($scope.ParamsLista[2] === undefined) ? null : $scope.ParamsLista[2];
									$scope.ParamsLista[3] = ($scope.ParamsLista[3] === undefined) ? null : $scope.ParamsLista[3];
									$scope.ParamsLista[4] = ($scope.ParamsLista[4] === undefined) ? null : $scope.ParamsLista[4];
									$scope.ParamsLista[5] = ($scope.ParamsLista[5] === undefined) ? null : $scope.ParamsLista[5];
									$scope.ParamsLista[6] = ($scope.ParamsLista[6] === undefined) ? null : $scope.ParamsLista[6];
									$scope.ParamsLista[7] = ($scope.ParamsLista[7] === undefined) ? null : $scope.ParamsLista[7];
									$scope.ParamsLista[8] = ($scope.ParamsLista[8] === undefined) ? null : $scope.ParamsLista[8];
									$scope.ParamsLista[9] = ($scope.ParamsLista[9] === undefined) ? null : $scope.ParamsLista[9];
									$scope.ParamsLista[10] = ($scope.ParamsLista[10] === undefined) ? null : $scope.ParamsLista[10];
									$scope.ParamsLista[11] = ($scope.ParamsLista[11] === undefined) ? null : $scope.ParamsLista[11];

								}

								function trataErro(data) {
									//Tratamento unificado de erro de request HTTP
									var error = "";
									if (data) {
										if (Object.prototype.toString
												.call(data) === "[object String]") {
											error = data;
										} else {
											var errorMsg = (data.msg
													|| data.desc
													|| data.message
													|| data.error || data.responseText);
											if (errorMsg) {
												error = errorMsg;
											}
										}
									}
									if (!error) {
										error = "Erro";
									}
									var regex = /<h1>(.*)<\/h1>/gmi;
									result = regex.exec(error);
									if (result && result.length >= 2) {
										error = result[1];
									}
									showError({
										name : "Bad Request",
										message : error
									})
								}

								function showError(e) {
									if (!e.hasOwnProperty('message')) {
										e.message = 'Erro não tratado';
									}
									if (!e.hasOwnProperty('title')) {
										if (e.hasOwnProperty('name')) {
											e.title = e.name;
										} else {
											e.title = 'Erro não tratado';
										}
									}
									if (!e.hasOwnProperty('delay')) {
										e.delay = 5000;
									}

									Notification.error(e);
									resetViewState();
									populaCertidoes();
								}

								function showWarning(e) {
									if (!e.hasOwnProperty('message')) {
										e.message = 'Operação não realizada';
									}
									if (!e.hasOwnProperty('title')) {
										if (e.hasOwnProperty('name')) {
											e.title = e.name;
										} else {
											e.title = 'Um erro não tratado impediu a operação';
										}
									}
									if (!e.hasOwnProperty('delay')) {
										e.delay = 5000;
									}

									Notification.warning(e);
								}
                
                //Popula os datasets das listas dinamicas
								function populaListaInfo1() {
								  if( listInativos.active.seqDivInfo1 !== undefined){
								  var seqinfo1 = 0;
								  if (listInativos.active.atributosInfo !== null && listInativos.active.atributosInfo !== undefined)
								  {
								    seqinfo1 = (listInativos.active.atributosInfo.campoVantIndexado !== undefined && listInativos.active.atributosInfo.campoVantIndexado !== null ? listInativos.active.atributosInfo.campoVantIndexado : ( listInativos.active.atributosInfo.seq === undefined ) ? listInativos.active.atributosInfo.atributosInfo.seq : listInativos.active.atributosInfo.seq );
								  }
  								  
  									GenericService
  											.getData(
  													(window.hostApp || "")
  															
  															+ "api/rest/ergon/Vantagens/listaValoresAtributos"
  															+ "?numfunc="         + $scope.numfunc + "&numvinc=" + $scope.numvinc
  															+ "&vantagem="    + listInativos.active.vantagens
  															+ "&pcampovant="  + seqinfo1
  															+ "&dtini="       + (listInativos.active.dtini !== null && listInativos.active.dtini !== undefined ? listInativos.active.dtini.substring(8,10)  + "/" + listInativos.active.dtini.substring(5,7) + "/" + listInativos.active.dtini.substring(0,4) : "")
  															+ "&dtfim="       + (listInativos.active.dtfim !== null && listInativos.active.dtfim !== undefined ? listInativos.active.dtfim.substring(8,10)  + "/" + listInativos.active.dtfim.substring(5,7) + "/" + listInativos.active.dtfim.substring(0,4) : "")
  															+ "&valor01="     + $scope.ParamsLista[0] 
  															+ "&valor02="     + $scope.ParamsLista[1] 
  															+ "&valor03="     + $scope.ParamsLista[2] 
  															+ "&valor04="     + $scope.ParamsLista[3] 
  															+ "&valor05="     + $scope.ParamsLista[4] 
  															+ "&valor06="     + $scope.ParamsLista[5] 
  															+ "&valor07="     + $scope.ParamsLista[6] 
  															+ "&valor08="     + $scope.ParamsLista[7] 
  															+ "&valor09="     + $scope.ParamsLista[8] 
  															+ "&valor10="     + $scope.ParamsLista[9] 
  															+ "&valor11="     + $scope.ParamsLista[10] 
  															+ "&valor12="     + $scope.ParamsLista[11] 
  															)
  											.then(
  													//success
  													function(response) {
  														$scope.listaInfo1 = {
  															data : []
  														};
  														$scope.listaInfo1.data = response;
  
  													},
  													//failure
  													function(response) {
  														Notification.error("Ocorreu um erro na consulta das listas dinamicas do atributo info1");
  													});
								  }
								}
								function populaListaInfo2() {
								  
								  if( listInativos.active.seqDivInfo2 !== undefined){
								  var seqinfo2 = 0;
  								  // define qual o campovant do info 2
  								if (listInativos.active.atributosInfo !== null && listInativos.active.atributosInfo !== undefined)
								  {
  								  seqinfo2 = (listInativos.active.atributosInfo2.campoVantIndexado !== undefined && listInativos.active.atributosInfo2.campoVantIndexado ? listInativos.active.atributosInfo2.campoVantIndexado : ( listInativos.active.atributosInfo2.seq === undefined ) ? listInativos.active.atributosInfo.atributosInfo2.seq : listInativos.active.atributosInfo2.seq );
								  } 
  								  
  									GenericService
  											.getData(
  													(window.hostApp || "")
  															+ "api/rest/ergon/Vantagens/listaValoresAtributos"
  															+ "?numfunc="         + $scope.numfunc + "&numvinc=" + $scope.numvinc
  															+ "&vantagem="    + listInativos.active.vantagens
  															+ "&pcampovant="  + seqinfo2
  															+ "&dtini="       + (listInativos.active.dtini !== null && listInativos.active.dtini !== undefined ? listInativos.active.dtini.substring(8,10)  + "/" + listInativos.active.dtini.substring(5,7) + "/" + listInativos.active.dtini.substring(0,4) : "")
  															+ "&dtfim="       + (listInativos.active.dtfim !== null && listInativos.active.dtfim !== undefined ? listInativos.active.dtfim.substring(8,10)  + "/" + listInativos.active.dtfim.substring(5,7) + "/" + listInativos.active.dtfim.substring(0,4) : "")
  															+ "&valor01="     + $scope.ParamsLista[0] 
  															+ "&valor02="     + $scope.ParamsLista[1] 
  															+ "&valor03="     + $scope.ParamsLista[2] 
  															+ "&valor04="     + $scope.ParamsLista[3] 
  															+ "&valor05="     + $scope.ParamsLista[4] 
  															+ "&valor06="     + $scope.ParamsLista[5] 
  															+ "&valor07="     + $scope.ParamsLista[6] 
  															+ "&valor08="     + $scope.ParamsLista[7] 
  															+ "&valor09="     + $scope.ParamsLista[8] 
  															+ "&valor10="     + $scope.ParamsLista[9] 
  															+ "&valor11="     + $scope.ParamsLista[10] 
  															+ "&valor12="     + $scope.ParamsLista[11] 														)
  											.then(
  													//success
  													function(response) {
  														
  														$scope.listaInfo2.data = response;
  
  													},
  													//failure
  													function(response) {
  														Notification.error("Ocorreu um erro na consulta das listas dinamicas do atributo info2");
  													});
								  }
								}
								function populaListaInfo3() {
								  
								  if( listInativos.active.seqDivInfo3 !== undefined){
								  var seqinfo3 = 0;
  								  // define qual o campovant do info 3
  								 if (listInativos.active.atributosInfo !== null && listInativos.active.atributosInfo !== undefined)
								  {
  								  seqinfo3 = (listInativos.active.atributosInfo3.campoVantIndexado !== undefined && listInativos.active.atributosInfo3.campoVantIndexado !== null ? listInativos.active.atributosInfo3.campoVantIndexado : ( listInativos.active.atributosInfo3.seq === undefined ) ? listInativos.active.atributosInfo.atributosInfo3.seq : listInativos.active.atributosInfo3.seq );
								  } 
  								  
  									GenericService
  											.getData(
  													(window.hostApp || "")
  															+ "api/rest/ergon/Vantagens/listaValoresAtributos"
  															+ "?numfunc="         + $scope.numfunc + "&numvinc=" + $scope.numvinc
  															+ "&vantagem="    + listInativos.active.vantagens
  															+ "&pcampovant="  + seqinfo3
  															+ "&dtini="       + (listInativos.active.dtini !== null && listInativos.active.dtini !== undefined ? listInativos.active.dtini.substring(8,10)  + "/" + listInativos.active.dtini.substring(5,7) + "/" + listInativos.active.dtini.substring(0,4) : "")
  															+ "&dtfim="       + (listInativos.active.dtfim !== null && listInativos.active.dtfim !== undefined ? listInativos.active.dtfim.substring(8,10)  + "/" + listInativos.active.dtfim.substring(5,7) + "/" + listInativos.active.dtfim.substring(0,4) : "")
  															+ "&valor01="     + $scope.ParamsLista[0] 
  															+ "&valor02="     + $scope.ParamsLista[1] 
  															+ "&valor03="     + $scope.ParamsLista[2] 
  															+ "&valor04="     + $scope.ParamsLista[3] 
  															+ "&valor05="     + $scope.ParamsLista[4] 
  															+ "&valor06="     + $scope.ParamsLista[5] 
  															+ "&valor07="     + $scope.ParamsLista[6] 
  															+ "&valor08="     + $scope.ParamsLista[7] 
  															+ "&valor09="     + $scope.ParamsLista[8] 
  															+ "&valor10="     + $scope.ParamsLista[9] 
  															+ "&valor11="     + $scope.ParamsLista[10] 
  															+ "&valor12="     + $scope.ParamsLista[11] 
  															)
  											.then(
  													//success
  													function(response) {
  														
  														$scope.listaInfo3.data = response;
  
  													},
  													//failure
  													function(response) {
  														Notification.error("Ocorreu um erro na consulta das listas dinamicas do atributo info3");
  													});
								  }
								}
								function populaListaInfo4() {
								  
								  if( listInativos.active.seqDivInfo4 !== undefined){
								  var seqinfo4 = 0;
  								  // define qual o campovant do info 4
  								 if (listInativos.active.atributosInfo !== null && listInativos.active.atributosInfo !== undefined)
								  {
  								  seqinfo4 = (listInativos.active.atributosInfo4.campoVantIndexado !== undefined && listInativos.active.atributosInfo4.campoVantIndexado !== null ? listInativos.active.atributosInfo4.campoVantIndexado : ( listInativos.active.atributosInfo4.seq === undefined ) ? listInativos.active.atributosInfo.atributosInfo4.seq : listInativos.active.atributosInfo4.seq );
								  } 
  								  GenericService
  											.getData(
  													(window.hostApp || "")
  															+ "api/rest/ergon/Vantagens/listaValoresAtributos"
  															+ "?numfunc="         + $scope.numfunc + "&numvinc=" + $scope.numvinc
  															+ "&vantagem="    + listInativos.active.vantagens
  															+ "&pcampovant="  + seqinfo4
  															+ "&dtini="       + (listInativos.active.dtini !== null && listInativos.active.dtini !== undefined ? listInativos.active.dtini.substring(8,10)  + "/" + listInativos.active.dtini.substring(5,7) + "/" + listInativos.active.dtini.substring(0,4) : "")
  															+ "&dtfim="       + (listInativos.active.dtfim !== null && listInativos.active.dtfim !== undefined ? listInativos.active.dtfim.substring(8,10)  + "/" + listInativos.active.dtfim.substring(5,7) + "/" + listInativos.active.dtfim.substring(0,4) : "")
  															+ "&valor01="     + $scope.ParamsLista[0] 
  															+ "&valor02="     + $scope.ParamsLista[1] 
  															+ "&valor03="     + $scope.ParamsLista[2] 
  															+ "&valor04="     + $scope.ParamsLista[3] 
  															+ "&valor05="     + $scope.ParamsLista[4] 
  															+ "&valor06="     + $scope.ParamsLista[5] 
  															+ "&valor07="     + $scope.ParamsLista[6] 
  															+ "&valor08="     + $scope.ParamsLista[7] 
  															+ "&valor09="     + $scope.ParamsLista[8] 
  															+ "&valor10="     + $scope.ParamsLista[9] 
  															+ "&valor11="     + $scope.ParamsLista[10] 
  															+ "&valor12="     + $scope.ParamsLista[11] 
  															)
  											.then(
  													//success
  													function(response) {
  														$scope.listaInfo4.data = response;
  													},
  													//failure
  													function(response) {
  														Notification.error("Ocorreu um erro na consulta das listas dinamicas do atributo info4");
  													});
								  }
								}
								function populaListaInfo5() {
								  
								  if( listInativos.active.seqDivInfo5 !== undefined){
								  var seqinfo5 = 0;
  								  // define qual o campovant do info 5
  								 if (listInativos.active.atributosInfo !== null && listInativos.active.atributosInfo !== undefined)
								  {
  								  seqinfo5 = (listInativos.active.atributosInfo5.campoVantIndexado !== undefined && listInativos.active.atributosInfo5.campoVantIndexado !== null ? listInativos.active.atributosInfo5.campoVantIndexado : ( listInativos.active.atributosInfo5.seq === undefined ) ? listInativos.active.atributosInfo.atributosInfo5.seq : listInativos.active.atributosInfo5.seq );
								  } 
  									GenericService
  											.getData(
  													(window.hostApp || "")
  															+ "api/rest/ergon/Vantagens/listaValoresAtributos"
  															+ "?numfunc="         + $scope.numfunc + "&numvinc=" + $scope.numvinc
  															+ "&vantagem="    + listInativos.active.vantagens
  															+ "&pcampovant="  + seqinfo5
  															+ "&dtini="       + (listInativos.active.dtini !== null && listInativos.active.dtini !== undefined ? listInativos.active.dtini.substring(8,10)  + "/" + listInativos.active.dtini.substring(5,7) + "/" + listInativos.active.dtini.substring(0,4) : "")
  															+ "&dtfim="       + (listInativos.active.dtfim !== null && listInativos.active.dtfim !== undefined ? listInativos.active.dtfim.substring(8,10)  + "/" + listInativos.active.dtfim.substring(5,7) + "/" + listInativos.active.dtfim.substring(0,4) : "")
  															+ "&valor01="     + $scope.ParamsLista[0] 
  															+ "&valor02="     + $scope.ParamsLista[1] 
  															+ "&valor03="     + $scope.ParamsLista[2] 
  															+ "&valor04="     + $scope.ParamsLista[3] 
  															+ "&valor05="     + $scope.ParamsLista[4] 
  															+ "&valor06="     + $scope.ParamsLista[5] 
  															+ "&valor07="     + $scope.ParamsLista[6] 
  															+ "&valor08="     + $scope.ParamsLista[7] 
  															+ "&valor09="     + $scope.ParamsLista[8] 
  															+ "&valor10="     + $scope.ParamsLista[9] 
  															+ "&valor11="     + $scope.ParamsLista[10] 
  															+ "&valor12="     + $scope.ParamsLista[11] 
  															
  															)
  											.then(
  													//success
  													function(response) {
  														
  														$scope.listaInfo5.data = response;
  
  													},
  													//failure
  													function(response) {
  														Notification.error("Ocorreu um erro na consulta das listas dinamicas do atributo info5");
  													});
								  }
								}
								function populaListaInfo6() {
								  
								  if( listInativos.active.seqDivInfo6 !== undefined){
								  var seqinfo6 = 0;
  								  // define qual o campovant do info 6
  								 if (listInativos.active.atributosInfo !== null && listInativos.active.atributosInfo !== undefined)
								  {
  								  seqinfo6 = (listInativos.active.atributosInfo6.campoVantIndexado !== undefined && listInativos.active.atributosInfo6.campoVantIndexado !== null ? listInativos.active.atributosInfo6.campoVantIndexado : ( listInativos.active.atributosInfo6.seq === undefined ) ? listInativos.active.atributosInfo.atributosInfo6.seq : listInativos.active.atributosInfo6.seq );
								  } 
  								  GenericService
  											.getData(
  													(window.hostApp || "")
  															+ "api/rest/ergon/Vantagens/listaValoresAtributos"
  															+ "?numfunc="     + $scope.numfunc + "&numvinc=" + $scope.numvinc
  															+ "&vantagem="    + listInativos.active.vantagens
  															+ "&pcampovant="  + seqinfo6
  															+ "&dtini="       + (listInativos.active.dtini !== null && listInativos.active.dtini !== undefined ? listInativos.active.dtini.substring(8,10)  + "/" + listInativos.active.dtini.substring(5,7) + "/" + listInativos.active.dtini.substring(0,4) : "")
  															+ "&dtfim="       + (listInativos.active.dtfim !== null && listInativos.active.dtfim !== undefined ? listInativos.active.dtfim.substring(8,10)  + "/" + listInativos.active.dtfim.substring(5,7) + "/" + listInativos.active.dtfim.substring(0,4) : "")
  															+ "&valor01="     + $scope.ParamsLista[0] 
  															+ "&valor02="     + $scope.ParamsLista[1] 
  															+ "&valor03="     + $scope.ParamsLista[2] 
  															+ "&valor04="     + $scope.ParamsLista[3] 
  															+ "&valor05="     + $scope.ParamsLista[4] 
  															+ "&valor06="     + $scope.ParamsLista[5] 
  															+ "&valor07="     + $scope.ParamsLista[6] 
  															+ "&valor08="     + $scope.ParamsLista[7] 
  															+ "&valor09="     + $scope.ParamsLista[8] 
  															+ "&valor10="     + $scope.ParamsLista[9] 
  															+ "&valor11="     + $scope.ParamsLista[10] 
  															+ "&valor12="     + $scope.ParamsLista[11]															
  															)
  											.then(
  													//success
  													function(response) {
  														
  														$scope.listaInfo6.data = response;
  
  													},
  													//failure
  													function(response) {
  														Notification.error("Ocorreu um erro na consulta das listas dinamicas do atributo info6.");
  													});
								  }
								}
								
								//Metodo que atualiza as listas dinamicas
								function atualizarListasValores(){
								  $scope.ordenarValores();
								  contarDiv();
								  organizaParamsLista();
								  populaListaInfo1();
								  populaListaInfo2();
								  populaListaInfo3();
								  populaListaInfo4();
								  populaListaInfo5();
								  populaListaInfo6();
								}
							}

					]);

}(app));