(function ($app) {
  angular.module('page.controllers', []);
  
    app.controller('trpv0029', ['$scope', 
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
          $scope.TipoFreq.filtro = "";
          $scope.CodigosFreq.filtro = "";
        }
        
        $scope.diffDays = function(dtini, dtfim){
          
          if (dtini !== undefined && dtfim !== undefined){
            
          var dataini = new Date(dtini);
          var datafim = new Date(dtfim);
          
          var _MS_PER_DAY = 1000 * 60 * 60 * 24;
           
           $scope.setHoursZero(dataini);
           $scope.setHoursZero(datafim);
           
          var utc1 = Date.UTC(dataini.getFullYear(), dataini.getMonth(), dataini.getDate());
          var utc2 = Date.UTC(datafim.getFullYear(), datafim.getMonth(), datafim.getDate());
          
          var diff = Math.floor((utc2 - utc1) / _MS_PER_DAY) + 1;
          
          FrequenciasPreSigrh.active.qtde = diff;
           
          }
        }
        
        $scope.setHoursZero = function(data){
          data.setHours(0);
          data.setMinutes(0);
          data.setSeconds(0);
          data.setMilliseconds(0);
        }

      }
    ]);

} (app));