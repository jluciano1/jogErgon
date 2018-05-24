(function () {
    'use strict';

    angular
        .module('custom.controllers')
        .controller('ReportController', ReportController);

    ReportController.$inject = ['$scope', '$modal', 'ReportService', 'Notification', '$rootScope'];

    function ReportController($scope, $modal, ReportService, Notification, $rootScope) {

        function escapeRegExp(str) {
            return str.replace(/([.*+?^=!:()|\[\]\/\\])/g, "\\$1");
        }

        function replaceAll(str, find, replace) {
            return str.replace(new RegExp(escapeRegExp(find), 'g'), replace);
        }

        function showParameters(report) {
            var parameters = report.parameters;

            var htmlParameters = [];

            var index = 0;

            function next() {
                if (index < parameters.length) {
                    var parameter = parameters[index++];
                    $.get("js/reports/templates/" + parameter.type + ".parameter.html").done(function (result) {
                        htmlParameters.push(replaceAll(result, "_field_", parameter.name));
                        next();
                    });
                } else if (htmlParameters.length > 0) {
                    $modal.open({
                        templateUrl: 'js/reports/reports.parameters.html',
                        controller: 'ParameterController',
                        resolve: {
                            report: function () {
                                return JSON.parse(JSON.stringify(report));
                            },
                            htmlParameters: function () {
                                return JSON.parse(JSON.stringify(htmlParameters));
                            }
                        }
                    });
                }
            }

            next();
        }

        $scope.getReport = function (reportName) {
            ReportService.getReport(reportName).then(function (result) {
                if (result && result.data) {
                    showParameters(JSON.parse(JSON.stringify(result.data)));
                }
            });
        };
        
        $scope.getReportCheckListDocumentosGeral = function () {
            var reportName = "trpvrel0001";
            ReportService.getReport(reportName).then(function (result) {
                var reportParams = {
                                  reportName: reportName,
                                  parameters: 
                                  [{
                                    name: "REQUERIMENTO",
                                    type: "TIPO_REQUERIMENTO",
                                    value: null,
                                    show: true
                                  },
                                  {
                                    name: "REQUERIMENTO_NOME",
                                    type: "STRING",
                                    value: null,
                                    show: false
                                  },
                                  {
                                    name: "USUARIO",
                                    type: "STRING",
                                    value: null,
                                    show: false
                                  }],
                                  reportShowName: "CheckList de Documentos"
                                };
            showParametersSelecionado(JSON.parse(JSON.stringify(reportParams)));
            }, errorHandle); 
        };
        
        $scope.getReportTermoAcumulacao = function (idFunc, idVinc) {
            var reportName = "trpvrel0008";
            ReportService.getReport(reportName).then(function (result) {
                var reportParams = {
                                  reportName: reportName,
                                  parameters: 
                                  [{
                                    name: "ACUMULACAO",
                                    type: "ACUMULACAO",
                                    value: null,
                                    show: true
                                  },
                                  {
                                    name: "SEGUNDAMATRICULA",
                                    type: "STRING_ACUMULA",
                                    value: null,
                                    show: true,
                                    showName: "Segunda matrícula"
                                  },
                                  {
                                    name: "CARGOSEG",
                                    type: "STRING_ACUMULA",
                                    value: null,
                                    show: true,
                                    showName: "Cargo da segunda matrícula"
                                  },
                                  {
                                    name: "ORGAOSEG",
                                    type: "STRING_ACUMULA",
                                    value: null,
                                    show: true,
                                    showName: "Orgão da segunda matrícula"
                                  },
                                  {
                                    name: "DATAEXERCSEG",
                                    type: "DATE_ACUMULAVA",
                                    value: null,
                                    show: true,
                                    showName: "Data de exercício da segunda matrícula"
                                  },
                                  {
                                    name: "DATAAPOSETSEG",
                                    type: "DATE_ACUMULA",
                                    value: null,
                                    show: true,
                                    showName: "Data de aposentadoria da segunda matrícula"
                                  },
                                  {
                                    name: "DATAEXOSEG",
                                    type: "DATE_ACUMULAVA",
                                    value: null,
                                    show: true,
                                    showName: "Data de exoneração da segunda matrícula"
                                  },
                                  {
                                    name: "DATARENUNSEG",
                                    type: "DATE_ACUMULAVA",
                                    value: null,
                                    show: true,
                                    showName: "Data de renuncia da segunda matrícula"
                                  },
                                  {
                                    name: "NUMFUNC",
                                    type: "STRING",
                                    value: idFunc,
                                    show: false
                                  },
                                  {
                                    name: "NUMVINC",
                                    type: "STRING",
                                    value: idVinc,
                                    show: false
                                  },
                                  {
                                    name: "REQUERIMENTO_ID",
                                    type: "STRING",
                                    value: null,
                                    show: false
                                  }],
                                  reportShowName: "Termo de Acumulação"
                                };
            showParametersSelecionado(JSON.parse(JSON.stringify(reportParams)));
            }, errorHandle); 
        };
        
        $scope.getReportCertidaoSituacaoPrev = function (numfunc, numvinc, dtini, dtfim) {
          var reportName = "trpvrel0027";
            ReportService.getReport(reportName).then(function (result) {
                var reportParams = {
                                  reportName: reportName,
                                  parameters: 
                                  [{
                                    name: "PROCESSO",
                                    type: "STRING",
                                    value: null,
                                    show: true,
                                    showName: "Código do processo"
                                  },
                                  {
                                    name: "ORGAO",
                                    type: "STRING",
                                    value: null,
                                    show: true,
                                    showName: "Órgão"
                                  },
                                  {
                                    name: "NR_CSP",
                                    type: "STRING",
                                    value: null,
                                    show: true,
                                    showName: "Número da CSP"
                                  },
                                  {
                                    name: "NUMFUNC",
                                    type: "STRING",
                                    value: numfunc,
                                    show: false
                                  },
                                  {
                                    name: "NUMVINC",
                                    type: "STRING",
                                    value: numvinc,
                                    show: false
                                  },
                                  {
                                    name: "DTINI",
                                    type: "DATE",
                                    value: dtini,
                                    show: false
                                  },
                                  {
                                    name: "DTFIM",
                                    type: "DATE",
                                    value: dtfim,
                                    show: false
                                  }],
                                  reportShowName: "Certidão de Situação Previdenciária"
                                };
            showParametersSelecionado(JSON.parse(JSON.stringify(reportParams)));
            }, errorHandle);
        }
        
        
        $scope.getReportEspelhoSimulacao = function (simulacaoId, finalidade, tipoApos) {
            var reportName = "trpvrel0004";
                var reportParams = {
                  reportName: reportName,
                  parameters: 
                  [{
                    name: "NUM_INSS",
                    type: "STRING",
                    value: null,
                    show: true,
                    showName: "Número do ofício averbação INSS"
                  },
                  {
                    name: "DATA_INSS",
                    type: "DATE",
                    value: null,
                    show: true,
                    showName: "Data do ofício"
                  },
                  {
                    name: "CARGOS_SERV",
                    type: "STRING",
                    value: null,
                    show: true,
                    showName: "Acumulação de cargo declarada pelo servidor"
                  },
                  {
                    name: "CARGOS_DEPEC",
                    type: "STRING",
                    value: null,
                    show: true,
                    showName: "Acumulação de cargo - DEPEC"
                  },
                  {
                    name: "TIPO_APOS",
                    type: "STRING",
                    value: tipoApos,
                    show: false
                  },
                  {
                    name: "FINALIDADE",
                    type: "STRING",
                    value: finalidade,
                    show: false
                  },
                  {
                    name: "SIMULACAOID",
                    type: "STRING",
                    value: simulacaoId,
                    show: false
                  }],
                  reportShowName: "Espelho de Simulação"
                };
            showParametersSelecionado(JSON.parse(JSON.stringify(reportParams)));
        };
        
        $scope.getReportSimulacaoProventos = function (id, data){
          var _url = "";
          
          //ULTIMA REMUNERAÇÃO - 25
          if(data.tipoReajuste == "Paridade"){
            _url = "proventosUltimaRemuneracao?simulacaoId="+id+"&finalidade="+ data.finalidade +"&tipoApos="+ data.tipoAposentadoria;
          
          //MEDIA COM REDUTOR - 26 
          }else if(data.tipoCalculo == "Média" && data.finalidade == "APOS INT EC41 ART2"){
            _url = "proventosMediaRedutor?simulacaoId="+id+"&finalidade="+ data.finalidade +"&idFixacao="+ data.id;
          
          //MEDIA - 09
          }else{
            _url = "simulaCalculoIniProvento?simulacaoId="+id+"&finalidade="+ data.finalidade +"&idFixacao="+ data.id;
          }
          
          ReportService.getPDF(null,"api/ws/rest/ergon/v1.0/relatorios/relatorio/"+ _url).then(ReportService.openPDF, trataErro);
          
        };
        
        $scope.getReportMemoriaCalculo = function (id, data){
          var _url = "";
          
          //ULTIMA REMUNERAÇÃO - 22
          if(data.tipoReajuste == "Paridade"){
            _url = "calculoFixacaoUltimaRemuneracao?simulacaoId=" + id + "&finalidade=" + data.finalidade + "&tipoApos=" + data.tipoAposentadoria;
          
          //MEDIA COM REDUTOR - 23 
          }else if(data.tipoCalculo == "Média" && data.finalidade == "APOS INT EC41 ART2"){
            _url = "memoriaCalculoMediaRedutor?simulacaoId="+id+"&finalidade="+ data.finalidade +"&idFixacao="+ data.id + "&tipoapos=" + data.tipoAposentadoria;
          
          //MEDIA - 24
          }else{
            _url = "simulaCalculoFixacaoMedia?simulacaoId=" + id + "&finalidade=" + data.finalidade + "&idFixacao=" + data.id + "&tipoApos=" + data.tipoAposentadoria;
          }
          
          ReportService.getPDF(null,"api/ws/rest/ergon/v1.0/relatorios/relatorio/"+ _url).then(ReportService.openPDF, trataErro);
          
        };
        
        function showParametersSelecionado(report) {
            var parameters = report.parameters;
            
            var htmlParameters = [];

            var index = 0;
            
            function next() {
                if (index < parameters.length) {
                    var parameter = parameters[index++];
                    if (parameter.show) //verificando se o parâmetro está configurado para ser exibido na popup de parâmetros
                    {
                      var aux;
                      if (parameter.showName !== undefined)
                      {
                        aux = parameter.name;
                        parameter.name = parameter.showName;
                        parameter.showName = aux;
                      }
                      $.get("js/reports/templates/" + parameter.type + ".parameter.html").done(function (result) {
                        htmlParameters.push(replaceAll(result, "_field_", parameter.name));
                        next();
                      });
                    }
                    else
                    {
                      next();
                    }
                } else if (htmlParameters.length > 0) {
                    $modal.open({
                        templateUrl: 'js/reports/reports.parameters.html',
                        controller: 'ParameterController',
                        resolve: {
                            report: function () {
                              return JSON.parse(JSON.stringify(report));
                            },
                            htmlParameters: function () {
                              return JSON.parse(JSON.stringify(htmlParameters));
                            }
                        }
                    });
                }
            }
            
            next();
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
        
        function errorHandle(result) {
            if(result.status === 403)
            {
              Notification.error("Sem permissão de acesso para esse relatório.")
            }
            else
            {
              Notification.error("Erro na solicitação do relatório. Contate o suporte.")
            }
        }
        
        function trataErro(data) {
            //Tratamento unificado de erro de request HTTP
            var error = "";
            if (data) {
              if (Object.prototype.toString.call(data) === "[object String]") {
                error = data;
              } else {
                var enc = new TextDecoder();
                var errorMsg = enc.decode(data.data);
                if (errorMsg) {
                  error = errorMsg;
                }
              }
            }
            if (!error) {
              Notification.error()
              error = "Erro";
            }
            Notification.error(error);
          }
    }

})();
