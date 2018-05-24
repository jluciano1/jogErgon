(function($app) {
	angular.module('page.controllers', []);

	app.controller('trpv0006', [
			'$scope',
			'$http',
			'$rootScope',
			'$state',
			'$location',
			'$translate',
			'Notification',
			function($scope, $http, $rootScope, $state, $location, $translate,
					Notification) {
        
        $scope.clearFilter = function(){
          $scope.searchFilters = {};
          $scope.searchFilters2 = {};
        }
        
        $scope.formatAno = function(ano){
          $scope.searchFilters2.anoTratado = ano.slice(0, 4);
        }
        
        $scope.associaErgLeiTipoAoNovoObjeto = function(){
          ErgLeis.active.ergLeiTipo=ErgLeiTipo.active;
        }
         
        $scope.associaErgLeisAErgLeiRefer = function(){
          ErgLeiRefer.active.ergLeis=ErgLeis.active;
        }
        
        
        //Filtros de dependencias
        
        $scope.filtroEmpresa = null;
        
        $scope.setFilterListBy = function(datasource, empCodigo){
          
          if(!datasource.inserting && typeof(datasource.active) !== 'undefined' && Object.getOwnPropertyNames(datasource.active).length !== 0){
            $scope.filtroEmpresa = empCodigo;
              return datasource.active;
            }else{
               $scope.filtroEmpresa = null;
               return;
            }
        }
        
        $scope.filtroErgLeiTipo = null;
        $scope.filtroErgLeisNumero=null;
        $scope.filtroErgLeisAno=null;
        
        $scope.setFiltroErgLeiRefer = function(rowData){
            $scope.filtroErgLeiTipo = rowData.ergLeiTipo.tipodoc;
            $scope.filtroErgLeisNumero= rowData.numero;
            $scope.filtroErgLeisAno= rowData.ano;
        };

			}]);
			
			app.directive('ddTipoAbrangencia', function() {
      return {
        restrict: 'E',
        require:  'ngModel',
        template: '<div class="component-holder ng-binding ng-scope" data-component="crn-combobox">' +
                  '  <div class="form-group">' +
                  '  	<ui-select theme="bootstrap" class="crn-select">' +
                  '      <ui-select-match>{{$select.selected.nome}}</ui-select-match>' +
                  '      <ui-select-choices repeat="rowData.tipoAbrangencia as rowData in tipoAbrangenciaOptions | filter: $select.search">' +
                  '        <div data-container="true">{{rowData.nome}}</div>' +
                  '      </ui-select-choices>' +
                  '    </ui-select>' +
                  '  </div>' +
                  '</div>',
        scope: true,
        controller: function($scope) { 
            $scope.tipoAbrangenciaOptions = [
            {tipoAbrangencia: 'E', nome:'Estadual'},
            {tipoAbrangencia: 'F', nome:'Federal'},
            {tipoAbrangencia: 'L', nome:'Local'},
            {tipoAbrangencia: 'M', nome:'Municipal'}
            
          ];
        }
      }
    });

}(app));