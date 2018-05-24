(function ($app) {
  angular.module('page.controllers', []);
  
    app.controller('trpv0001', ['$scope', 
                                '$http', 
                                '$rootScope', 
                                '$state', 
                                '$location', 
                                '$translate', 
                                'Notification', 
      function ($scope, $http, $rootScope, $state, $location, $translate, Notification) {
    
        $scope.tipoOrdem = [
              {tOrdem: 'Inicial'},
              {tOrdem: 'Intermediário'},
              {tOrdem: 'Final'}
          ];
        $scope.tipoCarac = [
              {tOrdem: 'Inicial', caracteristica: 'Agendamento'},
              {tOrdem: 'Inicial', caracteristica: 'Autorização'},
              {tOrdem: 'Inicial', caracteristica: 'Concessão'},              
              {tOrdem: 'Intermediário', caracteristica: 'Agendamento'},
              {tOrdem: 'Intermediário', caracteristica: 'Autorização'},
              {tOrdem: 'Intermediário', caracteristica: 'Concessão'},
              {tOrdem: 'Final', caracteristica: 'Agendamento'},
              {tOrdem: 'Final', caracteristica: 'Autorização'},
              {tOrdem: 'Final', caracteristica: 'Concessão'},
              {tOrdem: 'Final', caracteristica: 'Expiração'}
        ];

          $scope.tipoDoc = [
              {tOrdem: 'Inicial', docObrigatoria: 'N'},
              {tOrdem: 'Intermediário', docObrigatoria: 'S'},
              {tOrdem: 'Intermediário', docObrigatoria: 'N'},
              {tOrdem: 'Final', docObrigatoria: 'S'},
              {tOrdem: 'Final', docObrigatoria: 'N'}
          ];
          
          $scope.resetValues = function(){
            Passos.active.caracteristica = "";
            Passos.active.docObrigatoria = "";
          }
        
      }
    ]);
} (app));