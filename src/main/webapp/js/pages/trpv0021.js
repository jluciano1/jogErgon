(function ($app) {
  angular.module('page.controllers', []);
  
    app.controller('trpv0021', ['$scope', 
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
          $scope.Finalidade.filtro = "";
          $scope.tipoDeVinculo.filtro = "";
          $scope.regimeJuridico.filtro = "";
          $scope.restCategoria.filtro = "";
          $scope.restSubFilter.filtro = "";
        }
      }
    ]);
} (app));