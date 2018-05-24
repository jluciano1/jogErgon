(function ($app) {
  angular.module('page.controllers', []);
  
    app.controller('trpv0048', ['$scope',
                                '$filter', 
                                '$http', 
                                '$rootScope', 
                                '$state', 
                                '$location', 
                                '$translate', 
                                'Notification', 
      function ($scope, $filter, $http, $rootScope, $state, $location, $translate, Notification) {
        //Instancionado valores padrões para a trpv0048
        $scope.reajuste=true;//ng-disable
        $scope.prefixo= "Percentual";
        $scope.percentualDisable=true;
        $scope.percentualLength=6;
        $scope.percentualMax=100;
        $scope.lastBase=null;
        $scope.sufixo="%";
        
        $scope.clearFilter = function(){
          $scope.dtini = "";
          $scope.dtfim = "";
        }
        
        //Seta o ponteiro de publicação do registro corrente
        //Utilizado como callback na diretiva blkPont
        $scope.blkRefresh = function(pont, tipoPonteiro){
          if(tipoPonteiro == "pontpubl")
            PensaoAlimenticia.row.pontPubl = pont;
          else if(tipoPonteiro == "pontlei")
            PensaoAlimenticia.row.pontLei = pont;
        }
        
        //Formata o dinamismo do modal
        $scope.formatacaoCamposModal = function(datasource){
          if(datasource.inserting){
            $scope.reajuste=true; //Valores padroes para o modal caso o modal esteja dando insert
            $scope.prefixo= "Percentual";
            $scope.percentualDisable=true;
            $scope.percentualLength=6;
            $scope.sufixo="%";
          }else{
            $scope.lastBase=null;
            $scope.watchBase(datasource.active);
          }
        }
        
        //observa o ui-select de base e assim formata os campos do modal de acordo com seu valor
        $scope.watchBase = function(obj){
          if(typeof(obj.base) !== 'undefined'){
            if(obj.base.admitereajuste == "N") {
                $scope.reajuste=true; //retorna para um ng-disabled
                delete obj.tiporeaj;
              }else{ 
                $scope.reajuste=false;
            }
             $scope.percentualDisable=false;
             $scope.setPercentualFormat(obj);
             $scope.lastBase=obj.base.base;
          }else{
            $scope.percentualDisable=true;
            $scope.setPercentualFormat(obj);
          }
          if(typeof(obj.base) !== 'undefined' && obj.base.prefixo !== null){
            $scope.prefixo = obj.base.prefixo.replace(/\./g, '');
          }else{
            if(typeof(obj.base) !== 'undefined' && obj.base.evalorfixo == "S"){
               $scope.prefixo = "Valor";
            }else{
               $scope.prefixo = "Percentual";
            }
            
          }
        }
        
        $scope.setPercentualFormat = function(rowData){ //Formata o sufixo do campo setado pela function watchBase()
          if(typeof(rowData) !== 'undefined'){
            if(typeof(rowData.base) !== 'undefined'){
              
              if(typeof(rowData.base.sufixo) !== 'undefined' && rowData.base.sufixo !== null){
                $scope.sufixo = rowData.base.sufixo;
                if(rowData.base.sufixo == '%' || rowData.base.evalorfixo == 'N') { 
                  $scope.percentualLength=6 ; 
                }else{
                  $scope.percentualLength=14;
                }
              }else{
                $scope.sufixo = "";
                $scope.percentualLength=14;
              }
              if($scope.lastBase !== null && $scope.lastBase != rowData.base.base)
                rowData.percentual=null;
            }else{
              $scope.sufixo = "";
              $scope.percentualLength=6;
              rowData.percentual = null;
            }
            
          }
          
        }
        
        
        
      }
    ]);


} (app));