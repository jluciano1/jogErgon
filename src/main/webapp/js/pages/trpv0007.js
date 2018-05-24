(function ($app) {
  angular.module('page.controllers', []);
  
    app.controller('trpv0007', ['$scope', 
                                '$http', 
                                '$filter',  
                                '$rootScope', 
                                '$state', 
                                '$location', 
                                '$translate', 
                                'Notification', 
      function ($scope, $http, $filter, $rootScope, $state, $location, $translate, Notification) {
        //Função criada pois é precisar dar refresh em outro datasource quando efetuado uma operação no primeiro datasource
        app.userEvents.refreshTransPadAces= function(event){
          TransPadAcesDTO.refreshLastFilter();
          NotTransPadAces.refreshLastFilter();
          return true;
        }
        app.userEvents.refreshFiltro = function(event){
          PadraoAcessoFiltro.refreshLastFilter();
          PadraoAcesso.refreshLastFilter();
          PadraoAcessoCopia.refreshLastFilter();
          return true;
        }
        
        $scope.insertTransPadAces = function(){
          var obj = NotTransPadAces.active;
          if(typeof(obj) !== "undefined" && Object.getOwnPropertyNames(obj).length > 0){
            NotTransPadAces.startInserting();
            NotTransPadAces.active = obj;
            NotTransPadAces.post();
            return;
          }else{
            Notification.error({message: 'Selecione uma transação para associar!', delay: 3000})
            return;
            
          }
        }
        
        $scope.filtroTransPadAcesDTO = null;
        $scope.filtroNotTransPadAces = null;
        $scope.setFiltroTransPadAcesDTO = function(datasource){
            $scope.filtroTransPadAcesDTO =  datasource.active.padAces;
            $scope.filtroNotTransPadAces =  datasource.active.padAces;
        }
        
        $scope.filtroPadraoRelatorioDTO = null;
        $scope.setFiltroPadraoRelatorioDTO = function(datasource){
            $scope.filtroPadraoRelatorioDTO = datasource.active.padAces;
        }
        
        $scope.filtroPadraoRotinaDTO = null;
        $scope.setFiltroPadraoRotinaDTO = function(datasource){
            $scope.filtroPadraoRotinaDTO =  datasource.active.padAces;
        }
        
        $scope.clearFilter = function(){
          $scope.PadraoAcessoFiltro.filtro = "";
        }
        
       
      }
    ]);

} (app));