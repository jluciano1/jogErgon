(function ($app) {
  angular.module('page.controllers', []);

  app.controller('trpv0028', ['$scope', 
    '$http', 
    '$rootScope', 
    '$state', 
    '$location', 
    '$translate', 
    'Notification',
    'GenericService',
    function ($scope, $http, $rootScope, $state, $location, $translate, Notification, GenericService) {
      
      var dtini = "";
      var dtfim = "";
      var tipoContribuicao = "";
      
      $scope.clearFilter = function(){
        $scope.ContribuicaoPrevidenciaria.filtroContrib = "";
        $scope.filtroDtIni = "";
        $scope.filtroDtFim = "";
      }
      
      
      $scope.tipo = {};
          
      $scope.tipos = [
            {sigla: 'CSP', nome: 'Certidão de Situação Previdenciária'},
            {sigla: 'CRP', nome: 'Certidão de Regularidade Previdenciária'}
        ];
      $scope.onOpenForm = function() {
        $scope.tipo = $scope.tipos.find(function(e){
          return e.sigla == ContribuicaoPrevidenciaria.active.tipo;
        })
      };
      
      
      
      $scope.downloadGrid =  function(){
        
        dtini = $scope.filtroDtIni;
        dtfim = $scope.filtroDtFim;
        tipoContribuicao = $scope.ContribuicaoPrevidenciaria.filtroContrib;
        
        if(typeof($scope.filtroDtIni) == "undefined" || $scope.filtroDtIni == "")
          dtini = "";
          
        if(typeof($scope.filtroDtFim) == "undefined" || $scope.filtroDtFim == "")
          dtfim = "";
          
        if(typeof($scope.ContribuicaoPrevidenciaria.filtroContrib) == "undefined")
          tipoContribuicao = "";
        
        var url = "api/rest/ergon/ContribuicaoPrevidenciaria/downloadContribuicoesPrev?"
        +"numfunc="+$scope.blkVinc.numfunc+"&numvinc="+$scope.blkVinc.numvinc+"&dtini="+ dtini +"&dtfim="+ dtfim +"&tipoContr="+ tipoContribuicao;
        console.log(url);
        var request = $http({
          method: 'GET',
          url: (window.hostApp || "") + url,
          responseType: 'arraybuffer'
        }).success(function (response, status) {

          if(status == 200){
            var blob = new Blob([response],{type:"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"});
            saveData(blob, "Contribuições Previdenciárias.xlsx", callback);

          }else if(status == 204){
            Notification.warning({message: 'Nenhum conteúdo', delay: 3000})
          }


        }).error(function (response, status) {
          callback(false, status);
        });
      }

          function callback(done, status, downloadError) {
            if (done === true) {
              Notification.success({message: 'Download efetuado com sucesso!', delay: 3000})
            } else if (done === false) {
              if(status == 500)
                Notification.error({message: 'Erro interno', delay: 3000})
              else if(downloadError)
                Notification.error({message: 'Não foi possível realizar o download!', delay: 3000})
              else
                Notification.error({message: 'Erro durante a requisição', delay: 3000})
            }
          }
        //Função para download
        var saveData = (function () {
          var a = document.createElement("a");
          document.body.appendChild(a);
          a.style = "display: none";
          return function (blob, fileName, cb) {
            try{
              url = window.URL.createObjectURL(blob);
              a.href = url;
              a.download = fileName;
              a.click();
              cb(true);
            }catch(e){
              cb(false, null, true);
            }
            setTimeout(function(){
              document.body.removeChild(a);
              window.URL.revokeObjectURL(url);
            }, 200);  
          };
        }());


}
]);
} (app));
