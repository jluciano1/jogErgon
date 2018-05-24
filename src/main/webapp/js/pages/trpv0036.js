(function ($app) {
  angular.module('page.controllers', []);
  
    app.controller('trpv0036', ['$scope', 
                                '$http', 
                                '$rootScope', 
                                '$state', 
                                '$location', 
                                '$translate', 
                                'Notification', 
      function ($scope, $http, $rootScope, $state, $location, $translate, Notification) {
       
        $scope.clearFilter = function(){
          $scope.dtini = "";
          $scope.dtfim = "";
          $scope.Cargo.filtro = "";
        }
        
      }
    ]);

} (app));