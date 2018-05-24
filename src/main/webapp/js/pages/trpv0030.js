(function ($app) {
  angular.module('page.controllers', []);
  
    app.controller('trpv0030', ['$scope', 
                                '$http', 
                                '$rootScope', 
                                '$state', 
                                '$location', 
                                '$translate', 
                                'Notification', 
      function ($scope, $http, $rootScope, $state, $location, $translate, Notification) {
        
        $scope.clearFilter = function(){
          $scope.dtfim = "";
          $scope.dtini = "";
          $scope.Atividade.filtro = "";
          $scope.Disciplina.filtro = "";
          $scope.setor = "";
          $scope.Turnos.filtro = "";
        }
        
        $scope.concatenacao = function (rowData) {
               $scope.numfuncInfo = (rowData.numfunc !== null) ? rowData.numfunc.numero + ' - ' + rowData.numfunc.nome : "";
               $scope.atividadeInfo = (rowData.atividade !== null) ? rowData.atividade.codigo + ' - ' + rowData.atividade.nome : "";
               $scope.disciplinaInfo = (rowData.disciplina !== null) ? rowData.disciplina.disciplina + ' - ' + rowData.disciplina.descricao: "";
               $scope.turnoInfo = (rowData.turno !== null) ? rowData.turno.turno + ' - ' + rowData.turno.descricao : "";
            }

      }
    ]);

} (app));