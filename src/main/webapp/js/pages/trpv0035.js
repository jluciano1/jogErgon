(function ($app) {
  angular.module('page.controllers', []);
  
    app.controller('trpv0035', ['$scope', 
                                '$http', 
                                '$rootScope', 
                                '$state', 
                                '$location', 
                                '$translate', 
                                'Notification', 
                                'GenericService',
      function ($scope, $http, $rootScope, $state, $location, $translate, Notification, GenericService) {
       
        $scope.clearFilter = function(){
          $scope.dtini = "";
          $scope.dtfim = "";
          $scope.restVantagens.filtro = "";
        }
        
        $scope.showDetails = function(datasource, rowData){
          datasource.cancel();
          datasource.copyForm(rowData);

					GenericService
							.getData(
									(window.hostApp || "")
											
											+ "api/rest/ergon/Vantagens/findValorAtrib/"+ rowData.chavevant
											)
							.then(
									//success
									function(response) {
										$scope.valorAtrib = response.descr;
									},
									//failure
									function(response) {
										Notification.error("Ocorreu um erro na consulta dos valores do atributo");
									});
        }
      }
    ]);

} (app));