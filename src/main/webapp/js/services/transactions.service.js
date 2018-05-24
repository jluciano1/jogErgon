(function ($app) {
  angular.module('custom.controllers', []);
    //Obtem as transacoes (permissoes) do usuario para aplicar nas rotas (ui-router) e links
    app.factory('TransactionsService', ['$http', '$q', 'GenericService', 'Notification',
      function ($http, $q, GenericService, Notification) {
        
        var deferred = $q.defer();
        var permissions = {};
        var pageAccess = {};
        var pageParam = {};
        var isEmpty = function(permissions){
          return Object.keys(permissions).length == 0;
        }
        var getAccess = function(page){
          if(page.match('Menu')){
            pageAccess = true;
            return pageAccess;
          }
          if(isEmpty(permissions)){
            return pageAccess;
          }
          permissions.map(function(transaction){
            if(transaction.page == page){ 
              pageAccess = transaction.openAllowed;
            }
          });
          pageParam = page;
          return pageAccess;
        }
        
        var linkGetAccess = function(page){
          // i verifica se a pagina existe
          i = -1;
          if(page.match('Menu')){
            pageAccess = true;
            return pageAccess;
          }
          if(isEmpty(permissions)){
            return pageAccess;
          }
          permissions.map(function(transaction){
            if(transaction.page == page){ 
              pageAccess = transaction.openAllowed;
              i = 1;
            }
          });
          if(i == -1){
            return false;
          }
          pageParam = page;
          return pageAccess;
        }
        
        //Seta as permissoes do usuario
        var setPermissions = function(username) {
          GenericService.getData("api/rest/ergon/Usuario/getUserTransactionsAccessList/" + username).then(function(response){
           permissions = response;
            deferred.resolve(permissions);
          });
          return deferred.promise;
        } 
        
        //Obtem permissoes do usuario
        var getPermissions = function() {
          return permissions;
        }
        
        //Obtem permissao de uma pagina especifica com checkagem de parametros da pagina anterior
        var getLinkPermission = function(page) {
          if(pageParam != page){
            pageAccess = getAccess(page);
          }  
          return pageAccess;
        }
        
        //Obtem permissao de uma pagina especifica 
        var directiveGetLinkPermission = function(page) {
          pageAccess = getAccess(page);
          return pageAccess;
        }
        
        return {
          getPermissions: getPermissions,
          setPermissions: setPermissions,
          linkGetAccess: linkGetAccess,
          getLinkPermission: getLinkPermission,
          directiveGetLinkPermission: directiveGetLinkPermission
        };   
      }
    ]);
} (app));