(function ($app) {
  angular.module('page.controllers', []);
  
    app.controller('trpv0027', ['$scope', 
                                '$http', 
                                '$rootScope', 
                                '$state', 
                                '$location', 
                                '$translate', 
                                'Notification', 
                                'GenericService',
      function ($scope, $http, $rootScope, $state, $location, $translate, Notification, GenericService) {
        $scope.tipo = {};
        $scope.lote = {env: false};
        $scope.enableLote = true;
        $scope.tipoCargas = [
              {sigla: 'Boleto', nome: 'Inclusão via boleto'},
              {sigla: 'Suplementar', nome: 'Inclusão via carga suplementar'},
              {sigla: 'DACPREV', nome: 'DACPREV'},
              {sigla: 'Não informada', nome: 'Não informada'}
          ];
          
        $scope.tipos = [
              {sigla: 'CSP', nome: 'Certidão de Situação Previdenciária'},
              {sigla: 'CRP', nome: 'Certidão de Regularidade Previdenciária'}
          ];
        
        $scope.ultimoValorBase = null;
        $scope.ultimoValorSegurado = null;
        $scope.ultimoValorPatronal = null;  
          
        $scope.onOpenForm = function() {
          $scope.tipo = $scope.tipos.find(function(e){
            return e.sigla == ContribuicaoPrevidenciaria.active.tipo;
          })
        };
        
        $scope.setTipo = function(o){
          if(typeof(o) !== "undefined")
            ContribuicaoPrevidenciaria.active.tipo = o.sigla;
          else
            ContribuicaoPrevidenciaria.active.tipo = null;
        }
        
        $scope.clearFilter = function(){
          $scope.filtroDtFim = "";
          $scope.filtroDtIni = "";
        }
        
        $scope.postInsereContribLote = function(numfunc, numvinc, form){
          $scope.lote.env = true;
          var aux = $scope.lote.tipo;
          if (typeof($scope.lote.tipoCarga) !== "undefined")
            $scope.lote.tipoDeContribuicao = $scope.lote.tipoCarga.sigla;
          if (typeof($scope.lote.tipo) !== "undefined")
            $scope.lote.tipo = $scope.lote.tipo.sigla;
          if((form.$valid)&&(!form.$pristine)){
            GenericService.postData("api/ws/rest/ergon/v1.0/previdencia/contribuicoes/lote/" + numfunc + "/" + numvinc, $scope.lote)
            .then(function(response){
              if (response.length > 0)
              {
                $scope.enableLote = false;
                $scope.lote.valorPatronal = response[0].patronal;
                $scope.lote.valorSegurado = response[0].segurado;
                
                GenericService.getData("api/rest/ergon/ContribuicaoPrevidenciaria/listByData?numFunc=" + numfunc + "&numVinc=" + numvinc
                + "&dtIni=" + $scope.filtroDtIni + "&dtFim=" + $scope.filtroDtFim)
                .then(function(response){
                  ContribuicaoPrevidenciaria.data = response.content;
                });
              } 
              $scope.lote.tipo = aux;
            });
          }
        }
        
        $scope.initInsereContribLote = function(){
          $scope.lote = {env: false};
          $scope.enableLote = true;
        }
        
        $scope.configValorIsento = function(){
          if (ContribuicaoPrevidenciaria.active.isento === 'S')
          {
            $scope.ultimoValorBase = ContribuicaoPrevidenciaria.active.base;
            $scope.ultimoValorSegurado = ContribuicaoPrevidenciaria.active.segurado;
            $scope.ultimoValorPatronal = ContribuicaoPrevidenciaria.active.patronal;
            ContribuicaoPrevidenciaria.active.base = 0;
            ContribuicaoPrevidenciaria.active.segurado = 0;
            ContribuicaoPrevidenciaria.active.patronal = 0;
            patronal
          }
          else
          {
            ContribuicaoPrevidenciaria.active.base = $scope.ultimoValorBase;
            ContribuicaoPrevidenciaria.active.segurado = $scope.ultimoValorSegurado;
            ContribuicaoPrevidenciaria.active.patronal = $scope.ultimoValorPatronal;
          }
        }
        
      }
    ]);
} (app));