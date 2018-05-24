(function ($app) {
  angular.module('page.controllers', []);
  
    app.controller('trpv0025', ['$scope', 
                                '$http', 
                                '$rootScope', 
                                '$state', 
                                '$location', 
                                '$translate', 
                                'Notification',
                                'GenericService',
      function ($scope, $http, $rootScope, $state, $location, $translate, Notification, GenericService) {
        
        // arrays utilizados no modal de alteração em lote
        $scope.sinal = [ { sinal: 1 }, { sinal: 0 }, { sinal: -1 } ];
        $scope.ativo = [ { ativo: 'S' }, { ativo: 'N' } ];
        $scope.inativo = [ { inativo: 'S' }, { inativo: 'N' } ];
        $scope.altLote = {};
        
        //Seta o ponteiro de publicação do registro corrente
        //Utilizado como callback na diretiva blkPont
        $scope.blkRefresh = function(pont, tipoPonteiro){
          if(tipoPonteiro == "pontlei")
            Master.row.pontlei = pont;
        }
        
        $scope.restFinalidade = {};
        $scope.tipoDeVinculo = {};
        $scope.regimeJuridico = {};
        $scope.restCategoria = {};
        $scope.restSubFilter = {};
        $scope.restRubrica = {};
        
        $scope.copyCategoria = function(masterObject){
          masterObject.map(function(master){
            master.categoria = master.subcategoria.categoria;
          });
        }
        
        app.userEvents.refreshMaster = function(event) {
          Master.refreshLastFilter();
          return true;
        }

        $scope.setDirtyForm = function(form) {
          form.$setDirty();
        }

        $scope.copyReg = function(){
          GeraComb.active.tipoCalculo = Master.active.tipoCalculo; //alt
          GeraComb.active.rubricas = Master.active.rubricas;
          GeraComb.active.sinal = Master.active.sinal;
          GeraComb.active.complemento = Master.active.complemento;
        }
        
        $scope.post = function(){
          $scope.btnCopyGenComb = true;
        }
        
        $scope.onOpenForm = function(){
          if (Master.inserting  && typeof Master.active.sinal === "undefined")
            Master.active.sinal = 0;
          if (GeraComb.inserting  && typeof GeraComb.active.sinal === "undefined")
            GeraComb.active.sinal = 0;
        }

        $scope.plus = function(form) {
          form.$setDirty();
          if (Master.inserting || Master.editing ){
            if (Master.active.sinal < 1) 
              Master.active.sinal++;
          }
          if (GeraComb.inserting || GeraComb.editing ){
             if (GeraComb.active.sinal < 1) 
            GeraComb.active.sinal++;         
          }          

        };
        
        $scope.minus = function(form) {
          form.$setDirty();
          if (Master.inserting || Master.editing ){
            if (Master.active.sinal > -1 )
              Master.active.sinal--;      
          }          
          if (GeraComb.inserting || GeraComb.editing ){
            if (GeraComb.active.sinal > -1 )
              GeraComb.active.sinal--;      
          }          
        };
        
        $scope.clearFilter = function(){
          $scope.dtini = "";
          $scope.dtfim = "";
          $scope.restFinalidade.filtro = "";
          $scope.tipoDeVinculo.filtro = "";
          $scope.regimeJuridico.filtro = "";
          $scope.restCategoria.filtro = "";
          $scope.restSubFilter.filtro = "";
          $scope.restRubrica.filtro = "";
        }
        
        /*$scope.validateField = function(formController, field){
         if(formController[field].$invalid && !formController[field].$pristine)
            return true;
         else
            return false;
        }*/
        
        $scope.verifCampos = function() {
          if(typeof $scope.altLote.tipoCalculo === 'undefined' && typeof $scope.altLote.sinal === 'undefined'
              && typeof $scope.altLote.complemento === 'undefined' && typeof $scope.altLote.ativo === 'undefined'
              && typeof $scope.altLote.inativo === 'undefined') {
            return true;
          }
          return false;
        }
        
        $scope.validateCancel = function(formController){
          formController.$setPristine();
          formController.$setUntouched();
        }
        
        $scope.clearModalAltLote = function() {
           $scope.altLote = {};
        }
        
        $scope.atualizarLote = function(form) {
          $scope.pendingControlParam = true;
          
          if(form.$invalid) {
            Notification.warning({ 
              title: 'Campos Obrigatórios', 
              message: 'Os campos data de referência e rubrica são obrigatórios para filtrar os registros', 
              delay: 5000 });
            $scope.pendingControlParam = false;
            return;
          } else {
            
            if(!$scope.verifCampos()) {
              
              GenericService.putData('api/rest/ergon/ParamRubricaFixacao/atualizacaoLote', $scope.altLote)
              .then(function(response) {
                $scope.altLote.mens = response.mens;
                $scope.validateCancel(form);
                $scope.pendingControlParam = false;
                app.userEvents.refreshMaster(event);
              });
              
            } else {
              
              Notification.warning({ 
                title: 'Informações a serem alteradas', 
                message: 'Para gerar a alteração em lote, é necessário informar pelo menos um dos campos que devem ser alterados.', 
                delay: 7000 });
              $scope.pendingControlParam = false;
            
            }
          }
        }
      }
    ]);
    
} (app));