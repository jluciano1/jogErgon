(function ($app) {
  angular.module('page.controllers', []);
  
    app.controller('trpv0022', ['$scope', 
                                '$rootScope', 
                                'Notification', 
      function ($scope, $rootScope, Notification) {
        $scope.isCollapsed = false;
        $scope.verificarAgendamento = false;
        
        $scope.$watch('blkReqVinc.agendamento', function(){
          if(typeof($scope.blkReqVinc) !== 'undefined' ){
            if(typeof($scope.blkReqVinc.agendamento) !== 'undefined' && $scope.blkReqVinc.agendamento !== null){
              $scope.isCollapsed = true;
              $scope.verificarAgendamento = false;
            }else{
              $scope.isCollapsed = false;
              $scope.verificarAgendamento = true;
            }
          }else{
            $scope.isCollapsed = false;
            $scope.verificarAgendamento = false;
          }
        });
        
        $scope.efetivarAgenda = function(){
          if (typeof $scope.blkReqVinc.idreq == "undefined") {
            Notification.warning({message: 'Selecione um requerimento para efetivar o agendamento!', delay: 3000});
            return;            
          } 
          
          RequerimentoAposent.startInserting();
          RequerimentoAposent.active.fieldLong = $scope.blkReqVinc.idreq;
          RequerimentoAposent.active.fieldDate = RequerimentoAposent.fieldDate;
          RequerimentoAposent.post();
        }; 
      }
    ]);
} (app));