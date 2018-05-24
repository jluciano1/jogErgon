(function ($app) {
    
    app.directive('chart', ['GenericService', '$http', '$rootScope', '$window', '$filter', 'Notification', function(GenericService, $http, $rootScope, $window, $filter, Notification){

      
      /************************
      
        Variáveis de contrução
      
      *************************/
      // Valores default
      
      //Estrutural
      var _backgroundColor          = [
          '#97BBCD', // blue
          '#F7464A', // red
          '#DCDCDC', // light grey
          '#46BFBD', // green
          '#FDB45C', // yellow
          '#949FB1', // grey
          '#4D5360'  // dark grey
        ];
      var _borderColor              = [
          '#97BBCD', // blue
          '#F7464A', // red
          '#DCDCDC', // light grey
          '#46BFBD', // green
          '#FDB45C', // yellow
          '#949FB1', // grey
          '#4D5360'  // dark grey
        ];
      var _borderWidth              = 1;
      
      var useExcanvas = typeof window.G_vmlCanvasManager === 'object' &&
        window.G_vmlCanvasManager !== null &&
        typeof window.G_vmlCanvasManager.initElement === 'function';
      
      function getRandomColor () {
          
        var color = [getRandomInt(0, 255), getRandomInt(0, 255), getRandomInt(0, 255)];
        return getColor(color);
      }

      function getColor (color) {
        return {
          backgroundColor: rgba(color, 0.6),
          pointBackgroundColor: rgba(color, 1),
          pointHoverBackgroundColor: rgba(color, 0.8),
          borderColor: rgba(color, 0.8),
          pointBorderColor: '#fff',
          pointHoverBorderColor: rgba(color, 1)
        };
      }
      
      function getRandomInt (min, max) {
        return Math.floor(Math.random() * (max - min + 1)) + min;
      }
  
      function rgba (color, alpha) {
        // rgba not supported by IE8
        return useExcanvas ? 'rgb(' + color.join(',') + ')' : 'rgba(' + color.concat(alpha).join(',') + ')';
      }
      
      //Componentes
      var _legend                   = {
                  display: true,
                  reverse: true,
                  position: 'right',
                  labels: {
                    boxWidth: 15,
                    usePointStyle: true
                  }
        };
        
      var _percentageTooltips       = {
              callbacks: {
                label: function(tooltipItem, data) {
                  var dataset = data.datasets[tooltipItem.datasetIndex];
                  var total = dataset.data.reduce(function(previousValue, currentValue, currentIndex, array) {
                    return previousValue + currentValue;
                  });
                  var currentValue = dataset.data[tooltipItem.index];
                  var precentage = Math.floor(((currentValue/total) * 100)+0.5);
                  return  data.labels[tooltipItem.index]+ " : " + precentage + "%";
                }
              }
      };
      
       var _monetaryTooltips       = {
              callbacks: {
                label: function(tooltipItem, data) {
                  var dataset = data.datasets[tooltipItem.datasetIndex];
                  return  data.labels[tooltipItem.index]+ " :  " + $filter('currency')(dataset.data[tooltipItem.index], 'R$');
                }
              }
      };
        
      //Animações
      
      //Animação de loading
      function loadingChart(name, isLoading){
        var elem = $("#"+name+"Chart");
        if(isLoading) 
          elem.css("opacity", "0.3");
        else
          elem.css("opacity", "1");
      }
      
      /************************
      
            AngularChart
      
      *************************/
      //Contrutor AngularChart
      function AngularChart(name, content){
        this.name = name;
        this.chartName =  name + "Chart";
         
        if(content.length > 0){
          this.datas = content.map(function(item){
            delete item.links;
            return item;
          });
          this.dtoAttrNames = Object.keys(this.datas[0]);
        }else if(content.length == 0){
          this.datas = [];
          this.dtoAttrNames = ['label', 'data', 'series'];
        }
        this.active = null;
      }
      
      AngularChart.prototype.splitForChart = function(attr){
        return this.datas.map(function(dto){
                return dto[attr];
              });
      }
      
           
      AngularChart.prototype.splitForChartWithSeries = function(attr){
        var v ;
        let unique;
          switch(attr){
            case 'series':
               
              v  = this.datas.map(function(dto){
                return dto['series'];
              });
                unique = [...new Set(v)];
                return unique;
              break;
               
            case 'label':
               
                v = this.datas.map(function(dto){
                return dto['label'];
              });
                unique = [...new Set(v)];
                return unique;
              break;
               
            case 'data':
                //Retorna o array list de series existentes
                v  = this.datas.map(function(dto){
                  return dto['series'];
                });
                //Retorna um array list sem repetição das series
                unique = [...new Set(v)];
                 
                //Ordena os dados pelo atributo label
                var datas = this.datas.sort(function(a,b){
                  return a.label.localeCompare(b.label);
                });
                 
                //Variáveis de controle
                var v = [];
                //Constroí um array
                for(i=0; i<unique.length; i++){
                  var s = [];
                  s = datas.filter(function(item){
                    return item.series == unique[i];
                  });
                  s = s.map(function(item){
                    return item.data;
                  });
                  
                  v.push({
                    series : unique[i],
                    data  : s 
                  });
                }
                return v; 
              
              break;
              
          }
      }//Fim função splitForChartWithSeries
      
      /************************
      
          Funções auxiliares
      
      *************************/
      //Função que verifica o atributo dependents-on, caso haja, verifica se há valores nos campos
      //retorna um booleano da verificação
      function verifyDependents($scope, $attrs){
        var controle = true;
        if(typeof($attrs.dependentsOn) !== 'undefined'){
          var dependents = $attrs.dependentsOn;
          try{
            dependents = JSON.parse(dependents);
            
            dependents.map(function(item){
              if(item === undefined || item === null || item == "" ){
                controle = false;
              }
            });
          }catch(error){
            console.error("Directive Chart error: \n Os valores dos dependentes devem estar em um vetor, mesmo que seja somente um valor");
          }
        }
        $scope[$attrs.name+"HasNoDependents"] = controle;
        return controle;
        
      }
      
      function confirm(text, downloadFunction, labelFiltro, seriesFiltro, fileName){
        $.prompt(text, {
          	buttons: { "Sim": true, "Não": false },
          	focus: 1,
          	zIndex: 9999,
          	opacity: 0.4,
          	submit: function(e,v,m,f){
          	  if(v)
          		  downloadFunction(fileName, labelFiltro, seriesFiltro);
          	}
          });
      }
      
      function returnDataset(data){
        if(typeof(data[0]) === "object"){
          return data.map(function(item, i){
            var dataset = {
              backgroundColor : _backgroundColor[i]
            }
            dataset.data = item.data;
            dataset.label = item.series;
            return dataset;
          });
        }else{
          var dataset = {
            backgroundColor : _backgroundColor,
            borderColor : _borderColor,
            borderWidth : _borderWidth,
            data : data
          }
          return [dataset];
        }
      }
      
      function builder($scope, $attrs,  angularChart){
        
        var clickPart = function (event, part){
              var chartController = $rootScope[this.options.chartController];
              var fileName = this.options.fileName;
               
              if(part.length >= 1){
                var labelFiltro = part[0]._view.label;
                var seriesFiltro = null, valorSeriesFiltro = null;
                
                if(part.length == 1){
                  seriesFiltro = part[0]._view.datasetLabel;
                  valorSeriesFiltro = chartController.data[part[0]._datasetIndex][part[0]._index];
                }
                
                if(part.length>1){
                  //Chart with series
                } 
                
                if((typeof(valorSeriesFiltro) === 'undefined' || valorSeriesFiltro === null) || valorSeriesFiltro > 0){
                  chartController.active = chartController.datas[part[0]._index];
                  //$rootScope.$digest();
                  
                  if(typeof($attrs.downloadPart) !== 'undefined'){
                    confirm('Deseja fazer o download ?', download, labelFiltro, seriesFiltro, (fileName || null));
                  }
                }
              }
          }//Fim função clickPart
          
        var download = function (fileName, labelFiltro, seriesFiltro){
                  var url;
                  var newFileName = "CONCESSÃO DE APOSENTADORIA.xlsx"; //Nome Padrão caso não seja especificado
                  
                  //Montagem do restpath para download
                  if(labelFiltro){
                    if($attrs.downloadLabelFilter && $attrs.downloadLabelFilter != ""){
                      url = $attrs.restEntity + $attrs.restDownload + $attrs.filter + $attrs.downloadLabelFilter + labelFiltro;
                      if(seriesFiltro){
                        if($attrs.downloadSerieFilter && $attrs.downloadSerieFilter != "")
                          url+=$attrs.downloadSerieFilter + seriesFiltro;
                        else
                          console.error("Directive Chart error: \n Não é possível fazer o download desta parte do gráfico, o atributo download-serie-filter não foi setado")
                      }
                      
                    }else
                      console.error("Directive Chart error: \n Não é possível fazer o download desta parte do gráfico, o atributo download-label-filter não foi setado")
                     
                    if(fileName)
                      newFileName = fileName +" - "+ labelFiltro + ".xlsx";
                  }else{
                    url = $attrs.restEntity + $attrs.restDownload + $attrs.filter;
                    if(fileName)
                      newFileName = fileName +".xlsx";
                  }
                  loadingChart($attrs.name, true);
                  //Execução do request
                  var request = $http({
                      method: 'GET',
                      url: (window.hostApp || "") + url,
                      responseType: 'arraybuffer'
                  }).success(function (response, status) {
                      
                      
                      if(status == 200){
                        var blob = new Blob([response],{type:"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"});
                        saveData(blob, newFileName, callback);
                        
                      }else if(status == 204){
                        Notification.warning({message: 'Nenhum conteúdo', delay: 3000})
                      }
                      
                      
                  }).error(function (response, status) {
                      callback(false, status);
                  });
      
              function callback(done, status, downloadError) {
                  if (done === true) {
                      Notification.success({message: 'Download efetuado com sucesso!', delay: 3000})
                  } else if (done === false) {
                      if(status == 500)
                          Notification.error({message: 'Erro interno', delay: 3000})
                      else if(downloadError)
                        Notification.error({message: 'Não foi possível realizar o download!', delay: 3000})
                      else
                        Notification.error({message: 'Erro durante a requisição', delay: 3000})
                  }
                  loadingChart($attrs.name, false);
              }
              //Função para download
              var saveData = (function () {
                    var a = document.createElement("a");
                    document.body.appendChild(a);
                    a.style = "display: none";
                    return function (blob, fileName, cb) {
                      try{
                        url = window.URL.createObjectURL(blob);
                        a.href = url;
                        a.download = fileName;
                        a.click();
                        cb(true);
                      }catch(e){
                        cb(false, null, true);
                      }
                        setTimeout(function(){
                            document.body.removeChild(a);
                            window.URL.revokeObjectURL(url);
                        }, 200);  
                    };
                }());
                
          };
        angularChart.download = download;

         var _chartElem = $("#"+$attrs.name+"Chart");
         
        //Valor default para o tipo do gráfico, caso não seja especificado
          var _chartType="pie";
          if(typeof($attrs.chartType) !== 'undefined' && $attrs.chartType.length > 0){
            _chartType=$attrs.chartType;
          }
          
          var _options = {
            chartController :   $attrs.name+"Chart",
            fileName        :   $attrs.fileName,
            responsive      :   true,
            onClick         :   clickPart
          }
          
          if(typeof($attrs.subtitled) !== 'undefined')
            _options.legend = _legend;
          
          if(typeof($attrs.percentage) !== 'undefined')
            _options.tooltips = _percentageTooltips;
          
          if(typeof($attrs.monetary) !== 'undefined')
            _options.tooltips = _monetaryTooltips;
          
          return new Chart(_chartElem, {
                type: _chartType,
                data: {
                    labels: angularChart.label,
                    datasets: returnDataset(angularChart.data)
                },
                options: _options
          });
            
      };
      
      //Função responsável pela contrução e manutenção do gráfico
      function build($scope, $attrs, content){
          var _chartElem = $("#"+$attrs.name+"Chart");
          
          var angularChart = new AngularChart($attrs.name, content);
          
          if(content.length > 0){
            //Se o gráfico possuí o atributo series
            if(angularChart.datas[0].hasOwnProperty('series') && angularChart.datas[0].series !== null){
              angularChart.dtoAttrNames.map(function(dtoAttr){
                angularChart[dtoAttr] = angularChart.splitForChartWithSeries(dtoAttr);
              });
            }else{
              angularChart.dtoAttrNames.map(function(dtoAttr){
                if(dtoAttr != 'series'){
                  angularChart[dtoAttr] = angularChart.splitForChart(dtoAttr); //Para cada atributo do DTO
                }
                }); 
            }
          }else{
            $scope["noContent"+angularChart.chartName] = true; 
          }
          
          //Necessário para remover o antigo gráfico
          if($rootScope.hasOwnProperty("object_"+angularChart.chartName))
            $rootScope["object_"+angularChart.chartName].destroy();
          
          if(!$scope["noContent"+angularChart.chartName]){
            $rootScope["object_"+angularChart.chartName] = builder($scope, $attrs, angularChart);
          }
          
          //Seta o chart no scope      
          $rootScope[angularChart.chartName] = angularChart;
           //Seta os dados do chart no scope
          //Nome do chart .data, utilizado no dir-paginate -> Ex: Funcionarios.data
           $rootScope[angularChart.name] = {};
           $rootScope[angularChart.name].data = angularChart.datas;
         
      }
      
      function getContent($scope, $attrs, restPath){
          loadingChart($attrs.name, true);
          $scope["noContent"+$attrs.name+"Chart"] = false;
          GenericService.getData(restPath).then(function(response){ 
              if(response.hasOwnProperty('content')){
                build($scope, $attrs, response.content);
              }else{
                build($scope, $attrs, response);
              } 
            loadingChart($attrs.name, false);
          });
      }
        
      //Retorno da diretiva
      return {
        restrict: 'E', 
        //Função para montar o template dinâmico do canvas
        template: function(elem, attr){
          
          //Verifica se há o atributo download-all, se tiver seta o botão de download de todos os dados do gráfico na template
          //Caso não esteja, somente seta o gráfico
          var downloadAllButton = "";
          if(typeof(attr.downloadAll) !== 'undefined'){
            var downloadFunction = attr.name+"Chart.download('"+attr.fileName+"')";
            downloadAllButton = ' <button type="button" '
                          +'  class="btn btn-sm  btn-primary pull-right" '
                          +'  ng-click="'+downloadFunction+'" tooltip="Download"> '
                          +'  <i class="glyphicon glyphicon-download-alt"></i> '
                          +'  </button>'
          }
          
          
          //Controla visualização da diretiva dependendos dos filtros obrigatórios 
          var hasNoDepedentsFlag = attr.name + "HasNoDependents";
          
          //Mensagem customizada para noContent
          var msgNoContent = "Não foram encontrados dados que atendam aos filtros informados";
          if(typeof(attr.onNoContent) !== "undefined" && attr.onNoContent !== null && attr.onNoContent != "")
            msgNoContent = attr.onNoContent;
          
          
          return ' <div ng-show="'+hasNoDepedentsFlag+'" ">'
                +' <canvas  id="'+attr.name+'Chart" ng-hide="noContent'+attr.name+'Chart"></canvas>'
                +  downloadAllButton
                + ' <div ng-show="noContent'+attr.name+'Chart" class="alert alert-warning" style="transition-duration: 5s;" role="alert"> '
                + '   <span class="glyphicon glyphicon-exclamation-sign" aria-hidden="true"></span> '
                + '   <span class="sr-only">Error: </span> '+msgNoContent+''
                + ' </div> '
                +' </div>';
        },
        transclude: 'element',
        replace: true,
        controller: function($scope, $attrs){
          //Declaração variaveis de escopo da diretiva
          $scope["noContent"+$attrs.name+"Chart"] = true;
          
          //Execução quando ocorre mudança no filtro 
          $attrs.$observe('filter', function(filterValue) {
            
              //Só é possível fazer o request caso os campos dependentes sejam preechidos
              if(verifyDependents($scope, $attrs)){
                var restPath = $attrs.restEntity + $attrs.restChart;
                if(typeof(filterValue) !== 'undefined' && filterValue !== null){
                  restPath += filterValue;
                }
                getContent($scope, $attrs, restPath);
              }
          });
          
        }
      };
    
    }]);
    
} (app));