(function ($app) {
    angular.module('custom.controllers', []);

    app.controller('LoginController', ['$scope', '$http', '$location', '$rootScope', '$window', '$state', '$translate', 'Notification', function ($scope, $http, $location, $rootScope, $window, $state, $translate, Notification) {

        $scope.message = {};
        $scope.login = function () {

            $scope.message.error = undefined;

            var user = { username: $scope.username.value, password: $scope.password.value };

            $http({
                method: 'POST',
                url: 'auth',
                data: $.param(user),
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
            }).success(handleSuccess).error(handleError);
        }
        
        function handleSuccess(data, status, headers, config) {
            // Store data response on session storage
            // The session storage will be cleaned when the browser window is closed
            if(typeof(Storage) !== "undefined") {
                // save the user data on localStorage
                sessionStorage.setItem("_u",JSON.stringify(data));
            } else {
                // Sorry! No Web Storage support.
                // The home page may not work if it depends
                // on the logged user data
            }
            // Ajusta valor padrão de itens por página
            sessionStorage.setItem("pageSize", 50);
            
            // Guarda username do usuário logado
            sessionStorage.setItem("usuarioCorrente", data.usuario.usuario);

            // Guarda empresa do usuário logado
            sessionStorage.setItem("empresaUsuario", JSON.stringify(data.usuario.empCodigo));
            
            // Redirect to home page
            if (data.usuario.altsenha == "S") {
              sessionStorage.setItem("alteraSenhaObrig", "S");
            } else {
              sessionStorage.setItem("alteraSenhaObrig", "N");
            } 
            transactionAccess();
            
            $state.go("home.begin");
        }

        function handleError(data, status, headers, config) {
            var error;

            if(status == 401) {
              if((data.message !== null) && (data.message !== "")) {
                error = data.message;
              } else {
                error = $translate.instant('Login.view.invalidPassword');
              }
            } else {
              error = data;
            }
            Notification.error(error);
        }
        
        function transactionAccess(){
            $http({
                method: 'GET',
                url: "api/rest/ergon/Usuario/getUserTransactionsAccessList/" + $scope.username.value
            }).success(function(response){
                sessionStorage.setItem("transactions",JSON.stringify(response));
            }).error(function(response){
                console.log("Erro: " + response);
            })
        };        
        
    }]);

    app.controller('HomeController', ['$scope', '$http', '$rootScope', '$state', '$location', '$translate', 'Notification', 'TransactionsService', function ($scope, $http, $rootScope, $state, $location, $translate, Notification, TransactionsService) {
        $scope.message = {};
        
        $scope.selecionado = {
          valor : 1
        }
        
        // When access home page we have to check
        // if the user is authenticated and the userData
        // was saved on the browser's sessionStorage
        $rootScope.session = (sessionStorage._u) ? JSON.parse(sessionStorage._u) : null;

        //Desvia para página de login se usuário não está autenticado
        if(!$rootScope.session || $rootScope.session === null || typeof($rootScope.session) === "undefined") {
          $state.go("login");
        }

        //Guarda usuário corrente no scopo da página home
        $scope.usuarioCorrente = sessionStorage.getItem("usuarioCorrente");
        
        //Desvia para página de alteração de senha se a senha do usuário estiver expirada
        if(sessionStorage.getItem("alteraSenhaObrig") == "S") {
          $state.go("home.changePassword");
        }

        $rootScope.myTheme = $rootScope.session.theme;
        $scope.$watch('myTheme', function(value) {
          if (value !== undefined && value != "") {
            $('#themeSytleSheet').attr('href', "css/themes/"+value+".min.css");
          }
        });

        if(!$rootScope.session) {
          // If there isn't a user registered on the sessionStorage
          // we must send back to login page
          // TODO - REVISAR login oauth2
          //$state.go("login");
        }
        
        $rootScope.logout = function logout() {
          systemLogOut();
          $rootScope.session = {};
          if(typeof (Storage) !== "undefined") {
            // save the user data on localStorage
            sessionStorage.removeItem("_u");
          }
          $state.go("login");
        }
        
        $scope.changePassword = function () {

            var user = { oldPassword: senhaAtual.value, newPassword: novaSenha.value, newPasswordConfirmation: novaSenhaConfirm.value };

            $http({
                method: 'POST',
                url: 'changePassword',
                data: $.param(user),
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
            }).success(changeSuccess).error(changeError);
            
            function changeSuccess(data, status, headers, config) {
              Notification.info($translate.instant('Home.view.passwordChanged'));
              sessionStorage.setItem("alteraSenhaObrig", "N");
              cleanPasswordFields();
              $state.go("home.begin");
            }
    
            function changeError(data, status, headers, config) {
              var error;

              if(status == 401) {
                if((data.message !== null) && (data.message !== "")) {
                  error = data.message;
                } else {
                  error = $translate.instant('Home.view.InvalidPassword');
                }
              } else {
                error = data;
              }
              Notification.error(error);
                
            }     
            
            function cleanPasswordFields() {
                senhaAtual.value = "";
                novaSenha.value = "";
                novaSenhaConfirm.value = "";
            }
        }
        
        $rootScope.getPermissionAccess = function(page){
          return TransactionsService.linkGetAccess(page);
        }
        
        var closeMenuHandler = function () {
          var element = $(this);
          if(element.closest('.sub-menu').length > 0) {
            element.closest(".navbar-nav").collapse('hide');
          }
        }
          
        $scope.$on('$viewContentLoaded', function(){
          var navMain = $(".navbar-nav");
          
          //Here your view content is fully loaded !!
          navMain.off("click", "a", closeMenuHandler);
          navMain.on("click", "a", closeMenuHandler);
        });
        
        $scope.themes = ["cerulean","cosmo","cyborg","darkly","flatly","journal","lumen","paper","readable","sandstone","simplex","slate","spacelab","superhero","united","yeti"];

        $scope.changeTheme = function(theme) {
          console.log(theme);
          if (theme !== undefined) {
            console.log(theme);
            $('body').append('<div id="transition" />');
            $('#transition').css({
              'background-color':'#FFF',
              'zIndex':100000,
              'position':'fixed',
              'top':'0px',
              'right':'0px',
              'bottom':'0px',
              'left':'0px',
              'overflow':'hidden',
              'display':'block'
            });
            $('#transition').fadeIn(800, function(){
              $('#themeSytleSheet').attr('href', "css/themes/"+theme+".min.css");
              $rootScope.myTheme = theme;
              $('#transition').fadeOut(1000,function(){$('#transition').remove();});  
            });
            
            var user = { theme: theme };

            $http({
                method: 'POST',
                url: 'changeTheme',
                data: $.param(user),
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
            }).success(changeSuccess).error(changeError);
            
            function changeSuccess(data, status, headers, config) {
              $rootScope.session.theme = theme;
              sessionStorage.setItem("_u",JSON.stringify($rootScope.session));
            }
    
            function changeError(data, status, headers, config) {
                var error = data;
                Notification.error(error);
            }     
            
          }
        }
        // refresh token
        function refreshToken() {
            $http({
                method: 'GET',
                url: 'auth/refresh'
            }).success(function(data, status, headers, config) {
                // Store data response on session storage
                  console.log('revive :' , new Date(data.expires));
                  sessionStorage.setItem("_u",JSON.stringify(data));
                  // Recussive 
                  setTimeout(function() {
                    refreshToken();
                    // refres time
                  },(1800*1000));
                  
            }).error(function() {
              // abafar TODO 
            });
        }
        
        // exist session
        if(!$rootScope.session || $rootScope.session === null || typeof($rootScope.session) === "undefined") {
          $state.go("login");
        } else {
           if ($rootScope.session.token) refreshToken();
        }
    }]);
    
    app.controller('FswGridController', ['$scope','$filter','DatasetManager',
      function($scope,$filter,DatasetManager) {
        
        var gridCtl        = this;
        
        gridCtl.targetDataSet = null;
        gridCtl.predicate     = null;
        gridCtl.fieldType     = null;
        gridCtl.reverse       = false;
        
        var reset = function() {
          gridCtl.targetDataSet = null;
          gridCtl.predicate     = null;
          gridCtl.fieldType     = null;
          gridCtl.reverse       = false;
        }
        
        $scope.reorder = function() {
          if (!gridCtl.targetDataSet || gridCtl.targetDataSet===null || !gridCtl.targetDataSet.data || gridCtl.targetDataSet.data.length <= 0)
            return;
        
          if (!gridCtl.predicate)
            gridCtl.setPredicate(gridCtl.targetDataSet.keys[0], false);
          
          gridCtl.targetDataSet.data = $scope.orderGrid(gridCtl.targetDataSet.data, gridCtl.predicate, gridCtl.reverse, gridCtl.fieldType);
        }

        $scope.orderGrid = function(items, predicate, reverse, fieldType) {
          if (typeof(items)==="undefined" || typeof(predicate)==="undefined" || typeof(reverse)==="undefined")
            return items;
          
          if (items.length == 0)
            return items;
            
          var pred = (predicate?predicate:0);
          var rev  = (reverse?reverse:false);
          var type = (fieldType?fieldType:typeof(items[0][pred]));

          if (type === "string") {
			  		for (var i = 0; i < items.length; i++) {
			  			if (items[i][pred] === null) {
			  				items[i][pred] = "";
			  			}
			  		}
			  		items = $filter('orderByString')(items, pred, rev);
			  	} else {
			  		if (type === "object") {
			  			items = $filter('ordenarObjeto')(items, pred, rev);
			  		  
			  		}	else if (fieldType == "number") { 
			  		  for (var i = 0; i < items.length; i++) {
			  			  if (items[i][pred] === null) {
			  				   items[i][pred] = "";
			  			  }
			  		  }
			  		  items = $filter('orderByNumber')(items, pred, rev);
			  		
			  		}	else if (type === "date") { 
			  		  for (var i = 0; i < items.length; i++) {
			  			  if (items[i][pred] === null) {
			  				   items[i][pred] = "";
			  			  }
			  		  }
			  		  items = $filter('orderByDate')(items, pred, rev);
			  		}	else {
			  			items = $filter('orderBy')(items, pred, rev);
			  		}
			  	}
			  	
			    return items;
        }
        
        $scope.setPredicate = function(field, fieldType, reverse) {
          
          if (!gridCtl.targetDataSet || gridCtl.targetDataSet===null) {
            reset();
            return;
          }
          
          if (!gridCtl.targetDataSet.data || gridCtl.targetDataSet.data.length <= 0)
            gridCtl.fieldType = (fieldType?fieldType:null);
          else
            gridCtl.fieldType = (fieldType?fieldType:typeof(gridCtl.targetDataSet.data[0][field]));
          
          if (reverse && typeof(reverse)==="boolean")
            gridCtl.reverse = reverse;
          else if (gridCtl.predicate == field)
            gridCtl.reverse = !gridCtl.reverse;
          else
            gridCtl.reverse = false;
          
          if (!field || typeof(field)==="undefined")
            gridCtl.predicate = 0;
          else
            gridCtl.predicate = field;
          
          $scope.reorder();
        }
        
        $scope.setTargetDataSet = function(target, predini, typeini, revini) {
          
          if (!target || typeof(target) === "undefined") {
            reset();
            return;
          }
          
          if (Object.prototype.toString(target) === "[Datasource]")
            gridCtl.targetDataSet = target;
          else if (DatasetManager.datasets[target])
            gridCtl.targetDataSet = DatasetManager.datasets[target];
          else {
            reset();
            return;
          }
          
          if (predini)
            gridCtl.predicate = predini;
          if (typeini)
            gridCtl.fieldType = typeini;
          if (typeof(revini)!=="undefined")
            gridCtl.reverse = revini;
          
          if (!gridCtl.targetDataSet.onAfterFill)
            gridCtl.targetDataSet.onAfterFill = function(ds) {
              ds.data = $scope.orderGrid(ds.data, gridCtl.predicate, gridCtl.reverse, gridCtl.fieldType);
            }
        }
    }]);

    app.controller('ValidFormController', ['$scope', '$rootScope', function($scope, $rootScope){
      
      $rootScope.enviarForm = function(){
        $rootScope.submitted = true;
      }
      $rootScope.cancelarForm = function(){
        $rootScope.submitted = false;
      }
      
      $scope.validField = function(field, datasource, submitted){
        var vldfield;
        
        if(submitted){
          if (typeof(field) !== undefined && field !== null)
          {
            vldfield = field.$invalid && !field.$pristine;
            if(!vldfield){
              // Invalido e campo tocado mas nao alterado
              vldfield = field.$touched && field.$invalid;
            }
            if(!vldfield){
              //vldfield = send && field.$invalid;
              vldfield = field.$invalid;
            }
            return vldfield; 
          }
        }
        
        //var send = datasource.inserting || datasource.editing;
        if (field == undefined || typeof(field) === "undefined")
          return false;
        if ((!datasource) || (typeof(datasource) === "undefined"))
          return false;
        if ((datasource.env == undefined) || (datasource.env == null) || (datasource.env == "") || (datasource.env == false))
          return false; // campos estarão sempre sem erros quando datasource.env for false 
        
        vldfield = field.$invalid && !field.$pristine;
        
        if(!vldfield){
          // Invalido e campo tocado mas nao alterado
          vldfield = field.$touched && field.$invalid;
        }
        if(!vldfield){
          //vldfield = send && field.$invalid;
          vldfield = field.$invalid;
        }

        return vldfield;
      };
      
      $scope.send = function(form, datasource, attrEmpresa, blockVinc){
        datasource.env = true;
        blockVincEmpresa = null;
        numvinc = {};
        numfunc = {};

        if((form.$valid)&&(!form.$pristine)){
          if(blockVinc != null){
            
            numfunc.numero = blockVinc.numfunc;
            numvinc.numero = blockVinc.numvinc;
            
            numvinc.numfunc = numfunc;
            blockVincEmpresa = blockVinc.empresa;

            datasource.active.numvinc = numvinc;
          }
          
          if(attrEmpresa != null) {
            var empresa = {};
            
            // Se há empresa selecionada na página, inclui o código no header da requisição        
            if (!((typeof Empresas === "undefined") || (typeof Empresas.active === "undefined") || (typeof Empresas.active.empresa === "undefined"))) {
              empresa = Empresas.active;
            } 
            // Se há empresa específica selecionada na página, inclui o código no header da requisição        
            else if (!((typeof EmpresasOpt === "undefined") || (typeof EmpresasOpt.active === "undefined") || (typeof EmpresasOpt.active.empresa === "undefined") || (EmpresasOpt.active.empresa === 0))) {
              empresa = EmpresasOpt.active;
            }
            // Se há vínculo selecionado na página, inclui o código no header da requisição                
            else if (blockVincEmpresa != null) {
              empresa.empresa = parseInt(blockVincEmpresa);
            }
            // Se nenhuma empresa local à transação for encontrada, usa a empresa do usuário logado
            else {
              empresa = JSON.parse(sessionStorage.getItem("empresaUsuario"));
            }
            
            datasource.active[attrEmpresa] = empresa;
          }
          datasource.post();
          datasource.env = false;
        };
      };

      $scope.formCancel = function(datasource, dataTarget, fechaModal) {
        var fechar = (typeof(fechaModal)==="undefined"?true:fechaModal);
        datasource.cancel();
        datasource.env = false;
        if (fechar)
          if (dataTarget && typeof(dataTarget) !== "undefined" && dataTarget !== '')
            $(''+dataTarget+'').modal('hide');
          else
            $("[data-dismiss=modal]").trigger({ type: "click" });
      }
      
    }]);
} (app));