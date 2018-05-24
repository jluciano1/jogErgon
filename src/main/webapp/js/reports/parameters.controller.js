(function () {
    'use strict';

    angular
        .module('custom.controllers')
        .controller('ParameterController', ParameterController)
        .filter('trusted', ['$sce', function ($sce) {
            return function (text) {
                return $sce.trustAsHtml(text);
            };
        }])
        .directive('compile', function ($compile, $timeout) {
            return {
                restrict: 'A',
                link: function (scope, elem) {
                    $timeout(function () {
                        $compile(elem.contents())(scope);
                    });
                }
            }
        })
        .directive("formatDate", function () {
            return {
                require: 'ngModel',
                link: function (scope, elem, attr, modelCtrl) {
                    modelCtrl.$formatters.push(function (modelValue) {
                        if (modelValue) {
                            return new Date(modelValue);
                        }
                        else {
                            return null;
                        }
                    });
                }
            };
        });

    ParameterController.$inject = ['$modalInstance', '$scope', 'ReportService', 'report', 'htmlParameters', 'Notification', '$rootScope'];

    function ParameterController($modalInstance, $scope, ReportService, report, htmlParameters, Notification, $rootScope) {
        $scope.acumulacao;
        $scope.report = report;

        $scope.htmlParameters = htmlParameters;

        $scope.configuraAcumula = function (acumulacao) {
          $scope.acumulacao = acumulacao;
          for (var i = 0; i < $scope.report.parameters.length; i++)
          {
            if ($scope.report.parameters[i].name !== "ACUMULACAO" && $scope.report.parameters[i].name !== "NUMFUNC" && $scope.report.parameters[i].name !== "NUMVINC")
            {
              $scope.report.parameters[i].value = null;
            }
          }
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
            var enc = new TextDecoder();
            Notification.error(enc.decode(result.data))
        }

        $scope.onPrint = function () {
            //variáveis para armazenar data em ms antes de ser convertida em Date
            var temp = [];
            var index = [];
            for (var i = 0; i < $scope.report.parameters.length; i++)
            {
              if($scope.report.parameters[i].type === "DATE")
              {
                //caso parâmetro do relatório seja do tipo data, é feita conversão de long ms para Date
                if ($scope.report.parameters[i].value !== null && $scope.report.parameters[i].value !== undefined)
                {
                  //armazenando informação da data antes de efetuar a conversão para Date
                  temp.push($scope.report.parameters[i].value);
                  index.push(i);
                  $scope.report.parameters[i].value = new Date($scope.report.parameters[i].value);
                }
              }
              if($scope.report.parameters[i].name === "REQUERIMENTO")
              {
                $scope.report.parameters[i].type = "STRING";
                if ($scope.$$childTail.$$childHead.todosSelect === 'S')
                {
                  $scope.report.parameters[i].value = null;
                }
                else
                {
                  $scope.report.parameters[i].value = SelectParametrizacaoDocumentos.active.idTipoRequerimento.id;
                }
              }
              if($scope.report.parameters[i].type === "STRING_ACUMULA")
              {
                $scope.report.parameters[i].type = "STRING";
              }
              if($scope.report.parameters[i].type === "DATE_ACUMULA" || $scope.report.parameters[i].type === "DATE_ACUMULAVA")
              {
                $scope.report.parameters[i].type = "DATE";
              }
              
              if($scope.report.parameters[i].name === "REQUERIMENTO_NOME")
              {
                $scope.report.parameters[i].type = "STRING";
                if ($scope.$$childTail.$$childHead.todosSelect === 'S')
                {
                  $scope.report.parameters[i].value = null;  
                }
                else
                {
                  $scope.report.parameters[i].value = SelectParametrizacaoDocumentos.active.idTipoRequerimento.tipoRequerimento;  
                }
              }
              if($scope.report.parameters[i].name === "ACUMULACAO")
              {
                $scope.report.parameters[i].type = "STRING";
                $scope.report.parameters[i].value = $scope.acumulacao;
              }
              
              if ($scope.report.parameters[i].showName !== undefined) //Caso o parâmetro tenha sido configurado com um nome para exibição
              {
                 var aux = $scope.report.parameters[i].name;
                 $scope.report.parameters[i].name = $scope.report.parameters[i].showName;
                 $scope.report.parameters[i].showName = aux;
              }
            }
            
            if(report.reportName === "trpvrel0004")
            {
              var params = {};
              for (var k = 0; k < $scope.report.parameters.length; k++)
              {
                if ($scope.report.parameters[k].name === "NUM_INSS")
                {
                  params.numInss = $scope.report.parameters[k].value;
                }
                else if ($scope.report.parameters[k].name === "DATA_INSS")
                {
                  if (!isNaN($scope.report.parameters[k].value))
                  {
                    if ($scope.report.parameters[k].value !== undefined && $scope.report.parameters[k].value !== null)
                    {
                      $scope.report.parameters[k].value.setDate($scope.report.parameters[k].value.getDate() + 1);
                      params.dataInss = $scope.report.parameters[k].value.getFullYear()  + "-" + ($scope.report.parameters[k].value.getMonth() + 1 < 10 ? "0" + ($scope.report.parameters[k].value.getMonth()+1) : ($scope.report.parameters[k].value.getMonth()+1)) + "-" + ($scope.report.parameters[k].value.getDate()); 
                    }
                  }
                }
                else if ($scope.report.parameters[k].name === "CARGOS_SERV")
                {
                  params.cargosServ = $scope.report.parameters[k].value;
                }
                else if ($scope.report.parameters[k].name === "CARGOS_DEPEC")
                {
                  params.cargosDepec = $scope.report.parameters[k].value;
                }
                else if ($scope.report.parameters[k].name === "FINALIDADE")
                {
                  params.finalidade = $scope.report.parameters[k].value;
                }
                else if ($scope.report.parameters[k].name === "TIPO_APOS")
                {
                  params.tipoApos = $scope.report.parameters[k].value;
                }
                else if ($scope.report.parameters[k].name === "SIMULACAOID")
                {
                  params.simulacaoId = $scope.report.parameters[k].value;
                }
              }
              ReportService.getPDF(params, "api/ws/rest/ergon/v1.0/relatorios/relatorio/espelhoSimulacao").then(openPDF, errorHandle); 
            }
            else if(report.reportName === "trpvrel0008")
            {
              var params = {};
              for (var k = 0; k < $scope.report.parameters.length; k++)
              {
                if ($scope.report.parameters[k].name === "ACUMULACAO")
                {
                  params.acumulacao = $scope.report.parameters[k].value;
                }
                else if ($scope.report.parameters[k].name === "SEGUNDAMATRICULA")
                {
                  params.segundaMatricula = $scope.report.parameters[k].value;
                }
                else if ($scope.report.parameters[k].name === "CARGOSEG")
                {
                  params.cargoSeg = $scope.report.parameters[k].value;
                }
                else if ($scope.report.parameters[k].name === "ORGAOSEG")
                {
                  params.orgaoSeg = $scope.report.parameters[k].value;
                }
                else if ($scope.report.parameters[k].name === "DATAEXERCSEG")
                {
                  if (typeof $scope.report.parameters[k].value === "string")
                  {
                    params.dataExerSeg = $scope.report.parameters[k].value;  
                  }
                  else
                  {
                    if (!isNaN($scope.report.parameters[k].value))
                    {
                      if ($scope.report.parameters[k].value !== null && $scope.report.parameters[k].value !== undefined)
                      {
                        $scope.report.parameters[k].value.setDate($scope.report.parameters[k].value.getDate() + 1);
                        params.dataExerSeg = $scope.report.parameters[k].value.getFullYear()  + "-" + ($scope.report.parameters[k].value.getMonth() + 1 < 10 ? "0" + ($scope.report.parameters[k].value.getMonth()+1) : ($scope.report.parameters[k].value.getMonth()+1)) + "-" + ($scope.report.parameters[k].value.getDate());
                      }  
                    }
                  }
                }
                else if ($scope.report.parameters[k].name === "DATAEXOSEG")
                {
                  if (typeof $scope.report.parameters[k].value === "string")
                  {
                    params.dataExoSeg = $scope.report.parameters[k].value;  
                  }
                  else
                  {
                    if (!isNaN($scope.report.parameters[k].value))
                    {
                      if ($scope.report.parameters[k].value !== null && $scope.report.parameters[k].value !== undefined)
                      {
                        $scope.report.parameters[k].value.setDate($scope.report.parameters[k].value.getDate() + 1);
                        params.dataExoSeg = $scope.report.parameters[k].value.getFullYear()  + "-" + ($scope.report.parameters[k].value.getMonth() + 1 < 10 ? "0" + ($scope.report.parameters[k].value.getMonth()+1) : ($scope.report.parameters[k].value.getMonth()+1)) + "-" + ($scope.report.parameters[k].value.getDate());
                      } 
                    }
                  }
                }
                else if ($scope.report.parameters[k].name === "DATARENUNSEG")
                {
                  if (typeof $scope.report.parameters[k].value === "string")
                  {
                    params.dataRenunSeg = $scope.report.parameters[k].value;  
                  }
                  else
                  {
                    if (!isNaN($scope.report.parameters[k].value))
                    {
                      if ($scope.report.parameters[k].value !== null && $scope.report.parameters[k].value !== undefined)
                      {
                        $scope.report.parameters[k].value.setDate($scope.report.parameters[k].value.getDate() + 1);
                        params.dataRenunSeg = $scope.report.parameters[k].value.getFullYear()  + "-" + ($scope.report.parameters[k].value.getMonth() + 1 < 10 ? "0" + ($scope.report.parameters[k].value.getMonth()+1) : ($scope.report.parameters[k].value.getMonth()+1)) + "-" + ($scope.report.parameters[k].value.getDate());
                      }  
                    }
                  }
                }
                else if ($scope.report.parameters[k].name === "DATAAPOSETSEG")
                {
                  if (typeof $scope.report.parameters[k].value === "string")
                  {
                    params.dataAposetSeg = $scope.report.parameters[k].value;  
                  }
                  else
                  {
                    if (!isNaN($scope.report.parameters[k].value))
                    {
                      if ($scope.report.parameters[k].value !== null && $scope.report.parameters[k].value !== undefined)
                      {
                        $scope.report.parameters[k].value.setDate($scope.report.parameters[k].value.getDate() + 1);
                        params.dataAposetSeg = $scope.report.parameters[k].value.getFullYear()  + "-" + ($scope.report.parameters[k].value.getMonth() + 1 < 10 ? "0" + ($scope.report.parameters[k].value.getMonth()+1) : ($scope.report.parameters[k].value.getMonth()+1)) + "-" + ($scope.report.parameters[k].value.getDate());
                      }  
                    }
                  }
                }
                else if ($scope.report.parameters[k].name === "NUMFUNC")
                {
                  params.numfunc = $scope.report.parameters[k].value;
                }
                else if ($scope.report.parameters[k].name === "NUMVINC")
                {
                  params.numvinc = $scope.report.parameters[k].value;
                }
                else if ($scope.report.parameters[k].name === "REQUERIMENTO_ID")
                {
                  params.requerimentoId = $scope.report.parameters[k].value;
                }
              }
              ReportService.getPDF(params, "api/ws/rest/ergon/v1.0/relatorios/relatorio/termoAcumulacao").then(openPDF, errorHandle); 
            }
            else if(report.reportName === "trpvrel0027")
            {
              var params = {};
              for (var k = 0; k < $scope.report.parameters.length; k++)
              {
                if ($scope.report.parameters[k].name === "PROCESSO")
                {
                  params.processo = $scope.report.parameters[k].value;
                }
                else if ($scope.report.parameters[k].name === "ORGAO")
                {
                  params.orgao = $scope.report.parameters[k].value;
                }
                else if ($scope.report.parameters[k].name === "NR_CSP")
                {
                  params.nrCsp = $scope.report.parameters[k].value;
                }
                else if ($scope.report.parameters[k].name === "NUMFUNC")
                {
                  params.numfunc = $scope.report.parameters[k].value;
                }
                else if ($scope.report.parameters[k].name === "NUMVINC")
                {
                  params.numvinc = $scope.report.parameters[k].value;
                }
                else if ($scope.report.parameters[k].name === "DTINI")
                {
                  $scope.report.parameters[k].value.setDate($scope.report.parameters[k].value.getDate() + 1);
                  params.dtini = $scope.report.parameters[k].value.getFullYear()  + "-" + ($scope.report.parameters[k].value.getMonth() + 1 < 10 ? "0" + ($scope.report.parameters[k].value.getMonth()+1) : ($scope.report.parameters[k].value.getMonth()+1)) + "-" + ($scope.report.parameters[k].value.getDate());
                }
                else if ($scope.report.parameters[k].name === "DTFIM")
                {
                  $scope.report.parameters[k].value.setDate($scope.report.parameters[k].value.getDate() + 1);
                  params.dtfim = $scope.report.parameters[k].value.getFullYear()  + "-" + ($scope.report.parameters[k].value.getMonth() + 1 < 10 ? "0" + ($scope.report.parameters[k].value.getMonth()+1) : ($scope.report.parameters[k].value.getMonth()+1)) + "-" + ($scope.report.parameters[k].value.getDate());
                }
              }
              ReportService.getPDF(params, "api/ws/rest/ergon/v1.0/relatorios/relatorio/certidaoSituacaoPrev").then(openPDF, errorHandle); 
            }
            else
            {
              ReportService.getPDFPost($scope.report).then(openPDF, errorHandle);  
            }
            
            for (i = 0; i < $scope.report.parameters.length; i++)
            {
              if ($scope.report.parameters[i].showName !== undefined) //altera o nome do parâmetro para o nome de exibição do mesmo
              {
                 aux = $scope.report.parameters[i].name;
                 $scope.report.parameters[i].name = $scope.report.parameters[i].showName;
                 $scope.report.parameters[i].showName = aux;
              }
            }
            //caso tenha sido efetuada a conversão para Date, retorna a Data selecionada para o valor antes da conversão
            if (temp.length > 0)
            {
              for (i = 0; i < index.length; i++)
              {
                $scope.report.parameters[index[i]].value = temp[i];
              }
            }
        };

        $scope.onCancel = function () {
            $modalInstance.dismiss('cancel');
        };
    }

})();