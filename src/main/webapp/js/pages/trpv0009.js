(function ($app) {
    angular.module('page.controllers', []);

    app.filter('tipoSimulacaoDesc', function() {
      return function(input) {
        if (input === null) return '  ';
        var sigla = input || '';
        if (sigla == 'I') return 'Inicial';
        if (sigla == 'A') return 'Autorização';
        if (sigla == 'C') return 'Concessão';
        if (sigla == 'P') return 'Portal';
        return sigla;
      }
    });
    
    app.controller('trpv0009', ['$scope',
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
      function ($scope, $sce, $http, $rootScope, $state, $location, $translate, $timeout, Notification, stripBarsFilter, GenericService, ReportService) {
        
        // Membros públicos
        $scope.idSimulacao                  = null;
        $scope.simulacaoApos                = {};
        $scope.SimulacaoTempo               = {data: []};
        $scope.SimulacaoFixacao             = {data: []};
        $scope.SimulacaoFixacaoRubricas     = {data: []};
        $scope.detalhesAutorefreshInterval  = 3;//s
        $scope.simulacaoIncluiFixacao       = true;
        $scope.viewStateFlags               = {
          vinculoSelecionado              : false,
          btnSimulacaoDisabled            : false,
          geraSimulacaoWaitingRequest     : false,
          detalhesSimulacaoWaitingRequest : false,
          aguardandoContagem              : false,
          aguardandoFixacao               : false,
          contagemSimulada                : false,
          fixacaoSimulada                 : false,
          detalhesSimulacaoAutorefresh    : true
        };
        
        // Métodos expostos
        $scope.registerParameterForm    = registerParameterForm;
        $scope.handleBtnSimulacaoClick  = handleBtnSimulacaoClick;
        $scope.handleSwitchAutorefresh  = handleSwitchAutorefresh;
        $scope.handleClickFixacaoGrid   = handleClickFixacaoGrid;
        $scope.forceNewSimulacao        = forceNewSimulacao;
        $scope.usePrevSimulacao         = usePrevSimulacao;
        $scope.refreshDetalhesSimulacao = refreshDetalhesSimulacao;
        $scope.clearSimulacao           = clearSimulacao;
        
        // Watchers
        $scope.$watch(function() {
            return $scope.idSimulacao;
          }.bind($scope), function(idSimulacao) {
          if ((idSimulacao && !lastIdSimulacao) || (!idSimulacao && lastIdSimulacao)) {
            $('#detalhesSimulacaoDiv').collapse('toggle');
          } 
          lastIdSimulacao = idSimulacao;
        });
        
        $scope.$watch(function() {
          return $scope.viewStateFlags.vinculoSelecionado;
        }.bind($scope), function(vinculoSelecionado) {
          if ((!histFuncDivOpen && vinculoSelecionado) || (histFuncDivOpen && !vinculoSelecionado))
            $('#historicoFuncionalDiv').collapse('toggle');
          histFuncDivOpen = vinculoSelecionado;
        })
        
        $scope.$watch(function() {
          return $scope.blkVinc;
        }.bind($scope), function(blkVinc) {
          if (blkVinc && typeof(blkVinc)==='object' && !angular.equals(blkVinc,{})) {
            if (lastBlkVinc.numfunc!==blkVinc.numfunc || lastBlkVinc.numvinc!==blkVinc.numvinc) {
              clearSimulacao();
              clearParameterForm();
              $scope.viewStateFlags.vinculoSelecionado = true;
            }
            lastBlkVinc.numfunc = blkVinc.numfunc;
            lastBlkVinc.numvinc = blkVinc.numvinc;
          } else {
            $scope.viewStateFlags.vinculoSelecionado = false;
            resetViewState();
          }
        });

        ////////////////////////////////////////////////////////////////////////////////////////////////////
        // Membros privados
        var parameterFormName     = null;
        var parameterFormCtrl     = null;
        var lastIdSimulacao       = null;
        var lastFetchedSimulacao  = null;
        var pendingAutorefresh    = null;
        var lastIdFixacao         = null;
        var histFuncDivOpen       = false;
        var lastBlkVinc           = {numfunc: null, numvinc: null};
        
        // Declaração de métodos
        function registerParameterForm(form) {
          if (form && typeof(form)==='string' && $scope.hasOwnProperty(form)) {
            parameterFormName = form;
            parameterFormCtrl = $scope[form];
          } else {
            showError({name:'Elemento inválido',message:'Não foi possível localizar o formulário '+form+' no documento'});
          }
        }
        
        function validaParametros() {
          //Valida existência e coesão das informações no form de parâmetros
          if (!parameterFormCtrl) {
            showError({name:'Form Inválido',message:'Form de parâmetros não configurado'});
          } else
            return true;
        }
        
        function validaBlkVinc() { 
          //Valida existência e coesão das informações de vínculo selecionado
          if (!$scope.blkVinc || typeof($scope.blkVinc)!=='object' || angular.equals($scope.blkVinc,{})) {
            showError({name:'Vínculo Ausente',message:'Nenhum vínculo selecionado'});
          } else
            return true;
        }
        
        function fetchSimulacaoByUK(numfunc, numvinc, data) {
          //Retorna $promise da busca pelos dados da simulação para o vínculo na data informada
          var _method   = "GET";
          var _url      = (window.hostApp || "") + "api/ws/rest/ergon/v1.0/aposentadoria/simulacoes";
          var _headers  = "origin-path:" + $location.path();
          
          if (numfunc && numfunc !== null && !Number.isNaN(numfunc) &&
              numvinc && numvinc !== null && !Number.isNaN(numvinc) &&
              data && data !== null && moment(new Date(data)).isValid())
          {
            var _path     = '/' + numfunc + '/' + numvinc + '/' + data;
            var _params   = {};
          
            return $http({
              method  : _method,
              url     : _url + _path,
              params  : _params,
              headers : _headers
            });
            
          } else {
            showError({name:"Parâmetros inválidos",message:"Erro nos parâmetros informados {numfunc:"+numfunc+",numvinc:"+numvinc+",data:"+data+"}"});
          }
        }
        
        function fetchSimulacaoByID(idSimulacao) {
          //Retorna $promise da busca pelos dados da simulação com o id informado
          var _method   = "GET";
          var _url      = (window.hostApp || "") + "api/ws/rest/ergon/v1.0/aposentadoria/simulacoes/simulacao";
          var _headers  = "origin-path:" + $location.path();
          
          if (idSimulacao && idSimulacao !== null && typeof(idSimulacao)==='string')
          {
            var _path     = '/' + idSimulacao;
          
            return $http({
              method  : _method,
              url     : _url + _path,
              params  : {},
              headers : _headers
            });
            
          } else {
            showError({name:"Parâmetro inválido",message:"Erro no parâmetro informado {idSimulacao:"+idSimulacao+"}"});
          }
        }
        
        function handleBtnSimulacaoClick() {
          if ($scope.viewStateFlags.detalhesSimulacaoWaitingRequest) {
            showWarning({name:'Solicitação inváida',message:'Já existe solicitação sendo processada, aguarde o término da execução'});
          } else if (validaParametros() && validaBlkVinc()) {
            //TODO: Validação de execução repetida ou indevida
            
            if(validDateSelected()){
          
              if (parameterFormCtrl.$invalid) return;
            
              $scope.viewStateFlags.btnSimulacaoDisabled = true;
              clearSimulacao();
              
              $scope.viewStateFlags.detalhesSimulacaoWaitingRequest = true;
              fetchSimulacaoByUK($scope.blkVinc.numfunc, $scope.blkVinc.numvinc, parameterFormCtrl.data.$modelValue)
                .success(function(data, status, headers, config) {
                  $scope.viewStateFlags.detalhesSimulacaoWaitingRequest = false;
                  if (data && data !== null) {
                    if (Object.prototype.toString.call(data) === "[object Array]") {
                      lastFetchedSimulacao = data[0];
                    } else {
                      lastFetchedSimulacao = data;
                    }
                    informaSimulacaoExistente();
                  } else {
                    geraSimulacaoApos();
                  }
                })
                .error(function(data, status, headers, config) {
                  $scope.viewStateFlags.detalhesSimulacaoWaitingRequest = false;
                  geraSimulacaoApos();
                });
            }else{
              showWarning({name:"Data inválida",message:"Data de referência para simulação deve ser anterior a data corrente"});
              parameterFormCtrl.data.$setViewValue(null); parameterFormCtrl.data.$render();
            }
          }
        }
        
        function handleClickFixacaoGrid(id_fixacao_fv) {
          if (lastIdFixacao!=id_fixacao_fv) {
            clearFixacaoRubricasGrid();
            lastIdFixacao = id_fixacao_fv;
            populaSimulacaoFixacaoRubricas(id_fixacao_fv);
          }
        }
        
        function informaSimulacaoExistente() {
          //TODO: Exibir o popup de confirmação de uso da informação existente e chamar condicionalmente setSimulacao ou geraSimulacao nos métodos ng-click dos botões
          $('.bs-simulacao-existente-sm').modal('toggle');
        }
        
        function geraSimulacaoApos() {
          var _method   = "POST";
          var _url      = (window.hostApp || "") + "api/ws/rest/ergon/v1.0/aposentadoria/simulacoes/simulacao";
          var _headers  = "origin-path:" + $location.path();
          
          function trataSucesso(data) {
            var _d = data;
            if (typeof(_d)==='object'&&_d.hasOwnProperty('idSimulacao')) {
              if (_d.idSimulacao===null) {
                showError({name:"ID Não Retornado",message:"Valor de ID de Simulação não retornado ou inválido"});
              } else {
                getDetalhesSimulacaoByID(_d.idSimulacao);
              }
            } else {
              trataErro(data);
            }
          }
          
          var form = parameterFormCtrl;
          var _data = JSON.stringify({
            numfunc       : $scope.blkVinc.numfunc,
            numvinc       : $scope.blkVinc.numvinc,
            tipoSimulacao : 'I',
            apenasTempo   : form.apenasTempo.$modelValue,
            data          : form.data.$modelValue,
            diasFerDobro  : form.diasFerDobro.$modelValue,
            diasLpDobro   : form.diasLpDobro.$modelValue,
            diasServPubl  : form.diasServPubl.$modelValue,
            diasServPriv  : form.diasServPriv.$modelValue,
            idSimulacao   : null
          });
          
          $scope.viewStateFlags.geraSimulacaoWaitingRequest = true;
          var $promise = $http({
            method  : _method,
            url     : _url,
            data    : _data,
            headers : _headers
          })
            .success(function(data, status, headers, config) {
              $scope.viewStateFlags.geraSimulacaoWaitingRequest = false;
              trataSucesso(data);
          })
            .error(function(data, status, headers, config) {
              $scope.viewStateFlags.geraSimulacaoWaitingRequest = false;
              trataErro(data);
          });
          
        }
        
        function usePrevSimulacao() {
          if (!lastFetchedSimulacao) {
            showError({name:'Dados não encontrados',message:'Não existem dados de simulação prévia para carregar'});
          } else {
            setSimulacao(lastFetchedSimulacao);
            lastFetchedSimulacao = null;
          }
        }
        
        function forceNewSimulacao() {
          lastFetchedSimulacao = null;
          geraSimulacaoApos();
        }
        
        function refreshDetalhesSimulacao() {
          if ($scope.idSimulacao) {
            getDetalhesSimulacaoByID($scope.idSimulacao);
          }
        }
        
        function getDetalhesSimulacaoByID(idSimulacao) {
          $scope.viewStateFlags.detalhesSimulacaoWaitingRequest = true;
          fetchSimulacaoByID(idSimulacao)
            .success(function(data, status, headers, config) {
              $scope.viewStateFlags.detalhesSimulacaoWaitingRequest = false;
              if (data && data !== null) {
                setSimulacao(data);
              } else {
                trataErro(data);
              }
            })
            .error(function(data, status, headers, config) {
              $scope.viewStateFlags.detalhesSimulacaoWaitingRequest = false;
              trataErro(data);
            });
        }
        
        function setSimulacao(regSimulacaoApos) {
          $scope.simulacaoApos  = Object.assign($scope.simulacaoApos, regSimulacaoApos);
          $scope.idSimulacao    = regSimulacaoApos.id;
          if (regSimulacaoApos.apenasTempo=='N')
            $scope.simulacaoIncluiFixacao = true;
          else
            $scope.simulacaoIncluiFixacao = false;
          if (regSimulacaoApos.situacao && typeof(regSimulacaoApos.situacao)==='string') {
            // Controla as flags de execução em aguardo
            if (regSimulacaoApos.situacao=="EM FILA" ||
                regSimulacaoApos.situacao=="EM ANDAMENTO - CONTAGEM")
            {
              $scope.viewStateFlags.aguardandoContagem = true;
              if ($scope.simulacaoApos.apenasTempo=="N") {
                $scope.viewStateFlags.aguardandoFixacao = true;
              }
            } else {
              $scope.viewStateFlags.aguardandoContagem = false;
              if ($scope.simulacaoApos.apenasTempo=="N" && regSimulacaoApos.situacao=="EM ANDAMENTO - FOLHA") {
                $scope.viewStateFlags.aguardandoFixacao = true;
              } else {
                $scope.viewStateFlags.aguardandoFixacao = false;
              }
            }
            // Controla a atualização automática
            if ($scope.viewStateFlags.detalhesSimulacaoAutorefresh &&
                (regSimulacaoApos.situacao=="EM FILA" ||
                 regSimulacaoApos.situacao=="EM ANDAMENTO - CONTAGEM" ||
                 regSimulacaoApos.situacao=="EM ANDAMENTO - FOLHA"))
            {
              queueRefresh();
            } else {
              cancelRefresh();
            }
            // Controla o preenchimento do resumo da contagem
            if (!$scope.viewStateFlags.contagemSimulada &&
                (regSimulacaoApos.situacao=="EM ANDAMENTO - FOLHA" || 
                 regSimulacaoApos.situacao=="CONCLUIDA"))
            {
              populaSimulacaoTempo();
            }
            // Controla o preenchimento do resumo de fixação
            if (!$scope.viewStateFlags.fixacaoSimulada &&
                $scope.simulacaoApos.apenasTempo=="N" &&
                regSimulacaoApos.situacao=="CONCLUIDA")
            {
              populaSimulacaoFixacao();
            }
            // Reabilita o botão de simulação somente após interrupção ou conclusão
            if ($scope.viewStateFlags.btnSimulacaoDisabled &&
                (regSimulacaoApos.situacao=="INTERROMPIDA" || 
                 regSimulacaoApos.situacao=="CONCLUIDA"))
            {
              $scope.viewStateFlags.btnSimulacaoDisabled  = false;
            }
          }
        }
        
        function handleSwitchAutorefresh() {
          if ($scope.viewStateFlags.detalhesSimulacaoAutorefresh) {
            // inicia o autorefresh
            refreshDetalhesSimulacao();
          } else {
            // interrompe o autorefresh
            cancelRefresh();
          }
        }
        
        function queueRefresh() {
          pendingAutorefresh = $timeout(
              function() {
                getDetalhesSimulacaoByID($scope.idSimulacao);
              }, 
              ($scope.detalhesAutorefreshInterval?$scope.detalhesAutorefreshInterval * 1000:1000)
            );
        }
        
        function cancelRefresh() {
          if (pendingAutorefresh!==null) {
            $timeout.cancel(pendingAutorefresh);
            pendingAutorefresh = null;
          }
        }
        
        function clearSimulacao() {
          cancelRefresh();
          if ($scope.viewStateFlags.fixacaoSimulada)
            clearSimulacaoFixacao();
          if ($scope.viewStateFlags.contagemSimulada)
            clearSimulacaoTempo();
          $scope.simulacaoApos  = {};
          $scope.idSimulacao    = null;
          $scope.simulacaoIncluiFixacao = true;
        }
        
        function clearSimulacaoTempo() {
          $scope.SimulacaoTempo.data = [];
          $scope.viewStateFlags.contagemSimulada  = false;
          $scope.viewStateFlags.aguardandoContagem = false;
        }
        
        function clearSimulacaoFixacao() {
          clearFixacaoRubricasGrid();
          $scope.SimulacaoFixacao.data = [];
          $scope.viewStateFlags.fixacaoSimulada  = false;
          $scope.viewStateFlags.aguardandoFixacao = false;
        }
        
        function clearFixacaoRubricasGrid() {
          $scope.SimulacaoFixacaoRubricas.data = [];
          lastIdFixacao = null;
        }
        
        function clearParameterForm() {
          if (parameterFormCtrl) {
            parameterFormCtrl.data.$setViewValue(null); parameterFormCtrl.data.$render();
            parameterFormCtrl.apenasTempo.$setViewValue("N"); parameterFormCtrl.apenasTempo.$render();
            parameterFormCtrl.diasServPriv.$setViewValue(null); parameterFormCtrl.diasServPriv.$render();
            parameterFormCtrl.diasServPubl.$setViewValue(null); parameterFormCtrl.diasServPubl.$render();
            parameterFormCtrl.diasLpDobro.$setViewValue(null); parameterFormCtrl.diasLpDobro.$render();
            parameterFormCtrl.diasFerDobro.$setViewValue(null); parameterFormCtrl.diasFerDobro.$render();
          }
        }
        
        function populaSimulacaoTempo() {
          GenericService.getData(
            "api/ws/rest/ergon/v1.0/aposentadoria/simulacoes/simulacao/resultados/contagem/"+$scope.idSimulacao,
            function(data,error) {
              if (error) {
                if (!data.status || data.status != 404)
                  clearSimulacaoTempo();
                trataErro(data);
              } else {
                $scope.SimulacaoTempo.data              = data;
                $scope.viewStateFlags.contagemSimulada  = true;
              }
            });
        }
        
        function populaSimulacaoFixacao() {
          GenericService.getData(
            "api/ws/rest/ergon/v1.0/aposentadoria/simulacoes/simulacao/resultados/fixacao/"+$scope.idSimulacao,
            function (data,error) {
              if (error) {
                if (!data.status || data.status != 404)
                  clearSimulacaoFixacao();
                trataErro(data);
              } else {
                /*
                data.map(function(simulacao){
                  simulacao.tipoReajuste = simulacao.tipoCalculo;
                  if(simulacao.tipoCalculo == 'PARIDADE'){
                    simulacao.tipoCalculo = 'Último vencimento';
                  }
                  if(simulacao.tipoCalculo == 'MEDIA'){
                    simulacao.tipoCalculo = 'Média';
                  }
                });
                */
                $scope.SimulacaoFixacao.data          = data;
                $scope.viewStateFlags.fixacaoSimulada = true;
                
                if ($scope.SimulacaoFixacao.data.length > 0)
                  handleClickFixacaoGrid($scope.SimulacaoFixacao.data[0].id);
              }
            });
        }
        
        function populaSimulacaoFixacaoRubricas(idFixacao) {
          GenericService.getData(
            "api/ws/rest/ergon/v1.0/aposentadoria/simulacoes/simulacao/resultados/fixacao/resultado/parcelas/"+$scope.idSimulacao+"/"+idFixacao,
            function (data, error) {
              if (error) {
                trataErro(data);
              } else {
                $scope.SimulacaoFixacaoRubricas.data  = data;
              }
            });
        }
        
        function trataErro(data) {
          //Tratamento unificado de erro de request HTTP
          if (data.status && data.status == 404) {
            console.log("404 - Nenhum registro encontrado");
          } else {
            var error = "";
            if (data) {
              if (Object.prototype.toString.call(data) === "[object String]") {
                error = data;
              } else {
                var errorMsg = (data.msg || data.desc || data.message || data.error || data.responseText);
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
            $scope.viewStateFlags.btnSimulacaoDisabled = false;
            showError({name:"Bad Request",message:error});
          }
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

        function resetViewState() {
          clearSimulacao();
          clearParameterForm();
          lastBlkVinc                                           = {numfunc:false, numvinc:false};
          $scope.viewStateFlags.vinculoSelecionado              = false;
          $scope.viewStateFlags.btnSimulacaoDisabled            = false;
          $scope.viewStateFlags.detalhesSimulacaoWaitingRequest = false;
          $scope.viewStateFlags.geraSimulacaoWaitingRequest     = false;
          $scope.viewStateFlags.contagemSimulada                = false;
          $scope.viewStateFlags.fixacaoSimulada                 = false;
          $scope.simulacaoIncluiFixacao                         = true;
        }
        
        function validDateSelected(){
          var strData = parameterFormCtrl.data.$modelValue;
          var partesData = strData.split("-");
          var data = new Date(partesData[0], partesData[1] - 1, partesData[2]);
          if(data > (new Date())){
            clearSimulacao();
            return false;
          }
          return true;
        }
        
      }
    ]);
    
} (app));
