(function ($app) {
  angular.module('page.controllers', []);
  
    app.controller('trpv0005', ['$scope', 
                                '$http', 
                                '$rootScope', 
                                '$state', 
                                '$location', 
                                '$translate', 
                                'Notification',
                                'GenericService',
      function ($scope, $http, $rootScope, $state, $location, $translate, Notification, GenericService) {
        
        $scope.updateAll = true;
        $scope.seeDetail = false;
        $scope.vinculosUrl = "api/ws/rest/ergon/v1.0/funcional/vinculos/dadosBancarios";
        $scope.vinculosDadosFuncionais = "api/ws/rest/ergon/v1.0/funcional/vinculos/dadosFuncionais";
        $scope.Vinculos = { data: [] };
        $scope.VinculosDetalhes = { data: [] };
        $scope.VinculosCopy = {};
        
        $scope.$watch('FuncionariosFiltro.query', function() {
          if($scope.FuncionariosFiltro.query == null || $scope.FuncionariosFiltro.query == ""){
            $scope.Vinculos.data = {};
          }
          if($scope.FuncionariosFiltro.query){
            GenericService.getData($scope.vinculosUrl + '/' + $scope.FuncionariosFiltro.query).then(function(response){
              $scope.Vinculos.data = response;
            })
            GenericService.getData($scope.vinculosDadosFuncionais + '/' + $scope.FuncionariosFiltro.query).then(function(response){
              $scope.VinculosDetalhes.data = response;
            })
          }
        });
        
        $scope.$watchGroup(['VinculosCopy.banco', 'VinculosCopy.agencia', 'VinculosCopy.conta', 'VinculosCopy.tipoPagamento'], function() {
          if ($scope.Vinculos.active) {
            if ($scope.VinculosCopy.banco) {
                $scope.Vinculos.active.bancoNumero = $scope.VinculosCopy.banco.banco;
                $scope.Vinculos.active.bancoNome = $scope.VinculosCopy.banco.nome;
                $scope.Vinculos.active.bancoDescr = $scope.VinculosCopy.banco.descr;
            } else {
                $scope.Vinculos.active.bancoNumero = null;
                $scope.Vinculos.active.bancoNome = null;
                $scope.Vinculos.active.bancoDescr = null;
            }
            if ($scope.VinculosCopy.agencia) {
                $scope.Vinculos.active.agenciaNumero = $scope.VinculosCopy.agencia.agencia;
                $scope.Vinculos.active.agenciaNome = $scope.VinculosCopy.agencia.nome;
                $scope.Vinculos.active.agenciaDescr = $scope.VinculosCopy.agencia.descr;
            } else {
                $scope.Vinculos.active.agenciaNumero = null;
                $scope.Vinculos.active.agenciaNome = null;
                $scope.Vinculos.active.agenciaDescr = null;
            }
            if ($scope.VinculosCopy.tipoPagamento) {
                $scope.Vinculos.active.tipoPagamento = $scope.VinculosCopy.tipoPagamento;
            } else {
                $scope.Vinculos.active.tipoPagamento = null;
            }
            if ($scope.VinculosCopy.conta) {
                $scope.Vinculos.active.conta = $scope.VinculosCopy.conta;
            } else {
                $scope.Vinculos.active.conta = null;
            }
          }
        });
        
        $scope.getVinculoActive = function(vinculo){
          $scope.VinculosCopy = {};
          $scope.VinculosCopy.banco = {
            nome: vinculo.bancoNome,
            banco: vinculo.bancoNumero,
            descr: vinculo.bancoDescr
          }
          $scope.VinculosCopy.agencia = {
            agencia: vinculo.agenciaNumero,
            nome: vinculo.agenciaNome,
            descr: vinculo.agenciaDescr
          }
          $scope.VinculosCopy.tipoPagamento = vinculo.tipoPagamento;          
          $scope.VinculosCopy.conta = vinculo.conta;
          $scope.updateAll = false;
          $scope.VinculosDetalhes.data.map(function(detalhe){
            if(vinculo.numero == detalhe.numvinc){
              $scope.VinculosDetalhes.active = detalhe;
            }
          })
        }
        
        $scope.removeContaVinculo = function(rowData){
          var sendObject = {
                "numfunc": $scope.FuncionariosFiltro.query,
                "numero": $scope.Vinculos.active.numero,
                "bancoNumero": null,
                "bancoNome": null,
		            "bancoDescr": null,
		            "agenciaNumero": null,
		            "agenciaNome": null,
		            "agenciaDescr": null,
                "conta": null,
                "tipoPagamento": null,
                "entityStateHash": rowData.entityStateHash
              }
          $scope.prompt("Deseja remover os dados bancários deste vínculo?",
            function(){
              GenericService.putData('api/ws/rest/ergon/v1.0/funcional/vinculos/vinculo/dadosBancarios/' + $scope.FuncionariosFiltro.query + '/' + $scope.Vinculos.active.numero, sendObject).then(function(response){
                GenericService.getData($scope.vinculosUrl + '/' + $scope.FuncionariosFiltro.query).then(function(response){
                  $scope.Vinculos.data = response;
                })    
              })
            }          
          );
        }
        
        $scope.removeContas = function(){
          var sendObject = {
                "numfunc": $scope.FuncionariosFiltro.query,
                "agenciaNumero": null,
                "banco": null,
                "conta": null,
                "tipoPagamento": null
              }
          $scope.prompt("Deseja remover os dados bancários de todos os vínculos?",
            function(){
              GenericService.putData($scope.vinculosUrl + "/" + $scope.FuncionariosFiltro.query, sendObject).then(function(response){
                GenericService.getData($scope.vinculosUrl + '/' + $scope.FuncionariosFiltro.query).then(function(response){
                  $scope.Vinculos.data = response;
                })
              })
            }          
          );
        }
        
        $scope.atualizaContas = function(atualizacao){
            var sendObject = {
                "numfunc": null,
                "agenciaNumero": null,
                "bancoNumero": null,
                "conta": null,
                "tipoPagamento": null
            }
            if($scope.updateAll){
              sendObject.numfunc = $scope.FuncionariosFiltro.query;
              sendObject.agenciaNumero = atualizacao.agenciaNumero;
              sendObject.bancoNumero = atualizacao.bancoNumero;  
              if(atualizacao.conta){
                sendObject.conta = atualizacao.conta;
              }
              if(atualizacao.tipoPagamento){
                sendObject.tipoPagamento = atualizacao.tipoPagamento;
              }
              $scope.prompt("Deseja atualizar os dados bancários de todos os vínculos?",
                function(){
                  if(atualizacao.bancoNumero && atualizacao.agenciaNumero == null || atualizacao.agenciaNumero == ""){
                    Notification.error("A agencia não é válida para o banco: " + atualizacao.bancoNumero);
                  } else {
                    GenericService.putData($scope.vinculosUrl + "/" + $scope.FuncionariosFiltro.query, sendObject).then(function(response){
                      GenericService.getData($scope.vinculosUrl + '/' + $scope.FuncionariosFiltro.query).then(function(response){
                        $scope.Vinculos.data = response;
                      })
                    })
                  }
                }          
              );
            } else {
              var sendObject = {
                "numfunc": $scope.FuncionariosFiltro.query,
                "numero": $scope.Vinculos.active.numero,
                "bancoNumero": atualizacao.bancoNumero,
                "bancoNome": atualizacao.bancoNome,
		            "bancoDescr": atualizacao.bancoDescr,
		            "agenciaNumero": atualizacao.agenciaNumero,
		            "agenciaNome": atualizacao.agenciaNome,
		            "agenciaDescr": atualizacao.agenciaDescr,
                "conta": atualizacao.conta,
                "tipoPagamento": atualizacao.tipoPagamento,
                "entityStateHash": atualizacao.entityStateHash
              }
              if(atualizacao.bancoNumero && atualizacao.agenciaNumero == null || atualizacao.agenciaNumero == ""){
                Notification.error("A agencia não é válida para o banco: " + atualizacao.bancoNumero);
              } else {
                GenericService.putData('api/ws/rest/ergon/v1.0/funcional/vinculos/vinculo/dadosBancarios/' + $scope.FuncionariosFiltro.query + '/' + $scope.Vinculos.active.numero, sendObject).then(function(response){
                  GenericService.getData($scope.vinculosUrl + '/' + $scope.FuncionariosFiltro.query).then(function(response){
                    $scope.Vinculos.data = response;
                  })    
                })
              }  
            }
        }
        
        $scope.fecharModal = function(){
          GenericService.getData($scope.vinculosUrl + '/' + $scope.FuncionariosFiltro.query).then(function(response){
            $scope.Vinculos.data = response;
          })
          $scope.VinculosCopy = {};
          $scope.Vinculos.active = {};
          $scope.updateAll = true;
          $scope.seeDetail = false;
        }
        
        $scope.seeDetails = function(){
          $scope.seeDetail = true;
        }
        
        $scope.refreshFunc = function(func) {
          var numfunc;
          var posicaoBarra = func.indexOf('/');
          if (func.length > 0) {
              if (posicaoBarra > 0) { //se existe barra
                  numfunc = func.substr(0, posicaoBarra); //determina que numfunc é até a barra
                  if (IsNumeric(numfunc)) { //verifica se sobrou apenas numeros para considerar como numfunc
                      $scope.FuncionariosFiltro.filtro = '/numfunc/' + numfunc;
                  }
              } else {
                  if (IsNumeric(func)) {
                      if (func.length > 9)
                          return;
                      $scope.FuncionariosFiltro.filtro = '/numfunc/' + func;
                  } else {
                      $scope.FuncionariosFiltro.filtro = '/nome/' + func;
                  }
              }
          }
          function IsNumeric(input) {
              return (input - 0) == input && ('' + input).trim().length > 0;
          }
      }
      
      $scope.prompt = function(message, genericFunction){
        $.prompt(message, {
          buttons: { "Ok": true, "Cancel": false },
          focus: 1,
          zIndex: 9999,
          opacity: 0.4,
          submit: function(e,v,m,f){
            if(v){
            	genericFunction();
            }
          }
        });
      }
      
      }
      
    ]);
} (app));