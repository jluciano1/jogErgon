(function ($app) {
  angular.module('page.controllers', []);
  
    app.controller('trpv0054', ['$scope', 
                                '$http', 
                                '$rootScope', 
                                '$state', 
                                '$location', 
                                '$translate', 
                                'Notification', 
      function ($scope, $http, $rootScope, $state, $location, $translate, Notification) {
        
        
        $scope.TipoAposentadoria = {};
        
        $rootScope.$watch("AposetadoriaOrgaoOrigemChart.label", function(newValue){
          if((newValue) && newValue.length == 1) 
            $scope.TipoAposentadoria.filtro = newValue[0];
          else
            $scope.TipoAposentadoria.filtro = null;
        });
        
      }
    ]);

} (app));