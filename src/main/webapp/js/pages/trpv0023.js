(function ($app) {
  angular.module('page.controllers', []);
  
    app.controller('trpv0023', ['$scope', 
                                '$http', 
                                '$rootScope', 
                                '$state', 
                                '$location', 
                                '$translate', 
                                'Notification',
                                'GenericService',
      function ($scope, $http, $rootScope, $state, $location, $translate, Notification, GenericService) {
        $scope.clearFilter = function(){
          $scope.filtroDtIni = "";
          $scope.filtroDtFim = "";
          $scope.restFinalidade.filtro = "";
          $scope.restTipoVinc.filtro = "";
          $scope.restRegJur.filtro = "";
          $scope.restCategoria.filtro = "";
          $scope.restSubcategoria.filtro = "";
          $scope.restFrequencia.filtro = "";
        }
        
       $scope.validateField                = validateField;
       $scope.validateCancel               = validateCancel;
       $scope.CopiaCombinacoes             = {};  
       $scope.copyToActiveCopiaCombinacoes = copyToActiveCopiaCombinacoes;   
       $scope.copiaCombinacoes             = copiaCombinacoes;
       $scope.pendingControlParam          = false;
       
       
       
       
       function validateField(formController, field){
         if(formController[field].$invalid && !formController[field].$pristine)
          return true;
         else
          return false;
       }
       
       function validateCancel(formController){
         formController.$setPristine();
       }
       
       function setPristineInvalid(formController){
         var attrs = Object.getOwnPropertyNames(formController).filter(function(item){
           return item.indexOf("$") == -1;
         });
         
         attrs.map(function(attr){
           var _input = formController[attr];
           if(_input.$invalid)
              _input.$pristine = false;
         });
         
       }
       
       
       function copyToActiveCopiaCombinacoes(rowData){
         $scope.CopiaCombinacoes.active = {
           idParamFinalidade : rowData.id
         };
       }
       
       function copiaCombinacoes(formController) {
        
        if(formController.$invalid){
          setPristineInvalid(formController);
          Notification.warning({
              title: 'Campos Obrigatórios',
              message: 'O campo data de referência é obrigatório para filtrar os registros',
              delay: 5000 });
          return;
        }
        
        var _url = "api/rest/ergon/ParamFinalidade/copiaCombinacoes";
        
        var _data = $scope.receive($scope.CopiaCombinacoes.active);
        $scope.pendingControlParam = true;
        GenericService.postData(_url, _data)
          .then(
            //success
            function(response){
              if(typeof(response.status) === "undefined"){
                $scope.pendingControlParam = false;
                angular.copy(response, $scope.CopiaCombinacoes.active);
                validateCancel(formController);
                
              }else{
                $scope.retrive($scope.CopiaCombinacoes.active);
              }
              
            },
            //error
            function(error){
              $scope.retrive($scope.CopiaCombinacoes.active);
            });
       }
       
       
        
        
      }
    ]);
} (app));