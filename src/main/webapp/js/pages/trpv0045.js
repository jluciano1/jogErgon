(function ($app) {
  angular.module('page.controllers', []);
  
    app.controller('trpv0045', ['$scope', 
                                '$http', 
                                '$rootScope', 
                                '$state', 
                                '$location', 
                                '$translate',
                                '$base64',
                                'GenericService',
                                'Notification', 
      function ($scope, $http, $rootScope, $state, $location, $translate, $base64, GenericService, Notification) {
      
        var _url = "api/rest/ergon/FotoFuncionario";
        $scope.imageDependentsValues = ['numfunc'];
    	
        $scope.erroPainel = false;
        app.userEvents.fechaPainel = function(event){
          if(event){
            Notification.error({message: event, delay: 6000})
            $scope.erroPainel = true;
          }
        }
        
        
        function Painel(){
          //Objetos do fieldset
          this.dadosPessoais = {
              "nome" : null,
              "flexCampo04" : null,
              "numeroProcesso" : null,
              "nomeMae" : null,
              "nomePai" : null,
              "cpf" : null,
              "nacionalidade" : null,
              "estadoNascimento" : null,
              "cidadeNascimento" : null,
              "estadoCivil" : null,
              "escolaridade" : null,
              "dtnasc" : null,
              "chegadaBrasil" : null,
              "sexo" : null,
              "deficiente" : null,
              "tipoDeficiencia" : null,
              "raca" : null
            };
          this.dadosAdicionaisDoServidor = {
            "primeiroEmprego" : null,
            "flexCampo11" : null,
            "ufEmpregoAnterior" : null,
            "grupoSanguineo" : null,
            "flexCampo27" : null
          };
          this.enderecoDoServidor = {
            "estadoEndereco" : null,
            "cidadeEndereco" : null,
            "tipoLogradouro" : null,
            "cep" : null,
            "bairroEndereco" : null,
            "enderecoFuncionario" : null,
            "numeroEndereco" : null,
            "complementoEndereco" : null,
            "numeroCelular" : null,
            "telefone" : null,
            "email" : null,
            "flexCampo35" : null
          };
          this.documentosPessoaisDoServidor = {
            "tipoRegistroGeral" : null,
            "numeroRegistroGeral" : null,
            "orgaoRegistroGeral" : null,
            "ufrg" : null,
            "dataExpRegistroGeral" : null,
            "tipoCertidao" : null,
            "numeroCertidao" : null,
            "livroCertidao" : null,
            "folhaCertidao" : null,
            "estadoCartorio" : null,
            "municipioCartorio" : null,
            "cartorioCertidao" : null,
            "matriculaCertidao" : null,
            "flexCampo48" : null,
            "flexCampo45" : null,
            "flexCampo49" : null,
            "flexCampo46" : null,
            "flexCampo47" : null,
            "tipoCertidaoFim" : null,
            "numeroCertidaoFim" : null,
            "livroCertidaoFim" : null,
            "folhaCertidaoFim" : null,
            "cartorioCertidaoFim" : null,
            "dataCertidaoFim" : null,
            "estadoCartorioFim" : null,
            "municipioCartorioFim" : null,
            "matriculaCertidaoFim" : null,
            "cnh" : null,
            "categoriaCnh" : null,
            "validadeCnh" : null,
            "estadoCnh" : null,
            "numeroTituloEleitor" : null,
            "zonaTituloEleitor" : null,
            "secaoTituloEleitor" : null,
            "estadoTituloEleitor" : null,
            "numeroCarteiraProf" : null,
            "serieCarteiraProf" : null,
            "estadoCarteiraProf" : null,
            "tipoIdentProf" : null,
            "identificacaoProfissional" : null,
            "estadoIdentProf" : null,
            "numeroDocMilitar" : null,
            "serieDocMilitar" : null,
            "categoriaDocMilitar" : null,
            "orgaoMilitar" : null,
            "flexCampo29" : null,
            "estadoDocMilitar" : null,
            "numeroPisPasep" : null
          };
          //Controladores de fieldset
          this.dadosPessoaisOpen =false;
          this.dadosAdicionaisDoServidorOpen = false;
          this.enderecoDoServidorOpen = false;
          this.documentosPessoaisDoServidorOpen = false;
          this.backup = null;
          this.ctrl = null;
        }
        
        Painel.prototype.action = function(painel, action, send, ctrl){
          switch(action){
           case "edit" :
             this.setBackup(Funcionarios.active);
             this[painel+"Open"] = true;
             break;
            
            case "save" :
            this.ctrl=ctrl;
            $scope.whichPainel = painel+"Open";
            
            this.copyValues(this[painel], Funcionarios.active);
            
            Funcionarios.startEditing(Funcionarios.active);
            send(ctrl, Funcionarios, null);
            break;
             
            case "cancel" :
              if($scope.erroPainel)
                this.copyValues(this.backup, this[painel]);
              else
                this.copyValues(Funcionarios.active, this[painel]);
              
                this[painel+"Open"] = false;
             break;
         } 
        
        }
      
       Painel.prototype.setBackup = function(obj){
         if(obj)
          this.backup = shallowCopy(obj);
       }
      //Copia os valores da origem pro destino
      Painel.prototype.copyValues = function(origem, destino){
        Object.getOwnPropertyNames(origem).map(function(attr){
          if(destino.hasOwnProperty(attr)){
            destino[attr] = origem[attr];
          }
        });
      }
      
      app.userEvents.afterFill = function(){
        $scope.Painel = new Painel();
        var attr = ["dadosPessoais", "dadosAdicionaisDoServidor", "enderecoDoServidor", "documentosPessoaisDoServidor"];
        var obj = $scope.Painel;
        attr.map(function(attr){
          obj.copyValues(Funcionarios.active, obj[attr]);
        });
      }
      
      $scope.$watch("Funcionarios.editing", function(newValue){
          if(!Funcionarios.editing){
            if(typeof($scope.Painel) !== "undefined" && $scope.Painel.ctrl !== null){
              if(!$scope.erroPainel && ($scope.Painel.ctrl.$valid) && (!$scope.Painel.ctrl.$pristine)){
                $scope.Painel[$scope.whichPainel] = false;
                // Funcionarios.refreshLastFilter();
              }else{
                $scope.Painel[$scope.whichPainel] = true;
                $scope.erroPainel = false;
              }
            }
          }else{
            $scope.Painel[$scope.whichPainel] = true;
            $scope.erroPainel = false;
          }
        });
        
        $scope.sexo = [
              {opc: 'F'},
              {opc: 'M'}
          ];
          
        $scope.deficiente = [
              {opc: 'N'},
              {opc: 'S'}
          ];
          
        $scope.docMilitar = [
              {opc: 'Dispensa'},
              {opc: 'Reservista'}
          ];
          
      
      $scope.view = false; 
      $scope.setToView = function(vemDoFecharModal){
        if(vemDoFecharModal === 1){
          $scope.view = false;
        }else{
          $scope.view = !$scope.view;
        }
      }
        
        $scope.resetTipoDeficiencia = function(op){
          if(op == 'N'){
            $scope.Painel.dadosPessoais.tipoDeficiencia = null
          }
        }
        
        
        
        function shallowCopy(original){
            var clone = Object.create(Object.getPrototypeOf(original)) ;
            var i , keys = Object.getOwnPropertyNames(original);
            for ( i = 0 ; i < keys.length ; i ++ ){
                // copy each property into the clone
                Object.defineProperty(clone, keys[i],
                    Object.getOwnPropertyDescriptor(original, keys[i])
                );
            }
            return clone ;
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
                                $scope.FuncionariosFiltro.filtro = '/numfunc/' +func;
                            } else {
                                $scope.FuncionariosFiltro.filtro = '/nome/' + func;
                            }
                        }
                    }
                    function IsNumeric(input) {
                        return (input - 0) == input && ('' + input).trim().length > 0;
                    }
                }
                
            $scope.refreshRepre = function(func) {
                    var numfunc;
                    var posicaoBarra = func.indexOf('/');
                    if (func.length > 0) {
                        if (posicaoBarra > 0) { //se existe barra
                            numfunc = func.substr(0, posicaoBarra); //determina que numfunc é até a barra
                            if (IsNumeric(numfunc)) { //verifica se sobrou apenas numeros para considerar como numfunc
                                $scope.NRepresentante.filtro = '/numrep/' + numfunc;
                            }
                        } else {
                            if (IsNumeric(func)) {
                                if (func.length > 9)
                                    return;
                                $scope.NRepresentante.filtro = '/numrep/' +func;
                            } else {
                                $scope.NRepresentante.filtro = '/nome/' + func;
                            }
                        }
                    }
                    function IsNumeric(input) {
                        return (input - 0) == input && ('' + input).trim().length > 0;
                    }
                }
        
      }
    
    ]);
} (app));