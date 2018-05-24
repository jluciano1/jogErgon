(function ($app) {
  angular.module('page.controllers', []);
  
    app.controller('trpv0031', ['$scope', 
                                '$http', 
                                '$rootScope', 
                                '$state', 
                                '$location', 
                                '$translate', 
                                'Notification',
                                'GenericService',
      function ($scope, $http, $rootScope, $state, $location, $translate, Notification, GenericService) {
        
        $scope.Contribuicoes = { data: [] };
        $scope.regPrev = [{opc: 'RGPS'}, {opc: 'RPPS'}, {opc: 'RPC'}];
        $scope.contribuicoesParams = {};
        
        $scope.clearFilter = function(){
          $scope.dtfim = "";
          $scope.dtini = "";
          $scope.Finalidade.filtro = "";
          $scope.regPrev.filtro = "";
        }
        
        $scope.getContribuicoes = function(averbacao, blkVinc){
          GenericService.getData('api/rest/ergon/ContribuicaoPrevidenciaria/listByChave?' + 'numfunc=' + blkVinc.numfunc
          + '&numvinc=' + blkVinc.numvinc + '&chave=' + averbacao.chave + '&page=0&size=100').then(function(response){
            $scope.Contribuicoes.data = response.content;
          });
        }

      }
    ]);

} (app));