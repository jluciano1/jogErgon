(function ($app) {
  angular.module('page.controllers', []);
  
    app.controller('trpv0004', ['$scope', 
                                '$http', 
                                '$rootScope', 
                                '$state', 
                                '$location', 
                                '$translate', 
                                'Notification', 
      function ($scope, $http, $rootScope, $state, $location, $translate, Notification) {
        /* inicializa os atributos que são usados pelo specificSearch */
        $scope.ativo = 'S';
        $scope.tipo = true; /* seta true quando os dois checkbox estiverem selecionados */
        $scope.checkInativo = false;
        
        $scope.tipoPrazo = [
              {tprazo: 'N'},
              {tprazo: 'E'}
          ];
          
        $scope.contadosApartir = [
              {tContado: 'E'},
              {tContado: 'A'}
          ];
        
        /* verifica os checkboxs de ativo/inativo */   
        $scope.verificarSituacao = function(ativo, inativo) {
          if(ativo === false && inativo === false) $scope.ativo = false; /* seta false se nenhum dos checkbox estiver selecionado */
          
          if(ativo !== false && inativo !== false)
            $scope.ativo = true;
          else {
            if(ativo !== false)
              $scope.ativo = 'S';
            else if(inativo !== false)
              $scope.ativo = 'N';  
          }
        };
        
        /* verifica os checkboxs de notificação/expiração */ 
        $scope.verificarTipoPr = function(notif, exp) {
          if(notif === false && exp === false) $scope.tipo = false; /* seta false se nenhum dos checkbox estiver selecionado */
          
          if(notif !== false && exp !== false)
            $scope.tipo = true;
          else {
            if(notif !== false)
              $scope.tipo = 'N';
            else if(exp !== false)
              $scope.tipo = 'E';
          }
        }; /* fim das funções de verificação de checkbox */
        
        $scope.clearFilter = function(){
          $scope.PrazosPassos.filtro = "";
          $scope.checkNotif = false;
          $scope.checkExp = false;
          $scope.checkAtivo = false;
          $scope.checkInativo = false;
        }
      }
    ]);
} (app));