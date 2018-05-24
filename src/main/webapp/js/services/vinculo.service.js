(function ($app) {
  angular.module('custom.controllers', []);
    //Obtem lista dos ultimos vinculos pesquisados
    app.service('VinculoService',function(){
      
      var ultimosAcessos = [];
     
      this.setUltimosAcessos = function(acesso){
        if(sessionStorage.ultimosAcessos){
          ultimosAcessos = JSON.parse(sessionStorage.ultimosAcessos);
          ultimosAcessos.map(function(acessoStorage){
            i = ultimosAcessos.indexOf(acessoStorage);
            if(acesso.numfunc == acessoStorage.numfunc && acesso.numvinc == acessoStorage.numvinc) {
            	ultimosAcessos.splice(i, 1);
            }
          });
        }
        ultimosAcessos.unshift(acesso);
        sessionStorage.setItem("ultimosAcessos", JSON.stringify(ultimosAcessos));
      };
    
      this.getUltimosAcessos = function(){
        return sessionStorage.getItem("ultimosAcessos");
      };
      
    });
    
} (app))