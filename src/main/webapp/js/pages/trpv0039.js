(function ($app) {
  angular.module('page.controllers', []);
  
    app.controller('trpv0039', ['$scope',
                                '$filter',
                                '$http', 
                                '$rootScope', 
                                '$state', 
                                '$location', 
                                '$translate', 
                                'Notification', 
      function ($scope, $filter, $http, $rootScope, $state, $location, $translate, Notification) {
        
        $scope.formatarDetalhes = function (rowData) {
          rowData.valorFormatado =  $filter('currency')(rowData.valor, 'R$', 2);
        }
        
        $scope.clearFilter = function(){
          $scope.dtini = "";
          $scope.dtfim = "";
        }

      }
    ]);

} (app));