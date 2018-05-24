(function ($app) {
  angular.module('page.controllers', []);
  
    app.controller('trpv0010', ['$scope', 
                                '$http', 
                                '$rootScope', 
                                '$state', 
                                '$location', 
                                '$translate', 
                                'Notification', 
      function ($scope, $http, $rootScope, $state, $location, $translate, Notification) {

        $scope.ativaBotaoAlterarPasso = function(){
          if ($scope.blkReqVinc == undefined || ReqAposentHistorico.filtro == undefined)
            return true ;  
          return false;
        };
        
        $scope.ativaBotaoParecer = function(){
          if ($scope.blkReqVinc == undefined || GravarParecer.parecer == undefined)
            return true ;  
          return false;
        };        
        
        $scope.alterarPasso = function() {
          
          AlterarPasso.startInserting();
          requerimento = {};
          
          passoAtual = {};
          passoAtual.id = ReqAposentHistorico.filtro.proxPasso;
          
          requerimento.numero = $scope.blkReqVinc.idreq;
          AlterarPasso.active.requerimento  = requerimento;
          AlterarPasso.active.passo         = passoAtual;
          AlterarPasso.post();
        }

        $scope.gravarParecer = function() {
          
          GravarParecer.startEditing();

          GravarParecer.active.requerimento  = $scope.blkReqVinc.idreq;
          GravarParecer.active.parecer       = GravarParecer.parecer;
 
          GravarParecer.post();
        } 

      }
    ]);
} (app));