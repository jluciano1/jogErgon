(function ($app) {
  angular.module('page.controllers', []);
  
    app.controller('trpv0037', ['$scope', 
                                '$http', 
                                '$rootScope', 
                                '$state', 
                                '$location', 
                                '$translate', 
                                'Notification', 
      function ($scope, $http, $rootScope, $state, $location, $translate, Notification) {
       
        $scope.clearFilter = function(){
          $scope.dtini = "";
        }
        
      }
    ]);

} (app));