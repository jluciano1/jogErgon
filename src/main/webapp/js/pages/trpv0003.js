(function ($app) {
  angular.module('page.controllers', []);
  
    app.controller('trpv0003', ['$scope', 
                                '$http', 
                                '$rootScope', 
                                '$state', 
                                '$location', 
                                '$translate', 
                                'Notification', 
      function ($scope, $http, $rootScope, $state, $location, $translate, Notification) {
        
        $scope.formatarDescricao = function(rowData, $event){
            var obj = new Object();
            var array = rowData.recursoDescricao.split(';');
            obj["tipoRequerimento"] =  array[0].split(':')[1];
            obj["versao"] =  array[1].split(':')[1];
            obj["passoOrigem"] =  array[2].split(':')[1];
            obj["passoDestino"] =  array[3].split(':')[1];
            $scope.sequencia = obj;
          return;
        }
      
        $scope.formatarDescricaoDropDown = function(rowData, $event){
            var obj = new Object();
            var array = rowData.descricao.split(';');
            obj["tipoRequerimento"] =  array[0].split(':')[1];
            obj["versao"] =  array[1].split(':')[1];
            obj["passoOrigem"] =  array[2].split(':')[1];
            obj["passoDestino"] =  array[3].split(':')[1];
            $scope.descricaoDropDown = obj;
          return;
        }
        
        $scope.formatarDescricaoSelecionado = function($select, $event){
            var obj = new Object();
            var selected = $select.selected;
            var array = selected.descricao.split(';');
            obj["tipoRequerimento"] =  array[0].split(':')[1];
            obj["versao"] =  array[1].split(':')[1];
            obj["passoOrigem"] =  array[2].split(':')[1];
            obj["passoDestino"] =  array[3].split(':')[1];
            $scope.descricaoSelecionado = obj;
          return;
        }
        
        app.userEvents.setRecursoAndGrupoRec = function(){
          if(typeof(HadRecursoGrupoRec.active)!=='undefined' && Object.getOwnPropertyNames(HadRecursoGrupoRec.active).length > 0)
          {
            HadRecursoGrupoRec.active.guidGrupoRecurso = HadGrupoRecurso.active.guidGrupoRecurso
            HadRecursoGrupoRec.active.guidRecurso = HadRecurso.active.guidRecurso;
            HadRecursoGrupoRec.active.recursoDescricao = HadRecurso.active.descricao;
          }
          else
          {
             HadRecursoGrupoRec.active = {
               "guidGrupoRecurso" : HadGrupoRecurso.active.guidGrupoRecurso,
               "guidRecurso" : HadRecurso.active.guidRecurso,
               "recursoDescricao" : HadRecurso.active.descricao
             }
          }
          
        }
        
        
        app.userEvents.setGuidRecursoGrupoRecPadaces = function(){
          if(typeof(HadGrupoRecPadaces.active)!=='undefined' && Object.getOwnPropertyNames(HadGrupoRecPadaces.active).length > 0)
          {
            HadGrupoRecPadaces.active.guidGrupoRecurso = HadGrupoRecurso.active.guidGrupoRecurso;
          }
          else
          {
             HadGrupoRecPadaces.active = {
               "guidGrupoRecurso" : HadGrupoRecurso.active.guidGrupoRecurso
              
             }
          }
          
        }
        
        
        $scope.setRecursoAndGrupoRecCadastro = function(){
            HadRecursoGrupoRec.active.guidGrupoRecurso = HadGrupoRecurso.active.guidGrupoRecurso
            HadRecursoGrupoRec.active.guidRecurso = HadRecurso.active.guidRecurso;
            HadRecursoGrupoRec.active.recursoDescricao = HadRecurso.active.descricao;
        }
        
        $scope.setGuidRecursoCadastroPermissoes = function(){
            HadGrupoRecPadaces.active.guidGrupoRecurso = HadGrupoRecurso.active.guidGrupoRecurso;
            HadGrupoRecPadaces.active.siglaPadraoAcesso = PadUsuario.active.siglaPadraoAcesso;
        }
      
        $scope.setPadraoAcesso = function(selected)
        {
          HadGrupoRecPadaces.active.siglaPadraoAcesso = selected.siglaPadraoAcesso;
          HadGrupoRecPadaces.active.nomePadraoAcesso = selected.nomePadraoAcesso;
        }
      
      }
    ]);
    
    

} (app));

