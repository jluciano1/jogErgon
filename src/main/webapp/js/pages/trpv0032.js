(function ($app) {
  angular.module('page.controllers', []);
  
    app.controller('trpv0032', ['$scope', 
                                '$http', 
                                '$rootScope', 
                                '$state', 
                                '$location', 
                                '$translate', 
                                'Notification', 
      function ($scope, $http, $rootScope, $state, $location, $translate, Notification) {
        $scope.numfuncnumvinc1 = "";
        $scope.numfuncnumvinc2 = "";
        $scope.concatenacao = function () {
              if(Cessoes.active.permutnumfunc1 !== null && Cessoes.active.permutnumvinc1 !==null)
                $scope.numfuncnumvinc1 = Cessoes.active.permutnumfunc1 + " / " + Cessoes.active.permutnumvinc1;
              else
                $scope.numfuncnumvinc1 = "";
              
              if(Cessoes.active.permutnumfunc2 !== null && Cessoes.active.permutnumvinc2 !==null)
                $scope.numfuncnumvinc2 = Cessoes.active.permutnumfunc2 + " / " + Cessoes.active.permutnumvinc2;
              else
                $scope.numfuncnumvinc2 = "";
        }
        
        $scope.clearFilter = function(){
          $scope.filtroDtIni = "";
          $scope.filtroDtFim = "";
        }
      }
    ]);

} (app));