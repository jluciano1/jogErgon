(function ($app) {
  angular.module('page.controllers', []);
  
    app.controller('trpv0060', ['$scope', 
                                '$http', 
                                '$rootScope', 
                                '$state', 
                                '$location', 
                                '$timeout',
                                '$translate', 
                                'Notification',
                                'stripBarsFilter',
                                'GenericService',
      function ($scope, $http, $rootScope, $state, $location, $timeout, $translate, Notification, stripBarsFilter, GenericService) {
        $scope.Rubrica = {};
        
        $scope.InsertDocLei = { data: [] };
        $scope.quantidade = 0;
        $scope.exibePaineis = false;
        var urlProc = "api/ws/rest/ergon/v1.0/folha/rubricas/lotes/lote/baseLegal/";
        var urlCont = "api/rest/ergon/ParamRubricaFixacao/contador/";
        
        //Recebe parametros
        $scope.paramsFixos = {
          empresa: "",
          rubrica: "",
          data: ""
        };
        
        //Watches
        $scope.$watchGroup(['data','Empresas.active.empresa','Rubrica.filtro'], function(newValues) {
            if(newValues[0] !== undefined && newValues[0] !== null &&
               newValues[1] !== undefined && newValues[1] !== null &&
               newValues[2] !== undefined && newValues[2] !== null){
                 
                $scope.exibePaineis = true;
                $scope.paramsFixos.data = newValues[0];
                $scope.paramsFixos.empresa = newValues[1];
                $scope.paramsFixos.rubrica = newValues[2].rubrica;
                getCount();
            }
        });
      //*********CHAMADA DO WS*********//
      sendData = function(_method, _url, _data){
        var _headers = "origin-path:" + $location.path();
        
        return $http({
            method  : _method,
            url     : _url,
            data    : _data,
            headers : _headers
          })
            .success(function(data, status, headers, config) {
              Notification.success(data.mens);
          })
            .error(function(data, status, headers, config) {
              Notification.error(data);
          });
      }
        
      //*********INSERÇÃO*********//
      $scope.insercaoLote = function(data){
          if(data === undefined){
            showError("Campos obrigatórios deixados em branco");
          }else if(data.tipo === undefined){
            showError("Tipo de documento é obrigatório");
          }else if(data.numero === undefined){
            showError("Número/Ano é obrigatório");
          }else{
            $.prompt("Tem certeza que deseja gerar base legal para " + $scope.quantidade + " registros?", {
          	buttons: { "Sim": true, "Cancelar": false },
          	focus: 1,
          	zIndex: 9999,
          	opacity: 0.4,
          	submit: function(e,v,m,f){
          		if(v){
          		  var _data = JSON.stringify({
                          	flag        : data.flag,
                          	oper        : 'I',
              	            data        : $scope.paramsFixos.data,
              	            empCodigo   : $scope.paramsFixos.empresa,
              	            rubrica     : $scope.paramsFixos.rubrica,
              	            tipoDoc     : data.tipo.tipodoc,
              	            numero      : data.numero.numero,
              	            ano         : data.numero.ano,
              	            refer       : data.refer,
              	            obs         : data.obs,
              	            historico   : data.historico
                        });
                sendData("POST", urlProc + $scope.paramsFixos.empresa + '/' + $scope.paramsFixos.rubrica + '/' + $scope.paramsFixos.data, _data);
              }
          	}
          }
        )}
      }
        
      //*********EXCLUSÃO*********//
      $scope.exclusaoLote = function(){
        $.prompt("Tem certeza que deseja excluir base legal de " + $scope.quantidade + " registros?", {
          	buttons: { "Sim": true, "Cancelar": false },
          	focus: 1,
          	zIndex: 9999,
          	opacity: 0.4,
          	submit: function(e,v,m,f){
          		if(v){
          		  sendData("DELETE", urlProc + $scope.paramsFixos.empresa + '/' + $scope.paramsFixos.rubrica + '/' + $scope.paramsFixos.data)
              }
          	}
          }
        )
        }
        
      //******** GET CONTADOR **********//
      function getCount(){
          GenericService.getData(urlCont + $scope.paramsFixos.empresa + '/' + $scope.paramsFixos.rubrica + '/' + $scope.paramsFixos.data)
            .then(
              //success
              function(response) {
                $scope.quantidade = response;
              },
              //failure
              function(response) {
                $scope.quantidade  = 0;
              }
            );
        }
        
      //******** FUNÇÕES AUXILIARES ********//
      function showError(e) {
          if (!e.hasOwnProperty('message')) {
            e.message = 'Erro não tratado';
          }
          if (!e.hasOwnProperty('title')) {
            if (e.hasOwnProperty('name')) {
              e.title = e.name;
            } else {
              e.title = 'Erro não tratado';
            }
          }
          if (!e.hasOwnProperty('delay')) {
            e.delay = 5000;
          }
          Notification.error(e);
        }
      }
    ]);

} (app));