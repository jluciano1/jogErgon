(function($app) {
    angular.module('page.controllers', []);

    app.controller('trpv0058', ['$scope',
        '$http',
        '$rootScope',
        '$state',
        '$location',
        '$translate',
        '$filter',
        'Notification',
        'GenericService',
        function($scope, $http, $rootScope, $state, $location, $translate, $filter, Notification, GenericService) {
            
            $scope.RepresentanteLegal = { data: [] };
            $scope.sexo = [{opc: 'F'}, {opc: 'M'}];
            $scope.startInsert = false;
            
            // Limpa os campos caso não tenha valor no input de pesquisa
            $scope.$watch('RepresentanteLegal.filtro', function() {
              if($scope.RepresentanteLegal.filtro == null || $scope.RepresentanteLegal.filtro == ""){
                $scope.RepresentanteLegal.active = {};
              }
            });
            
            $scope.novoRepresentante = function(){
              $scope.startInsert = true;
            }

            // Recebe a lista de todos representantes cadastrados
            $scope.getRepresentante = function(representante) {
              if(representante.length > 0){
                if(isNaN(representante)){
                  // get por nome do representante
                  GenericService.getData("api/ws/rest/ergon/v1.0/pessoal/representantes/representante/nome/" + representante,
                  function(response, error) {
                    if(response){
                      $scope.RepresentanteLegal.data = response; 
                    }
                  })
                  $scope.$watch('RepresentanteLegal.filtro', function() {
                    if($scope.RepresentanteLegal){
                    	$scope.RepresentanteLegal.data.map(function(representante){
                    	  if($scope.RepresentanteLegal.filtro == representante.numero){
                    	    $scope.RepresentanteLegal.active = representante;
                    	  }
                    	});
                    }
                  });
                } else {
                  // get por numero do representante
                  $scope.RepresentanteLegal.data = [];
                  GenericService.getData("api/ws/rest/ergon/v1.0/pessoal/representantes/representante/" + representante,
                  function(response, error) {
                    if(response){
                      $scope.RepresentanteLegal.data.push(response);
                    }
                  })
                  $scope.$watch('RepresentanteLegal.filtro', function() {
                    if($scope.RepresentanteLegal){
                    	$scope.RepresentanteLegal.data.map(function(representante){
                    	  if($scope.RepresentanteLegal.filtro == representante.numero){
                    	    $scope.RepresentanteLegal.active = representante;
                    	  }
                    	});
                    }
                  });
                }
              }
            };
            
            // Recebe tipos de RG
            GenericService.getData("api/rest/ergon/ItemTabela/Tabela/TIPO_RG").then(function(response){
              $scope.tipoRegistro = response;
            });
            // Recebe orgao Expeditor do RG
            GenericService.getData("api/rest/ergon/ItemTabela/Tabela/ORGAO%20RG?size=100000").then(function(response){
              $scope.orgaoExpeditor = response;
            });
            // Recebe estados
            GenericService.getData("api/rest/ergon/ItemTabela/Tabela/UF?size=30").then(function(response){
              $scope.estados = response;
            });
            // recebe tipos de logradouros
            GenericService.getData("api/rest/ergon/ItemTabela/Tabela/Logradouros").then(function(response){
              $scope.logradouros = response.content;
              $scope.logradouros.map(function(logradouro){
                logradouro.descricao = logradouro.descricao.toUpperCase();
              })
            });
            // recebe lista de bancos
            GenericService.getData("api/rest/ergon/Bancos?size=100000").then(function(response){
              $scope.bancos = response;
            });
            // Recebe lista de cidades quando estado é selecionado
            $scope.$watch('RepresentanteLegal.active.ufEnder', function() {
              if($scope.RepresentanteLegal.active && $scope.RepresentanteLegal.active.ufEnder){
              	GenericService.getData("api/rest/ergon/Municipio/listByEstado?size=1000000&estado="
              	+ $scope.RepresentanteLegal.active.ufEnder).then(function(response){
              	  $scope.cidadeEndereco = response;
              	});
              }
            });
            // Observa se algum banco foi escolhido e busca suas agencias
            $scope.$watch('RepresentanteLegal.active.banco', function() {
               if($scope.RepresentanteLegal.active && $scope.RepresentanteLegal.active.banco){
                 GenericService.getData("api/rest/ergon/Agencias/listByBanco/" + $scope.RepresentanteLegal.active.banco).then(function(response){
                   $scope.agencias = response;
                 });
               }
            });
            
            // Remove representante legal
            $scope.removeRepresentante = function(representante) {
                $scope.prompt("Deseja remover o representante legal?",
                    function() {
                        GenericService.deleteData("api/ws/rest/ergon/v1.0/pessoal/representantes/representante" +
                        "/" + representante).then(function(response) {
                          $scope.RepresentanteLegal.data = [];
                          $scope.RepresentanteLegal.filtro = "";
                          $scope.RepresentanteLegal.active = {};
                        })
                    }
                );
            }

            // Insere ou atualiza um representante legal
            $scope.atualizaRepresentante = function(representante, representanteActive) {
              if(representanteActive.nome && representanteActive.cpf && representanteActive.sexo && representanteActive.dtNasc){
                var sendObject = {
                  "agencia": null,
                  "agenciaDescr": null,
                  "agenciaNome": null,
                  "bairroEnder": null,
                  "banco": null,
                  "bancoDescr": null,
                  "bancoNome": null,
                  "cepEnder": null,
                  "cidadeEnder": null,
                  "cidadeUfEnder": null,
                  "complementoEnder": null,
                  "conta": null,
                  "cpf": null,
                  "dtNasc": null,
                  "expedRg": null,
                  "nome": null,
                  "nomeLogEnder": null,
                  "numero": null,
                  "numeroEnder": null,
                  "orgaoRg": null,
                  "pontPubl": null,
                  "rg": null,
                  "sexo": null,
                  "sexoDescr": null,
                  "sexoNome": null,
                  "telefoneEnder": null,
                  "tipoLogradouroEnder": null,
                  "tipoLogradouroEnderDescr": null,
                  "tipoPag": null,
                  "tipoRg": null,
                  "ufEnder": null,
                  "ufRg": null
                }
                sendObject = {
                  "agencia": representanteActive.agencia,
                  "agenciaDescr": representanteActive.agenciaDescr,
                  "agenciaNome": representanteActive.agenciaNome,
                  "bairroEnder": representanteActive.bairroEnder,
                  "banco": representanteActive.banco,
                  "bancoDescr": representanteActive.bancoDescr,
                  "bancoNome": representanteActive.bancoNome,
                  "cepEnder": representanteActive.cepEnder,
                  "cidadeEnder": representanteActive.cidadeEnder,
                  "cidadeUfEnder": representanteActive.cidadeUfEnder,
                  "complementoEnder": representanteActive.complementoEnder,
                  "conta": representanteActive.conta,
                  "cpf": representanteActive.cpf,
                  "dtNasc": representanteActive.dtNasc,
                  "expedRg": representanteActive.expedRg,
                  "nome": representanteActive.nome,
                  "nomeLogEnder": representanteActive.nomeLogEnder,
                  "numero": representanteActive.numero,
                  "numeroEnder": representanteActive.numeroEnder,
                  "orgaoRg": representanteActive.orgaoRg,
                  "pontPubl": null,
                  "rg": representanteActive.rg,
                  "sexo": representanteActive.sexo,
                  "sexoDescr": representanteActive.sexoDescr,
                  "sexoNome": representanteActive.sexoNome,
                  "telefoneEnder": representanteActive.telefoneEnder,
                  "tipoLogradouroEnder": representanteActive.tipoLogradouroEnder,
                  "tipoLogradouroEnderDescr": representanteActive.tipoLogradouroEnderDescr,
                  "tipoPag": representanteActive.tipoPag,
                  "tipoRg": representanteActive.tipoRg,
                  "ufEnder": representanteActive.ufEnder,
                  "ufRg": representanteActive.ufRg
                }
                
                if(representanteActive.banco == null || representanteActive.banco == ""){
                  representanteActive.bancoNome = null;
                  representanteActive.bancoDescr = null;
                  representanteActive.banco = null;
                }
                if(representanteActive.agencia == null || representanteActive.agencia == ""){
                  representanteActive.agenciaNome = null;
                  representanteActive.agenciaDescr = null;
                  representanteActive.agencia = null;  
                }
                if(representanteActive.conta == null || representanteActive.conta == ""){
                  representanteActive.conta = null;
                }
                if(representanteActive.tipoPag == null || representanteActive.tipoPag == ""){
                  representanteActive.tipoPag = null;
                }
                if(representanteActive.tipoRg == null || representanteActive.tipoRg == ""){
                  representanteActive.tipoRg = null;
                }
                if(representanteActive.ufEnder == null || representanteActive.ufEnder == ""){
                  representanteActive.ufEnder = null;
                }
                if(representanteActive.ufRg == null || representanteActive.ufRg == ""){
                  representanteActive.ufRg = null;
                }
                if(representanteActive.orgaoRg == null || representanteActive.orgaoRg == ""){
                  representanteActive.orgaoRg = null;
                }
                if(representanteActive.rg == null || representanteActive.rg == ""){
                  representanteActive.rg = null;
                }
                if(representanteActive.tipoLogradouroEnder == null || representanteActive.tipoLogradouroEnder == ""){
                  representanteActive.tipoLogradouroEnder = null;
                }
                if(representanteActive.tipoLogradouroEnderDescr == null || representanteActive.tipoLogradouroEnderDescr == ""){
                  representanteActive.tipoLogradouroEnderDescr = null;
                }
                if(representanteActive.tipoLogradouroEnderDescr == null || representanteActive.tipoLogradouroEnderDescr == ""){
                  representanteActive.tipoLogradouroEnderDescr = null;
                }
                if(representanteActive.cidadeEnder == null || representanteActive.cidadeEnder == ""){
                  representanteActive.cidadeEnder = null;
                }
                if(representanteActive.cidadeUfEnder == null || representanteActive.cidadeUfEnder == ""){
                  representanteActive.cidadeUfEnder = null;
                }
                if (representante) {
                    GenericService.putDataCallErr("api/ws/rest/ergon/v1.0/pessoal/representantes/representante" +
                      "/" + representante, representanteActive).then(function(response) {
                       $scope.RepresentanteLegal.active = response;
                    },function(errResponse) {
                        Notification.error(errResponse.data.message);
                        })
                  } else {
                    GenericService.postData("api/ws/rest/ergon/v1.0/pessoal/representantes/representante", sendObject)
                      .then(function(response) {
                      if(response.numero){
                        $scope.RepresentanteLegal.active = response; 
                      }
                    })
                }
              }
            }

            $scope.cancelarFormulario = function() {
                $scope.RepresentanteLegal.filtro = "";
                $scope.RepresentanteLegal.active = {};
                $scope.startInsert = false;
                $rootScope.submitted = false;
            }

            $scope.prompt = function(message, genericFunction) {
              $.prompt(message, {
                buttons: { "Ok": true, "Cancel": false },
                focus: 1,
                zIndex: 9999,
                opacity: 0.4,
                submit: function(e, v, m, f) {
                  if (v) {
                    genericFunction();
                  }
                }
              });  
            }

        }

    ]);
}(app));