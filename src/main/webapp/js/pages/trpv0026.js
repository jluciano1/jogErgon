(function ($app) {
  angular.module('page.controllers', []);
  
    app.controller('trpv0026', ['$scope', 
                                '$http', 
                                '$rootScope', 
                                '$state', 
                                '$location', 
                                '$translate', 
                                'Notification',
                                'GenericService',
      function ($scope, $http, $rootScope, $state, $location, $translate, Notification, GenericService) {
        
        $scope.fundamentoFinalidade = "";
        $scope.regraFinalidade = "";
        $scope.modalidadeAposentadoria = [];
        $scope.tipoAposentadoria = { data: [] };
        
        GenericService.getData('api/rest/ergon/TipoAposentadoria?page=0&size=1000').then(function(response){
          $scope.tipoAposentadoria.data = response.content;
        });
        
        $scope.modalidadeAposentadoria = [
          {numero: 1, modalidade: "Voluntária integral"},
          {numero: 2, modalidade: "Voluntária especial"},
          {numero: 3, modalidade: "Voluntária proporcional por idade"},
          {numero: 4, modalidade: "Compulsória integral"},
          {numero: 5, modalidade: "Compulsória proporcional"},
          {numero: 6, modalidade: "Invalidez integral"},
          {numero: 7, modalidade: "Invalidez proporcional"},
          {numero: 8, modalidade: "Vol. Proporcional t. Contribuição"},
          {numero: 9, modalidade: "Voluntária com redutor"}
        ]
        
        $scope.regraAposentadoria = [
          {numero: 1, regra: "Regra antes EC20"},
          {numero: 2, regra: "Regra Permanente"},
          {numero: 3, regra: "Transição Emenda 20"},
          {numero: 4, regra: "Transição Art. 2º EC41"},
          {numero: 5, regra: "Transição Art. 6º EC41"},
          {numero: 6, regra: "Transição Emenda 47"},
          {numero: 7, regra: "Transição Art. 6º Alínea a EC41 (EC 70)"},
          {numero: 8, regra: "Regra Art. 40, § 4º, III da CF, c/c a Súmula Vinculante nº 33/14 do STF"},
          {numero: 9, regra: "Regra Art. 40, § 4º, II da CF"}
        ]
        
        $scope.clearFilter = function(){
          $scope.tipoAposentadoria.filtro = "";
          $scope.FinalidadeContaFiltro.filtro = "";
        }
        
        //Seta o ponteiro de publicação do registro corrente
        //Utilizado como callback na diretiva blkPont
        $scope.blkRefresh = function(pont, tipoPonteiro){
          if(tipoPonteiro == "pontlei")
            TipoAposFinalidade.row.pontLei = pont;
        }
        
        $scope.$watch('TipoAposFinalidade.active.finalidadeConta', function(){
          if(typeof($scope.FinalidadeConta.data) !== 'undefined' )
          {
            for (var i = 0; i < FinalidadeConta.data.length; i++)
            {
              if (FinalidadeConta.data[i] === TipoAposFinalidade.active.finalidadeConta)
              {
                $scope.fundamentoFinalidade = FinalidadeConta.data[i].fundamento;
                $scope.regraFinalidade = FinalidadeConta.data[i].regraAplicada;
              }
            }
          }
        });
        

      }
    ]);
    
} (app));