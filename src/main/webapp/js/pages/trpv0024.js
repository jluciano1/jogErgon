(function ($app) {
  angular.module('page.controllers', []);
  
    app.controller('trpv0024', ['$scope', 
                                '$rootScope', 
                                'Notification', 
      function ($scope, $rootScope, Notification) {

        app.userEvents.concatPassoAnterior = function(){
          var data = infoPassoAtual.active.passoAnterior;
          if (typeof data !== "undefined")
            infoPassoAtual.active.passoAnterior.sigladescr = data.sigla !== null ? data.sigla + ' - ' +data.descricao : "";
          return;
        }

        $scope.reverterPassoAnterior = function(){
          var data = infoPassoAtual.active.passoAnterior;
          if (typeof data == "undefined"){
            Notification.warning({message: 'Selecione um requerimento para reverter o passo.', delay: 3000});
            return;
          }else{
            revertPasso.startInserting();
            revertPasso.active.id = infoPassoAtual.active.id;
            revertPasso.post();
          }

        };
        
      }
    ]);
    
} (app));