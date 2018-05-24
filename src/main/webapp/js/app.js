var app = (function() {
    return angular.module('MyApp', [
    'ui.router',
    'ui.select',
    'ui-select-infinity',
    'ngResource',
    'ngSanitize',
    'custom.controllers', 
    'custom.services',
    'datasourcejs',
    'chart.js',
	  'ngMask',
    'ngJustGage',
    'pascalprecht.translate',
    'tmh.dynamicLocale',
    'ui-notification',
    'ui.bootstrap',
    'angularUtils.directives.dirPagination',
    'ui.utils.masks',
    'angular-loading-bar',
    'ngFileUpload',
    'angular-loading-bar',
    'base64'
    ])
     
    .constant('LOCALES', {
      'locales': {
        'pt_BR': 'Portugues (Brasil)',
        'en_US': 'English'
      },
      'preferredLocale': 'pt_BR'
    })
    
    .config(['$httpProvider',
      function($httpProvider) {
        var interceptor = [
          '$q',
          '$rootScope',
          function($q, $rootScope) {
            var service = {
              'request': function(config) {
                var _u = JSON.parse(sessionStorage.getItem('_u'));
                if (_u && _u.token) config.headers['X-AUTH-TOKEN'] = _u.token;

                // Inclui nome da transação no header da requisição
                if (!((typeof TransacaoDescr === "undefined") || (typeof TransacaoDescr.data === "undefined") || (typeof TransacaoDescr.data[0] === "undefined"))) {
                  config.headers['X-TC'] = TransacaoDescr.data[0].transacao;
                }
                else {
                  config.headers['X-TC'] = "";
                }

                // Se há empresa selecionada na página, inclui o código no header da requisição                
                if (!((typeof Empresas === "undefined") || (typeof Empresas.active === "undefined") || (typeof Empresas.active.empresa === "undefined"))) {
                  config.headers['X-ES'] = Empresas.active.empresa;
                }
                // Se há empresa selecionada no filtro da página, inclui o código no header da requisição
                else if (!((typeof EmpresasOpt === "undefined") || (typeof EmpresasOpt.active === "undefined") || (typeof EmpresasOpt.active.empresa === "undefined") || (EmpresasOpt.active.empresa === 0))) {
                  config.headers['X-ES'] = EmpresasOpt.active.empresa;
                }
                // Se há vínculo selecionado na página, inclui o código no header da requisição                
                else if (!((typeof BlockVinc === "undefined") || (typeof BlockVinc.filtro === "undefined") || (typeof BlockVinc.filtro.empresa === "undefined"))) {
                  config.headers['X-ES'] = BlockVinc.filtro.empresa;
                }
                // Se não há empresa selecionada na página, envia empresa do usuário
                else if (typeof(sessionStorage.getItem("empresaUsuario")) !== "undefined" && sessionStorage.getItem("empresaUsuario") !== null) {
                  config.headers['X-ES'] = JSON.parse(sessionStorage.getItem("empresaUsuario")).empresa;
                } 
                // Se tudo o mais falhou, envia 0
                else {
                  config.headers['X-ES'] = 0;
                }

                return config;
              }
            };
            return service;
          }
        ];
        $httpProvider.interceptors.push(interceptor);
      }
    ])
    
    .config(function($stateProvider, $urlRouterProvider, NotificationProvider) {
        NotificationProvider.setOptions({
              delay: 10000,
              startTop: 20,
              startRight: 10,
              verticalSpacing: 20,
              horizontalSpacing: 20,
              positionX: 'center',
              positionY: 'top'
        });
        
        // Set up the states
        $stateProvider
          
        .state('login', {
            url: "",
            controller: 'LoginController',
            templateUrl: 'views/login.view.html'
        })
          
        .state('main', {
            url: "/",
            controller: 'LoginController',
            templateUrl: 'views/login.view.html'
        })

        .state('home', {
            url: "/home",
            controller: 'HomeController',
            templateUrl: 'views/logged/home.view.html',
            resolve: {
              data: ['$q', '$state', '$stateParams', '$timeout', 'TransactionsService', 'SessionService', 'Notification', function ($q, $state, $stateParams, $timeout, TransactionsService, SessionService, Notification) {
                SessionService.verifyToken().then(function(response){
                  if(!response || response == ""){
                    $state.go('login');
                  } else {
                    TransactionsService.setPermissions(sessionStorage.usuarioCorrente).then(function(response){
                      if(!response || response == ""){
                        $state.go('login');
                      }
                      }, function(errResponse) {
                          console.log(errResponse);  
                    });
                  }
                });
              }]
            }
        })

        .state('home.begin', {
            url: "/index",
            controller: 'PageController',
            templateUrl: 'views/logged/trpvHome.view.html'
        })

        .state('home.changePassword', {
            url: "/changePassword",
            controller: 'ChangePasswordController',
            templateUrl: 'views/logged/trpvChangePwd.view.html'
        })

        .state('home.pages', {
            url: "/logged/{name:.*}",
            params: {
              pNumfunc:{value:null}, 
              pNumvinc:{value:null}
            },
            controller: 'PageController',
            templateUrl: function(urlattr){
              return 'views/logged/'+urlattr.name+'.view.html';
            },
            resolve: {
              data: ['$q', '$state', '$stateParams', '$timeout', 'TransactionsService', function ($q, $state, $stateParams, $timeout, TransactionsService) {
                var pageAccess = true;
                var deferred = $q.defer();
                pageAccess = TransactionsService.directiveGetLinkPermission($stateParams.name);
                $timeout(function() {
                  if (!pageAccess) {
                    $state.go('403');
                    deferred.reject();
                  } else {
                    deferred.resolve();
                  }
                });
                return deferred.promise;
              }]
            }
        }) 
 
          
        .state('404', {
            url: "/error/404",
            controller: 'PageController',
            templateUrl: function(urlattr){
                return 'views/error/404.view.html';
            }
        })
          
        .state('403', {
            url: "/error/403",
            controller: 'PageController',
            templateUrl: function(urlattr){
                return 'views/error/403.view.html';
            }
        });
          
        // For any unmatched url, redirect to /state1
        $urlRouterProvider.otherwise("/error/404");
    })


    .config(function ($translateProvider, tmhDynamicLocaleProvider) {
      
        $translateProvider.useMissingTranslationHandlerLog();
      
        $translateProvider.useStaticFilesLoader({
          prefix: 'i18n/locale_',
          suffix: '.json'
        });
      
        $translateProvider.registerAvailableLanguageKeys(
          ['pt_BR', 'en_US'], {
            'en*': 'en_US',
            'pt*': 'pt_BR',
            '*'  : 'pt_BR'
        });
      
        var locale = (window.navigator.userLanguage || window.navigator.language || 'pt_BR').replace('-', '_');
      
        $translateProvider.use(locale);
        $translateProvider.useSanitizeValueStrategy('escaped');
      
        tmhDynamicLocaleProvider.defaultLocale(locale.replace('_', '-').toLowerCase());
        tmhDynamicLocaleProvider.localeLocationPattern('plugins/angular-i18n/angular-locale_{{locale}}.js');
    })

    .directive('crnValue', ['$parse', 
      function($parse) {
        return {
          restrict: 'A',
          require: '^ngModel',
          link: function(scope, element, attr, ngModel) {
            var evaluatedValue;
            if(attr.value) {
              evaluatedValue = attr.value;
            } else {
              evaluatedValue = $parse(attr.crnValue)(scope);
            }
            element.attr("data-evaluated", JSON.stringify(evaluatedValue));
            element.bind("click", function(event) {
              scope.$apply(function() {
                 ngModel.$setViewValue(evaluatedValue);  
              }.bind(element));
            });
          }
        };
    }])

    // General controller
    .controller('PageController',["$scope","$stateParams","$location","$http","$state","$rootScope","$filter","$sce","$window", "TransactionsService",
      function($scope, $stateParams, $location, $http, $state, $rootScope, $filter, $sce, $window, TransactionsService){
        
        //container para os filtros da página
        $scope.pageFilters = {};
      
        //variáveis de escopo que são utilizadas no blockVinc
        $scope.blkVincFiltro = {};
        // $scope.blkVinc = {};

	      //variáveis de escopo que são utilizadas no blockReqVinc
        $scope.blkReqVincFiltro = {};
        // $scope.blkReqVinc = {};
      
        //alimenta a variável de escopo com o conteúdo do campo que foi selecionado no blockVinc
        $scope.blkVincSelect = function(item) {
          // console.log(item);
          $scope.blkVinc = item;
          if (typeof(item)==="undefined") {
            if ($stateParams.hasOwnProperty('pNumfunc')) $stateParams.pNumfunc=null;
            if ($stateParams.hasOwnProperty('pNumvinc')) $stateParams.pNumvinc=null;
            $location.search({});
          } else if ( (item.numfunc!=='' && item.numfunc != ($stateParams['pNumfunc']||'') ) ||
                      (item.numvinc!=='' && item.numvinc != ($stateParams['pNumvinc']||'') ) )
          {
            $location.search({pNumfunc:item.numfunc,pNumvinc:item.numvinc});
          }
        };

        //alimenta a variável de escopo com o conteúdo do campo que foi selecionado no blockReqVinc
        $scope.blkReqVincSelect = function(item) {
          // console.log(item);
          $scope.blkReqVinc = item;
        };
      
        //controle readonly para blocos de lei e publ
        $scope.blkLeiReadOnly = false;
        $scope.blkPublReadOnly = false;
      
        //Controller do Ian
        $scope.empresaUsuario = JSON.parse(sessionStorage.getItem("empresaUsuario"));      
      
        //Desvia para página de login se usuário não está autenticado
        if(!$rootScope.session || $rootScope.session === null || typeof($rootScope.session) === "undefined") {
          $state.go("login");
        }

        $scope.senhaExpirada = sessionStorage.getItem("alteraSenhaObrig") == "S" ? true : false;

        //Desvia para página de alteração de senha se a senha do usuário estiver expirada
        if($scope.senhaExpirada) {
          $state.go("home.changePassword");
        }
      
        for(var x in app.userEvents)
          $scope[x]= app.userEvents[x].bind($scope);
      
        // TransactionAccessList
        $scope.transaction = JSON.parse(sessionStorage.getItem('transactions'));
        $scope.page = $location.path().split("/");
        $scope.transacao = getTransacao();
     
        function getTransacao(){
            var lpage = $scope.page[$scope.page.length - 1];
            if($scope.transaction){
              for (var x = 0; x < $scope.transaction.length; x++){
                  if($scope.transaction[x].page == lpage){
                      
                      $scope.transacao = $scope.transaction[x];
                        
                      $scope.nomeTrans = $scope.transaction[x].nomeTrans;
                      $scope.pageDescript = "/"+$scope.transaction[x].page+"/RPrevAposent";
                      $scope.insertAllowed = $scope.transaction[x].insertAllowed;
                      $scope.updateAllowed = $scope.transaction[x].updateAllowed;
                      $scope.deleteAllowed = $scope.transaction[x].deleteAllowed;
                      $scope.openAllowed = $scope.transaction[x].openAllowed;
                      
                      //console.log("Pode inserir: " + $scope.insertAllowed);
                      //console.log("Pode atualizar: " + $scope.updateAllowed);
                      //console.log("Pode remover: " + $scope.deleteAllowed);
                        
                  }
              }
            }
        }

        // save state params into scope
        $scope.params = $stateParams;
        /*if (typeof($scope.blkVinc)==="undefined" || typeof($scope.blkVinc.numfunc)==="undefined" || $scope.blkVinc.numfunc===null) {
          if ($stateParams.hasOwnProperty('pNumfunc') && $stateParams.pNumfunc!==null) {
            $scope.blkVinc.numfunc = $stateParams.pNumfunc;
            if ($stateParams.hasOwnProperty('pNumvinc') && $stateParams.pNumvinc!==null) {
              $scope.blkVinc.numvinc = $stateParams.pNumvinc;
            }
          }
        }*/
        $scope.$http = $http;
      
        $scope.changePageSize = function (pageSize) {
          console.log('sessionStorage.pageSize:' + sessionStorage.pageSize);
          console.log('pageSize:' + pageSize);
          sessionStorage.setItem("pageSize", pageSize);
        };

        // Datatable itens display
        if (!$scope.pageSize)
          $scope.pageSize = sessionStorage.pageSize;      
        
        $scope.pageSizeData = {
          model: null,
            options: [
              {id: 10},
              {id: 25},
              {id: 50}
            ], initialValue: {id: sessionStorage.pageSize}
        };

        $scope.pageSizeData2 = {
          model: null,
            options: [
              {id: 10},
              {id: 25},
              {id: 50}
            ], initialValue: {id: sessionStorage.pageSize}
        };
        // Query string params
        var queryStringParams = $location.search();
        for(var key in queryStringParams) {
          if(queryStringParams.hasOwnProperty(key)) {
            $scope.params[key] = queryStringParams[key];
          }
        }
        registerComponentScripts();
        
 	      var orderBy = $filter('orderBy');
			  $scope.predicate = ""; //coluna a ser ordenada
			  $scope.reverse = true; //se é ordem asc ou desc     
			
			  $scope.order = function(items, predicate, objPre,	reverse, tipo) {
			  	if ($scope.predicate == predicate) {
			  		if ($scope.reverse === false) {
			  			reverse = true;
			  		} else {
			  			reverse = false;
			  		}
			  	} else {
			  		reverse = false;
			  	}
			  	$scope.reverse = reverse
			  	if (tipo == "String") {
			  		for (var i = 0; i < items.length; i++) {
			  			if (items[i][predicate] === null) {
			  				items[i][predicate] = "";
			  			}
			  		}
			  		items = $filter("orderByString")(items, predicate, reverse);
			  	} else {
			  		if (tipo == "Object") {
			  			for (var i = 0; i < items.length; i++) {
			  				if (items[i][predicate] === null) {
			  					items[i][predicate] = [objPre];
			  					items[i][predicate][objPre] = "";
			  				}
			  			}
			  			items = $filter("ordenarObj")(items, predicate, objPre, reverse);
			  		  
			  		}	else if (tipo =="Number") { 
			  		  for (var i = 0; i < items.length; i++) {
			  			  if (items[i][predicate] === null) {
			  				   items[i][predicate] = "";
			  			  }
			  		  }
			  		  items = $filter("orderByNumber")(items, predicate, reverse);
			  		
			  		}	else if (tipo =="Date") { 
			  		  for (var i = 0; i < items.length; i++) {
			  			  if (items[i][predicate] === null) {
			  				   items[i][predicate] = "";
			  			  }
			  		  }
			  		  items = $filter("orderByDate")(items, predicate, reverse);
			  		}	else {
			  			items = $filter('orderBy')(items, predicate, reverse)
			  		}
			  	}
			  	$scope.predicate = predicate;
			  	return items;
			  };

        $scope.collapsing = function(idTransitionDiv, idCollapseArea, datasource) {
            $(idTransitionDiv).css("transition-duration", "0.5s");
            /*$(idCollapseArea).css("transition-duration", "0.5s");*/
            
            if ($(idTransitionDiv).hasClass('col-xs-12') && (datasource.inserting || datasource.editing)) {
  					  
  						$(idTransitionDiv).removeClass('col-xs-12');
  						$(idTransitionDiv).addClass('col-xs-7');
  						
  						window.setTimeout(function(){
  						  $(idCollapseArea).collapse('show');
  						  $(idCollapseArea).addClass('in');
  						}, 500);
  						
  					} 
  					
  					if ($(idTransitionDiv).hasClass('col-xs-7') && !datasource.inserting && !datasource.editing){
  					  
  					  $(idTransitionDiv).removeClass('col-xs-7');
  					  $(idTransitionDiv).addClass('col-xs-12');
  					
  					  $(idCollapseArea).removeClass('in');
  					  $(idCollapseArea).collapse('hide');
  					}
					};
					
					var backupData = {};
					
					$scope.receive = function(data){
					  backupData = {};
					  copy(data, backupData);
					  var o = {};
					  copy(data, o);
					  return o;
					}
					
					$scope.retrive = function(data){
					  copy(backupData, data);
					}
					
				  function copy(origem, destino){
            angular.copy(origem, destino);
          }
				
				
        
        $scope.highlight = function(text, search) {
          if (!search || typeof(search)==="undefined" || search==='') {
            return $sce.trustAsHtml(text);
          }
          var safetext = text || '';
          return $sce.trustAsHtml(unescape(escape(safetext).replace(new RegExp(escape(search), 'i'), escape('<span class="highlightedText">')+'$&'+escape('</span>'))));
        };
        
        $scope.applyParameters = function(url) {
          if (!url || typeof(url) !== "string" || url.length===0)
            return url;
          
          if (!$scope.params || typeof($scope.params)!=="object")
            return url;
          
          var _s = "?";
          var _r = url;
          for (var prop in $scope.params) {
            if ($scope.params.hasOwnProperty(prop) && prop!=="name") {
              _r = _r + _s + prop + "=" + $scope.params[prop];
              _s = "&";
            }
          }
          
          return _r;
        }
        
        $scope.followLink = function($event, _name) {
        
          $event.preventDefault();
          
          if (!_name || typeof(_name) !== "string" || _name.length===0)
            return;
            
          if (!TransactionsService.directiveGetLinkPermission(_name))
            return;
          
          var _params = {};
          if ($scope.params && typeof($scope.params)==="object")
            _params = Object.assign(_params,$scope.params);
          
          _params = Object.assign(_params,{name:_name});
          
          if ($event.shiftKey || $event.ctrlKey || $event.metaKey) {
            url = $state.href('home.pages', { name: _params.name }, { absolute: true });
            
            if (_params.hasOwnProperty('pNumfunc') && _params.pNumfunc!==null) {
              url = url + "?pNumfunc=" + _params.pNumfunc;
              if (_params.hasOwnProperty('pNumvinc') && _params.pNumvinc!==null) {
                url = url + "&pNumvinc=" + _params.pNumvinc;
              }
            }

            // open in a new window (shift) or tab (ctrl/option)
            $window.open(url, $event.shiftKey ? '_blank' : undefined);
          } else {
            $state.go('home.pages', _params);
          }
        }
    }])

    // Controller específico para página de alteração de senha
    .controller('ChangePasswordController',["$scope","$stateParams","$location","$http", "$rootScope",
      function($scope, $stateParams, $location, $http, $rootScope){

        //Desvia para página de login se usuário não está autenticado
        if(!$rootScope.session) {
          $state.go("login");
        }
      
        $scope.senhaExpirada = sessionStorage.getItem("alteraSenhaObrig") == "S" ? true : false;

        for(var x in app.userEvents)
          $scope[x]= app.userEvents[x].bind($scope);
      
        // save state params into scope
        $scope.params = $stateParams;
        $scope.$http = $http;
      
        // Query string params
        var queryStringParams = $location.search();
        for(var key in queryStringParams) {
          if(queryStringParams.hasOwnProperty(key)) {
            $scope.params[key] = queryStringParams[key];
          }
        }
        registerComponentScripts();
    }])
      
    .run(function($rootScope,$state,$location,Notification) {
      $rootScope.$on('$stateChangeError', function() {
        var event      = arguments[0];
        var toState    = arguments[1];
        var toParams   = arguments[2];
        var fromState  = arguments[3];
        var fromParams = arguments[4];
        if(!sessionStorage._u){
          $state.go('login');
          Notification.error('O usuário não está logado');  
        }
        if(arguments.length >= 6) {
          var requestObj = arguments[5];
          if(requestObj.status === 404 || requestObj.status === 403) {
            $state.go(requestObj.status.toString()); 
          } else if (requestObj.status === 401 && fromState.name !== "login") {
            event.preventDefault();
          }
        } else {
          $state.go('404');
        }
      });
      // Propaga query parameters pelos estados da aplicação
      $rootScope.$on('$stateChangeStart', function() {
        var elements = document.getElementsByClassName("in");
        if (typeof(elements) !== "undefined" && elements !== null && elements.length > 0)
        {
          for (var i = 0; i < elements.length; i++)
          {
             $(".in").remove();
          }
        }
        var event      = arguments[0];
        var toState    = arguments[1];
        var toParams   = arguments[2];
        var fromState  = arguments[3];
        var fromParams = arguments[4];
        //armazena a string de query da localização para reacrescentá-la ao término da transição
        sessionStorage.locationSearch = JSON.stringify($location.search());
      });
      $rootScope.$on('$stateChangeSuccess', function() {
        var event      = arguments[0];
        var toState    = arguments[1];
        var toParams   = arguments[2];
        var fromState  = arguments[3];
        var fromParams = arguments[4];
        //recupera a string de query da localização
        ssLocationSearch = (JSON.parse(sessionStorage.locationSearch)||{});
        locationSearch = {
          pNumfunc: (ssLocationSearch.pNumfunc||null),
          pNumvinc: (ssLocationSearch.pNumvinc||null)
        };
        $location.search(locationSearch);
        // TODO: Implementar aqui o sistema de redirect on login
        
        if($state.current.controller != 'LoginController' && !sessionStorage._u){
          $state.go('login');
          Notification.error('O usuário não está logado');  
        }
        
        $rootScope.redirectParam = function(){
          if(fromParams.name == "" || fromParams.name == null){
            $state.go('home.begin');
          } else {
            $state.go('home.pages', { name: fromParams.name });
          }
        }
        
      });
    });

}(window));

app.userEvents = {};

//Configuration
app.config = {};
app.config.datasourceApiVersion = 2;

//Components personalization jquery 
var registerComponentScripts = function() {
  //carousel slider
  $('.carousel-indicators li').on('click',function() {
    var currentCarousel = '#' + $(this).parent().parent().parent().attr('id');
    var index = $(currentCarousel+' .carousel-indicators li').index(this);
    $(currentCarousel + ' #carousel-example-generic').carousel(index);
  });
}