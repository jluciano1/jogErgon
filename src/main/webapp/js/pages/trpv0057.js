(function ($app) {
  angular.module('page.controllers', []);
  
    app.controller('trpv0057', ['$scope', 
                                '$http', 
                                '$rootScope', 
                                '$state', 
                                '$location', 
                                '$timeout',
                                '$translate', 
                                'Notification',
                                'stripBarsFilter',
                                'GenericService',
      function ($scope, $http, $rootScope, $state, $location, $timeout, $translate, Notification, stripBarsFilter, GenericService) {
        
        $scope.FolMovimentos = { data: [] };
        $scope.InfoMov = { data: [] };
        $scope.pageInfo = { data: [] };
        $scope.Rubrica = { data: [] };
        $scope.TipoMov = { data: [] };
        $scope.FinalidadeCalc = { data: [] };
        $scope.Complemento = { data: [] }; 
        $scope.mostraFinCalc = false;
        $scope.startUpdate =  false;
        $scope.startUpdateInfo = false;
        $scope.urlMovimentos = "api/ws/rest/ergon/v1.0/folha/movimentos";
        $scope.urlInfoMov = "api/ws/rest/ergon/v1.0/folha/movimentos/movimento/informacoes";
        $scope.urlPageInfo = "api/rest/ergon/Transacao/trpv0057/RPrevAposent";
        $scope.urlDetalhesVinculos = "api/rest/ergon/Vinculo/blockvincDetalhes";
        $scope.urlRubricas = "api/ws/rest/ergon/v1.0/lov/rubricas";
        $scope.urlTipoMovimentos = "api/ws/rest/ergon/v1.0/lov/itemTabela/tipoMovLancMA";
        $scope.urlFinalidadeCalc = "api/ws/rest/ergon/v1.0/lov/itemTabela/finalidadeCalc";
        $scope.urlComplementos = "api/ws/rest/ergon/v1.0/lov/rubricas/rubrica/complementos";
        
        //Recebe parametros
        $scope.paramsInfoGet = {
          movimento: "",
        };
        
        $scope.paramsInfoPost = {
          movimento: "",
          valor:"",
          descricao:""
        };
        
        $scope.paramsRubricaGet = {
          dtfim:"",
          dtini:""
        }; 
        
        $scope.paramsComplementoRubricasGet = {
          rubrica: ""
        };
        
        $scope.paramsMovimentoGet = {
          dtini: "",
          dtfim:""
        };
        
        $scope.paramsNumfuncNumvinc = {
          numfunc: "",
          numvinc: ""
        };
        
        //Watches
        $scope.$watch('blkVinc', function() {
          if(typeof($scope.blkVinc) !== "undefined"){
            $scope.paramsNumfuncNumvinc.numfunc = $scope.blkVinc.numfunc;
            $scope.paramsNumfuncNumvinc.numvinc = $scope.blkVinc.numvinc;
            
            getMovimentos();
          }else{
            $scope.FolMovimentos = { data:[] };
          }
        });
        
        $scope.$watchGroup(['dtini','dtfim'], function(newValues) {
            if(newValues[0] !== undefined && newValues[0] !== null){
              $scope.paramsMovimentoGet.dtini = newValues[0].substring(0, 10);
              try{
                $scope.paramsMovimentoGet.dtfim = newValues[1].substring(0, 10);
              }catch(e){
                $scope.paramsMovimentoGet.dtfim = "";
              }
              getMovimentos();
            }
        });
        
        $scope.$watchGroup(['FolMovimentos.modal.dtini','FolMovimentos.modal.dtfim'], function(newValues) {
            if(newValues[0] !== undefined && newValues[0] !== null){
              $scope.paramsRubricaGet.dtini = newValues[0].substring(0, 10);
              try{
                $scope.paramsRubricaGet.dtfim = newValues[1].substring(0, 10);
              }catch(e){
                $scope.paramsRubricaGet.dtfim = "";
              }
              getRubricas();
            }
        });
        $scope.$watch('FolMovimentos.modal.rubricaObj', function(value) {
            if (typeof($scope.FolMovimentos.modal) !== "undefined")
            {
              if(typeof($scope.FolMovimentos.modal.rubricaObj) !== "undefined"){
              
              $scope.FolMovimentos.modal.rubrica = value.rubrica;
              $scope.FolMovimentos.modal.rubricaDesc = value.nome;
              
              
              GenericService.getData($scope.urlComplementos+'/'+value.rubrica).then(function(response){
                $scope.Complemento.data = response;
              });
              
              if(value.usaComplemento == 'N'){
                $scope.FolMovimentos.modal.complemento = null;
              }
            }else{
              $scope.FolMovimentos.modal.complemento = null;
            }
          }
        });
        
        //*********MOVIMENTOS*********//
        
        $scope.insertMovimento = function(data){
          if((typeof(data.dtini) == "undefined") || (typeof(data.rubrica) == "undefined") || (typeof(data.tipo) == "undefined")){
            showError("Preencha os campos obrigatórios: Início, Rubrica e Tipo de movimento");
          }else{
            if(data.rubricaObj.usaComplemento === "S"){
                if((typeof(data.complemento) === "undefined") || data.complemento === null || data.complemento === ""){
                  showError("Necessário informar complemento para a rubrica selecionada");
                }else{
                  sendMovimento(data);
                }
              }else{
                sendMovimento(data);
              }
          }
        }
        
        $scope.startInserting = function() {
          $scope.FolMovimentos.modal = {};
          $scope.startUpdate =  false;
          getRubricas();
        }
        
        $scope.startEditing = function(data) {
          $scope.startUpdate =  true;
          if(data.FinalidadeCalculo !== null)
            mostraFinCalc = true;
        }
        
        $scope.copyMovimento = function(data) {
         $scope.FolMovimentos.modal = $scope.receive(data);
         $scope.FolMovimentos.modal.rubricaObj = {
                                                    "rubrica": $scope.FolMovimentos.modal.rubrica,
                                                    "nome": $scope.FolMovimentos.modal.rubricaDesc
                                                 };
        }
        
        $scope.cancelarForm = function(){
          $scope.FolMovimentos.modal= {};
          $scope.startUpdate =  false;
        }
        
        $scope.revertMostraCalc = function() {
          if($scope.mostraFinCalc !== false){
            $scope.mostraFinCalc = !$scope.mostraFinCalc;
          }
        }
        
        ////****Crud movimentos****////
        
        function sendMovimento(data){
          $scope.copyMovimento(data);
          if(!$scope.startUpdate){
            GenericService.postData($scope.urlMovimentos+'/movimento/'+$scope.paramsNumfuncNumvinc.numfunc+'/'+$scope.paramsNumfuncNumvinc.numvinc, data).then(function(response){
              if(typeof(response.status) === "undefined"){
                  getMovimentos();
                }else{
                  $scope.retrive($scope.FolMovimentos.modal); 
                }
            });
          } else {
              GenericService.putData($scope.urlMovimentos+'/movimento/'+$scope.paramsNumfuncNumvinc.numfunc+'/'+$scope.paramsNumfuncNumvinc.numvinc+'/'+data.movimento, data).then(function(response){
                if(typeof(response.status) === "undefined"){
                  getMovimentos();
                  $scope.FolMovimentos.modal = response; 
                  $scope.FolMovimentos.modal.rubricaObj = {
                                                    "rubrica": $scope.FolMovimentos.modal.rubrica,
                                                    "nome": $scope.FolMovimentos.modal.rubricaDesc
                                                 };
                }else{
                  $scope.retrive($scope.FolMovimentos.modal); 
                }
              });
            }
        }
        
        $scope.deleteMovimento = function(data){
          $.prompt("Deseja remover?", {
          	buttons: { "Ok": true, "Cancel": false },
          	focus: 1,
          	zIndex: 9999,
          	opacity: 0.4,
          	submit: function(e,v,m,f){
          		if(v){
          		  GenericService.deleteData($scope.urlMovimentos+'/movimento/'+$scope.paramsNumfuncNumvinc.numfunc+'/'+$scope.paramsNumfuncNumvinc.numvinc+'/'+data.movimento).then(function(response){
                  getMovimentos();
                });
          		}
          	}
          });
        }
        
      
       //*********INFORMAÇÕES*********//
      
        $scope.openInfo = function(data) {
          $scope.paramsInfoGet.movimento = data.movimento;
          getInfo();
        }
        
        $scope.startEditingInfo = function() {
          $scope.startUpdateInfo =  true;
        }
        
        $scope.copyInfo = function(data) {
          $scope.InfoMov.modal = $scope.receive(data);
        }
        
        $scope.startInsertingInfo = function() {
          $scope.InfoMov.modal = {};
          $scope.startUpdateInfo =  false;
        }
        
        $scope.formCancelInfo = function(){
          $scope.InfoMov.modal = {};
          $scope.startUpdateInfo =  false;
        }
        
        ////****Crud Informações****////
        
        $scope.sendInfo = function(data){
          if((typeof(data.valor) != "undefined") && (typeof(data.descricao) != "undefined")){
              $scope.paramsInfoPost.movimento = $scope.paramsInfoGet.movimento;
              $scope.paramsInfoPost.valor = data.valor;
              $scope.paramsInfoPost.descricao = data.descricao;
            if(!$scope.startUpdateInfo){
              GenericService.postData($scope.urlInfoMov+'/informacao/'+$scope.paramsNumfuncNumvinc.numfunc+'/'+$scope.paramsNumfuncNumvinc.numvinc+'/'+$scope.paramsInfoPost.movimento, $scope.paramsInfoPost).then(function(response){
                getInfo();
                for (var i = 0; i < $scope.FolMovimentos.data.length; i++)
                {
                  if ($scope.FolMovimentos.data[i].movimento === response.movimento
                  && $scope.FolMovimentos.data[i].numfunc === response.numfunc
                  && $scope.FolMovimentos.data[i].numvinc === response.numvinc)
                  {
                    $scope.FolMovimentos.data[i].entityStateHash = response.entityStateHash;
                  }
                }
              });
            } else {
              GenericService.putData($scope.urlInfoMov+'/informacao/'+$scope.paramsNumfuncNumvinc.numfunc+'/'+$scope.paramsNumfuncNumvinc.numvinc+'/'+$scope.paramsInfoPost.movimento+'/'+ stripBarsFilter($scope.paramsInfoPost.valor),  $scope.paramsInfoPost).then(function(response){
                getInfo();
                for (var i = 0; i < $scope.FolMovimentos.data.length; i++)
                {
                  if ($scope.FolMovimentos.data[i].movimento === response.movimento
                  && $scope.FolMovimentos.data[i].numfunc === response.numfunc
                  && $scope.FolMovimentos.data[i].numvinc === response.numvinc)
                  {
                    $scope.FolMovimentos.data[i].entityStateHash = response.entityStateHash;
                  }
                }
              });
            }
          }else{
            showError("Preencha os campos obrigatórios");
          }
        }
        
        $scope.deleteInfo = function(data){
          $.prompt("Deseja remover?", {
          	buttons: { "Ok": true, "Cancel": false },
          	focus: 1,
          	zIndex: 9999,
          	opacity: 0.4,
          	submit: function(e,v,m,f){
          		if(v){
          		  GenericService.deleteData($scope.urlInfoMov+'/informacao/'+$scope.paramsNumfuncNumvinc.numfunc+'/'+$scope.paramsNumfuncNumvinc.numvinc+'/'+data.movimento+'/'+ stripBarsFilter(data.valor)).then(function(response){
                  getInfo();
                  for (var i = 0; i < $scope.FolMovimentos.data.length; i++)
                  {
                    if ($scope.FolMovimentos.data[i].movimento === response.movimento
                    && $scope.FolMovimentos.data[i].numfunc === response.numfunc
                    && $scope.FolMovimentos.data[i].numvinc === response.numvinc)
                    {
                      $scope.FolMovimentos.data[i].entityStateHash = response.entityStateHash;
                    }
                  }
                });
          		}
          	}
          });
        }
      
      //******** FUNÇÕES AUXILIARES ********//
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
        }
        
      $scope.clearFilter = function(){
          $scope.dtini = "";
          $scope.dtfim = "";
        }
        
        
      //******** FUNÇÕES DE GET ********//
      function getRubricas(){
        GenericService.getData($scope.urlRubricas+'?numfunc='+$scope.paramsNumfuncNumvinc.numfunc+'&numvinc='+$scope.paramsNumfuncNumvinc.numvinc+'&dtini='+$scope.paramsRubricaGet.dtini+'&dtfim='+$scope.paramsRubricaGet.dtfim).then(function(response){
          $scope.Rubrica.data = response;
          if($scope.Rubrica.data.exibeFinalidadeCalc === "S"){
            $scope.mostraFinCalc = true;
          }
        });
      }
      
      function getMovimentos(){
        GenericService.getData($scope.urlMovimentos+"?size=999999999&status=INATIVO&numfunc=" + $scope.paramsNumfuncNumvinc.numfunc + "&numvinc=" + $scope.paramsNumfuncNumvinc.numvinc + "&dtini=" + $scope.paramsMovimentoGet.dtini + "&dtfim="+ $scope.paramsMovimentoGet.dtfim).then(function(response){
          $scope.FolMovimentos.data = response.content;
        });
      }
      
      function getInfo(){
        GenericService.getData($scope.urlInfoMov+'/'+$scope.paramsNumfuncNumvinc.numfunc+'/'+$scope.paramsNumfuncNumvinc.numvinc+'/'+$scope.paramsInfoGet.movimento+'?size=999999999').then(function(response){
          $scope.InfoMov.data = response.content;
        });
      }
      
      GenericService.getData($scope.urlTipoMovimentos).then(function(response){
        $scope.TipoMov.data = response;
      });
      
      GenericService.getData($scope.urlFinalidadeCalc).then(function(response){
        $scope.FinalidadeCalc.data = response;
      });
      
      GenericService.getData($scope.urlPageInfo).then(function(response){
        $scope.pageInfo.data = response;
      });
        
      }
    ]);

} (app));
