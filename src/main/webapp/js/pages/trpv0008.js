(function ($app) {
  angular.module('page.controllers', []);
  
    app.controller('trpv0008', ['$scope', 
                                '$http', 
                                '$rootScope', 
                                '$state', 
                                '$location', 
                                '$translate', 
                                'Notification', 
      function ($scope, $http, $rootScope, $state, $location, $translate, Notification) {

        $scope.ativaBotao = function(){
          if ($scope.blkVinc == undefined || CaminhoReq.filtro == undefined)
            return true ;  
          return false;
        };
        
        app.userEvents.refreshMaster = function(event){
          RequerimentoAposent.refreshLastFilter();
        }
        
        app.userEvents.atualizaPublicada = function(event) {
          for(i = 0; i < RequerimentoAposent.data.length; i++){
            if((CaminhoReq.data[i].tipoRequerimento.id == CaminhoReq.active.tipoRequerimento.id) && (CaminhoReq.active.id != CaminhoReq.data[i].id))
            CaminhoReq.data[i].publicada = "N";
          }
        }

        
        $scope.abrirRequerimento = function() {
          AbrirRequerimento.startInserting();
          AbrirRequerimento.active.numfunc    = $scope.blkVinc.numfunc;
          AbrirRequerimento.active.numvinc    = $scope.blkVinc.numvinc;
          AbrirRequerimento.active.caminhoReq = CaminhoReq.filtro;
          AbrirRequerimento.post();
        }        
      }
    ]);
} (app));