(function ($app) {
  angular.module('page.controllers', []);
  
    app.controller('trpv0051', ['$scope', 
                                '$http', 
                                '$rootScope', 
                                '$state', 
                                '$location', 
                                '$translate', 
                                'Notification',
                                'GenericService',
      function ($scope, $http, $rootScope, $state, $location, $translate, Notification, GenericService) {
        
        $scope.checkNoValue = function(value){
          return (value === '') || (value === null) || (value === undefined)
        }
        
        $scope.faixaProventos = [{opc: 'Até R$ 2000,00'}, {opc: 'De R$ 2000,01 até R$ 5000,00'}, {opc: 'De R$ 5000,01 até R$ 10000,00'}, {opc: 'Acima de R$ 10000,00'}];
        $scope.showProventoDetails = false;
        
        $scope.$watch('faixaProventos.filtro', function() {
          
          if($scope.faixaProventos.filtro){
            $scope.showProventoDetails = true;
            if($scope.faixaProventos.filtro == 'Até R$ 2000,00'){
              $scope.faixaProventos.proventoMinimo = 0;
              $scope.faixaProventos.proventoMaximo = 2000;
            }
            if($scope.faixaProventos.filtro == 'De R$ 2000,01 até R$ 5000,00'){
              $scope.faixaProventos.proventoMinimo = 2000;
              $scope.faixaProventos.proventoMaximo = 5000;
            }
            if($scope.faixaProventos.filtro == 'De R$ 5000,01 até R$ 10000,00'){
              $scope.faixaProventos.proventoMinimo = 5000;
              $scope.faixaProventos.proventoMaximo = 10000; 
            }
            if($scope.faixaProventos.filtro == 'Acima de R$ 10000,00'){
              $scope.faixaProventos.proventoMinimo = 10000;
              $scope.faixaProventos.proventoMaximo = null;
            }
          } else {
            $scope.showProventoDetails = false;
          }
          
        });
          
      }
      
    ]);
} (app));