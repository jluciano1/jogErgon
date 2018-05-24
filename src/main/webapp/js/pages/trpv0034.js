(function ($app) {
  angular.module('page.controllers', []);
  
    app.controller('trpv0034', ['$scope', 
                                '$http', 
                                '$rootScope', 
                                '$state', 
                                '$location', 
                                '$translate',
                                '$filter',
                                '$timeout',
                                'Notification',
                                'GenericService',
      function ($scope, $http, $rootScope, $state, $location, $translate, $filter, $timeout, Notification, GenericService) {
        
        $scope.diasUsufruto = { data: [] };
        $scope.diasDobro = { data: [] };
        $scope.diasVendidos = { data: [] };
        $scope.totalUsufruto = [];
        $scope.totalDobro = [];
        $scope.totalVendidos = [];
        
        $scope.clearFilter = function(){
          $scope.filtroDtIni = "";
          $scope.filtroDtFim = "";
        }
        
        $scope.getDiasUsufruto = function(rowData){
          $scope.totalUsufruto = [];
          if($scope.diasUsufruto.data == "" || $scope.diasUsufruto.data == null)
            return "";
          $scope.diasUsufruto.data.map(function(diaUsufruto){
            if(diaUsufruto.chave == rowData.chave){
              var diffDays = $filter('diffDays')(diaUsufruto.dtini, diaUsufruto.dtfim);
              $scope.totalUsufruto.push(diffDays);
            }
          });
          $timeout(rowData.diasDeUsufruto = $scope.somarArray($scope.totalUsufruto), 200);
        }
        
        $scope.getDiasDobro = function(rowData){
          $scope.totalDobro = [];
          if($scope.diasDobro.data == "" || $scope.diasDobro.data == null)
            return "";
          $scope.diasDobro.data.map(function(diaDobro){
            if(diaDobro.chave == rowData.chave){
              $scope.totalDobro.push(diaDobro.diasConvertidos);
            }
          });
          $timeout(rowData.totalDiasDobro = parseInt($scope.somarArray($scope.totalDobro)), 200);
        }
        
        $scope.getDiasVendidos = function(rowData){
          $scope.totalVendidos = [];
          if($scope.diasVendidos.data == "" || $scope.diasVendidos.data == null)
            return "";
          $scope.diasVendidos.data.map(function(diaVendido){
            if(diaVendido.chaveperaqlesp == rowData.chave){
              $scope.totalVendidos.push(diaVendido.dias_vendidos);
            }
          });
          $timeout(rowData.totalDiasVendidos = parseInt($scope.somarArray($scope.totalVendidos)), 200);
        }
        
        $scope.$watch('blkVinc.numfunc', function() {
          if($scope.blkVinc){
            GenericService.getData('api/ws/rest/ergon/v1.0/tempoServico/licencasEspeciais/periodosAquisitivos/periodo/gozo'
            + '/' + $scope.blkVinc.numfunc + '/' + $scope.blkVinc.numvinc).then(function(response){
              $scope.diasUsufruto.data = response;
            });
            GenericService.getData('api/ws/rest/ergon/v1.0/tempoServico/licencasEspeciais/periodosAquisitivos/periodo/saldo'
            + '/' + $scope.blkVinc.numfunc + '/' + $scope.blkVinc.numvinc).then(function(response){
              $scope.diasDobro.data = response;
            });
            GenericService.getData('api/ws/rest/ergon/v1.0/tempoServico/licencasEspeciais/periodosAquisitivos/periodo/venda'
            + '/' + $scope.blkVinc.numfunc + '/' + $scope.blkVinc.numvinc).then(function(response){
              $scope.diasVendidos.data = response;
            });
          }
        });
        
        $scope.somarArray = function(array) {
            var total = 0;
            for (var i = 0; i < array.length; i++) {
                if (array[i] >= 2) {
                    total += array[i];
                }
            }
            return total;
        }
        
      }
    ]);

} (app));