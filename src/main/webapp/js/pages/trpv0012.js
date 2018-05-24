(function ($app) {
  angular.module('page.controllers', []);
  
    app.controller('trpv0012', ['$scope', 
                                '$http', 
                                '$rootScope', 
                                '$state', 
                                '$location', 
                                '$translate', 
                                'Notification', 
      function ($scope, $http, $rootScope, $state, $location, $translate, Notification) {
        
        $scope.filtroEvSelecionado = null;
        
        
        $scope.getEvSelecionado = function(rowData){
            $scope.filtroEvSelecionado = rowData;
        }
        
        
        //Seta o ponteiro de publicação do registro corrente
        //Utilizado como callback na diretiva blkPont
        $scope.blkRefresh = function(pont, tipoPonteiro){
          if(tipoPonteiro == "pontpubl")
            Eventos.row.pontPubl = pont;
          else if(tipoPonteiro == "pontlei")
            Eventos.row.pontLei = pont;
        }
       
      }
    ]);

} (app));