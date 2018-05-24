(function ($app) {
    angular.module('page.controllers', []);
    
    app.controller('trpv0046', ['$scope',
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
        
        //Seta o ponteiro de publicação do registro corrente
        //Utilizado como callback na diretiva blkPont
        $scope.blkRefresh = function(pont, tipoPonteiro){
          if(tipoPonteiro == "pontpubl")
            $scope.Certidoes.row.pontPubl = pont;
        }
        
        // Membros públicos
        $scope.Certidoes                    = { data: [], env: false};
        $scope.Frequencias                  = { data: []};
        $scope.Cargos                       = { data: []};
        $scope.Vinculos                     = { data: []};
        
        $scope.numfunc                      = null;
        $scope.numvinc                      = null;
        $scope.verDetalhes                  = false;
        
        $scope.viewStateFlags               = {
                                                vinculoSelecionado      : false,
                                                esperandoProcesso       : false,
                                                inserindoNovaCertidao   : false,
                                                alterandoCertidao       : false,
                                                inserindoCargo          : false,
                                                alterandoCargo          : false,
                                                inserindoVinculo        : false,
                                                alterandoVinculo        : false,
                                                inserindoFrequencia     : false,
                                                alterandoFrequencia     : false
        };
        
        // Métodos expostos
        $scope.clearCertidoes               = clearCertidoes;
        $scope.populaCertidoes              = populaCertidoes;
        $scope.acessosPainel                = acessosPainel;
        
        $scope.submitForm                   = submitForm;
        $scope.resetViewState               = resetViewState;
        
        $scope.populaCargos                 = populaCargos;
        $scope.populaFrequencias            = populaFrequencias;
        $scope.populaVinculos               = populaVinculos;
        
        $scope.gerarDados                   = gerarDados;
        
        $scope.preparaInsercaoCertidao      = preparaInsercaoCertidao;
        $scope.copyToActiveCertidao         = copyToActiveCertidao;
        $scope.btnOKCertificadoHandler      = btnOKCertificadoHandler;
        $scope.btnRemCertidaoHandler        = btnRemCertidaoHandler;
        
        $scope.preparaInsercaoFrequencia    = preparaInsercaoFrequencia;
        $scope.copyToActiveFrequencia       = copyToActiveFrequencia;
        $scope.btnOKFrequenciaHandler       = btnOKFrequenciaHandler;
        $scope.btnRemFrequenciaHandler      = btnRemFrequenciaHandler;
        $scope.openFrequenciasForm          = openFrequenciasForm;
        
        $scope.preparaInsercaoCargos        = preparaInsercaoCargos;
        $scope.copyToActiveCargo            = copyToActiveCargo;
        $scope.btnOKCargoHandler            = btnOKCargoHandler;
        $scope.btnRemCargoHandler           = btnRemCargoHandler;
        $scope.openCargosForm               = openCargosForm;
        
        $scope.preparaInsercaoVinculo       = preparaInsercaoVinculo;
        $scope.copyToActiveVinculo          = copyToActiveVinculo;
        $scope.btnOKVinculoHandler          = btnOKVinculoHandler;
        $scope.btnRemVinculoHandler         = btnRemVinculoHandler;
        $scope.openVinculosForm             = openVinculosForm;
        
        $scope.btnUpdateFrequenciaHandler   = btnUpdateFrequenciaHandler;
        
        $scope.populaVinculosFuncionario    = populaVinculosFuncionario;

        // Watchers
        $scope.searchFunc = function(func) {
                    
                    var url = "api/rest/ergon/Funcionarios/listFuncionarios";

                    if (func.length > 0) {

                            if (IsNumeric(func)) {
                                if (func.length > 9 && func.length < 13) {
                                  url += '/cpf/' + func;
                                  populaFuncionarios(url);
                                  return;
                                }
                                if (func.length >= 13) {
                                  return;
                                }
                               url += '/numfunc/' + func;
                               populaFuncionarios(url);
                            } else {
                               url += '/nome/' + func;
                               populaFuncionarios(url);
                            }
                    }
            function IsNumeric(input) {
                return (input - 0) == input && ('' + input).trim().length > 0;
            }
            function populaFuncionarios(url) {
              GenericService.getData(url)
                  .then(
                    //success
                    function(response){
                        if(typeof(response.status) === "undefined"){
                          $scope.Funcionarios = {
                            data : response  
                          }
                        }
                        
                    }
                );
            } 
        }
        
        
        $scope.selectFunc = function(func) {
          if (func && typeof(func)==='object' && !angular.equals(func,{})) {
              clearCertidoes();
              $scope.viewStateFlags.vinculoSelecionado = true;
              $scope.numfunc = func.numero;
              
              
               $scope.populaCertidoes(function(data){
                 $scope.Certidoes.row = data[0];
               }); 
              
              $scope.populaVinculosFuncionario();
              acessosPainel();
            
          } else {
            $scope.viewStateFlags.vinculoSelecionado = false;
            resetViewState();
            clearCertidoes();
            
          }
        };
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////
        // Membros privados
        var parameterFormName     = null;
        var parameterFormCtrl     = null;
        var lastBlkVinc           = {numfunc: null, numvinc: null};
        
        
        /** -------------------------------------------------- 
         * 
         *  ---- FUNÇÕES DE CONTROLES DE TELA             ---
         * 
         *  --------------------------------------------------
        **/
        
        function acessosPainel(){
          
          
          //se não ha nenhum registro selecionado não libera a geração de dados
          $scope.viewStateFlags.gerarDadosHabilitado = $scope.Certidoes.row !== null;
          
          
        }
        
        function openFrequenciasForm(){
          $("#FrequenciaFormModal").modal({
              backdrop : "static",
              keyboard : false,
              show : true
           });
        }
        
        function openCargosForm(){
          $("#CargoFormModal").modal({
              backdrop : "static",
              keyboard : false,
              show : true
           });
        }
        
        function openVinculosForm(){
          $("#VinculoFormModal").modal({
              backdrop : "static",
              keyboard : false,
              show : true
           });
        }
        
        function clearCertidoes() {
          $scope.Certidoes                    = { data: [], env: true};
          $scope.Cargos                       = { data: []};
          $scope.Vinculos                     = { data: []};
          $scope.Frequencias                  = { data: []};
          
          resetViewState();
          
        }
        
        function preparaInsercaoCertidao(){
          $scope.Certidoes.active                = {
                                                idCertidao       	: null,
                                                numfunc       		: $scope.numfunc,
                                                numeroCertidao    : null,
                                                grupoFinalidade   : null,
                                                orgaoDestino   		: null,
                                                dataAContar       : null,
                                                dataSemEfeito     : null,
                                                numfuncDestino    : null,
                                                numvincDestino    : null,
                                                numeroVia       	: null,
                                                pontPubl       		: null,
                                                obs       			  : null,
                                                itemRegistro      : null,
                                                textoRegistro     : null,
                                                itemCertifico     : null,
                                                empCodigo       	: null,
                                                dataEmissao       : null };
          $scope.viewStateFlags.inserindoNovaCertidao = true;
        }
        
        function preparaInsercaoCargos(){
          $scope.Cargos.active                = {
                                                idCertidaoCargo           : $scope.idCertidao,
                                              	numvinc                   : $scope.numvinc,
                                              	dtini                     : null,
                                              	dtfim                     : null,
                                              	nomeCargo                 : null,
                                              	certidao                  : null,
                                              	portariaNomeacao          : null,
                                              	dataPublicacaoPortaria    : null,
                                              	numeroPortariaExoneracao  : null,
                                              	dataPortariaExonecarao    : null
          };
              $scope.viewStateFlags.inserindoCargo = true;
        }
        
        function preparaInsercaoVinculo(){
          $scope.Vinculos.active            = {
                                                idCertidaoVinculo         : $scope.idCertidao, 
                                          			vinculo                   : $scope.numvinc, 
                                          			dataIni                   : null,
                                          			dataFim                   : null, 
                                          			empresa                   : null, 
                                          			certidao                  : null
                                                
                                                 };
                $scope.viewStateFlags.inserindoVinculo = true;
        }
        
        function preparaInsercaoFrequencia(){
          $scope.Frequencias.active           = {
                                                idCertidaoFrequencia    : $scope.idCertidao,
                                            	  numvinc                 : $scope.numvinc,
                                            	  ano                     : null,
                                            	  bruto                   : null,
                                            	  faltas                  : null,
                                            	  licencas                : null,
                                            	  licencasSemVencer       : null,
                                            	  suspensoes              : null,
                                            	  disponibilidade         : null,
                                            	  outras                  : null,
                                            	  certidao                : null
                                                };
          $scope.viewStateFlags.inserindoFrequencia = true;
                                                
        }
        
        function copyToActiveCertidao(rowData){
          $scope.Certidoes.active = {};
          angular.copy(rowData, $scope.Certidoes.active);
        }
        
        function copyToActiveCargo(rowData){
          $scope.Cargos.active = {};
          angular.copy(rowData, $scope.Cargos.active);
        }
        
        function copyToActiveFrequencia(rowData){
          $scope.Frequencias.active = {};
          angular.copy(rowData, $scope.Frequencias.active);
          $scope.Frequencias.active.anoAux = new Date(rowData.ano, 0).getTime();
        }
        
        function copyToActiveVinculo(rowData){
          $scope.Vinculos.active = {};
          angular.copy(rowData, $scope.Vinculos.active);
        }
        
        //função que é disparada no momento em que submetem um formulario
        function submitForm(form){
          if(form.$valid) {
            $scope.Certidoes.env = false;
            if(form.$name === 'frmCertidao'){
              btnOKCertificadoHandler();
            }
            if(form.$name === 'frmFrequencia'){
              btnOKFrequenciaHandler();
            }
            if(form.$name === 'frmCargo'){
              btnOKCargoHandler();
            }
            if(form.$name === 'frmVinculo'){
              btnOKVinculoHandler();
            }
          }
          else
          {
            $scope.Certidoes.env = true;  //configura erros no form
          }
        }
        
        function validaBlkVinc() { 
          //Valida existência e coesão das informações de vínculo selecionado
          if (!$scope.blkVinc || typeof($scope.blkVinc)!=='object' || angular.equals($scope.blkVinc,{})) {
            showError({name:'Vínculo Ausente',message:'Nenhum vínculo selecionado'});
          } else
            return true;
        }
        
        function handleClickCertidao(){
            
            // TODO fazer validação de vinc anterior e posterior se necessário
            clearCertidoes();
            populaCertidoes();
        }
        
        /** ------------------------------------------------------------- 
         * 
         *  ---- FUNÇÕES DE TRATAMENTO DE ERROS E DE RESPOSTAS DE WS  ---
         * 
         *  ------------------------------------------------------------
        **/
        
        function trataErro(data) {
          //Tratamento unificado de erro de request HTTP
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
          showError({name:"Bad Request",message:error})
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

        function resetViewState() {
          $scope.viewStateFlags.esperandoProcesso               = false;
          $scope.viewStateFlags.geracaoHabilitada               = false;
          
          $scope.viewStateFlags.inserindoNovaCertidao           = false;
          $scope.viewStateFlags.alterandoCertidao               = false;
          $scope.viewStateFlags.inserindoCargo                  = false;
          $scope.viewStateFlags.alterandoCargo                  = false;
          $scope.viewStateFlags.inserindoVinculo                = false;
          $scope.viewStateFlags.alterandoVinculo                = false;
          $scope.viewStateFlags.inserindoFrequencia             = false;
          $scope.viewStateFlags.alterandoFrequencia             = false;
          
        }
        
        
        /** -------------------------------------------------- 
         * 
         *  ---- FUNÇÕES PARA POPULAR OS GRIDS DOS MODAIS  ---
         * 
         *  --------------------------------------------------
        **/
        
        function populaCertidoes(cb) {
          GenericService.getData("api/ws/rest/ergon/v1.0/certidoes/?numfunc="+$scope.numfunc+"&size=2000")
            .then(
              //success
              function(response) {
                $scope.Certidoes = {
                  data: response.content,
                  env: false
                };
                //callback
                if(cb && typeof(cb) == "function")
                  cb(response.content);
                
              },
              //failure
              function(response) {
                clearCertidoes();
              }
            );
        }
        
        function populaCargos(cb){
          GenericService.getData("api/ws/rest/ergon/v1.0/certidoes/cargo/?idCertidao="+$scope.Certidoes.active.idCertidao)
            .then(
              //success
              function(response) {
                $scope.Cargos = {
                  data: response.content
                };
                if(cb && typeof(cb) == "function")
                  cb(response.content);
                
              },
              //failure
              function(response) {
                clearCertidoes();
              }
            );
        }
        
        function populaFrequencias(cb) {
          GenericService.getData("api/ws/rest/ergon/v1.0/certidoes/frequencia/?idCertidao="+$scope.Certidoes.active.idCertidao)
            .then(
              //success
              function(response) {
                $scope.Frequencias = {
                  data : response.content
                };
                if(cb && typeof(cb) == "function")
                  cb(response.content);
                
              },
              //failure
              function(response) {
                clearCertidoes();
              }
            );
          
        }
        
        function populaVinculos(cb){
          GenericService.getData("api/ws/rest/ergon/v1.0/certidoes/vinculo/"+$scope.Certidoes.active.idCertidao)
            .then(
              //success
              function(response) {
                $scope.Vinculos = {data : response.content};
                
                if(cb && typeof(cb) == "function")
                  cb(response.content);
                
              },
              //failure
              function(response) {
                clearCertidoes();
              }
            );
        }
        
        function populaVinculosFuncionario(){
          GenericService.getData( (window.hostApp || "") + "api/ws/rest/ergon/v1.0/funcional/vinculos/vinculo/dadosFuncionais/numero/"+$scope.numfunc)
            .then(
              //success
              function(response) {
                
                $scope.VinculosFunc      = {data:[]};
                $scope.VinculosFunc.data = response;
              },
              //failure
              function(response) {
                clearCertidoes();
              }
            );
        }
        
        /** -------------------------------------------------------------------------------------------------------
         * 
         *  ---- CHAMADAS A FUNÇÕES POR METODOS PUT E POST PARA INSERÇÃO, ALTERAÇÃO DE DADOS, DELEÇÃO DE DADOS  ---
         * 
         *  -------------------------------------------------------------------------------------------------------
        **/
        
        //---------------------------------------------CERTIDAO
        function inserirCertidao() {
          var _url      = "api/ws/rest/ergon/v1.0/certidoes/"+$scope.numfunc;
          
          var form = parameterFormCtrl;
          
          $scope.Certidoes.active.numfunc = $scope.numfunc;
          var _data = $scope.receive($scope.Certidoes.active);
          
          GenericService.postData(_url, _data)
          .then(
            //Success
            function(response){
              $scope.viewStateFlags.esperandoProcesso = false;
              
              
              if(typeof(response.status) == "undefined"){
                populaCertidoes(function(data){
                
                  $scope.Certidoes.row = data.find(function(item){
                    return item.idCertidao == response.idCertidao;
                  });
                  copyToActiveCertidao($scope.Certidoes.row);
                  resetViewState();
                  $scope.seeDetails();
                  
                });
              }else{
                $scope.retrive($scope.Certidoes.active);
              }
              
              
            },
            //Error
            function(error){
              $scope.viewStateFlags.esperandoProcesso = false;
              //
              $scope.retrive($scope.Certidoes.active);
            }
          );
          
        } 
        
        function alterarCertidao() {
          var _url      = "api/ws/rest/ergon/v1.0/certidoes/"+$scope.Certidoes.active.idCertidao;
          
          var form = parameterFormCtrl;
          var _data = $scope.receive($scope.Certidoes.active);
          
          
          GenericService.putData(_url, _data)
          .then(
            //Success
            function(response){
              $scope.viewStateFlags.esperandoProcesso = false;
              
              
              if(typeof(response.status) == "undefined"){
                populaCertidoes(function(data){
                
                  $scope.Certidoes.row = data.find(function(item){
                    return item.idCertidao == response.idCertidao;
                  });
                  copyToActiveCertidao($scope.Certidoes.row);
                  resetViewState();
                  $scope.seeDetails();
                });
              }else{
                $scope.retrive($scope.Certidoes.active);
              }
              
            },
            //Error
            function(error){
              $scope.viewStateFlags.esperandoProcesso = false;
              //
              $scope.retrive($scope.Certidoes.active);
            }
          );
          
        } 
        
        function excluirCertidao() {
          var _url = "api/ws/rest/ergon/v1.0/certidoes/" + $scope.Certidoes.row.idCertidao
          
          var form = parameterFormCtrl;
          
          GenericService.deleteData(_url)
          .then(
            //Success
            function(response){
              $scope.viewStateFlags.esperandoProcesso = false;
              
              populaCertidoes(function(data){
                
                $scope.Certidoes.row = data[0];
                copyToActiveCertidao($scope.Certidoes.row);
                resetViewState();
              });
            },
            //Error
            function(error){
              $scope.viewStateFlags.esperandoProcesso = false;
            }
          );
          
        } 
        
        
        //---------------------------------------------CARGOS
        function inserirCargo() {
          var _url = "api/ws/rest/ergon/v1.0/certidoes/cargo";
          
          
          
          var form = parameterFormCtrl;
          $scope.Cargos.active.certidao = $scope.Certidoes.active.idCertidao;
          
          var _data = $scope.receive($scope.Cargos.active);
          
          
          GenericService.postData(_url, _data)
          .then(
            //Success
            function(response){
              $scope.viewStateFlags.esperandoProcesso = false;
              
              if(typeof(response.status) == "undefined"){
                populaCargos(function(data){
                
                  $scope.Cargos.row = data.find(function(item){
                    return item.idCertidaoCargo == response.idCertidaoCargo;
                  });
                  copyToActiveCargo($scope.Cargos.row);
                  resetViewState();
                  $scope.seeDetails();
                  
                });
              }else{
                $scope.retrive($scope.Cargos.active);
              }
              
            },
            //Error
            function(error){
              $scope.viewStateFlags.esperandoProcesso = false;
              //
              $scope.retrive($scope.Cargos.active);
            }
          );
          
        } 
        
        function alterarCargo() {
          var _url = "api/ws/rest/ergon/v1.0/certidoes/cargo/"+$scope.Cargos.active.idCertidaoCargo;
          
          
          
          var form = parameterFormCtrl;
          $scope.Cargos.active.certidao = $scope.Certidoes.active.idCertidao;
          
          var _data = $scope.receive($scope.Cargos.active);
          
          
          GenericService.putData(_url, _data)
          .then(
            //Success
            function(response){
              $scope.viewStateFlags.esperandoProcesso = false;
              
              
              if(typeof(response.status) == "undefined"){
                populaCargos(function(data){
                
                  $scope.Cargos.row = data.find(function(item){
                    return item.idCertidaoCargo == response.idCertidaoCargo;
                  });
                  copyToActiveCargo($scope.Cargos.row);
                  resetViewState();
                  $scope.seeDetails();
                  
                });
              }else{
                $scope.retrive($scope.Cargos.active);
              }
              
              
            },
            //Error
            function(error){
              $scope.viewStateFlags.esperandoProcesso = false;
              //
              $scope.retrive($scope.Cargos.active);
            }
          );
          
        } 
        
        function excluirCargo() {
          
          var _url = "api/ws/rest/ergon/v1.0/certidoes/cargo/" + $scope.Cargos.row.idCertidaoCargo;
          
          var form = parameterFormCtrl;
          
          GenericService.deleteData(_url)
          .then(
            //Success
            function(response){
              $scope.viewStateFlags.esperandoProcesso = false;
              
              populaCargos(function(data){
                
                $scope.Cargos.row = data[0];
                copyToActiveCargo($scope.Cargos.row);
                resetViewState();
              });
            },
            //Error
            function(error){
              $scope.viewStateFlags.esperandoProcesso = false;
            }
          );
          
        } 
        
        
        //---------------------------------------------FREQUENCIAS
        function inserirFrequencia() {
          var _url = "api/ws/rest/ergon/v1.0/certidoes/frequencia";
          
          var form = parameterFormCtrl;
          $scope.Frequencias.active.certidao = $scope.Certidoes.active.idCertidao;
          //Ano attribute
            $scope.Frequencias.active.ano = new Date($scope.Frequencias.active.anoAux).getFullYear();
          
          
          var _data = $scope.receive($scope.Frequencias.active);
          
          
          GenericService.postData(_url, _data)
          .then(
            //Success
            function(response){
              $scope.viewStateFlags.esperandoProcesso = false;
              
              if(typeof(response.status) == "undefined"){
                populaFrequencias(function(data){
                
                  $scope.Frequencias.row = data.find(function(item){
                    return item.idCertidaoFrequencia == response.idCertidaoFrequencia;
                  });
                  copyToActiveFrequencia($scope.Frequencias.row);
                  resetViewState();
                  $scope.seeDetails();
                  
                });
              }else{
                $scope.retrive($scope.Frequencias.active);
              }
              
            },
            //Error
            function(error){
              $scope.viewStateFlags.esperandoProcesso = false;
              //
              $scope.retrive($scope.Frequencias.active);
            }
          );
          
        } 
        
        function alterarFrequencia() {
          var _url      = "api/ws/rest/ergon/v1.0/certidoes/frequencia/"+$scope.Frequencias.active.idCertidaoFrequencia;
          
          var form = parameterFormCtrl;
          $scope.Frequencias.active.certidao = $scope.Certidoes.active.idCertidao;
          
          //Ano attribute
            $scope.Frequencias.active.ano = new Date($scope.Frequencias.active.anoAux).getFullYear();
          
          
          var _data = $scope.receive($scope.Frequencias.active);
          
          
          GenericService.putData(_url, _data)
          .then(
            //Success
            function(response){
              $scope.viewStateFlags.esperandoProcesso = false;
              
              if(typeof(response.status) == "undefined"){
                populaFrequencias(function(data){
                
                  $scope.Frequencias.row = data.find(function(item){
                    return item.idCertidaoFrequencia == response.idCertidaoFrequencia;
                  });
                  copyToActiveFrequencia($scope.Frequencias.row);
                  resetViewState();
                  $scope.seeDetails();
                  
                });
              }else{
                $scope.retrive($scope.Frequencias.active);
              }
              
            },
            //Error
            function(error){
              $scope.viewStateFlags.esperandoProcesso = false;
              //
              $scope.retrive($scope.Frequencias.active);
            }
          ); 
          
          
        } 
        
        function excluirFrequencia() {
          var _url = "api/ws/rest/ergon/v1.0/certidoes/frequencia/"+$scope.Frequencias.active.idCertidaoFrequencia;
          
          var form = parameterFormCtrl;
          
          GenericService.deleteData(_url)
          .then(
            //Success
            function(response){
              $scope.viewStateFlags.esperandoProcesso = false;
              
              if(typeof(response.status) == "undefined"){
                populaFrequencias(function(data){
                
                  $scope.Frequencias.row = data[0];
                  copyToActiveFrequencia($scope.Frequencias.row);
                  resetViewState();
                  
                });
              }else{
                $scope.retrive($scope.Frequencias.active);
              }
              
            },
            //Error
            function(error){
              $scope.viewStateFlags.esperandoProcesso = false;
              //
              $scope.retrive($scope.Frequencias.active);
            }
          );
          
        } 
        
        
        //---------------------------------------------VINCULOS
        function inserirVinculo() {
          var _url      ="api/ws/rest/ergon/v1.0/certidoes/vinculo";
          
          var form = parameterFormCtrl;
          $scope.Vinculos.active.certidao = $scope.Certidoes.active.idCertidao;
          
          var _data = $scope.receive($scope.Vinculos.active);
          
          
          GenericService.postData(_url, _data)
          .then(
            //Success
            function(response){
              $scope.viewStateFlags.esperandoProcesso = false;
              
              if(typeof(response.status) == "undefined"){
                populaVinculos(function(data){
                
                  $scope.Vinculos.row = data.find(function(item){
                    return item.idCertidaoVinculo == response.idCertidaoVinculo;
                  });
                  copyToActiveVinculo($scope.Vinculos.row);
                  resetViewState();
                  $scope.seeDetails();
                  
                });
              }else{
                $scope.retrive($scope.Vinculos.active);
              }
              
            },
            //Error
            function(error){
              $scope.viewStateFlags.esperandoProcesso = false;
              //
              $scope.retrive($scope.Vinculos.active);
            }
          );
          
        } 
        
        function alterarVinculo() {
          var _url      ="api/ws/rest/ergon/v1.0/certidoes/vinculo/"+$scope.Vinculos.active.idCertidaoVinculo;
          
          var form = parameterFormCtrl;
          $scope.Vinculos.active.certidao = $scope.Certidoes.active.idCertidao;
          
          var _data = $scope.receive($scope.Vinculos.active);
          
          
          GenericService.putData(_url, _data)
          .then(
            //Success
            function(response){
              $scope.viewStateFlags.esperandoProcesso = false;
              
              if(typeof(response.status) == "undefined"){
                populaVinculos(function(data){
                
                  $scope.Vinculos.row = data.find(function(item){
                    return item.idCertidaoVinculo == response.idCertidaoVinculo;
                  });
                  copyToActiveVinculo($scope.Vinculos.row);
                  resetViewState();
                  $scope.seeDetails();
                  
                });
              }else{
                $scope.retrive($scope.Vinculos.active);
              }
              
            },
            //Error
            function(error){
              $scope.viewStateFlags.esperandoProcesso = false;
              //
              $scope.retrive($scope.Vinculos.active);
            }
          );
          
        } 
        
        function excluirVinculo() {
          var _url      ="api/ws/rest/ergon/v1.0/certidoes/vinculo/"+$scope.Vinculos.active.idCertidaoVinculo;
          
          var form = parameterFormCtrl;
          $scope.Vinculos.active.certidao = $scope.Certidoes.active.idCertidao;
          
          var _data = $scope.receive($scope.Vinculos.active);
          
          
          GenericService.deleteData(_url)
          .then(
            //Success
            function(response){
              $scope.viewStateFlags.esperandoProcesso = false;
              
              if(typeof(response.status) == "undefined"){
                populaVinculos(function(data){
                
                  $scope.Vinculos.row = data[0];
                  copyToActiveVinculo($scope.Vinculos.row);
                  resetViewState();
                  
                });
              }else{
                $scope.retrive($scope.Vinculos.active);
              }
              
            },
            //Error
            function(error){
              $scope.viewStateFlags.esperandoProcesso = false;
              //
              $scope.retrive($scope.Vinculos.active);
            }
          );
          
        } 
        
        /** CHAMADAS A PROCEDURES POR METODO POST **/
        function gerarDados() {
          var _method   = "POST";
          var _url      = (window.hostApp || "") + "api/ws/rest/ergon/v1.0/certidoes/gerardados";
          var _headers  = "origin-path:" + $location.path();
          
          function trataSucesso(data) {
            var _d = data;
            if (typeof(_d)==='object'&&_d.hasOwnProperty('idCertidao')) {
                populaCertidoes();
                Notification.success({message: 'Operação efetuada com sucesso!', delay: 3000});
                //TODO fechar modal angular.element(document.getElementById('RevisaoAcaoJudicial')).close();
                
            } else {
              trataErro(data);
            }
          }
          
          var form = parameterFormCtrl;
          var _data = JSON.stringify({
            	
            	idCertidao       	: $scope.Certidoes.row.idCertidao
              
          })
          
          $scope.viewStateFlags.esperandoProcesso = true;
          var $promise = $http({
            method  : _method,
            url     : _url,
            data    : _data,
            headers : _headers
          })
            .success(function(data, status, headers, config) {
              $scope.viewStateFlags.esperandoProcesso = false;
              
              trataSucesso(data);
          })
            .error(function(data, status, headers, config) {
              $scope.viewStateFlags.esperandoProcesso = false;
              trataErro(data);
          });
          
        }     
        
        
        /** --------------------------------------------------
         *  ---     Handlers de botoes na tela        --------
         *  --------------------------------------------------
         */ 
        
        // btnOK
        function btnOKCertificadoHandler(){
          
          //se não é somente visualizacao.
          if($scope.viewStateFlags.inserindoNovaCertidao || $scope.viewStateFlags.alterandoCertidao){
            if($scope.viewStateFlags.inserindoNovaCertidao){
              inserirCertidao();
            }else{
              alterarCertidao();
            }
          }
        }
        
        function btnOKCargoHandler(){
          //se não é somente visualizacao.
          if($scope.viewStateFlags.inserindoCargo || $scope.viewStateFlags.alterandoCargo){
            if($scope.viewStateFlags.inserindoCargo){
              inserirCargo();
            }else{
              alterarCargo();
            }
          }
        }
        
        function btnOKFrequenciaHandler(){
        //se não é somente visualizacao.
          if($scope.viewStateFlags.inserindoFrequencia || $scope.viewStateFlags.alterandoFrequencia){  
            if($scope.viewStateFlags.inserindoFrequencia){
              inserirFrequencia();
            }else{
              alterarFrequencia();
            }
          }
        }
        
        function btnOKVinculoHandler(){
          
          //se não é somente visualizacao.
          if($scope.viewStateFlags.inserindoVinculo || $scope.viewStateFlags.alterandoVinculo){
            if($scope.viewStateFlags.inserindoVinculo){
              inserirVinculo();
            }else{
              alterarVinculo();
            }
          }
          
        }
        
        // btnExcluir
        function btnRemCertidaoHandler(){
            
          $.prompt("Deseja remover ?", {
          	buttons: { "Ok": true, "Cancel": false },
          	focus: 1,
          	zIndex: 9999,
          	opacity: 0.4,
          	submit: function(e,v,m,f){
          		if(v){
          		  excluirCertidao();
                clearCertidoes();
                populaCertidoes();
          		}
          	}
          });
        }
        
        function btnRemFrequenciaHandler(){
            
          $.prompt("Deseja remover ?", {
          	buttons: { "Ok": true, "Cancel": false },
          	focus: 1,
          	zIndex: 9999,
          	opacity: 0.4,
          	submit: function(e,v,m,f){
          		if(v){
          		  excluirFrequencia();
          		}
          	}
          });
            
             
        }
        
        function btnRemCargoHandler(){
            $.prompt("Deseja remover ?", {
          	buttons: { "Ok": true, "Cancel": false },
          	focus: 1,
          	zIndex: 9999,
          	opacity: 0.4,
          	submit: function(e,v,m,f){
          		if(v){
          		  excluirCargo();
          		}
          	}
          });
            
             
            
        }
        
        function btnRemVinculoHandler(){
            $.prompt("Deseja remover ?", {
          	buttons: { "Ok": true, "Cancel": false },
          	focus: 1,
          	zIndex: 9999,
          	opacity: 0.4,
          	submit: function(e,v,m,f){
          		if(v){
          		  excluirVinculo();
          		}
          	}
          });
            
             
        }
        
        function btnUpdateFrequenciaHandler(rowData){
          $scope.viewStateFlags.alterandoFrequencia =   true;
          var found = false;
          var updatedData;
          for (i = 0; i<$scope.Frequencias.data.length && !found; i++) {
                if ($scope.Frequencias.data[i].idCertidaoFrequencia === rowData.idCertidaoFrequencia) {
                    updatedData     =         {
                                                idCertidaoFrequencia    : rowData.idCertidaoFrequencia,
                                            	  numeroVinculo           : rowData.numeroVinculo,
                                            	  ano                     : rowData.ano,
                                            	  bruto                   : rowData.bruto,
                                            	  faltas                  : rowData.faltas,
                                            	  licencas                : rowData.licencas,
                                            	  licencasSemVencer       : rowData.licencasSemVencer,
                                            	  suspensoes              : rowData.suspensoes,
                                            	  disponibilidade         : rowData.disponibilidade,
                                            	  outras                  : rowData.outras,
                                            	  certidao                : rowData.certidao
                    }
                    
                    angular.copy(updatedData, $scope.Frequencias.data[i]);
                    found = true;
                }
          }

        }
        
        
        // btnGeraDados
        function handleGeraCertidoes(){
          if ($scope.viewStateFlags.esperandoProcesso ) {
            showWarning({name:'Solicitação inváida',message:'Já existe solicitação sendo processada, aguarde o término da execução'});
          } else if (validaParametros() && validaBlkVinc()) {
           
            //TODO :  1. Fazer validações necessárias, 2. Chamar o Serviço que chama a proc que executa o processo.
            registrarTCEAposentadoria();
          }
        }
        
        $scope.seeDetails = function(){
          $scope.verDetalhes = true;
        }
        $scope.fecharModal = function(){
          $scope.verDetalhes = false;
          $scope.Certidoes.env = false;
          $scope.viewStateFlags.alterandoCertidao = false;
          $scope.viewStateFlags.inserirCertidao = false;
        }
        
      }
    ]);
    
} (app));
