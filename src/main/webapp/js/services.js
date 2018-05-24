(function($app) {
    angular.module('custom.services', []);
    
    app.factory('sharedGenericService', function($rootScope) {
        var sharedService = {};
        sharedService.pontlei = '';
        sharedService.pontpubl = '';
        sharedService.blkvinc = {};
        
        sharedService.prepForBroadcastBlkvinc = function(blkfunc) {
            this.blkvinc = blkfunc;
            this.broadcastItem();
        };

        sharedService.prepForBroadcastPublLei = function(attrs) {
            this.pontlei  = attrs.pontlei;
            this.pontpubl = attrs.pontpubl;
            this.broadcastItem();
        };
        
        sharedService.broadcastItem = function() {
            $rootScope.$broadcast('handleBroadcast');
        };
    
        return sharedService;
    }); 
    
    
}(app));