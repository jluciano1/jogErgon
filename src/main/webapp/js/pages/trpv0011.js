(function ($app) {
  angular.module('page.controllers', []);
  
    app.controller('trpv0011', ['$scope', 
                                '$http', 
                                '$rootScope', 
                                '$state', 
                                '$location', 
                                '$translate', 
                                'Notification', 
      function ($scope, $http, $rootScope, $state, $location, $translate, Notification) {
        
        $scope.filtroPadraoUsuario = null;
        $scope.searchFilters = {};
        
        $scope.setfiltroPadraoUsuario = function(rowData){
          $scope.filtroPadraoUsuario = rowData.usuario;
        }
        
        $scope.clearFilter = function(){
          $scope.searchFilters.usuario = "";
        }
       
      }
    ]);

} (app));