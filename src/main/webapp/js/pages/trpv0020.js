(function ($app) {
  angular.module('page.controllers', []);
  
    app.controller('trpv0020', ['$scope', 
                                '$http', 
                                '$rootScope', 
                                '$state', 
                                '$location', 
                                '$translate', 
                                'Notification', 
      function ($scope, $http, $rootScope, $state, $location, $translate, Notification) {
        //Teste fake da grid
        $scope.teste = function(){
          //função para gerar objetos fakes para teste da grid
          for(i=0; i<200;i++){
            RequerimentoAposent.data.push(
              {
                "numRequerimento" : Math.random()*100,
                "numProcessoTCE" : Math.random()*10000,
                "numProcessoDigital" : Math.random()*10000,
                "homolog" : new Date()*Math.random(),
                "dtAgendamento" : new Date()*Math.random(),
                "dtConcessao" : new Date()*Math.random(),
                "usuarioAbertura" : "Usuario "+Math.random()*10,
                "dtAbertura" : new Date()*Math.random(),
                "dtEntrada" : new Date()*Math.random(),
                "tipoRequerimento": {"tipoRequerimento" : "teste", "descricao" : "testeDescrição"},
                "ultrapassado" : ((Math.random()%2===0)? "Sim" : "Não")
                
              }
            );
          }
        }
        
      }
    ]);
} (app));