(function ($app) {
    app.directive('blkTransacao', function () {
        return {
            restrict: 'E', 
            templateUrl: 'views/htmlDirectives/blkTransacao.html'
        };
    });

    app.directive('blkEmpresa', function () {
        return {
            restrict: 'E', 
            templateUrl: 'views/htmlDirectives/blkEmpresa.html'
        };
    });
    
    app.directive('blkEmpresaOpt', function () {
        return {
            restrict: 'E', 
            templateUrl: 'views/htmlDirectives/blkEmpresaOpt.html'
        };
    });

    app.directive('blkVinculo', function(sharedGenericService) {
        return {
            restrict: 'E',
            templateUrl: 'views/htmlDirectives/blkVinculo.html',
            controller: ['$scope','$attrs', 'VinculoService', function($scope, $attrs, VinculoService) {
                var vm = this;
                $scope.ultimosAcessosBoolean = false;
                $scope.listaUltimosAcessos = { data: [] };
                $scope.listaUltimosAcessos = VinculoService.getUltimosAcessos();
                $scope.listaUltimosAcessos = JSON.parse($scope.listaUltimosAcessos);

                if (typeof($attrs.ativo) === 'undefined') { //filtra apenas inativos
                   status = '/INATIVO';
                } else if ($attrs.ativo == 'ativo') { //(typeof($attrs.ativo) === 'ativo') { //filtra apenas ativos if ($(this).attr("myAttr") == "0") {
                   status = '/ATIVO';
                } else if ($attrs.ativo == 'todos') {  //{ //filtra todos if (typeof($attrs.ativo) === 'todos')
                   status = '/TODOS';
                }

                $scope.refreshFunc = function(func) {
                    // if (/\W+/.test(func))
                    //   return;
                    var numfunc;
                    var numvinc;
                    var posicaoBarra = func.indexOf('/');

                    if (func.length > 0) {
                        
                         $scope.ultimosAcessosBoolean = false;
                                
                        if (posicaoBarra > 0) { //se existe barra
                          
                            numfunc = func.substr(0, posicaoBarra); //determina que numfunc é até a barra
                            numvinc = func.substr((posicaoBarra + 1), 2); // e as duas posicoes após a barra é numvinc

                            if (numvinc.indexOf('/') > 0) { //verifica se existe alguma outra barra no suposto numvinc e remove
                                numvinc = numvinc.replace("/", "");
                            }

                            if (IsNumeric(numfunc) && IsNumeric(numvinc)) { //verifica se sobrou apenas numeros para considerar como numfunc/numvinc
                                $scope.blkVincFiltro.filtro = status + '/funcvinc/' + numfunc + '/' + numvinc;
                            }

                        } else {

                            if (IsNumeric(func)) {

                                if (func.length > 9 && func.length < 13) {
                                  $scope.blkVincFiltro.filtro = status + '/cpf/' + func;
                                  return;
                                }
                                if (func.length >= 13) {
                                  return;
                                }

                                $scope.blkVincFiltro.filtro = status + '/numfunc/' + func;
                            } else {
                                $scope.blkVincFiltro.filtro = status + '/nome/' + func;
                            }
                        }
                    }

                    function IsNumeric(input) {
                        return (input - 0) == input && ('' + input).trim().length > 0;
                    }
                }
                
                $scope.onAfterParamSearch = function(datasource) {
                  if (datasource.data.length == 1) {
                    if (typeof($scope.blkVincSelect==='function'))
                      $scope.blkVincSelect.call($scope, datasource.data[0]);
                    if (vm.uis) {
                      // vm.uis.$select.selected = vm.uis.$select.items[0];
                      vm.uis.$select.selected = vm.uis.datasource.data[0];
                    }
                  } else if (datasource.data.length > 1) {
                    if (vm.uis) {
                      vm.uis.$select.toggle;
                    }
                  }
                }
                
                $scope.applyParams = function(uiSelect, datasource) {
                  if ($scope.params && $scope.params.hasOwnProperty('pNumfunc')) {
                    vm.uis = uiSelect;
                    datasource.setOnetimeAfterFillCallback($scope.onAfterParamSearch);
                    uiSelect.$select.search=($scope.params.pNumfunc?$scope.params.pNumfunc:'')+($scope.params.pNumvinc?'/'+$scope.params.pNumvinc:'');
                  } else
                    vm.uis = null;
                }

                $scope.getFuncionarioData = function(selecionado){
                  VinculoService.setUltimosAcessos(selecionado);
                  $scope.listaUltimosAcessos = VinculoService.getUltimosAcessos();
                  $scope.listaUltimosAcessos = JSON.parse($scope.listaUltimosAcessos);
                }
                
                $scope.getUltimosAcessos = function(){
                  $scope.ultimosAcessosBoolean = !$scope.ultimosAcessosBoolean;
                  $scope.BlockVinc.filtro = "";
                }
                
            }]
        };
    });
    
    app.directive('blkReqvinc', function (sharedGenericService) {
        return {
            restrict: 'E', 
            templateUrl: 'views/htmlDirectives/blkReqVinc.html',
            controller: function ($scope, $attrs) {
                                    var vm = this;
                                    
                                    $scope.refreshReqVinc = function(func) {

                                      var numfunc;
                                      var numvinc;
                                      var posicaoBarra = func.indexOf('/');
                                      
                                      if (func.length > 0) { //verifica se foi informado alguma informação no campo de pesquisa
                                      
                                          if (posicaoBarra > 0) { //se existe barra
                                            
                                              numfunc = func.substr(0, posicaoBarra); //determina que numfunc é até a barra
                                              numvinc = func.substr((posicaoBarra +1), 2); // e as duas posicoes após a barra é numvinc
                                              
                                              if (numvinc.indexOf('/') > 0) { //verifica se existe alguma outra barra no suposto numvinc e remove
                                                numvinc = numvinc.replace("/","");
                                              }
                                              
                                              if ( IsNumeric(numfunc) && IsNumeric(numvinc) ) { //verifica se sobrou apenas numeros para considerar como numfunc/numvinc
                                                $scope.blkReqVincFiltro.filtro = '/funcvinc/' + numfunc + '/' + numvinc;
                                               } 
                                               
                                          } else {
                                            
                                            if (IsNumeric(func))  {
                                              $scope.blkReqVincFiltro.filtro = '/numero/' + func;
                                            } else { 
                                              $scope.blkReqVincFiltro.filtro = '/nome/' + func;
                                            }
                                          }
                                          
                                      }

                                  }
                                    
                                    function IsNumeric(input)
                                     {
                                      return (input - 0) == input && (''+input).trim().length > 0;
                                     }
                                    
                                  }
        };
    });
    
    app.directive('blkLeiBtn', function (sharedGenericService) {
      
        var verify = function(mecanismoPont, confirmedExecution){
          $.prompt("Deseja acionar o mecanismo de documentos legais para este registro ?", {
          	buttons: { "Sim": true, "Não": false },
          	focus: 1,
          	zIndex: 9999,
          	opacity: 0.4,
          	submit: function(e,v,m,f){
          		if(v){
          		  mecanismoPont();
          		  confirmedExecution();
          		}
          	}
          });
        }
        return {
            restrict: 'AE', 
            // template: '<button ng-click="handleClick()">Directive</button>',
            template: '<button type="button" class="btn btn-default btn-sm" ng-click="handleClick();" tooltip="Documentos legais">'+
                      '    <i class="fa fa-balance-scale" aria-hidden="true"></i>'+
                      '</button>',        
            replace: true,
            scope: true,
            controller: function($scope, $attrs, sharedGenericService) {
                var confirmedExecution = function(){
                  $("#modalErglei").modal({
                    backdrop: "static",
                    keyboard: false,
                    show: true
                  });
                  
                }
                
                $scope.handleClick = function(event) {
                  var lei = {pontlei:$attrs.pontlei};
                  sharedGenericService.prepForBroadcastPublLei(lei);
                  
                  if(!$attrs.pontlei && !$scope.blkLeiReadOnly)
                    verify($scope.mecanismoPontLei, confirmedExecution);
                  else
                    confirmedExecution();
                };
    
                $scope.$on('handleBroadcastPublLei', function() {
                    $scope.message = sharedGenericService.pontlei;
                });
            }     
        };
    });
    
    app.directive('blkPublBtn', function (sharedGenericService) {
      
        var verify = function(mecanismoPont, confirmedExecution){
          $.prompt("Deseja acionar o mecanismo de publicação para este registro ?", {
          	buttons: { "Sim": true, "Não": false },
          	focus: 1,
          	zIndex: 9999,
          	opacity: 0.4,
          	submit: function(e,v,m,f){
          		if(v){
          		  mecanismoPont();
          		  confirmedExecution();
          		}
          	}
          });
        }
      
        return {
            restrict: 'AE', 
            template: '<button type="button" class="btn btn-default btn-sm" ng-click="handleClick();"  tooltip="Publicações">'+
                      '    <i class="fa fa-file-text-o" aria-hidden="true"></i>'+
                      '</button>',        
            replace: true,
            scope: true,
            controller: function($scope, $attrs, sharedGenericService) {
                
                var confirmedExecution = function(){
                  $("#modalPubl").modal({
                    backdrop: "static",
                    keyboard: false,
                    show: true
                  });
                  
                }
                
                $scope.handleClick = function(event) {
                  var publ = {pontpubl:$attrs.pontpubl};
                  sharedGenericService.prepForBroadcastPublLei(publ);
                  
                  if(!$attrs.pontpubl && !$scope.blkPublReadOnly)
                    verify($scope.mecanismoPontPubl, confirmedExecution);
                  else
                    confirmedExecution();
                };
    
                $scope.$on('handleBroadcastPublLei', function() {
                    $scope.message = sharedGenericService.pontpubl;
                });
            }     
        };
    });

    app.directive('blkLeiModal', ['GenericService', function(GenericService){
      return {
        restrict: 'E',
        link: function($scope, elem, $attrs) {
          $scope.$watch('pontlei',function(changedVal){
            $scope.blkLeiReadOnly =  $attrs.blkreadonly;
          });
        },
        controller: function($scope, $attrs, sharedGenericService) {
          
            $scope.mecanismoPontLei = function(){
              GenericService.putData($attrs.blkUrlService+"/mecanismoPontLei", JSON.parse($attrs.blkactive)).then(function(response){
                if(typeof(response.status) == "undefined"){
                  $scope.pontlei = response;
                  if($scope.blkRefresh && typeof($scope.blkRefresh) == "function")
                    $scope.blkRefresh(response, "pontlei");
                }
              });
            }
          
          
            $scope.$on('handleBroadcast', function() {
                $scope.pontlei = sharedGenericService.pontlei;
            });
            $scope.setPontlei = function(){
              ErgLeiReg.active.pontlei = $scope.pontlei;
            };
            
            $scope.$watchCollection('ergLeiRefer.data', function(newData){
              if(ErgLeiReg.inserting || ErgLeiReg.editing){
                ErgLeiReg.active.refer = ( newData.length > 0 ) ? newData[0].refer : null;
              }
                
            })
            
           
        },
        templateUrl: 'views/htmlDirectives/blkLei.html',
      };
    
    }]); 

    app.directive('blkPublModal', ['DatasetManager', 'GenericService', function(DatasetManager, GenericService){
      return {
        restrict: 'E',
        link: function($scope, $elem, $attrs) {
            $scope.blkPublReadOnly =  $attrs.blkreadonly;
            $scope.blkPublTabela =  $attrs.blktabela; 
            $scope.$watch('pontpubl',function(changedVal){
              $scope.blkPublReadOnly = $attrs.blkreadonly;
            });
        },
        controller: function($scope, $attrs, sharedGenericService) {
          
            $scope.mecanismoPontPubl = function(){
              GenericService.putData($attrs.blkUrlService+"/mecanismoPontPubl", JSON.parse($attrs.blkactive)).then(function(response){
                if(typeof(response.status) == "undefined"){
                  $scope.pontpubl = response;
                  if($scope.blkRefresh && typeof($scope.blkRefresh) == "function")
                    $scope.blkRefresh(response, "pontpubl");
                }
              });
            }
            $scope.$on('handleBroadcast', function() {
              if ($scope.pontpubl !== sharedGenericService.pontpubl && DatasetManager.datasets &&
                  DatasetManager.datasets.hasOwnProperty('Publicacoes') &&
                  DatasetManager.datasets['Publicacoes'].toString() === "[Datasource]"){
                DatasetManager.datasets['Publicacoes'].cleanup();
              }
              
              $scope.pontpubl = sharedGenericService.pontpubl;
            });
            $scope.setPontpubl = function(){
              Publicacoes.active.publxPont = $scope.pontpubl;
            }
            $scope.novaPublicacao = function(datasource) {
              if (!datasource || typeof(datasource)==='undefined' || datasource.toString()!=='[Datasource]')
                return;
              datasource.startInserting();
              if (!datasource.data || datasource.data.length===0)
                datasource.active.versao = 1;
              else {
                var lastver = 0;
                for (var i=0;i<datasource.data.length;i++)
                  if (datasource.data[i].versao > lastver)
                    lastver = datasource.data[i].versao;
                datasource.active.versao = lastver+1;
              }
              datasource.active.publxNumFunc = $scope.blkVinc.numfunc;
              datasource.active.publxNumVinc = $scope.blkVinc.numvinc;
              datasource.active.publxTabela = $scope.blkPublTabela;
              
            }
           
            //Função para setar os atributos do DTO, no ui-select, a partir do objeto MotivoPublicacao
            //Utilizado no on-select do ui-select de MotivoPublicacao
            $scope.selectMotivo = function(selected){
              if(typeof(selected) !== 'undefined' && selected !== null){
                Publicacoes.active.motivoSigla = selected.sigla;
                Publicacoes.active.motivoDescricao = selected.descricao;
              }else{
                Publicacoes.active.motivoSigla = null;
                Publicacoes.active.motivoDescricao = null;
              }
            }
            //Função construir exibição do objeto MotivoPublicacao no ui-select a partir do DTO
            // Utilizado no ng-init e ng-click da linha da grid
            $scope.setMotivoPubl = function(){
              Publicacoes.active.motivoPublicacao = {
                "sigla" : Publicacoes.active.motivoSigla,
                "descricao" : Publicacoes.active.motivoDescricao
              }
            }
        },
        templateUrl: 'views/htmlDirectives/blkPubl.html',
      };
    
    }]);      
} (app));