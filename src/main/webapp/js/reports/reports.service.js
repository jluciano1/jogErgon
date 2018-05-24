(function () {
    'use strict';

    angular
        .module('custom.services')
        .service('ReportService', ReportService);

    ReportService.$inject = ['$http'];

    function ReportService($http) {

        function getReport(reportName) {
            var req = {
                url: 'api/rest/report/',
                method: 'GET'
            };
            req.url += reportName;
            return $http(req);
        }

        function getPDF(report, _url) {
            var url;
            url = _url;
            if (_url === undefined || _url === null)
            {
              //_url = 'api/rest/report/pdf';
              throw({name:'URL inválida',message:'URL de relatório não informada'}); 
            }
            var req = {
                url: _url,
                method: 'GET',
                responseType: 'arraybuffer',
                params: report
                //data: angular.toJson(report)
            };
            return $http(req);
        }
        
        function getPDFPost(report) {
            /*
            var url;
            url = 'api/rest/report/pdf';
            if (_url === undefined || _url === null)
            {
              //_url = 'api/rest/report/pdf';
              throw({name:'URL inválida',message:'URL de relatório não informada'}); 
            }
            */
            var req = {
                url: 'api/rest/report/pdf',
                method: 'POST',
                responseType: 'arraybuffer',
                //params: report
                data: angular.toJson(report)
            };
            return $http(req);
        }
        
        function openPDF(result) {
            var blob = new Blob([result.data], {type: 'application/pdf'});

            var ieEDGE = navigator.userAgent.match(/Edge/g);
            var ie = navigator.userAgent.match(/.NET/g);
            var oldIE = navigator.userAgent.match(/MSIE/g);

            if (ie || oldIE || ieEDGE) {
                window.navigator.msSaveBlob(blob, $scope.report.reportName + ".pdf");
            }
            else {
                window.open(URL.createObjectURL(blob));
            }
        }

        return {
            getReport: getReport,
            getPDF: getPDF,
            getPDFPost: getPDFPost,
            openPDF: openPDF
        };
    }

})();