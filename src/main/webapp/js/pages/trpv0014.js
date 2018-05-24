(function ($app) {
  angular.module('page.controllers', []);
  
    app.controller('trpv0014', ['$scope', 
                                '$http', 
                                '$rootScope', 
                                '$state', 
                                '$location', 
                                '$translate', 
                                'Notification', 
      function ($scope, $http, $rootScope, $state, $location, $translate, Notification) {
        
        $scope.clearFilter = function(){
          $scope.restTipoRequerimento.filtro = "";
          $scope.referenciaFilter = "";
        }
       
      }
    ]);

} (app));