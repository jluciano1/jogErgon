(function ($app) {
  angular.module('custom.controllers', []);
    //Obtem informações da sessão do usuário
    app.factory('SessionService', ['$http', 'Notification',
      function ($http, Notification) {
        
        var verifyToken = function(_url, _data, _headers) {
          return $http({
                method: 'GET',
                url: 'auth/refresh',
                data: _data,
                headers: _headers
              }).then(
                function(response) {
                  return response;
                },
                function(errResponse) {
                  Notification.error('A sessão do usuário expirou');
              });
        }
        
        return {
          verifyToken: verifyToken
        };   
      }
    ]);
} (app));