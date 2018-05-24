(function ($app) {
    angular.module('page.controllers', []);

    app.filter('valorTaxaDesc', function() {
      return function(input) {
        if (input === null) return '  ';
        var sigla = input || '';
        if (sigla == 'V') return 'Valor';
        if (sigla == 'T') return 'Taxa';
        return sigla;
      }
    });
    
    app.controller('trpv0017', ['$scope',
                                '$sce',
                                '$http', 
                                '$rootScope', 
                                '$state', 
                                '$location', 
                                '$translate', 
                                'Notification', 
                                'stripBarsFilter',
                                'valorTaxaDescFilter',
      function ($scope, $sce, $http, $rootScope, $state, $location, $translate, Notification, stripBarsFilter, valorTaxaDescFilter) {
      
        // Inicializa variáveis de filtro para que elas possam ser associadas a ui-selects encapsulados por directives
        $scope.searchFilters = function() {
          var tipoValor = null;
          var valorTaxa = null;
          var dtini = null;
          var dtfim = null;
          
          return this;
        }
        
        //Seta o ponteiro de publicação do registro corrente
        //Utilizado como callback na diretiva blkPont
        $scope.blkRefresh = function(pont, tipoPonteiro){
          if(tipoPonteiro == "pontpubl")
            TipoValor.row.pontPubl = pont;
        }
        
        $scope.removeTipoValor = function(rowData) {
          //begin-user-code
          $rootScope.TipoValor.copyForm(rowData);
          //end-user-code
          $rootScope.TipoValor.remove(rowData);
          //begin-user-code
          //end-user-code
        }

        // Verifica quantidade de empresas associadas a TipoValor
        $scope.isAtribuido = function(tv) {
          var str = stripBarsFilter(encodeURIComponent(tv + ''));
          if (str.length > 0) {
            $http({
              url: (window.hostApp || "") + 'api/rest/ergon/TipoValorEmpresa/countByTipoValor/' + str,
              method: 'GET',
              transformResponse: [function (data) {
                if (data.length === 0 || data[0] == '{' || data[0] === '0') {
                  return false;
                } else {
                  return true;
                }
              }]
            });
          }
          return false;
        };
        
        $scope.clearFilter = function(){
          $scope.searchFilters.tipoValor = "";
          $scope.searchFilters.valorTaxa = "";
          $scope.searchFilters.dtini = "";
          $scope.searchFilters.dtfim = "";
        }
        
      }
    ]);
    
    app.controller('ValidTipoValorFormController', ['$scope','$rootScope','$translate','$controller',
      function($scope,$rootScope,$translate,$controller) {
        angular.merge(this, $controller('ValidFormController', {$scope: $scope}));
        var datasource  = $rootScope.TipoValor;
        
        $scope.sendData = function(form, datasource, attrEmpresa, blockVinc){
          //
          $scope.send(form, datasource, attrEmpresa, blockVinc);
          
          $rootScope.ValoresGrid.refreshLastFilter();
          $rootScope.EmpresasAssociaveis.refreshLastFilter();
        }
        
        $scope.validate = function(field) { 
          var vldfield = true;
          
          if (!field || typeof(field) === "undefined")
            return vldfield;
          if ((!datasource) || (typeof(datasource) === "undefined"))
            return vldfield;
          //if (field.$pristine || !field.$touched)
          //  return vldfield; // campos em estado pristine ou untouched não são revalidados
        
          angular.forEach(field.$error, function(value, key) {
            if (key=='required' && value===true && datasource.env!==null && datasource.env===true) {
              vldfield = false;
            } else if (key!=='required' && value===true) {
              vldfield = false;
            }
          });
          
          return vldfield;
        }
      }]);
    
    app.controller('ValidValoresGridFormController', ['$scope','$rootScope','$translate','$controller',
      function($scope,$rootScope,$translate,$controller) {
        angular.merge(this, $controller('ValidFormController', {$scope: $scope}));
        var datasource  = $rootScope.ValoresGrid;
        
        $scope.sendData = function(form, datasource, attrEmpresa, blockVinc){
          //
          
          $scope.send(form, datasource, attrEmpresa, blockVinc);
          
          if (!datasource.inserting && !datasource.editing) {
            $rootScope.ValoresGrid.refreshLastFilter();
            $('#modalValoresGrid').modal('hide');
          }
        }
        
        $scope.validate = function(field) { 
          var vldfield = true;
          
          if (!field || typeof(field) === "undefined")
            return vldfield;
          if ((!datasource) || (typeof(datasource) === "undefined"))
            return vldfield;
          //if (field.$pristine || !field.$touched)
          //  return vldfield; // campos em estado pristine ou untouched não são revalidados
        
          angular.forEach(field.$error, function(value, key) {
            if (key=='required' && value===true && datasource.env!==null && datasource.env===true) {
              vldfield = false;
            } else if (key!='required' && value===true) {
              vldfield = false;
            }
          });
          
          return vldfield;
        }
      }]); 
    
    app.directive('ddValorTaxa', function() {
      return {
        restrict: 'E',
        require:  'ngModel',
        template: '<div class="component-holder ng-binding ng-scope" data-component="crn-combobox">' +
                  '  <div class="form-group">' +
                  '  	<ui-select theme="bootstrap" class="crn-select">' +
                  '      <ui-select-match allow-clear="true">{{$select.selected | valorTaxaDesc}}</ui-select-match>' +
                  '      <ui-select-choices repeat="row in valorTaxaSelect | filter:$select.search">' +
                  '        <div data-container="true" ng-if="row === null">&nbsp;</div>' +
                  '        <div data-container="true" ng-if="row !== null">{{ row | valorTaxaDesc }}</div>' +
                  '      </ui-select-choices>' +
                  '    </ui-select>' +
                  '  </div>' +
                  '</div>',
        scope: true,
        controller: function($scope) { 
          $scope.valorTaxaSelect = [null, 'V', 'T'];
        }
      }
    });

} (app));