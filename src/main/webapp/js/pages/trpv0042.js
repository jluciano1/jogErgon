(function ($app) {
    angular.module('page.controllers', []);
    
    app.controller('trpv0042', ['$scope',
                                '$sce',
                                '$http', 
                                '$rootScope', 
                                '$state', 
                                '$location', 
                                '$translate', 
                                '$timeout',
                                'Notification', 
                                'stripBarsFilter',
                                'GenericService',
                                'ReportService',
      function ($scope, $sce, $http, $rootScope, $state, $location, $translate, $timeout, Notification, stripBarsFilter, GenericService, ReportService) {
        
        //Seta o ponteiro de publicação do registro corrente
        //Utilizado como callback na diretiva blkPont
        $scope.blkRefresh = function(pont, tipoPonteiro){
          if(tipoPonteiro == "pontpubl")
            $scope.Aposentadoria.row.pontPubl = pont;
        }
        
        // Membros públicos
        $scope.Aposendadoria                = { data: []};
        $scope.TipoAposentadoria            = { data: []};
        $scope.TipoEventos                  = { data: []};
        $scope.EspeciesEvento               = { data: []};
        $scope.Setores                      = { data: []};
        $scope.Jornadas                     = { data: []};
        $scope.Referencias                  = { data: []};
        $scope.Fracao1                      = { data: []};
        $scope.MotivosReab                  = { data: []};
        $scope.MotivosRev                   = { data: []};
        $scope.Vagas                        = { data: []};
        $scope.numfunc                      = null;
        $scope.numvinc                      = null;
        $scope.cargosel                     = 0;
        $scope.dtini                        = null;
        $scope.cargo                        = null;
        $scope.setor                        = null;
        $scope.dtfim                        = null;
        $scope.dia                         = moment(new Date()).format('DD/MM/YYYY');
        $scope.viewStateFlags               = {
          vinculoSelecionado              : false,
          esperandoProcesso               : false,
          revisaoHabilitada               : false,
          reaberturaHabilitada            : false,
          reversaoHabilitada              : false,
          registroTCEHabilitado           : false,
          revisaoBloqueada                : false,
          reaberturaBloqueada             : false,
          reversaoBloqueada               : false,
          registroTCEBloqueada            : false
        };
        
        // Métodos expostos
        $scope.registerParameterForm    = registerParameterForm;
        $scope.handleRevisaoJudicial    = handleRevisaoJudicial;
        $scope.handleReversao           = handleReversao;
        $scope.handleReabertura         = handleReabertura;
        $scope.clearAposentadoria       = clearAposentadoria;
        $scope.populaAposentadoria      = populaAposentadoria;
        $scope.handleTCE                = handleTCE;
        $scope.populaTipoEventos        = populaTipoEventos;
        $scope.populaTipoAposentadoria  = populaTipoAposentadoria;
        $scope.populaEspeciesEvento     = populaEspeciesEvento;
        $scope.populaSetor              = populaSetor;
        $scope.populaCargo              = populaCargo;
        $scope.populaJornadas           = populaJornadas;
        $scope.populaReferencias        = populaReferencias;
        $scope.populaFracao1            = populaFracao1;
        $scope.populaVagas              = populaVagas;
        $scope.populaMotivosReab        = populaMotivosReab;
        $scope.populaMotivosRev         = populaMotivosRev;
        $scope.setParametrosVaga        = setParametrosVaga;
        $scope.acessosPainel            = acessosPainel;
        $scope.validarDataRevisao       = validarDataRevisao;
        $scope.copyToActiveAposentadoria= copyToActiveAposentadoria;
        $scope.populaModalReversao      = populaModalReversao;
        $scope.resetFlagsDeBloqueio     = resetFlagsDeBloqueio;
        
        // Watchers
        $scope.$watch(function() {
          return $scope.blkVinc;
        }.bind($scope), function(blkVinc) {
          if (blkVinc && typeof(blkVinc)==='object' && !angular.equals(blkVinc,{})) {
            if (lastBlkVinc.numfunc!==blkVinc.numfunc || lastBlkVinc.numvinc!==blkVinc.numvinc) {
              clearAposentadoria();
              $scope.viewStateFlags.vinculoSelecionado = true;
              $scope.numfunc =blkVinc.numfunc;
              $scope.numvinc =blkVinc.numvinc;
              
              $scope.populaAposentadoria();
              $scope.populaTipoAposentadoria();
              $scope.populaFracao1();
              $scope.populaMotivosReab();
              
              acessosPainel();
              
            }
            lastBlkVinc.numfunc = blkVinc.numfunc;
            lastBlkVinc.numvinc = blkVinc.numvinc;
          } else {
            $scope.viewStateFlags.vinculoSelecionado = false;
            resetViewState();
          }
        });
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////
        // Membros privados
        var parameterFormName     = null;
        var parameterFormCtrl     = null;
        var lastIdAposentadoria   = null;
        var vinculo               = null;
        var idAposentadoria       = null;
        var lastBlkVinc           = {numfunc: null, numvinc: null};
        
        // Controla os acessos do painel
        function acessosPainel(){
          
          //reinicia os flags
          $scope.viewStateFlags.revisaoHabilitada               = false;
          $scope.viewStateFlags.reaberturaHabilitada            = false;
          $scope.viewStateFlags.reversaoHabilitada              = false;
          $scope.viewStateFlags.registroTCEHabilitado           = false;
          
          //se não ha nenhum registro selecionado não libera revisão e tce
          if($scope.Aposentadoria !== undefined){
            $scope.viewStateFlags.revisaoHabilitada = $scope.Aposentadoria.row !== null;
            $scope.viewStateFlags.registroTCEHabilitado = $scope.Aposentadoria.row !== null;
          
            if($scope.Aposentadoria.row !== null && $scope.Aposentadoria.row !== undefined ){
              if ($scope.Aposentadoria.row.dtfim !== null && $scope.Aposentadoria.row.dtfim !== '' ){
                  //Se a dtini da ultima aposentadoria é igual ao dtini da aposentadoria do datarow, 
                  //quer dizer que esta editando a ultima
                  if( $scope.Aposentadoria.row.dtini === $scope.Aposentadoria.data[ ($scope.Aposentadoria.data.length - 1) ].dtini ){
                    $scope.viewStateFlags.reaberturaHabilitada = true;
                  }else{
                    $scope.viewStateFlags.reaberturaHabilitada = false;
                  }
                  
              }else{ //se a data fim for nula
                  
                  //E se tratatar do ultimo registro de apos
                  if( $scope.Aposentadoria.row.dtini === $scope.Aposentadoria.data[ ($scope.Aposentadoria.data.length - 1) ].dtini ){
                    $scope.viewStateFlags.reversaoHabilitada = true;
                  }else{
                    $scope.viewStateFlags.reversaoHabilitada = false;
                  }
                  
              } 
            }else{
              $scope.viewStateFlags.revisaoHabilitada = false;
              $scope.viewStateFlags.registroTCEHabilitado = false;
              $scope.viewStateFlags.reaberturaHabilitada = false;
              $scope.viewStateFlags.reversaoHabilitada = false;
            }
          }
        }
        
        // Declaração de métodos
        function registerParameterForm(form) {
          if (form && typeof(form)==='string' && $scope.hasOwnProperty(form)) {
            parameterFormName = form;
            parameterFormCtrl = $scope[form];
          } else {
            showError({name:'Elemento inválido',message:'Não foi possível localizar o formulário '+form+' no documento'});
          }
        }
        
        function validaParametros() {
          //Valida existência e coesão das informações no form de parâmetros
          if (!parameterFormCtrl) {
            showError({name:'Form Inválido',message:'Form de parâmetros não configurado'});
          } else
            return true;
        }
        
        function validaBlkVinc() { 
          //Valida existência e coesão das informações de vínculo selecionado
          if (!$scope.blkVinc || typeof($scope.blkVinc)!=='object' || angular.equals($scope.blkVinc,{})) {
            showError({name:'Vínculo Ausente',message:'Nenhum vínculo selecionado'});
          } else
            return true;
        }
        
        function fetchAposentadoriaByVinc(numfunc, numvinc) {
          //Retorna $promise da busca pelos dados da aposentadoria para o vínculo na data informada
          var _method   = "GET";
          var _url      = (window.hostApp || "") + "api/ws/rest/ergon/v1.0/aposentadoria/";
          var _headers  = "origin-path:" + $location.path();
          
          if (numfunc && numfunc !== null && !Number.isNaN(numfunc) &&
              numvinc && numvinc !== null && !Number.isNaN(numvinc) &&
              data && data !== null && !Number.isNaN(data) && moment(new Date(data)).isValid())
          {
            var _path     = '/' + numfunc + '/' + numvinc ;
            var _params   = { status:"concluida" };
          
            return $http({
              method  : _method,
              url     : _url + _path,
              params  : _params,
              headers : _headers
            });
            
          } else {
            showError({name:"Parâmetros inválidos",message:"Erro nos parâmetros informados {numfunc:"+numfunc+",numvinc:"+numvinc+",data:"+data+"}"});
          }
        }
        
        function handleTCE(){
          if ($scope.viewStateFlags.esperandoProcesso ) {
            showWarning({name:'Solicitação inválida',message:'Já existe solicitação sendo processada, aguarde o término da execução'});
          }else if($scope.Aposentadoria.active.dtRegistroTCE === undefined || $scope.Aposentadoria.active.dtRegistroTCE === null){
            showWarning({name:'Solicitação inválida',message:'Preencha os campos data do registro TCE'});
          }else if($scope.Aposentadoria.active.numRegistroTCE === undefined || $scope.Aposentadoria.active.numRegistroTCE === null){ 
            showWarning({name:'Solicitação inválida',message:'Preencha os campos número do registro TCE'});
          } else if ($scope.Aposentadoria.active.anostrab === undefined || $scope.Aposentadoria.active.diastrab === undefined ||
                     $scope.Aposentadoria.active.anosapos === undefined) {
          }else if (validaParametros() && validaBlkVinc()) {
            //TODO :  1. Fazer validações necessárias, 2. Chamar o Serviço que chama a proc que executa o processo.
            registrarTCEAposentadoria();
          }
        }
        
        function handleRevisaoJudicial() {
          if ($scope.viewStateFlags.esperandoProcesso ) {
            showWarning({name:'Solicitação inválida',message:'Já existe solicitação sendo processada, aguarde o término da execução'});
          } else if ($scope.Aposentadoria.active.anostrab === undefined || $scope.Aposentadoria.active.diastrab === undefined ||
                     $scope.Aposentadoria.active.anosapos === undefined) {
            
          } else if (validaParametros() && validaBlkVinc()) {
            //TODO :  1. Fazer validações necessárias, 2. Chamar o Serviço que chama a proc que executa o processo.
            validarDataRevisao();
            revisarAposentadoria();
            
          }
        }
        
        function handleReversao() {
          if ($scope.viewStateFlags.esperandoProcesso ) {
            showWarning({name:'Solicitação inválida',message:'Já existe solicitação sendo processada, aguarde o término da execução'});
          }else if($scope.Aposentadoria.active.tipoEvento === undefined || $scope.Aposentadoria.active.tipoEvento === null){
            showWarning({name:'Solicitação inválida',message:'É necessário informar o tipo de evento para reverter uma aposentadoria'});
          }else if($scope.Aposentadoria.active.cargo === undefined || $scope.Aposentadoria.active.cargo === null){
            showWarning({name:'Solicitação inválida',message:'É necessário informar o cargo para reverter uma aposentadoria'});
          }else if($scope.Aposentadoria.active.especieEvento === undefined || $scope.Aposentadoria.active.especieEvento === null){
            showWarning({name:'Solicitação inválida',message:'É necessário informar a espécie de evento para reverter uma aposentadoria'});
          }else if($scope.Aposentadoria.active.setor === undefined || $scope.Aposentadoria.active.setor === null){
            showWarning({name:'Solicitação inválida',message:'É necessário informar o setor para reverter uma aposentadoria'});
          } else if (validaParametros() && validaBlkVinc()) {
           
            //TODO :  1. Fazer validações necessárias, 2. Chamar o Serviço que chama a proc que executa o processo.
            reverterAposentadoria();
            
          }
        }
        
        function handleReabertura(){
          if ($scope.viewStateFlags.esperandoProcesso ) {
            showWarning({name:'Solicitação inválida',message:'Já existe solicitação sendo processada, aguarde o término da execução'});
          } else if ($scope.Aposentadoria.active.motivoReaberturaNome === undefined || $scope.Aposentadoria.active.motivoReaberturaNome === null) {
            showWarning({name:'Solicitação inválida',message:'Preencha o campo motivo da reabertura'});
          }else if(validaParametros() && validaBlkVinc()){
            //TODO :  1. Fazer validações necessárias, 2. Chamar o Serviço que chama a proc que executa o processo.
            reabrirAposentadoria(); 
          }
        }
        
        function handleClickAposentadoria() {
            
            // TODO fazer validação de vinc anterior e posterior se necessário
            clearAposentadoria();
            populaAposentadoria();
        }
        
        function populaAposentadoria(cb) {
          GenericService.getData("api/ws/rest/ergon/v1.0/aposentadoria/"+$scope.numfunc+"/"+$scope.numvinc)
            .then(
              //success
              function(response) {
                $scope.Aposentadoria = {data:[]};
                $scope.Aposentadoria.data = response;
               if(cb && typeof(cb) == "function")
                  cb(response)
              },//failure
              function(response) {
                clearAposentadoria();
              }
            );
        }
        
        function validarDataRevisao(){
          
          var rowindex = 0;
          var aposant  = false;
          
          //buscar o indice da apos selecionada
          if( $scope.Aposentadoria.data.length > 1 ){
            aposant = true;
            for (var i = 0, len = $scope.Aposentadoria.data.length; i < len; i++) {
                if( $scope.Aposentadoria.row.dtini === $scope.Aposentadoria.data[i].dtini ){ //teste para encontrar o registro
                  rowindex = i;
                }
            }
          }
          
          //encontra a apos anterior e valida
          //Se tem aposentadoria anterior simplemente aplica indice encontrado - 1 e valida, senão nao valida
          if( aposant ){
            if( $scope.Aposentadoria.data[ rowindex - 1 ] !== undefined ){ // neste caso não há aposentadoria anterior.
              if ($scope.Aposentadoria.data[ rowindex - 1 ].dtini > $scope.Aposentadoria.row.dtini){ 
                Notification.error( {message: 'A data de inicio para revisão deve ser maior que a data de inicio da aposentadoria anterior', delay: 3000})
              }
            }
          }
        }
        
        function trataErro(data) {
          //Tratamento unificado de erro de request HTTP
          var error = "";
          if (data) {
            if (Object.prototype.toString.call(data) === "[object String]") {
              error = data;
            } else {
              var errorMsg = (data.msg || data.desc || data.message || data.error || data.responseText);
              if (errorMsg) {
                error = errorMsg;
              }
            }
          }
          if (!error) {
            error = "Erro";
          }
          var regex = /<h1>(.*)<\/h1>/gmi;
          result = regex.exec(error);
          if (result && result.length >= 2) {
            error = result[1];
          }
          showError({name:"Erro",message:error})
        }
        
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
          //resetViewState();
          //populaAposentadoria();
          $scope.viewStateFlags.esperandoProcesso               = false;
        }
        
        function showWarning(e) {
          if (!e.hasOwnProperty('message')) {
            e.message = 'Operação não realizada';
          }
          if (!e.hasOwnProperty('title')) {
            if (e.hasOwnProperty('name')) {
              e.title = e.name;
            } else {
              e.title = 'Um erro não tratado impediu a operação';
            }
          }
          if (!e.hasOwnProperty('delay')) {
            e.delay = 5000;
          }
          
          Notification.warning(e);
        }

        function resetViewState() {
          clearAposentadoria();
          lastBlkVinc                                           = {numfunc:false, numvinc:false};
          $scope.viewStateFlags.vinculoSelecionado              = false;
          $scope.viewStateFlags.esperandoProcesso               = false;
          $scope.viewStateFlags.revisaoHabilitada               = false;
          $scope.viewStateFlags.reaberturaHabilitada            = false;
          $scope.viewStateFlags.reversaoHabilitada              = false;
          $scope.viewStateFlags.registroTCEHabilitado           = false;
          resetFlagsDeBloqueio();
        }
        
        function resetFlagsDeBloqueio() {
          $scope.viewStateFlags.revisaoBloqueada                = false;
          $scope.viewStateFlags.reaberturaBloqueada             = false;
          $scope.viewStateFlags.reversaoBloqueada               = false;
          $scope.viewStateFlags.registroTCEBloqueada            = false;
        }
        
        function validDateSelected(){
          var strData = formDetalhesAposentadoria.data.$modelValue;
          var partesData = strData.split("-");
          var data = new Date(partesData[0], partesData[1] - 1, partesData[2]);
          if(data > (new Date())){
            clearAposentadoria();
            return false;
          }
          return true;
        }
        
        function clearAposentadoria() {
          $scope.numfunc                      = null;
          $scope.numvinc                      = null;
          $scope.Aposentadoria                = { data: []};
          $scope.TipoAposentadoria            = { data: []};
          $scope.TipoEventos                  = { data: []};
          $scope.EspeciesEvento               = { data: []};
          $scope.Setores                      = { data: []};
          $scope.Jornadas                     = { data: []};
          $scope.Referencias                  = { data: []};
          $scope.Fracao1                      = { data: []};
          $scope.MotivosReab                  = { data: []};
          $scope.MotivosRev                   = { data: []};
          $scope.Vagas                        = { data: []};
        }
        
        function setParametrosVaga(){
          
          var dtIni = new Date($scope.Aposentadoria.active.dtini);
          var dtFim = new Date($scope.Aposentadoria.active.dtfim);
          
          $scope.setor =  $scope.Aposentadoria.active.setor;
          $scope.cargo =  $scope.Aposentadoria.active.cargo;
          $scope.dtini =  moment( dtIni ).format('YYYY-MM-DD');
          $scope.dtfim =  moment( dtFim ).format('YYYY-MM-DD');
            
        }
        
        function populaModalReversao(){
          $scope.Aposentadoria.active = {};
          angular.copy($scope.Aposentadoria.row, $scope.Aposentadoria.active);
          
          $scope.populaTipoEventos();
          $scope.populaSetor();
          $scope.populaEspeciesEvento();
          $scope.populaCargo();
          $scope.populaJornadas();
          $scope.populaReferencias();
          $scope.populaMotivosRev();
          
          $scope.Aposentadoria.active.dtfim = moment(new Date());
        }
        
        //Funções para popular dropdown
        function populaTipoEventos(){
          GenericService.getData( (window.hostApp || "") + "api/ws/rest/ergon/v1.0/funcional/tipoevento/listaEventosUsuario")
            .then(
              //success
              function(response) {
                $scope.TipoEventos.data = response;
              },
              //failure
              function(response) {
                $scope.TipoEventos = { data: []};
              }
            );
        }
        
        function populaTipoAposentadoria(){
          GenericService.getData( (window.hostApp || "") + "api/rest/ergon/TipoAposentadoria")
            .then(
              //success
              function(response) {
                $scope.TipoAposentadoria.data = response.content.map(function(item){
                  return item.tipo;
                });
              },
              //failure
              function(response) {
               $scope.TipoAposentadoria = { data: []};
              }
            );
        }
        
        function populaEspeciesEvento(){
          GenericService.getData( (window.hostApp || "") + "api/ws/rest/ergon/v1.0/funcional/especieEvento/listaEspecies")
            .then(
              //success
              function(response) {
                $scope.EspeciesEvento.data = response;
                
              },
              //failure
              function(response) {
                $scope.EspeciesEvento.data    = { data: []};
              }
            );
        }
        
        function populaSetor(){
          GenericService.getData( (window.hostApp || "") + "api/ws/rest/ergon/v1.0/lov/setores/listaSetores")
            .then(
              //success
              function(response) {
                $scope.Setores.data = response;
                
              },
              //failure
              function(response) {
                $scope.Setores.data    = { data: []};
              }
            );
        }
        
        function fechCargos(){
          
          //Retorna $promise da busca pelos dados dos cargos para o vínculo nainformado
          var _method   = "GET";
          var _url      = (window.hostApp || "") + "api/ws/rest/ergon/v1.0/lov/cargos/cargoPorCategoria";
          var _headers  = "origin-path:" + $location.path();
          
          if ($scope.numfunc && $scope.numfunc !== null && !Number.isNaN($scope.numfunc) &&
              $scope.numvinc && $scope.numvinc !== null && !Number.isNaN($scope.numvinc) )
          {
            
            return $http({
              method  : _method,
              url     : _url,
              params  : { numfunc: $scope.numfunc , numvinc : $scope.numvinc } ,
              headers : _headers
            });
            
          } else {
            showError({name:"Parâmetros inválidos",message:"Erro nos parâmetros informados {numfunc:"+$scope.numfunc+",numvinc:"+$scope.numvinc+",data:"+data+"}"});
          }
          
        }
        
        function populaCargo(){
          fechCargos()
            .success(function(data, status, headers, config) {
              $scope.Cargos       = { data: []};
              $scope.Cargos.data  = data;
            })
            .error(function(data, status, headers, config) {
              $scope.Cargos       = { data: []};
            });
        }
        
        function fechVagas(){
          //Retorna $promise da busca pelos dados dos cargos para o vínculo nainformado
          var _method   = "GET";
          var _url      = (window.hostApp || "") + "api/ws/rest/ergon/v1.0/lov/Vagas";
          var _headers  = "origin-path:" + $location.path();
          
          if ($scope.numfunc && $scope.numfunc !== null && !Number.isNaN($scope.numfunc) &&
              $scope.numvinc && $scope.numvinc !== null && !Number.isNaN($scope.numvinc) )
          {
            var _path     = '/listaVagas' ;
            
            return $http({
              method  : _method,
              url     : _url + _path,
              params  : { dtini:    $scope.dtini, 
                          numfunc:  $scope.numfunc , 
                          numvinc : $scope.numvinc , 
                          cargo:    $scope.cargo, 
                          setor:    $scope.setor , 
                          dtfim:    $scope.dtfim  
                         } ,
              headers : _headers
            });
            
          } else {
            showError({name:"Parâmetros inválidos",message:"Erro nos parâmetros informados {numfunc:"+$scope.numfunc+",numvinc:"+$scope.numvinc+",data:"+data+"}"});
          }
          
          
        }
        
        function populaVagas(){
          fechVagas()
            .success(function(data, status, headers, config) {
              $scope.Vagas       = { data: []};
              $scope.Vagas.data  = data;
              
            })
            .error(function(data, status, headers, config) {
              
              $scope.Vagas = { data: []};
              
            });
        }
        
        function populaJornadas(){
          GenericService.getData("api/rest/ergon/Jornada")
            .then(
              //success
              function(response) {
                $scope.Jornadas.data = response.content;
                
              },
              //failure
              function(response) {
                $scope.Jornadas.data    = { data: []};
              }
            );
          
        }
        
        function populaReferencias(){
          GenericService.getData("api/ws/rest/ergon/v1.0/lov/referencias/listRefByCargo/"+$scope.cargosel )
            .then(
              //success
              function(response) {
                $scope.Referencias.data = response;
                
              },
              //failure
              function(response) {
                $scope.Referencias  = { data: []};
              }
            );
          
        }
        
        function populaFracao1(){
          GenericService.getData("api/ws/rest/ergon/v1.0/lov/itemTabela/listaFracao1" )
            .then(
              //success
              function(response) {
                $scope.Fracao1.data = response;
                
              },
              //failure
              function(response) {
                $scope.Fracao1  = { data: []};
              }
            );
          
        }
        
        function populaMotivosReab(){
          GenericService.getData("api/ws/rest/ergon/v1.0/lov/itemTabela/listaMotivosReabertura" )
            .then(
              //success
              function(response) {
                $scope.MotivosReab.data = response;
                
              },
              //failure
              function(response) {
                $scope.MotivosReab = { data: []};
              }
            );
          
        }
        
        function populaMotivosRev(){
          GenericService.getData("api/ws/rest/ergon/v1.0/lov/itemTabela/listaMotivosReversao")
            .then(
              //success
              function(response) {
                $scope.MotivosRev.data = response;
                
              },
              //failure
              function(response) {
                $scope.MotivosRev  = { data: []};
              }
            );
          
        }
        
        function copyToActiveAposentadoria(){
          //Copiar rowdata para objeto active, sem passar referencia;
          $scope.Aposentadoria.active = {};
          angular.copy($scope.Aposentadoria.row, $scope.Aposentadoria.active);
        }
        
        /** CHAMADAS A PROCEDURES POR METODO POST **/
        function revisarAposentadoria() {
          var _url      = "api/rest/ergon/Aposentadoria/Alterar";
          
          var form = parameterFormCtrl;
          
          $scope.receive($scope.Aposentadoria.active);
          
          var _data = JSON.stringify({
            	operacao        : 'ALTERAR A PARTIR DE',
	            numfunc         : $scope.blkVinc.numfunc,
	            numvinc         : $scope.blkVinc.numvinc,
	            tipoAposent     : $scope.Aposentadoria.active.tipoAposent ,
	            dtini           : $scope.Aposentadoria.active.dtini,
	            dtfim           : $scope.Aposentadoria.active.dtfim,
	            dtRegistroTCE   : $scope.Aposentadoria.active.dtRegistroTCE,
	            anostrab        : $scope.Aposentadoria.active.anostrab,
	            diastrab        : $scope.Aposentadoria.active.diastrab,
	            anosapos        : $scope.Aposentadoria.active.anosapos,
	            fracao1         : $scope.Aposentadoria.active.fracao1,
	            fracao2         : $scope.Aposentadoria.active.fracao2,
	            obs             : $scope.Aposentadoria.active.obs,
	            numRequerimento : $scope.Aposentadoria.active.numRequerimento,
	            acaoJudicial    : $scope.Aposentadoria.active.acaoJudicial,
	            numProcessoJud  : $scope.Aposentadoria.active.numProcessoJud,
	            numRegistroTCE  : $scope.Aposentadoria.active.numRegistroTCE
          });
          
          GenericService.postData(_url, _data)
          .then(
            //Success
            function(response){
              $scope.viewStateFlags.esperandoProcesso = false;
              
              if(typeof(response.status) == "undefined"){
              populaAposentadoria(function(data){
                
                $scope.Aposentadoria.row = data.find(function(item){
                  return (item.numfunc == response.numfunc && item.numvinc == response.numvinc && item.dtini == response.dtini);
                });
                copyToActiveAposentadoria($scope.Aposentadoria.row);
                $scope.viewStateFlags.revisaoBloqueada = true;
              });
              }else{
                $scope.viewStateFlags.esperandoProcesso = false;
                $scope.retrive($scope.Aposentadoria.active);
              }
            },
            //Error
            function(error){
              $scope.viewStateFlags.esperandoProcesso = false;
              $scope.retrive($scope.Aposentadoria.active);
            }
          );
        }     
        
        function registrarTCEAposentadoria() {
          
          var _url      = "api/rest/ergon/Aposentadoria/Alterar";
          
          var form = parameterFormCtrl;
          
          $scope.receive($scope.Aposentadoria.active);
          
          var _data = JSON.stringify({
            	operacao        : 'ALTERAR',
	            numfunc         : $scope.blkVinc.numfunc,
	            numvinc         : $scope.blkVinc.numvinc,
	            tipoAposent     : $scope.Aposentadoria.active.tipoAposent ,
	            dtini           : $scope.Aposentadoria.active.dtini,
	            dtfim           : $scope.Aposentadoria.active.dtfim,
	            dtRegistroTCE   : $scope.Aposentadoria.active.dtRegistroTCE,
	            anostrab        : $scope.Aposentadoria.active.anostrab,
	            diastrab        : $scope.Aposentadoria.active.diastrab,
	            anosapos        : $scope.Aposentadoria.active.anosapos,
	            fracao1         : $scope.Aposentadoria.active.fracao1,
	            fracao2         : $scope.Aposentadoria.active.fracao2,
	            obs             : $scope.Aposentadoria.active.obs,
	            numRequerimento : $scope.Aposentadoria.active.numRequerimento,
	            acaoJudicial    : $scope.Aposentadoria.active.acaoJudicial,
	            numProcessoJud  : $scope.Aposentadoria.active.numProcessoJud,
	            numRegistroTCE  : $scope.Aposentadoria.active.numRegistroTCE
          });
          
          GenericService.postData(_url, _data)
          .then(
            //Success
            function(response){
              $scope.viewStateFlags.esperandoProcesso = false;
              
              if(typeof(response.status) == "undefined"){
              populaAposentadoria(function(data){
                
                $scope.Aposentadoria.row = data.find(function(item){
                  return (item.numfunc == response.numfunc && item.numvinc == response.numvinc && item.dtini == response.dtini);
                });
                copyToActiveAposentadoria($scope.Aposentadoria.row);
                $scope.viewStateFlags.registroTCEBloqueada = true;
              });
              }else{
                $scope.viewStateFlags.esperandoProcesso = false;
                $scope.retrive($scope.Aposentadoria.active);
              }
            },
            //Error
            function(error){
              $scope.viewStateFlags.esperandoProcesso = false;
              $scope.retrive($scope.Aposentadoria.active);
            }
          );
        }
        
        function reabrirAposentadoria() {
          
          var _url      = "api/rest/ergon/Aposentadoria/Reabrir";
          
          var form = parameterFormCtrl;
          
          $scope.receive($scope.Aposentadoria.active);
          
          var _data = JSON.stringify({
            	operacao      : "REABRIR",
            	dtini         : $scope.Aposentadoria.row.dtini,
            	numfunc       : $scope.blkVinc.numfunc,
            	numvinc       : $scope.blkVinc.numvinc,
            	obs           : $scope.Aposentadoria.active.obs,
            	motivo        : $scope.Aposentadoria.active.motivoReaberturaNome
          });
          
          GenericService.postData(_url, _data)
          .then(
            //Success
            function(response){
              $scope.viewStateFlags.esperandoProcesso = false;
              
              if(typeof(response.status) == "undefined"){
                populaAposentadoria(function(data){
                $scope.Aposentadoria.row = data.find(function(item){
                  return (item.numfunc == response.numfunc && item.numvinc == response.numvinc && item.dtini == response.dtini);
                });
                  copyToActiveAposentadoria($scope.Aposentadoria.row);
                  $scope.viewStateFlags.reaberturaBloqueada = true;
                });  
              }else{
                $scope.viewStateFlags.esperandoProcesso = false;
                $scope.retrive($scope.Aposentadoria.active);
              }
            },
            //Error
            function(error){
              $scope.viewStateFlags.esperandoProcesso = false;
              $scope.retrive($scope.Aposentadoria.active);
            }
          );
        }  
        
        function reverterAposentadoria() {
          
          var _url      = "api/rest/ergon/Aposentadoria/Reverter";
          
          var form = parameterFormCtrl;
          
          $scope.receive($scope.Aposentadoria.active);
          
          var _data = JSON.stringify({
              operacao 			:	'REVERTER',
              dtini 				:	$scope.Aposentadoria.active.dtini,
              dtfim         : moment(new Date()).format('YYYY-MM-DD'),
              // dtfim 				:	$scope.Aposentadoria.active.dtfim,
              numfunc				:	$scope.blkVinc.numfunc,
              numvinc				:	$scope.blkVinc.numvinc,
              obs 				  :	$scope.Aposentadoria.active.obs,
              tipoevento		:	$scope.Aposentadoria.active.especieEvento,
              cargo				  :	$scope.Aposentadoria.active.cargo,
              formaprov			:	$scope.Aposentadoria.active.especieEvento,
              setor				  :	$scope.Aposentadoria.active.setor,
              referencia		:	$scope.Aposentadoria.active.referencia,
              jornada				:	$scope.Aposentadoria.active.jornada,
              numerovaga		:	$scope.Aposentadoria.active.vaga ,
              motivo				:	$scope.Aposentadoria.active.motivoReversao
          });
        
          GenericService.postData(_url, _data)
          .then(
            //Success
            function(response){
              $scope.viewStateFlags.esperandoProcesso = false;
              
              if(typeof(response.status) == "undefined"){
              populaAposentadoria(function(data){
                
                $scope.Aposentadoria.row = data.find(function(item){
                  return (item.numfunc == response.numfunc && item.numvinc == response.numvinc && item.dtini == response.dtini);
                });
                copyToActiveAposentadoria($scope.Aposentadoria.row);
                $scope.viewStateFlags.reversaoBloqueada = true;
              });
              }else{
                $scope.viewStateFlags.esperandoProcesso = false;
                $scope.retrive($scope.Aposentadoria.active);
              }
            },
            //Error
            function(error){
              $scope.viewStateFlags.esperandoProcesso = false;
              $scope.retrive($scope.Aposentadoria.active);
            }
          );
        }
        
      }
    ]);
    
} (app));