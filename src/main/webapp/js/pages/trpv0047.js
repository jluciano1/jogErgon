(function ($app) {
  angular.module('page.controllers', []);
  
    app.controller('trpv0047', ['$scope', 
                                '$http', 
                                '$rootScope', 
                                '$state', 
                                '$location', 
                                '$translate',
                                '$base64',
                                '$filter',
                                '$timeout',
                                'GenericService',
                                'Notification', 
      function ($scope, $http, $rootScope, $state, $location, $translate, $base64, $filter, $timeout, GenericService, Notification) {
        
        $scope.Dependentes = { data: [] };
        $scope.Representantes = { data: [] };
        $scope.DependenteRepresentante = { data: [] };
        $scope.DependenteHistorico = { data: [] };
        $scope.DependenteDependencias = { data: [] };
        $scope.DependenteRepresentante.active = {};
        $scope.DependenteHistorico.active = {};
        $scope.DependenteDependencias.active = {};
        $scope.FuncionariosFiltro = {};
        $scope.Painel = {};
        $scope.Painel.dadosCadastraisOpen = false;
        $scope.Parentescos = null;
        $scope.view = false;
        $scope.seeDetails = false;
        $scope.sexo = [{opc: 'F'}, {opc: 'M'}];
        $scope.tipoDepen = [{opc: 'SALFAM'}, {opc: 'IR'}, {opc: 'A CONFIRMAR-SF'}, {opc: 'A CONFIRMAR-IR'}];
        $scope.DependenteHistorico.active.invalido = 'N';
        $scope.DependenteHistorico.active.universitario = 'N';
        $scope.DependenteHistorico.active.excepcional = 'N';
        $scope.DependenteHistorico.active.estudante = 'N';
        $scope.imageDependentsValues = ['numfunc', 'numdep'];
        
        var urlFuncionarios = "api/rest/ergon/Funcionarios/listFuncsInativo";
        var urlDependentes = "api/ws/rest/ergon/v1.0/pessoal/dependentes"; //WS
        var urlDependentesPost = "api/ws/rest/ergon/v1.0/pessoal/dependentes/dependente" //WS
        var urlDependenteSelecionado = "api/ws/rest/ergon/v1.0/pessoal/dependentes/dependente/dadosPessoais"; //WS
        var urlDependenteFoto = "api/ws/rest/ergon/v1.0/pessoal/dependentes/dependente/foto/"; //WS
        var urlDependenteDependencias = "api/ws/rest/ergon/v1.0/pessoal/dependentes/dependente/dependencias" //WS
        var urlDependenteDependenciasPost = "api/ws/rest/ergon/v1.0/pessoal/dependentes/dependente/dependencias/dependencia" //WS
        var urlDependenteHistorico = "api/ws/rest/ergon/v1.0/pessoal/dependentes/dependente/historico"; // WS
        var urlDependenteHistoricoPost = "api/ws/rest/ergon/v1.0/pessoal/dependentes/dependente/historico/registro"; // WS
        var urlRepresentantes = "api/ws/rest/ergon/v1.0/pessoal/dependentes/dependente/representantes"; // WS
        var urlRepresentantesPost = "api/ws/rest/ergon/v1.0/pessoal/dependentes/dependente/representantes/representante"; // WS";
        var urlRepresentantesLegal = " api/rest/ergon/RepresentanteLegal";
        var urlParentesco = "api/ws/rest/ergon/v1.0/lov/itemTabela/parentescos";
        var urlPensionistas = "api/ws/rest/ergon/v1.0/lov/pensionistas";
        var urlEstados = "api/rest/ergon/ItemTabela/Tabela/UF?size=30";
        var urlCidades = "api/rest/ergon/Municipio/listByEstado?size=1000000&estado=";
        var urlLogradouros = "api/rest/ergon/ItemTabela/Tabela/Logradouros";
        var urlTipoRegistro = "api/rest/ergon/ItemTabela/Tabela/TIPO_RG";
        var urlEstadoCivil = "api/rest/ergon/ItemTabela/Tabela/ERG_ESTCIVIL";
        var urlOrgaoExpeditor = "api/rest/ergon/ItemTabela/Tabela/ORGAO%20RG?size=100000";
        var urlTipoCertidao = "api/rest/ergon/ItemTabela/Tabela/TIPO_DOC_CERT_REP";
        var urlTipoCertidaoDesaparecimento = "api/rest/ergon/ItemTabela/Tabela/TIPO_DOC_CERT_FIM";
        var urlTipoInvalidez = "api/rest/ergon/ItemTabela/Tabela/ERG_DEP_TIPO_INV";
        var urlTipoExcepcionalidade = "api/rest/ergon/ItemTabela/Tabela/ERG_DEP_TIPO_EXCEP";
        var urlTipoPagamento = "api/rest/ergon/ItemTabela/Tabela/ERG_TIPO_PAG";
        var urlBancos = "api/rest/ergon/Bancos?size=100000";
        var urlAgencias = "api/rest/ergon/Agencias/listByBanco";
        var urlTipoRepresentantes = "api/rest/ergon/ItemTabela/Tabela/TIPO_REPRESENTANTE";
        var urlTipoDocRepresentantes = "api/rest/ergon/ItemTabela/Tabela/TIPO_DOC_CERT_REP";
        var _urlFotos = "api/ws/rest/ergon/v1.0/pessoal/dependentes/dependente/foto";
      
        // renderiza imagem se o usuario fizer upload do arquivo
        $scope.$watch('blkVinc.numfunc', function() {
          if($scope.blkVinc){
            GenericService.getData(urlDependentes + "/" + $scope.blkVinc.numfunc, null, null, null, true).then(function(response){
              $scope.Dependentes.data = response;
              $scope.Dependentes.active = null;
        });
          }else{
            $scope.Dependentes = { data: [] };
             $scope.Dependentes.active = null;
             $scope.Dependentes.filtro = null;
          }
        
        // Observa se algum funcionario foi escolhido
        });
        
        ////////////////////// Funções do crud de dependentes
        $scope.insertDependente = function() {
          $scope.Dependentes.active = null;
          $scope.Dependentes.filtro = null;
          $timeout(function(){
            $scope.insertData();
            $scope.Painel.dadosCadastraisOpen = true;
          }, 200);
        };
        $scope.removeDependente = function(dependente){
          $.prompt("Deseja remover?", {
            	buttons: { "Ok": true, "Cancel": false },
            	focus: 1,
            	zIndex: 9999,
            	opacity: 0.4,
            	submit: function(e,v,m,f){
            		if(v){
            		  GenericService.deleteData(urlDependentesPost  + '/' + $scope.blkVinc.numfunc + '/' +$scope.Dependentes.filtro.numdep).then(function(response){
                    GenericService.getData(urlDependentes + "/" + $scope.blkVinc.numfunc).then(function(response){
                      $scope.Dependentes.data = response;
                    });
                    //se response.status = undefined, então não houve erro por parte do servidor
                    if(typeof(response.status) == "undefined"){
                      $scope.Dependentes.filtro = {};
                      $scope.Dependentes.active = {};
                      $scope.Painel.dadosCadastraisOpen = false;
                    }
                  });
            		}
            	}
          });
        }
        $scope.sendDependente = function(data) {
          data.numfunc = $scope.blkVinc.numfunc;
          if(typeof(data.numdep) != "undefined" && typeof(data.nome) != "undefined" && typeof(data.dtnasc) != "undefined"){
          	if($scope.startInserting){
              GenericService.postData(urlDependentesPost, data).then(function(response){
                GenericService.getData(urlDependentes + "/" + $scope.blkVinc.numfunc).then(function(response){
                  $scope.Dependentes.data = response;
                });
                //se response.status = undefined, então não houve erro por parte do servidor
                if(typeof(response.status) == "undefined"){
                  $scope.Painel.dadosCadastraisOpen = false;
                  $scope.Dependentes.active = {};
                  $scope.startInserting = false;
                }
              });
           	} else {
              GenericService.putData(urlDependenteSelecionado + '/' + $scope.blkVinc.numfunc + '/' + $scope.Dependentes.active.numdep, data).then(function(response){
                $scope.Dependentes.active = response;
              });
           	}
           }
        };
        
        $scope.insertData = function() {
          $scope.startInserting = true;
          $scope.startUpdate =  false;
        };
        $scope.editData = function() {
          $scope.startInserting = false;
          $scope.startUpdate = true;
        };
        $scope.cancelInsertDependente = function() {
          $scope.Painel.dadosCadastraisOpen = false;
          $scope.startInserting = false;
          $scope.startUpdate = false;
        };
        $scope.editDependente = function() {
          $scope.Painel.dadosCadastraisOpen = true;
        };
        $scope.getDependenteDetails = function(){
          if($scope.Dependentes.filtro == null || typeof($scope.Dependentes.filtro.numdep) == "undefined"){
            $timeout(function(){
              $scope.Dependentes.active = null;
            }, 200);
          } else {
            GenericService.getData(urlDependenteSelecionado + '/' + $scope.blkVinc.numfunc + '/' + $scope.Dependentes.filtro.numdep).then(function(response){
              $scope.Dependentes.active = response;
            });
          }
        };
        ////////////// Fim das funções do crud de dependentes
        
        // Observa se algum dependente foi escolhido
        $scope.$watch('Dependentes.filtro', function() {
          $scope.Painel.dadosCadastraisOpen = false;
          $scope.startInserting = false;
          if($scope.Dependentes.filtro == null || typeof($scope.Dependentes.filtro.numdep) == "undefined") {
            $scope.DependenteRepresentante = { data: [] };
            $scope.DependenteHistorico = { data: [] };
            $scope.DependenteDependencias = { data: [] };
          }
            //////////// Início das funções do modal de dependências do dependente
            // Get - pega lista de dependencias de um dependente
            $scope.getDependenteDependencias = function(){
              if($scope.Dependentes.filtro && typeof($scope.Dependentes.filtro.numdep) !== "undefined") {
                GenericService.getData(urlDependenteDependencias + '/' + $scope.BlockVinc.filtro.numfunc + '/' + $scope.Dependentes.filtro.numdep).then(function(response){
                $scope.DependenteDependencias.data = response;
                  GenericService.getData(urlPensionistas + '/' + $scope.Dependentes.filtro.numdep).then(function(responsePensionistas){
                    $scope.pensionistas = responsePensionistas;
              		});
                });
              }
            };
            // Get - pega detalhes de uma dependencia
            $scope.getDependencia = function(dependencia){
              $scope.DependenteDependencias.active = dependencia;
            };
            // Post - envia uma dependência
            $scope.sendDependencia = function(dependencia){
              if($scope.startInserting){
                if(!dependencia || dependencia.tipoDepen==null || !dependencia.tipoDepen || dependencia.dtini == null || dependencia.dtini == "" || !dependencia.dtini){
                  return;
                }
                
                GenericService.postData(urlDependenteDependenciasPost  + '/' + $scope.BlockVinc.filtro.numfunc + '/' + $scope.Dependentes.active.numdep + '/' +  dependencia.tipoDepen  + '/' + $filter('shortISO')(dependencia.dtini), dependencia).then(function(response){
                  $scope.getDependenteDependencias();
                });  
              } else {
                GenericService.putData(urlDependenteDependenciasPost  + '/' + $scope.BlockVinc.filtro.numfunc + '/' + $scope.Dependentes.active.numdep  + '/' + dependencia.tipoDepen + '/' + $filter('shortISO')(dependencia.dtini), dependencia).then(function(response){
                  $scope.getDependenteDependencias();
                });
              }
            };
            $scope.removeDependencia = function(dependencia){
              $.prompt("Deseja remover?", {
              	buttons: { "Ok": true, "Cancel": false },
              	focus: 1,
              	zIndex: 9999,
              	opacity: 0.4,
              	submit: function(e,v,m,f){
              		if(v){
                  	GenericService.deleteData(urlDependenteDependenciasPost  + '/' + $scope.BlockVinc.filtro.numfunc + '/' + $scope.Dependentes.filtro.numdep  + '/' + dependencia.tipoDepen + '/' + $filter('shortISO')(dependencia.dtini), dependencia).then(function(response){
                      $scope.getDependenteDependencias();
                    });
              		}
              	}
              });
            }
            //////////// Fim das funções do modal de dependências do dependente
          
            //////////// Início das funções do modal de histórico do dependente
            // Get - pega lista de histórico de um dependente
            $scope.getDependenteHistoricoList = function(){
              if($scope.Dependentes.filtro && typeof($scope.Dependentes.filtro.numdep) != "undefined") {
                GenericService.getData(urlDependenteHistorico + '/' + $scope.BlockVinc.filtro.numfunc + '/' + $scope.Dependentes.filtro.numdep).then(function(response){
                $scope.DependenteHistorico.data = response;   
              });
              }
            };
            // Get - pega detalhes de uma dependencia
            $scope.getHistorico = function(historico){
              $scope.DependenteHistorico.active = historico;
            };
            // Post - envia um historico de um dependente
            $scope.sendHistorico = function(historico){
              if(!historico.invalido)
              historico.invalido = 'N';
              if(!historico.universitario)
              historico.universitario = 'N';
              if(!historico.excepcional)
              historico.excepcional = 'N';
              if(!historico.estudante)
              historico.estudante = 'N';
              if($scope.startInserting){
                if (historico.dtini !== null && historico.dtini !== undefined){
                  GenericService.postData(urlDependenteHistoricoPost  + '/' + $scope.BlockVinc.filtro.numfunc + '/' + $scope.Dependentes.filtro.numdep + '/' + historico.dtini, historico).then(function(response){
                    $scope.getDependenteHistoricoList();
                  });
                }
              }  
              else {
                GenericService.putData(urlDependenteHistoricoPost  + '/' + $scope.BlockVinc.filtro.numfunc + '/' + $scope.Dependentes.active.numdep + '/' + historico.dtini, historico).then(function(response){
                  $scope.getDependenteHistoricoList();
                
                });
              }  
            }
            $scope.removeHistorico = function(historico){
              $.prompt("Deseja remover?", {
              	buttons: { "Ok": true, "Cancel": false },
              	focus: 1,
              	zIndex: 9999,
              	opacity: 0.4,
              	submit: function(e,v,m,f){
              		if(v){
              		  GenericService.deleteData(urlDependenteHistoricoPost  + '/' + $scope.BlockVinc.filtro.numfunc + '/' + $scope.Dependentes.filtro.numdep + '/' + historico.dtini, historico).then(function(response){
                      GenericService.getData(urlDependenteHistorico + '/' + $scope.BlockVinc.filtro.numfunc + '/' + $scope.Dependentes.filtro.numdep).then(function(response){
                        $scope.DependenteHistorico.data = response;   
                      });
                    });
              		}
              	}
              });
            }
            //////////// Fim das funções do modal de histórico do dependente
          
            //////////// Início das funções do modal de representantes do dependente
            $scope.getRepresentantes = function(){
              if($scope.Dependentes.filtro && typeof($scope.Dependentes.filtro.numdep) != "undefined") {
              	GenericService.getData(urlRepresentantesLegal).then(function(response){
              	  $scope.Representantes.data = response.content;
              	});
              	// Get - pega lista de representantes de um dependente
              	GenericService.getData(urlTipoRepresentantes).then(function(response){
              	  $scope.tipoRep = response;
              	});
              	GenericService.getData(urlTipoDocRepresentantes).then(function(response){
              	  $scope.tipoDocRep = response;
              	});
              	GenericService.getData(urlRepresentantes  + '/' + $scope.BlockVinc.filtro.numfunc + '/' + $scope.Dependentes.filtro.numdep).then(function(response){
              	  $scope.DependenteRepresentante.data = response;
              	});
              }
            };
          
            // Get - pega detalhes de um representante
            $scope.getRepresentante = function(representante){
              $scope.DependenteRepresentante.active = representante;
            };
            
            // POST - envia um representante do dependente
            $scope.sendDependenteRepresentante =  function(representante){
              if($scope.startInserting){
                if (!representante || !$scope.DependenteRepresentante.active.numRep == null || !$scope.DependenteRepresentante.active.numRep || representante.dtini == null || !representante.dtini || representante.dtini == ""){
                  return;
                }
                GenericService.postData(urlRepresentantesPost  + '/' + $scope.BlockVinc.filtro.numfunc + '/' + $scope.Dependentes.active.numdep + '/' + $scope.DependenteRepresentante.active.numRep + '/' + representante.dtini, representante).then(function(response){
                  GenericService.getData(urlRepresentantes  + '/' + $scope.BlockVinc.filtro.numfunc + '/' + $scope.Dependentes.active.numdep).then(function(response){
                    $scope.DependenteRepresentante.data = response;
                  });
                });
              }else{
                GenericService.putData(urlRepresentantesPost  + '/' + $scope.BlockVinc.filtro.numfunc + '/' + $scope.Dependentes.filtro.numdep + '/' + $scope.DependenteRepresentante.active.numRep + '/' + representante.dtini, representante).then(function(response){
                  $scope.getRepresentantes();
                });
              }
            }
            
            // DELETE - exclui um representante do dependente
            $scope.removeRepresentante = function(representante){
              $.prompt("Deseja remover?", {
              	buttons: { "Ok": true, "Cancel": false },
              	focus: 1,
              	zIndex: 9999,
              	opacity: 0.4,
              	submit: function(e,v,m,f){
              		if(v){
              		  GenericService.deleteData(urlRepresentantesPost  + '/' + $scope.BlockVinc.filtro.numfunc + '/' + $scope.Dependentes.filtro.numdep + '/' + representante.numRep + '/' + representante.dtini, representante).then(function(response){
                      GenericService.getData(urlRepresentantes  + '/' + $scope.BlockVinc.filtro.numfunc + '/' + $scope.Dependentes.filtro.numdep).then(function(response){
                        $scope.DependenteRepresentante.data = response;
                      });
                    });
              		}
              	}
              });
            }
            /////////// Fim das funções do modal de representantes do dependente
        });
        
       GenericService.getData(urlTipoInvalidez).then(function(response){
          $scope.tipoDeficiencia = response.content;
        });
        GenericService.getData(urlTipoExcepcionalidade).then(function(response){
          $scope.tipoExcepcionalidade = response.content;
        });
        GenericService.getData(urlEstados).then(function(response){
          $scope.estados = response;
        });
        GenericService.getData(urlLogradouros).then(function(response){
          $scope.logradouros = response.content;
          $scope.logradouros.map(function(logradouro){
            logradouro.descricao = logradouro.descricao.toUpperCase();
          })
        });
        GenericService.getData(urlTipoRegistro).then(function(response){
          $scope.tipoRegistro = response;
        });
        GenericService.getData(urlParentesco).then(function(response){
          $scope.Parentescos = response;
        });
        GenericService.getData(urlEstadoCivil).then(function(response){
          $scope.estadoCivil = response;
        });
        GenericService.getData(urlOrgaoExpeditor).then(function(response){
          $scope.orgaoExpeditor = response;
        });
        GenericService.getData(urlTipoCertidao).then(function(response){
          $scope.tipoCertidao = response;
        });
        GenericService.getData(urlTipoCertidaoDesaparecimento).then(function(response){
          $scope.tipoCertidaoDesaparecimento = response;
        });
        GenericService.getData(urlTipoPagamento).then(function(response){
          $scope.tipoPagamento = response;
        });
        GenericService.getData(urlBancos).then(function(response){
          $scope.bancos = response;
        });
        
          // Observa se algum banco foi escolhido e busca suas agencias
          $scope.$watch('Dependentes.active.codBanco', function() {
             if($scope.Dependentes.active && $scope.Dependentes.active.codBanco){
               GenericService.getData(urlAgencias + '/' +$scope.Dependentes.active.codBanco).then(function(response){
                 $scope.agencias = response;
               });
             }
          });
          // Observa o estado escolhido e busca suas cidades
          $scope.$watch('Dependentes.active.ufEnder', function() {
            if($scope.Dependentes.active && $scope.Dependentes.active.ufEnder){
            	GenericService.getData(urlCidades + $scope.Dependentes.active.ufEnder).then(function(response){
            	  $scope.cidadeEndereco = response;
            	 });
            }
          });
          $scope.$watch('Dependentes.active.ufCartorio', function() {
            if($scope.Dependentes.active && $scope.Dependentes.active.ufCartorio){
            GenericService.getData(urlCidades + $scope.Dependentes.active.ufCartorio).then(function(response){
              $scope.cidadeCartorio = response;
            });
            }
          });
          $scope.$watch('Dependentes.active.ufCartorioFim', function() {
            if($scope.Dependentes.active && $scope.Dependentes.active.ufCartorioFim){
              GenericService.getData(urlCidades +$scope.Dependentes.active.ufCartorioFim).then(function(response){
                $scope.cidadeCartorioFim = response;
              });
            }
          });
          $scope.$watch('DependenteRepresentante.active.ufCartorio', function() {
            if($scope.Dependentes.active && $scope.DependenteRepresentante.active.ufCartorio){
              GenericService.getData(urlCidades + $scope.DependenteRepresentante.active.ufCartorio).then(function(response){
                $scope.cidadeRepresentante = response;
              });
            }
          });
      
        $scope.setToView = function(vemDoFecharModal, buttonType){
          if(vemDoFecharModal === 1){
            $scope.view = false;
            $scope.DependenteRepresentante.active = {};
            $scope.DependenteHistorico.active = {};
            $scope.DependenteDependencias.active = {};
          }else{
            $scope.view = !$scope.view;
          }
          if(buttonType == 'detalhe'){
            $scope.seeDetails = true;
          } else {
            $scope.seeDetails = false;
          }
        };
        
      }
    
    ]);
} (app));
