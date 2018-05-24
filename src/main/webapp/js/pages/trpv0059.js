(function ($app) {
  angular.module('page.controllers', []);
  
    app.controller('trpv0059', ['$scope', 
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
        
        $scope.clearFilter = function(){
          $scope.searchFilters.pPerfil = "";
        }
        
        $scope.posPost = function()
        {
          if (PerfilVantagem.inserting)
          {
            var present = false;
            for (var i = 0; i < searchFilters.data.length; i++)
            {
              if (PerfilVantagem.active.perfil === searchFilters.data[i].perfil)
              {
                present = true;
              }
            }
            if (!present)
            {
              searchFilters.data.push(PerfilVantagem.active);    
            }
          }
        }
       
      }
    ]);

} (app));