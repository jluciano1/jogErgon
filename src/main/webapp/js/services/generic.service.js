(function ($app) {
  angular.module('page.controllers', []);
  
    app.factory('GenericService', ['$http', 'Notification',
      function ($http, Notification) {

        var getData = function(_url, callback, _data, _headers, notShowError) {
          return $http({
                method: 'GET',
                url: _url,
                data: _data,
                headers: _headers
              }).then(
                function(response) {
                  this.data = response.data;
                  if(callback){
                    callback(response.data, false);
                  } else 
                    return this.data;
                },
                function(errResponse) {
                  if(callback){
                    callback(errResponse, true);
                  } else
                    if (notShowError !== true)
                    {
                      if(errResponse)
                      if(errResponse.status != '404'){
                        Notification.error(errResponse.message);  
                      }
                    }
              });
        }
        
        var postData = function(_url, _data, _headers) {
         return $http({
                method: 'POST',
                url: _url,
                data: _data,
                headers: _headers
              }).then(
                function(response){
                  Notification.success('Enviado com sucesso');
                    return response.data;
                }, 
                function(errResponse){
                  Notification.error(errResponse.data.message);
                  return errResponse;
                }
              );
        }
        
        var putData = function(_url, _data, _headers) {
         return $http({
                method: 'PUT',
                url: _url,
                data: _data,
                headers: _headers
              }).then(
                function(response){
                  Notification.success('Atualizado com sucesso');
                    return response.data;
                }, 
                function(errResponse){
                  Notification.error(errResponse.data.message);
                  return errResponse;
                }
              );
        }
        
        var putDataCallErr = function(_url, _data, _headers, _callbackErro) {
          return $http({
                 method: 'PUT',
                 url: _url,
                 data: _data,
                headers: _headers
               }).then(
                 function(response){
                   Notification.success('Atualizado com sucesso');
                     return response.data;
                 }, 
                 _callbackErro
               );
        }
        
        var deleteData = function(_url, _data, _headers) {
         return $http({
                method: 'DELETE',
                url: _url,
                data: _data,
                headers: _headers
              }).then(
                function(response){
                  Notification.success('Excluído com sucesso');
                    return response.data;
                }, 
                function(errResponse){
                  Notification.error(errResponse.data.message);
                  return errResponse;
                }
              );
        }
  
        return {
          getData: getData,
          postData: postData,
          putData: putData,
          deleteData: deleteData,
          putDataCallErr: putDataCallErr
        };   
  
      }
    ]);
} (app));