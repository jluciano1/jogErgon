(function ($app) {
    angular.module('page.controllers', []);
    
    app.controller('trpv0044', ['$scope',
                                '$sce',
                                '$http', 
                                '$rootScope', 
                                '$state', 
                                '$location', 
                                '$translate', 
                                '$timeout',
                                'Notification', 
                                'stripBarsFilter',
                                'GenericService',
                                'ReportService',
      function ($scope, $sce, $http, $rootScope, $state, $location, $translate, $timeout, Notification, stripBarsFilter, GenericService, ReportService) {
        $scope.$watch(function() {
          return $scope.blkVinc;
        }.bind($scope), function(blkVinc) {
          if (typeof($scope.relatorioData) !== "undefined")
          {
            $scope.relatorioData = {inicial: null, final: null}; 
          }
        });
      }
    ]);
    
} (app));