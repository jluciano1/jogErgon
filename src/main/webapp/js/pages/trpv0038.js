(function ($app) {
  angular.module('page.controllers', []);
  
    app.controller('trpv0038', ['$scope',
                                '$filter', 
                                '$http', 
                                '$rootScope', 
                                '$state', 
                                '$location', 
                                '$translate', 
                                'Notification', 
      function ($scope, $filter, $http, $rootScope, $state, $location, $translate, Notification) {
        
        $scope.camposDependentesFormatados = function(rowData){
          
          rowData.cpfFormatado = $filter('cpf')(rowData.cpf);
          rowData.telefoneFormatado = $filter('tel')(rowData.telefone);
          rowData.cependerFormatado = $filter('cep')(rowData.cepender);
          rowData.sexoFormatado = (rowData.sexo == "M") ? "MASCULINO" : "FEMININO";
          
          rowData.numfunc.cpfFormatado = $filter('cpf')(rowData.numfunc.cpf);
        }
        
        $scope.camposPaFormatados = function(rowData){
          rowData.percentualFormatado = rowData.percentual + rowData.base.sufixo;
          
          if(rowData.base.prefixo !== null){
            $scope.prefixo = rowData.base.prefixo.replace(/\./g, '');
            
          }else{
            if(rowData.base.evalorfixo == "S"){
               $scope.prefixo = "Valor";
               $scope.sufixo = null;
            }else{
               $scope.prefixo = "Percentual";
               $scope.sufixo = "%";
            }
          }
          $scope.sufixo = rowData.base.sufixo;
        }
        
        $scope.clearFilter = function(){
          $scope.Dependentes.filtro = "";
        }
       
      }
    ]);

} (app));