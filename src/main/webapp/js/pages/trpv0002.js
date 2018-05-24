(function ($app) {
  angular.module('page.controllers', []);
  
    app.controller('trpv0002', ['$scope', 
                                '$http', 
                                '$rootScope', 
                                '$state', 
                                '$location', 
                                '$translate', 
                                'Notification', 
      function ($scope, $http, $rootScope, $state, $location, $translate, Notification) {
        $scope.setValueForm = function()
        {
          PassosRequerimento.active.idCaminhoReq = CaminhoReq.active.id;
          PassosRequerimento.active.idPassoAtual = Passos.active.id;
          PassosRequerimento.active.siglaPassoAtual = Passos.active.sigla;
          PassosRequerimento.active.ordemPassoAtual = Passos.active.ordem;
          PassosRequerimento.active.caracPassoAtual = Passos.active.caracteristica;
          PassosRequerimento.active.caracProxPasso = PassosRequerimento.active.proxPasso.caracteristica;
          PassosRequerimento.active.ordemProxPasso = PassosRequerimento.active.proxPasso.ordem;
          PassosRequerimento.active.siglaProxPasso = PassosRequerimento.active.proxPasso.sigla;
          PassosRequerimento.active.idProxPasso = PassosRequerimento.active.proxPasso.id;
        }
        
        $scope.selectTipoRequerimento = function(selected)
        {
          if(typeof(selected) !== 'undefined' && selected !== null)
          {
            CaminhoReq.active.idTipoRequerimento = selected.id;
            CaminhoReq.active.nomeTipoRequerimento = selected.tipoRequerimento;
          }
          else
          {
            CaminhoReq.active.idTipoRequerimento = null;
            CaminhoReq.active.nomeTipoRequerimento = null;
          }
        }
      }
    ]);
    
    app.userEvents.atualizaPublicada = function(event) {
      for(i = 0; i < CaminhoReq.data.length; i++){
        if((CaminhoReq.data[i].idTipoRequerimento == CaminhoReq.active.idTipoRequerimento) && (CaminhoReq.active.id != CaminhoReq.data[i].id))
          CaminhoReq.data[i].publicada = "N";
      }
    }

} (app));

