(function ($app) {
    
  /**
   * Função que retorna o formato que será utilizado no componente
   * capturando o valor do atributo format do elemento, para mais formatos
   * consulte os formatos permitidos em http://momentjs.com/docs/#/parsing/string-format/
   * 
   */
  var patternFormat = function(element){
    if(element){
      return $(element).attr('format') || 'DD/MM/YYYY';
    }
    return 'DD/MM/YYYY';
  }
  
  /**
   * Em todo elemento que possuir o atibuto as-date será 
   * aplicado o componente Datetimepicker (http://eonasdan.github.io/bootstrap-datetimepicker/)
   * 
   * O componente se adequa de acordo com o formato, definido através do atributo format
   * espeficado no elemento.
   * Para data simples use format="DD/MMM/YYYY", para data e hora use format="DD/MM/YYYY HH:mm:ss"
   * 
   * @see http://eonasdan.github.io/bootstrap-datetimepicker/
   */
  app.directive('asDateUnix', ['Notification','$timeout', '$filter', function(Notification, $timeout, $filter) {
      return {
          require: '^ngModel',
          restrict: 'A',
          link: function (scope, element, attrs, ngModel) {
            
              //var testeDate = new Date();
              //console.log($filter('utcDate')(testeDate));
              
              if(!ngModel){
                return;
              }
            
              // Desliga a atualização de modelo do Angular para todos os eventos exceto o evento de mudança de valor do datepicker
              // Adiciona um debounce de 200ms para assegurar que o datepicker já processou os eventos antes do angular começar seu parse
              var forcedOptions = {
                  updateOn: 'dp.change',
                  debounce: {'dp.change':200},
                  updateOnDefault: false
              };
              
              var modelOptions = {};
              if (attrs.ngModelOptions && attrs.ngModelOptions.length > 0)
              modelOptions = scope.$eval('('+attrs.ngModelOptions+')') || {};
              modelOptions = Object.assign(modelOptions, forcedOptions);
                
              ngModel.$$setOptions(modelOptions);
              
              var format = patternFormat(element);
              
              var options = {
                format: format,
                locale : moment.locale(),
                showTodayButton: true,
                useStrict: true,
                useCurrent: false,
                showClear:  true,
                minDate: moment('01/01/1900', 'DD/MM/YYYY', true),
                maxDate: moment('31/12/2999', 'DD/MM/YYYY', true),
                keepInvalid: true,
                //remove o keybind padrão da letra T para a data atual
                keyBinds: {
                  t:null
                },
                tooltips: {
                  today: 'Hoje',
                  clear: 'Limpar seleção',
                  close: 'Fechar',
                  selectMonth: 'Selecionar mês',
                  prevMonth: 'Mês anterior',
                  nextMonth: 'Próximo mês',
                  selectYear: 'Selecionar ano',
                  prevYear: 'Ano anterior',
                  nextYear: 'Próximo ano',
                  selectDecade: 'Selecionar década',
                  prevDecade: 'Década anterior',
                  nextDecade: 'Próxima década',
                  prevCentury: 'Século anterior',
                  nextCentury: 'Próximo século'
                }
              };
              
              if(format != 'DD/MM/YYYY'){
                options.sideBySide = true;
              }
              
              element.datetimepicker(options);
              
              element.on('dp.change', function() {
                //console.log('::> EVENT: dp.change [ngModel.$viewValue == '+ngModel.$viewValue+'  ; ngModel.$modelValue == '+ngModel.$modelValue+'  ; element.val() == '+element.val()+' ; element.date() == '+element.data("DateTimePicker").date()+']');
                if(validaIntervalo(this)) {
                  scope.$apply(read);
                  
                } else {
                  scope.$apply(function() {
                    ngModel.$setViewValue(restoreFromModel(),'dp.change');
                  });
                }
                //console.log('<:: EVENT: dp.change [ngModel.$viewValue == '+ngModel.$viewValue+'  ; ngModel.$modelValue == '+ngModel.$modelValue+'  ; element.val() == '+element.val()+' ; element.date() == '+element.data("DateTimePicker").date()+']');
              });
              
              element.on('dp.error', function() {
                //console.log('::> EVENT: dp.error [ngModel.$viewValue == '+ngModel.$viewValue+'  ; ngModel.$modelValue == '+ngModel.$modelValue+'  ; element.val() == '+element.val()+' ; element.date() == '+element.data("DateTimePicker").date()+']');
                // Tenta um parse em forgiving mode se o parse padrão em strict falhou
                scope.$apply(insist());
                //console.log('<:: EVENT: dp.error [ngModel.$viewValue == '+ngModel.$viewValue+'  ; ngModel.$modelValue == '+ngModel.$modelValue+'  ; element.val() == '+element.val()+' ; element.date() == '+element.data("DateTimePicker").date()+']');
              });
              
              element.on('clear', function() {
                element.data("DateTimePicker").hide();
              })
              
              ngModel.$formatters.unshift(function(value) {
                //console.log('::> FORMATTER [value='+value+']');
                if(value) {
                  try {
                    var dateInMilliseconds = parseInt(value, 10);
                    var localDate = new Date(dateInMilliseconds);
                    var momentDate = moment($filter('utcDate')(localDate));
                    if(momentDate.isValid()) {
                      value = momentDate.format(patternFormat(element));
                    } 
                  } catch (e) {
                    console.log(e);
                  }
                }
                if (!value || typeof(value)==="undefined") {
                  if (element.data("DateTimePicker").date()) {
                    $timeout(function() { element.data("DateTimePicker").date(null); }, 0);
                  }
                } else {
                  if (!element.data("DateTimePicker").date() || moment(element.data("DateTimePicker").date(),patternFormat(element)).format(patternFormat(element))!==value) {
                    if (typeof(value)==="string") {
                      $timeout(function() { element.data("DateTimePicker").date(value,patternFormat(element)); },0);
                    } else {
                      $timeout(function() { element.data("DateTimePicker").date(value); }, 0);
                    }
                  }
                }
                //console.log('<:: FORMATTER [value == '+value+']');
                return value;
              });
              
              ngModel.$parsers.unshift(function(viewValue) {
                //console.log('====> PARSER [viewValue='+viewValue+' ; ngModel.$viewValue == '+ngModel.$viewValue+' ; ngModel.$modelValue == '+ngModel.$modelValue+']');
                
                var returnValue = viewValue;
                if (viewValue && viewValue!=="") {
                  try {
                    var momentDate = moment(viewValue, patternFormat(element));
                    if (!momentDate.isValid()) { // Tenta usar validação não-estrita caso a estrita falhe
                      if (patternFormat(element)=='DD/MM/YYYY') {
                        momentDate = moment(viewValue, ['DD/MM/YY','D/M/Y','DD/MM','D/M','MM/YY','M/Y','DD','D']);
                      } else if (patternFormat(element)=='MM/YYYY') {
                        momentDate = moment(viewValue, ['DD/MM/YY','D/M/Y','MM/YYYY','MM/YY','M/Y']);
                      } else {
                        momentDate = moment(viewValue, patternFormat(element), false);
                      }
                    }
                    
                    if (momentDate.isValid()) {
                      if (element.val()!==momentDate.format(patternFormat(element))) {
                        $timeout(function() { element.data("DateTimePicker").date(momentDate); },0);
                      }
                      
                      momentDate = $filter('utcDate')(momentDate.toDate())
                      returnValue = Date.parse(momentDate);
                      
                    } else {
                      Notification.warning({
                        message: 'A data informada "'+viewValue+'" não corresponde a uma data válida', 
                        title: 'Data inválida', 
                        delay: 5000
                      });
                      returnValue = restoreFromModel();
                    }
                  } catch (e) {
                    console.log(e);
                    element.val('');
                    returnValue = null;
                  }
                } 
                //console.log('<==== PARSER [returnValue == '+returnValue+' ; ngModel.$viewValue == '+ngModel.$viewValue+' ; ngModel.$modelValue == '+ngModel.$modelValue+']');
                return returnValue;
              });
  
              function insist() {
                $timeout(function(){
                  //console.log('-------> insist() [ngModel.$viewValue == '+ngModel.$viewValue+'  ; ngModel.$modelValue == '+ngModel.$modelValue+'  ; element.val() == '+element.val()+' ; element.date() == '+element.data("DateTimePicker").date()+']');
                  var value = element.val() || '';
                  if (value) {
                    if (patternFormat(element)=='DD/MM/YYYY') {
                      flexibleMomentDate = moment(value, ['DD/MM/YY','D/M/Y','DD/MM','D/M','MM/YY','M/Y','DD','D']);
                    } else if (patternFormat(element)=='MM/YYYY') {
                      flexibleMomentDate = moment(value, ['DD/MM/YY','D/M/Y','MM/YYYY','MM/YY','M/Y']);
                    } else {
                      flexibleMomentDate = moment(value, patternFormat(element), false);
                    }
                    if (typeof(flexibleMomentDate)!=="undefined" && flexibleMomentDate.isValid()) {
                      // Força um evento dp.change
                      element.data("DateTimePicker").date(flexibleMomentDate.toDate());
                    } else {
                      // Força a remoção de valores inválidos que teriam permanecido por causa do parâmetro keepInvalid
                      Notification.warning({
                        message: 'A data informada "'+value+'" não corresponde a uma data válida', 
                        title: 'Data inválida', 
                        delay: 5000
                      });
                      ngModel.$setViewValue(restoreFromModel(),'dp.change');
                    }
                  }
                  //console.log('<------- insist() [ngModel.$viewValue == '+ngModel.$viewValue+'  ; ngModel.$modelValue == '+ngModel.$modelValue+'  ; element.val() == '+element.val()+' ; element.date() == '+element.data("DateTimePicker").date()+']');
                }, 0);
              }
  
              function read() {
                  //console.log('-------> read() [ngModel.$viewValue == '+ngModel.$viewValue+'  ; ngModel.$modelValue == '+ngModel.$modelValue+'  ; element.val() == '+element.val()+' ; element.date() == '+element.data("DateTimePicker").date()+']');
                  var value = element.val() || '';
                  if (value==='')
                     ngModel.$setViewValue('','dp.change');
                  else {
                    var momentDate = moment.parseZone(value, patternFormat(element));
                    if (momentDate.isValid())
                      ngModel.$setViewValue(momentDate.format(patternFormat(element)),'dp.change');
                    else {
                      Notification.warning({
                        message: 'A data informada "'+value+'" não corresponde a uma data válida', 
                        title: 'Data inválida', 
                        delay: 5000
                      });
                      element.val('');
                      ngModel.$setViewValue('','dp.change');
                    }
                  }
                  //console.log('<------- read() [ngModel.$viewValue == '+ngModel.$viewValue+'  ; ngModel.$modelValue == '+ngModel.$modelValue+'  ; element.val() == '+element.val()+' ; element.date() == '+element.data("DateTimePicker").date()+']');
              }
              
              function restoreFromModel() {
                //console.log('-------> restoreFromModel() [ngModel.$viewValue == '+ngModel.$viewValue+'  ; ngModel.$modelValue == '+ngModel.$modelValue+'  ; element.val() == '+element.val()+' ; element.date() == '+element.data("DateTimePicker").date()+']');
                var returnValue = ngModel.$modelValue || null;
                if (returnValue) {
                  var momentDate = moment(parseInt(returnValue,10));
                  if (momentDate.isValid())
                    returnValue = momentDate.format(patternFormat(element));
                  else
                    returnValue = '';
                } else {
                  returnValue = '';
                }
                element.val(returnValue);
                //console.log('<------- restoreFromModel() [ngModel.$viewValue == '+ngModel.$viewValue+'  ; ngModel.$modelValue == '+ngModel.$modelValue+'  ; element.val() == '+element.val()+' ; element.date() == '+element.data("DateTimePicker").date()+']');
                return returnValue;
              }

              function validaIntervalo(dataAValidar) {
                
                var value = element.val() || '';
                if (value==='')
                  return true;
                var momentDate = moment(value, patternFormat(element));
                if(momentDate.isValid()) {
                  try {
                    for (i=0;i<dataAValidar.attributes.length;i++) {
                      if((dataAValidar.attributes[i].nodeName == "compare-greater-than") || (dataAValidar.attributes[i].nodeName == "compare-less-than")){
                        var dt2   = parseInt(($("#"+dataAValidar.attributes[i].nodeValue).val()).substring(0,2));
                        var mon2  = parseInt(($("#"+dataAValidar.attributes[i].nodeValue).val()).substring(3,5));
                        var yr2   = parseInt(($("#"+dataAValidar.attributes[i].nodeValue).val()).substring(6,10));
                        var date2 = new Date(yr2, mon2-1, dt2);
            
                        var dt1   = parseInt((dataAValidar.value).substring(0,2));
                        var mon1  = parseInt((dataAValidar.value).substring(3,5));
                        var yr1   = parseInt((dataAValidar.value).substring(6,10));
                        var date1 = new Date(yr1, mon1-1, dt1);

                        if ( date1 === undefined || date1 === "" || date2 === undefined || date2 === ""){
                          return true;
                        } else if ((date1 > date2 && dataAValidar.attributes[i].nodeName == "compare-greater-than") || (date1 < date2 && dataAValidar.attributes[i].nodeName == "compare-less-than")){
                          Notification.warning({
                            message: 'A data inicial do período informado não pode ser posterior à data final', 
                            title: 'Erro de intervalo de datas', 
                            delay: 5000
                          });
                          return false;
                        }
                      }
                    }
                  } catch (e) {
                    console.log(e);
                  }
                  return true;
                }
              }
  
              scope.clearDatePickerIfTrue = function(expr) {
                  if (expr){
                    element.val('');
                    ngModel.$setViewValue('','dp.change');
                  }
              }
          }
      };
  }])
  
  // alterar para string (0056)
  app.directive('asDateString', ['Notification','$timeout', '$filter', function(Notification, $timeout, $filter) {
      return {
          require: '^ngModel',
          restrict: 'A',
          link: function (scope, element, attrs, ngModel) {
            
              //var testeDate = new Date();
              //console.log($filter('utcDate')(testeDate));
              
              if(!ngModel){
                return;
              }
            
              // Desliga a atualização de modelo do Angular para todos os eventos exceto o evento de mudança de valor do datepicker
              // Adiciona um debounce de 200ms para assegurar que o datepicker já processou os eventos antes do angular começar seu parse
              var forcedOptions = {
                  updateOn: 'dp.change',
                  debounce: {'dp.change':200},
                  updateOnDefault: false
              };
              
              var modelOptions = {};
              if (attrs.ngModelOptions && attrs.ngModelOptions.length > 0)
              modelOptions = eval('('+attrs.ngModelOptions+')') || {};
              modelOptions = Object.assign(modelOptions, forcedOptions);
                
              ngModel.$$setOptions(modelOptions);
              
              var format = patternFormat(element);
              
              var options = {
                format: format,
                locale : moment.locale(),
                showTodayButton: true,
                useStrict: true,
                useCurrent: false,
                showClear:  true,
                minDate: moment('01/01/1900', 'DD/MM/YYYY', true),
                maxDate: moment('31/12/2999', 'DD/MM/YYYY', true),
                keepInvalid: true,
                //remove o keybind padrão da letra T para a data atual
                keyBinds: {
                  t:null
                },
                tooltips: {
                  today: 'Hoje',
                  clear: 'Limpar seleção',
                  close: 'Fechar',
                  selectMonth: 'Selecionar mês',
                  prevMonth: 'Mês anterior',
                  nextMonth: 'Próximo mês',
                  selectYear: 'Selecionar ano',
                  prevYear: 'Ano anterior',
                  nextYear: 'Próximo ano',
                  selectDecade: 'Selecionar década',
                  prevDecade: 'Década anterior',
                  nextDecade: 'Próxima década',
                  prevCentury: 'Século anterior',
                  nextCentury: 'Próximo século'
                }
              };
              
              if(format != 'DD/MM/YYYY'){
                options.sideBySide = true;
              }
              
              element.datetimepicker(options);
              
              element.on('dp.change', function() {
                //console.log('::> EVENT: dp.change [ngModel.$viewValue == '+ngModel.$viewValue+'  ; ngModel.$modelValue == '+ngModel.$modelValue+'  ; element.val() == '+element.val()+' ; element.date() == '+element.data("DateTimePicker").date()+']');
                if(validaIntervalo(this)) {
                  scope.$apply(read);
                  
                } else {
                  scope.$apply(function() {
                    ngModel.$setViewValue(restoreFromModel(),'dp.change');
                  });
                }
                //console.log('<:: EVENT: dp.change [ngModel.$viewValue == '+ngModel.$viewValue+'  ; ngModel.$modelValue == '+ngModel.$modelValue+'  ; element.val() == '+element.val()+' ; element.date() == '+element.data("DateTimePicker").date()+']');
              });
              
              element.on('dp.error', function() {
                //console.log('::> EVENT: dp.error [ngModel.$viewValue == '+ngModel.$viewValue+'  ; ngModel.$modelValue == '+ngModel.$modelValue+'  ; element.val() == '+element.val()+' ; element.date() == '+element.data("DateTimePicker").date()+']');
                // Tenta um parse em forgiving mode se o parse padrão em strict falhou
                scope.$apply(insist());
                //console.log('<:: EVENT: dp.error [ngModel.$viewValue == '+ngModel.$viewValue+'  ; ngModel.$modelValue == '+ngModel.$modelValue+'  ; element.val() == '+element.val()+' ; element.date() == '+element.data("DateTimePicker").date()+']');
              });
              
              element.on('clear', function() {
                element.data("DateTimePicker").hide();
              })
              
              ngModel.$formatters.unshift(function(value) {
                //console.log('::> FORMATTER [value='+value+']');
                if(value) {
                  try {
                    var dateInMilliseconds = parseInt(value, 10);
                    var localDate = new Date(dateInMilliseconds);
                    var momentDate = moment($filter('utcDate')(localDate));
                    if(momentDate.isValid()) {
                      value = momentDate.format(patternFormat(element));
                    } 
                  } catch (e) {
                    console.log(e);
                  }
                }
                if (!value || typeof(value)==="undefined") {
                  if (element.data("DateTimePicker").date()) {
                    $timeout(function() { element.data("DateTimePicker").date(null); }, 0);
                  }
                } else {
                  if (!element.data("DateTimePicker").date() || moment(element.data("DateTimePicker").date(),patternFormat(element)).format(patternFormat(element))!==value) {
                    if (typeof(value)==="string") {
                      $timeout(function() { element.data("DateTimePicker").date(value,patternFormat(element)); },0);
                    } else {
                      $timeout(function() { element.data("DateTimePicker").date(value); }, 0);
                    }
                  }
                }
                //console.log('<:: FORMATTER [value == '+value+']');
                return value;
              });
              
              
              // alterado para as date receber valor da view e devolver o mesmo valor string
              ngModel.$parsers.unshift(function(viewValue) {
                
                //console.log('====> PARSER [viewValue='+viewValue+' ; ngModel.$viewValue == '+ngModel.$viewValue+' ; ngModel.$modelValue == '+ngModel.$modelValue+']');
                
                var returnValue = viewValue;
                
                //console.log('<==== PARSER [returnValue == '+returnValue+' ; ngModel.$viewValue == '+ngModel.$viewValue+' ; ngModel.$modelValue == '+ngModel.$modelValue+']');
                return returnValue;
              });
  
              function insist() {
                $timeout(function(){
                  //console.log('-------> insist() [ngModel.$viewValue == '+ngModel.$viewValue+'  ; ngModel.$modelValue == '+ngModel.$modelValue+'  ; element.val() == '+element.val()+' ; element.date() == '+element.data("DateTimePicker").date()+']');
                  var value = element.val() || '';
                  if (value) {
                    if (patternFormat(element)=='DD/MM/YYYY') {
                      flexibleMomentDate = moment(value, ['DD/MM/YY','D/M/Y','DD/MM','D/M','MM/YY','M/Y','DD','D']);
                    } else if (patternFormat(element)=='MM/YYYY') {
                      flexibleMomentDate = moment(value, ['DD/MM/YY','D/M/Y','MM/YYYY','MM/YY','M/Y']);
                    } else {
                      flexibleMomentDate = moment(value, patternFormat(element), false);
                    }
                    if (typeof(flexibleMomentDate)!=="undefined" && flexibleMomentDate.isValid()) {
                      // Força um evento dp.change
                      element.data("DateTimePicker").date(flexibleMomentDate.toDate());
                    } else {
                      // Força a remoção de valores inválidos que teriam permanecido por causa do parâmetro keepInvalid
                      Notification.warning({
                        message: 'A data informada "'+value+'" não corresponde a uma data válida', 
                        title: 'Data inválida', 
                        delay: 5000
                      });
                      ngModel.$setViewValue(restoreFromModel(),'dp.change');
                    }
                  }
                  //console.log('<------- insist() [ngModel.$viewValue == '+ngModel.$viewValue+'  ; ngModel.$modelValue == '+ngModel.$modelValue+'  ; element.val() == '+element.val()+' ; element.date() == '+element.data("DateTimePicker").date()+']');
                }, 0);
              }
  
              function read() {
                  //console.log('-------> read() [ngModel.$viewValue == '+ngModel.$viewValue+'  ; ngModel.$modelValue == '+ngModel.$modelValue+'  ; element.val() == '+element.val()+' ; element.date() == '+element.data("DateTimePicker").date()+']');
                  var value = element.val() || '';
                  if (value==='')
                     ngModel.$setViewValue('','dp.change');
                  else {
                    var momentDate = moment.parseZone(value, patternFormat(element));
                    if (momentDate.isValid())
                      ngModel.$setViewValue(momentDate.format(patternFormat(element)),'dp.change');
                    else {
                      Notification.warning({
                        message: 'A data informada "'+value+'" não corresponde a uma data válida', 
                        title: 'Data inválida', 
                        delay: 5000
                      });
                      element.val('');
                      ngModel.$setViewValue('','dp.change');
                    }
                  }
                  //console.log('<------- read() [ngModel.$viewValue == '+ngModel.$viewValue+'  ; ngModel.$modelValue == '+ngModel.$modelValue+'  ; element.val() == '+element.val()+' ; element.date() == '+element.data("DateTimePicker").date()+']');
              }
              
              function restoreFromModel() {
                //console.log('-------> restoreFromModel() [ngModel.$viewValue == '+ngModel.$viewValue+'  ; ngModel.$modelValue == '+ngModel.$modelValue+'  ; element.val() == '+element.val()+' ; element.date() == '+element.data("DateTimePicker").date()+']');
                var returnValue = ngModel.$modelValue || null;
                if (returnValue) {
                  var momentDate = moment(parseInt(returnValue,10));
                  if (momentDate.isValid())
                    returnValue = momentDate.format(patternFormat(element));
                  else
                    returnValue = '';
                } else {
                  returnValue = '';
                }
                element.val(returnValue);
                //console.log('<------- restoreFromModel() [ngModel.$viewValue == '+ngModel.$viewValue+'  ; ngModel.$modelValue == '+ngModel.$modelValue+'  ; element.val() == '+element.val()+' ; element.date() == '+element.data("DateTimePicker").date()+']');
                return returnValue;
              }

              function validaIntervalo(dataAValidar) {
                
                var value = element.val() || '';
                if (value==='')
                  return true;
                var momentDate = moment(value, patternFormat(element));
                if(momentDate.isValid()) {
                  try {
                    for (i=0;i<dataAValidar.attributes.length;i++) {
                      if((dataAValidar.attributes[i].nodeName == "compare-greater-than") || (dataAValidar.attributes[i].nodeName == "compare-less-than")){
                        var dt2   = parseInt(($("#"+dataAValidar.attributes[i].nodeValue).val()).substring(0,2));
                        var mon2  = parseInt(($("#"+dataAValidar.attributes[i].nodeValue).val()).substring(3,5));
                        var yr2   = parseInt(($("#"+dataAValidar.attributes[i].nodeValue).val()).substring(6,10));
                        var date2 = new Date(yr2, mon2-1, dt2);
            
                        var dt1   = parseInt((dataAValidar.value).substring(0,2));
                        var mon1  = parseInt((dataAValidar.value).substring(3,5));
                        var yr1   = parseInt((dataAValidar.value).substring(6,10));
                        var date1 = new Date(yr1, mon1-1, dt1);

                        if ( date1 === undefined || date1 === "" || date2 === undefined || date2 === ""){
                          return true;
                        } else if ((date1 > date2 && dataAValidar.attributes[i].nodeName == "compare-greater-than") || (date1 < date2 && dataAValidar.attributes[i].nodeName == "compare-less-than")){
                          Notification.warning({
                            message: 'A data inicial do período informado não pode ser posterior à data final', 
                            title: 'Erro de intervalo de datas', 
                            delay: 5000
                          });
                          return false;
                        }
                      }
                    }
                  } catch (e) {
                    console.log(e);
                  }
                  return true;
                }
              }
  
              scope.clearDatePickerIfTrue = function(expr) {
                  if (expr){
                    element.val('');
                    ngModel.$setViewValue('','dp.change');
                  }
              }
          }
      };
  }])
  
  
  .directive('pwCheck', [function () { 'use strict';
    return {
      require: 'ngModel',
      link: function (scope, elem, attrs, ctrl) {
      var firstPassword = '#' + attrs.pwCheck;
      elem.add(firstPassword).on('keyup', function () {
        scope.$apply(function () {
          var v = elem.val()===$(firstPassword).val();
          ctrl.$setValidity('pwmatch', v);
        });
      });
      }
    }
  }])
  
  app.directive('dataHoje', function() {
    return {
      restrict: 'AEC',
      //template: new Date().toLocaleDateString()
      template: moment().locale('pt-BR').format('dddd, LL')
    };
  });
  
  //Atributo para validação de intervalos de datas em campos de forms AngularJS
  app.directive('validaDataMenorQue', ['$timeout', function($timeout) {
    return {
      restrict: 'A',
      require: ['ngModel','^?form'],
      link: function(scope, elem, attr, ctrl) {
        var ngModel = ctrl[0];
        var form = ctrl[1];
        var referencedField = attr.validaDataMenorQue;
        var outraPonta = {};
          
        //Chama o código de dentro de um timeout para garantir que só será executado após o término da renderização do DOM
        $timeout(function() {
            
          if (referencedField && typeof(referencedField)!=='undefined') {
            angular.forEach(form, function(value, key) {
              if (key===referencedField) {
                outraPonta = value;
                return;
              }
            })
          }

          if (outraPonta && typeof(outraPonta)==='object' && outraPonta.hasOwnProperty('$modelValue')) {
            ngModel.$validators.interval = function(modelValue) {
              if (modelValue && typeof(modelValue) !== "undefined" && modelValue !== '') {
                var terminoIntervalo = outraPonta.$modelValue;
                if (terminoIntervalo && typeof(terminoIntervalo) !== "undefined" && terminoIntervalo !== '' && terminoIntervalo < modelValue) {
                  return false;
                } else {
                  //ao validar uma ponta, valida também a outra caso a mesma esteja inválida
                  if (outraPonta.$error.interval)
                    outraPonta.$setValidity('interval',true);
                  return true;
                }
              } else {
                return true;
              }
            };
          }
            
        });
      }
    }
  }]);
    
  app.directive('validaDataMaiorQue', ['$timeout', function($timeout) {
    return {
      restrict: 'A',
      require: ['ngModel','^?form'],
      link: function(scope, elem, attr, ctrl) {
        var ngModel = ctrl[0];
        var form = ctrl[1];
        var referencedField = attr.validaDataMaiorQue;
        var outraPonta = {};
        
        //Chama o código de dentro de um timeout para garantir que só será executado após o término da renderização do DOM
        $timeout(function() {
          
          if (referencedField && typeof(referencedField)!=='undefined') {
            angular.forEach(form, function(value, key) {
              if (key===referencedField) {
                outraPonta = value;
                return;
              }
            })
          }
        
          if (outraPonta && typeof(outraPonta)==='object' && outraPonta.hasOwnProperty('$modelValue')) {
            ngModel.$validators.interval = function(modelValue) {
              if (modelValue && typeof(modelValue) !== "undefined" && modelValue !== '') {
                var inicioIntervalo = outraPonta.$modelValue;
                if (inicioIntervalo && typeof(inicioIntervalo) !== "undefined" && inicioIntervalo !== '' && inicioIntervalo > modelValue) {
                  return false;
                } else {
                  //ao validar uma ponta, valida também a outra caso a mesma esteja inválida
                  if (outraPonta.$error.interval)
                    outraPonta.$setValidity('interval',true);
                  return true;
                }
              } else {
                return true;
              }
            };
          }
          
        });
      }
    }
  }]);
  
  // diretiva que aceita somente valores númericos 
  app.directive('numericOnly', function(){
    return {
        require: 'ngModel',
        link: function(scope, element, attrs, modelCtrl) {

            modelCtrl.$parsers.push(function (inputValue) {
                var transformedInput = inputValue ? inputValue.replace(/[^\d.-]/g,'') : null;

                if (transformedInput!=inputValue) {
                    modelCtrl.$setViewValue(transformedInput);
                    modelCtrl.$render();
                }

                return transformedInput;
            });
        }
    };
  });
  
  //Diretiva para abrir uma caixa de dialogo confirmando ou não uma exclusão de registro. Utilizado ao remover os datasources das paginas.
  app.directive('ngConfirmaDelecao', [
    function(){
        return {
            priority: 1,
            terminal: true,
            link: function (scope, element, attr) {
                var msg = attr.ngConfirmClick || "Deseja realmente excluir este registro?";
                var clickAction = attr.ngClick;
                element.bind('click',function (event) {
                    $.prompt("Deseja remover?", {
                    	buttons: { "Ok": true, "Cancel": false },
                    	focus: 1,
                    	zIndex: 9999,
                    	opacity: 0.4,
                    	submit: function(e,v,m,f){
                    		if(v){
                          scope.$eval(clickAction);  
                    		}
                    	}
                    });
                });
            }
        };
  }]);

  
  //Atributo para formatar inputs que recebem valores numéricos inteiros ou decimais com mantissa variável
  app.directive('asFloat', ['$locale', function($locale) {
      return {
        resrtict: 'A',
        require: 'ngModel',
        link: function(scope, element, attrs, ngModelCtrl) {
          
          // Identifica o separador decimal localizado e cria máscara regex
          var decimalSeparator = $locale.NUMBER_FORMATS.DECIMAL_SEP;
          var localizedSeparatorMask = "\\" + decimalSeparator;
          var localizedSeparator = new RegExp(localizedSeparatorMask, "g");
          
          // Inicializa array de escopo da diretiva para armazenar as partes integral e fracionária do valor informado
          scope.in = '';//[];
          scope.fr = '';//[];
          //scope.dp = -1;
          
          // inicializa precisão e escala com valores padrão
          var _p = 15; // Precision
          var _s = 2;  // Scale
          
          // lê escala e precisão informados na diretiva
          if (attrs.hasOwnProperty('asFloat') && attrs.asFloat!=="") {
            var params = attrs.asFloat.replace(/^\(|\)$/gm, '').split(',');
            if (params && params.length > 0) {
              var p = scope.$eval(params[0]);
              if (typeof(p)==='number')
                _p = Math.max(0,p);
              if (params.length > 1) {
                var s = scope.$eval(params[1]);
                if (typeof(s)==='number') {
                  _s = Math.max(1,Math.min(16,s)); // limita à precisão máxima de ponto flutuante do JavaScript e mínima de 1 (não usar asFloat para campos sem escalar)
                } else {
                  _s = 2;
                }
              } else {
                _s = 2;
              }
            }
          }
          
          // Remove os inputs inválidos se o controle perde o foco
          element.on("blur",function() {
            if (ngModelCtrl.$viewValue == '-' || ngModelCtrl.$viewValue == ',' || ngModelCtrl.$viewValue == '-,')
              ngModelCtrl.$setViewValue('');
              ngModelCtrl.$render();
          });
          
          // Validação de número válido
          ngModelCtrl.$validators.number = function(modelValue) {
            if (typeof(modelValue)!=='undefined' && modelValue!=='' && (typeof(modelValue)!=='number' || Number.isNaN(modelValue)))
              return false;
            return true;
          }
          
          // Validação de precisão máxima
          ngModelCtrl.$validators.precision = function(modelValue) {
            if (modelValue && modelValue!==null) {
              var p = parseInt(Math.floor(Math.abs(modelValue)));
              if (p && p!=="" && !Number.isNaN(p) && p >= Math.pow(10,(_p-_s)))
                return false;
            }
            return true;
          }
          
          // Validação de escala máxima
          ngModelCtrl.$validators.scale = function(modelValue) {
            if (modelValue && modelValue!==null) {
              var s = modelValue.toString().replace(/\-\./g,'');
              if (s && s!=="" && s.length > _p)
                return false;
            }
            return true;
          }
          
          function removeAllButFirst(string, token) {
            var parts = string.split(token);
            if (parts[1]===undefined) {
              scope.in/*[scope.dp]*/ = string; scope.fr/*[scope.dp]*/ = ''; return string;
            } else if (parts[0].length === 0) {
              scope.in/*[scope.dp]*/ = ''; scope.fr/*[scope.dp]*/ = parts.slice(1).join(''); return "0" + token + parts.slice(1).join('');
            } else {
              scope.in/*[scope.dp]*/ = parts[0]; scope.fr/*[scope.dp]*/ = parts.slice(1).join(''); return parts[0] + token + parts.slice(1).join('');
            }
          }
          
          /** TODO: Retirar o código de debug comentado antes de enviar **/
          function toFloat(text) {
            // Ignora parser para situações especiais do viewValue
            if (!text || typeof(text)==='undefined' || text==='') return text;
            if (text=='-') return '';
            if (text=='0'+decimalSeparator || text=='-0'+decimalSeparator) return 0;
            // Transforma automaticamente algumas situações especiais do viewValue
            var safetext = text || '';
            if (safetext==('-'+decimalSeparator)) safetext='-0'+decimalSeparator;
            if (safetext==decimalSeparator) safetext='0'+decimalSeparator;
            //scope.dp++; console.log('=========='.substring(10-scope.dp*2)+'>'+' :: $vV='+ngModelCtrl.$viewValue+' | $$rMV='+ngModelCtrl.$$rawModelValue+' | $mV='+ngModelCtrl.$modelValue);
            //console.log('          '.substring(10-scope.dp*2)+'Teste 1: (stx)'+safetext+' !== (tx)'+text);
            if (text !== safetext) {
              ngModelCtrl.$setViewValue(safetext);
              ngModelCtrl.$render();
              //console.log('<'+'=========='.substring(10-scope.dp*2)+' :: $vV='+ngModelCtrl.$viewValue+' | $$rMV='+ngModelCtrl.$$rawModelValue+' | $mV='+ngModelCtrl.$modelValue); scope.dp--; 
              return ngModelCtrl.$$rawModelValue;
            }
            scope.in/*[scope.dp]*/ = ''; scope.fr/*[scope.dp]*/ = '';
            var transformedInput = removeAllButFirst(safetext.replace(localizedSeparator,'.').replace(/[^\-\d\.]/g,'').replace(/(?!^)-/g,''), '.');
            var transformedView  = transformedInput.replace(/\./g, decimalSeparator);
            var limitedIntegral  = (scope.in/*[scope.dp]*/!==''?(scope.in/*[scope.dp]*/.length > _p-_s?scope.in/*[scope.dp]*/.substr(0,_p-_s):scope.in/*[scope.dp]*/):(scope.fr/*[scope.dp]*/!==''?'0':''));
            var limitedFractional = (scope.in/*[scope.dp]*/!==''?(scope.fr/*[scope.dp]*/.length > _s?scope.fr/*[scope.dp]*/.substr(0,_s):scope.fr/*[scope.dp]*/):'');
            //console.log('          '.substring(10-scope.dp*2)+'Teste 2: (tv)'+transformedView+' !== (recomp)'+limitedIntegral+(limitedFractional!==''?decimalSeparator+limitedFractional:''));
            transformedView = limitedIntegral+(limitedFractional!==''?decimalSeparator+limitedFractional:'');
            //console.log('          '.substring(10-scope.dp*2)+'Teste 3: (tv)'+transformedView+' !== (tx\')'+text.replace(/\,$/,''));
            if (transformedView !== text.replace(/\,$/,'')) {
              ngModelCtrl.$setViewValue(transformedView);
              ngModelCtrl.$render();
              //console.log('<'+'=========='.substring(10-scope.dp*2)+' :: $vV='+ngModelCtrl.$viewValue+' | $$rMV='+ngModelCtrl.$$rawModelValue+' | $mV='+ngModelCtrl.$modelValue); scope.dp--; 
              return ngModelCtrl.$$rawModelValue;
            }
            if (transformedInput == '-' || transformedInput==',' || transformedInput==='') { /*console.log('<'+'=========='.substring(10-scope.dp*2)+' :: $vV='+ngModelCtrl.$viewValue+' | $$rMV='+ngModelCtrl.$$rawModelValue+' | $mV='+ngModelCtrl.$modelValue); scope.dp--;*/ return ''; }
            var parsedInput = Number.parseFloat(transformedInput);
            if (!Number.isNaN(parsedInput)) {
              //var retransformedView = parsedInput.toString(10).replace(/\./g, decimalSeparator);
              var retransformedView = parsedInput.toString(10).split('.'); var i = scope.in/*[scope.dp]*/; var f = scope.fr/*[scope.dp]*/;
              //console.log('          '.substring(1,scope.depth*2)+'Teste 2: (rtv)'+retransformedView+' !== (tv)'+transformedView);
              //if (retransformedView !== transformedView && (retransformedView+decimalSeparator) !== transformedView) {
              //console.log('          '.substring(10-scope.dp*2)+'Teste 4: (i)'+i+' !== (rvi)'+(retransformedView[0]?retransformedView[0]:'')+' || (f)'+(f?f.replace(/0+$/,''):'')+' !== (rvf)'+(retransformedView[1]?retransformedView[1]:''));
              if (retransformedView && (i!==(retransformedView[0]?retransformedView[0]:'') || (f?f.replace(/0+$/,''):'')!==(retransformedView[1]?retransformedView[1]:''))) {
                ngModelCtrl.$setViewValue(retransformedView.slice(0).join(decimalSeparator));
                ngModelCtrl.$render();
                //console.log('<'+'=========='.substring(10-scope.dp*2)+' :: $vV='+ngModelCtrl.$viewValue+' | $$rMV='+ngModelCtrl.$$rawModelValue+' | $mV='+ngModelCtrl.$modelValue); scope.dp--; 
                return ngModelCtrl.$$rawModelValue;
              }
            }
            //console.log('<'+'=========='.substring(10-scope.dp*2)+' :: $vV='+ngModelCtrl.$viewValue+' | $$rMV='+ngModelCtrl.$$rawModelValue+' | $mV='+ngModelCtrl.$modelValue); scope.dp--; 
            return parsedInput;
          }
          ngModelCtrl.$parsers.push(toFloat);
        }
      }
    }]);
    
    app.directive('asDate', ['Notification','$timeout', '$filter', function(Notification, $timeout, $filter) {
      return {
          require: '^ngModel',
          restrict: 'A',
          link: function (scope, element, attrs, ngModel) {
          
              if(!ngModel){
                return;
              }
            
              // Desliga a atualização de modelo do Angular para todos os eventos exceto o evento de mudança de valor do datepicker
              // Adiciona um debounce de 200ms para assegurar que o datepicker já processou os eventos antes do angular começar seu parse
              var forcedOptions = {
                  updateOn: 'dp.change',
                  debounce: {'dp.change':200},
                  updateOnDefault: false
              };
              
              var modelOptions = {};
              if (attrs.ngModelOptions && attrs.ngModelOptions.length > 0)
              modelOptions = scope.$eval('('+attrs.ngModelOptions+')') || {};
              modelOptions = Object.assign(modelOptions, forcedOptions);
                
              ngModel.$$setOptions(modelOptions);
              
              var format = patternFormat(element);
              
              var options = {
                format: format,
                locale : moment.locale(),
                showTodayButton: true,
                useStrict: true,
                useCurrent: false,
                showClear:  true,
                minDate: moment('01/01/1900', 'DD/MM/YYYY', true),
                maxDate: moment('31/12/2999', 'DD/MM/YYYY', true),
                keepInvalid: true,
                //remove o keybind padrão da letra T para a data atual
                keyBinds: {
                  t:null
                },
                tooltips: {
                  today: 'Hoje',
                  clear: 'Limpar seleção',
                  close: 'Fechar',
                  selectMonth: 'Selecionar mês',
                  prevMonth: 'Mês anterior',
                  nextMonth: 'Próximo mês',
                  selectYear: 'Selecionar ano',
                  prevYear: 'Ano anterior',
                  nextYear: 'Próximo ano',
                  selectDecade: 'Selecionar década',
                  prevDecade: 'Década anterior',
                  nextDecade: 'Próxima década',
                  prevCentury: 'Século anterior',
                  nextCentury: 'Próximo século'
                }
              };
              
              if(format != 'DD/MM/YYYY'){
                options.sideBySide = true;
              }
              
              element.datetimepicker(options);
              
              element.on('dp.change', function() {
                //console.log('::> EVENT: dp.change [ngModel.$viewValue == '+ngModel.$viewValue+'  ; ngModel.$modelValue == '+ngModel.$modelValue+'  ; element.val() == '+element.val()+' ; element.date() == '+element.data("DateTimePicker").date()+']');
                if(validaIntervalo(this)) {
                  scope.$apply(read);
                  
                } else {
                  scope.$apply(function() {
                    ngModel.$setViewValue(restoreFromModel(),'dp.change');
                  });
                }
                //console.log('<:: EVENT: dp.change [ngModel.$viewValue == '+ngModel.$viewValue+'  ; ngModel.$modelValue == '+ngModel.$modelValue+'  ; element.val() == '+element.val()+' ; element.date() == '+element.data("DateTimePicker").date()+']');
              });
              
              element.on('dp.error', function() {
                //console.log('::> EVENT: dp.error [ngModel.$viewValue == '+ngModel.$viewValue+'  ; ngModel.$modelValue == '+ngModel.$modelValue+'  ; element.val() == '+element.val()+' ; element.date() == '+element.data("DateTimePicker").date()+']');
                // Tenta um parse em forgiving mode se o parse padrão em strict falhou
                scope.$apply(insist());
                //console.log('<:: EVENT: dp.error [ngModel.$viewValue == '+ngModel.$viewValue+'  ; ngModel.$modelValue == '+ngModel.$modelValue+'  ; element.val() == '+element.val()+' ; element.date() == '+element.data("DateTimePicker").date()+']');
              });
              
              element.on('clear', function() {
                element.data("DateTimePicker").hide();
              })
              
              ngModel.$formatters.unshift(function(value) {
                //console.log('::> FORMATTER [value='+value+']');
                //se a data vier em unix timestamp é convertida para ISO_8601
                if(value){
                  if(!moment(value, moment.ISO_8601, true).isValid()){
                    value = $filter('milliToISO')(value);
                  }
                }
                if(value) {
                  try {
                    //checa se meu value esta no formato ISO_8601
                    if(moment(value, moment.ISO_8601, true).isValid()){
                      var date = new Date(value);
                      var momentDate = moment($filter('utcDate')(date));
                      if(momentDate.isValid()){
                        value = momentDate.format(patternFormat(element));
                      }
                    } else {
                        var dateInMilliseconds = parseInt(value, 10);
                        var localDate = new Date(dateInMilliseconds);
                        var momentDate = moment($filter('utcDate')(localDate));
                        if(momentDate.isValid()) {
                          value = momentDate.format(patternFormat(element));
                        }
                    }
                  } catch (e) {
                    console.log(e);
                  }
                }
                if (!value || typeof(value)==="undefined") {
                  if (element.data("DateTimePicker").date()) {
                    $timeout(function() { element.data("DateTimePicker").date(null); }, 0);
                  }
                } else {
                  if (!element.data("DateTimePicker").date() || moment(element.data("DateTimePicker").date(),patternFormat(element)).format(patternFormat(element))!==value) {
                    if (typeof(value)==="string") {
                      $timeout(function() { element.data("DateTimePicker").date(value,patternFormat(element)); },0);
                    } else {
                      $timeout(function() { element.data("DateTimePicker").date(value); }, 0);
                    }
                  }
                }
                //console.log('<:: FORMATTER [value == '+value+']');
                return value;
              });
              
              ngModel.$parsers.unshift(function(viewValue) {
                //console.log('====> PARSER [viewValue='+viewValue+' ; ngModel.$viewValue == '+ngModel.$viewValue+' ; ngModel.$modelValue == '+ngModel.$modelValue+']');
                var returnValue = viewValue;
                if (viewValue && viewValue!=="") {
                  try {
                    var momentDate = moment(viewValue, patternFormat(element));
                    //console.log(moment(viewValue, patternFormat(element)).isValid());
                    if (!momentDate.isValid()) { // Tenta usar validação não-estrita caso a estrita falhe
                      if (patternFormat(element)=='DD/MM/YYYY') {
                        momentDate = moment(viewValue, ['DD/MM/YY','D/M/Y','DD/MM','D/M','MM/YY','M/Y','DD','D']);
                      } else if (patternFormat(element)=='MM/YYYY') {
                        momentDate = moment(viewValue, ['DD/MM/YY','D/M/Y','MM/YYYY','MM/YY','M/Y']);
                      } else {
                        momentDate = moment(viewValue, patternFormat(element), false);
                      }
                    }
                    
                    if (momentDate.isValid()) {
                      if (element.val()!==momentDate.format(patternFormat(element))) {
                        $timeout(function() {
                          console.log(element.data("DateTimePicker").date(momentDate));
                          element.data("DateTimePicker").date(momentDate);
                        },0);
                      }
                      momentDate = $filter('utcDate')(momentDate.toDate());
                      returnValue = Date.parse(momentDate);
                    } else {
                      Notification.warning({
                        message: 'A data informada "'+viewValue+'" não corresponde a uma data válida', 
                        title: 'Data inválida', 
                        delay: 5000
                      });
                      returnValue = restoreFromModel();
                    }
                  } catch (e) {
                    console.log(e);
                    element.val('');
                    returnValue = null;
                  }
                }
              
                if(returnValue && returnValue!==""){
                  returnValue = $filter('milliToISO')(returnValue);
                  returnValue = moment(returnValue).format("YYYY-MM-DD");
                } else {
                  returnValue="";
                }
                
                //console.log('<==== PARSER [returnValue == '+returnValue+' ; ngModel.$viewValue == '+ngModel.$viewValue+' ; ngModel.$modelValue == '+ngModel.$modelValue+']');
                return returnValue;
              });
  
              function insist() {
                $timeout(function(){
                  //console.log('-------> insist() [ngModel.$viewValue == '+ngModel.$viewValue+'  ; ngModel.$modelValue == '+ngModel.$modelValue+'  ; element.val() == '+element.val()+' ; element.date() == '+element.data("DateTimePicker").date()+']');
                  var value = element.val() || '';
                  if (value) {
                    if (patternFormat(element)=='DD/MM/YYYY') {
                      flexibleMomentDate = moment(value, ['DD/MM/YY','D/M/Y','DD/MM','D/M','MM/YY','M/Y','DD','D']);
                    } else if (patternFormat(element)=='MM/YYYY') {
                      flexibleMomentDate = moment(value, ['DD/MM/YY','D/M/Y','MM/YYYY','MM/YY','M/Y']);
                    } else {
                      flexibleMomentDate = moment(value, patternFormat(element), false);
                    }
                    if (typeof(flexibleMomentDate)!=="undefined" && flexibleMomentDate.isValid() && flexibleMomentDate._pf.charsLeftOver===0 ) {
                      // Força um evento dp.change
                      element.data("DateTimePicker").date(flexibleMomentDate.toDate());
                    } else {
                      // Força a remoção de valores inválidos que teriam permanecido por causa do parâmetro keepInvalid
                      Notification.warning({
                        message: 'A data informada "'+value+'" não corresponde a uma data válida', 
                        title: 'Data inválida', 
                        delay: 5000
                      });
                      ngModel.$setViewValue(restoreFromModel(),'dp.change');
                    }
                  }
                  //console.log('<------- insist() [ngModel.$viewValue == '+ngModel.$viewValue+'  ; ngModel.$modelValue == '+ngModel.$modelValue+'  ; element.val() == '+element.val()+' ; element.date() == '+element.data("DateTimePicker").date()+']');
                }, 0);
              }
  
              function read() {
                  //console.log('-------> read() [ngModel.$viewValue == '+ngModel.$viewValue+'  ; ngModel.$modelValue == '+ngModel.$modelValue+'  ; element.val() == '+element.val()+' ; element.date() == '+element.data("DateTimePicker").date()+']');
                  var value = element.val() || '';
                  if (value==='')
                     ngModel.$setViewValue('','dp.change');
                  else {
                    var momentDate = moment.parseZone(value, patternFormat(element));
                    if (momentDate.isValid())
                      ngModel.$setViewValue(momentDate.format(patternFormat(element)),'dp.change');
                    else {
                      Notification.warning({
                        message: 'A data informada "'+value+'" não corresponde a uma data válida', 
                        title: 'Data inválida', 
                        delay: 5000
                      });
                      element.val('');
                      ngModel.$setViewValue('','dp.change');
                    }
                  }
                  //console.log('<------- read() [ngModel.$viewValue == '+ngModel.$viewValue+'  ; ngModel.$modelValue == '+ngModel.$modelValue+'  ; element.val() == '+element.val()+' ; element.date() == '+element.data("DateTimePicker").date()+']');
              }
              
              function restoreFromModel() {
                //console.log('-------> restoreFromModel() [ngModel.$viewValue == '+ngModel.$viewValue+'  ; ngModel.$modelValue == '+ngModel.$modelValue+'  ; element.val() == '+element.val()+' ; element.date() == '+element.data("DateTimePicker").date()+']');
                var returnValue = ngModel.$modelValue || null;
                if (returnValue) {
                  var momentDate = moment(parseInt(returnValue,10));
                  if (momentDate.isValid())
                    returnValue = momentDate.format(patternFormat(element));
                  else
                    returnValue = '';
                } else {
                  returnValue = '';
                }
                element.val(returnValue);
                //console.log('<------- restoreFromModel() [ngModel.$viewValue == '+ngModel.$viewValue+'  ; ngModel.$modelValue == '+ngModel.$modelValue+'  ; element.val() == '+element.val()+' ; element.date() == '+element.data("DateTimePicker").date()+']');
                return returnValue;
              }
              
              //Verificar código validaIntervalo
              function validaIntervalo(dataAValidar) {
                var value = element.val() || '';
                if (value==='')
                  return true;
                var momentDate = moment(value, patternFormat(element));
                if(momentDate.isValid()) {
                  try {
                    for (i=0;i<dataAValidar.attributes.length;i++) {
            
                        if((dataAValidar.attributes[i].nodeName == "compare-greater-than") || (dataAValidar.attributes[i].nodeName == "compare-less-than")){
                          var dt2   = parseInt(($("#"+dataAValidar.attributes[i].nodeValue).val()).substring(0,2));
                          var mon2  = parseInt(($("#"+dataAValidar.attributes[i].nodeValue).val()).substring(3,5));
                          var yr2   = parseInt(($("#"+dataAValidar.attributes[i].nodeValue).val()).substring(6,10));
                          var date2 = new Date(yr2, mon2-1, dt2);
              
                          var dt1   = parseInt((dataAValidar.value).substring(0,2));
                          var mon1  = parseInt((dataAValidar.value).substring(3,5));
                          var yr1   = parseInt((dataAValidar.value).substring(6,10));
                          var date1 = new Date(yr1, mon1-1, dt1);
  
                          if ( date1 === undefined || date1 === "" || date2 === undefined || date2 === ""){
                            return true;
                          } else if ((date1 > date2 && dataAValidar.attributes[i].nodeName == "compare-greater-than") || (date1 < date2 && dataAValidar.attributes[i].nodeName == "compare-less-than")){
                            Notification.warning({
                              message: 'A data inicial do período informado não pode ser posterior à data final', 
                              title: 'Erro de intervalo de datas', 
                              delay: 5000
                            });
                            
                            ngModel.$modelValue = dataAValidar;
                            
                            return false;
                          }  
                      }
                      
                    }
                  } catch (e) {
                    console.log(e);
                  }
                  return true;
                }
              }
  
              scope.clearDatePickerIfTrue = function(expr) {
                  if (expr){
                    element.val('');
                    ngModel.$setViewValue('','dp.change');
                  }
              }
          }
      }
    }]);

    //desabita links sem permissão
    app.directive('linkEnable', ['TransactionsService', function (TransactionsService) {
      return {
        restrict: 'A',
        scope: {
        },
        link: function(scope, element, attrs) {
          var linkPermission = TransactionsService.directiveGetLinkPermission(attrs.page);
          if(!linkPermission) {
            element.addClass('disabled-link');
            element[0].childNodes[1].classList.remove('ca-icon');
            element[0].childNodes[1].classList.add('ca-icon-disabled');
            element[0].childNodes[1].querySelector('.color-awesome').classList.add('color-awesome-disabled');
            element[0].childNodes[7].querySelector('.ca-main').classList.add('ca-main-disabled');
            element[0].childNodes[7].querySelector('.ca-main').classList.remove('ca-main');
          }
          element.bind('click', function(event) {
            if(!linkPermission) {
              event.preventDefault();
            }
          });
        }
      };
    }])
    
    
    .directive("imageFile", ['GenericService', function (GenericService) {
      
      //Função auxiliar
      function settingFoto(response, element, retiraBackground){
        var labelElem = $(element[0].childNodes[3]);
        if(typeof(response) !== 'undefined' && response !== null && response.foto !== null){
          
          var byteCharacters = atob(response.foto);
          var byteNumbers = new Array(byteCharacters.length);
          for (var i = 0; i < byteCharacters.length; i++) {
              byteNumbers[i] = byteCharacters.charCodeAt(i);
          }
          var byteArray = new Uint8Array(byteNumbers);
          
          labelElem.addClass('file-ok');
          labelElem.css('background-image', 'url(' + window.URL.createObjectURL(new Blob([byteArray], {type:"image/png"})) + ')');
          labelElem.css("opacity", "1");
          labelElem.css("cursor", "pointer");
        }else{
          if(retiraBackground){
            labelElem.removeClass('file-ok');
            labelElem.css('background-image', '');
          }
          labelElem.css("opacity", "1");
          labelElem.css("cursor", "pointer");
        }
      }
      
      function verifyDependents($scope, $attrs){
        var controle = true;
        if(typeof($attrs.dependentsOn) !== 'undefined'){
          var dependents = $attrs.dependentsOn;
          try{
            dependents = JSON.parse(dependents);
            
            dependents.map(function(item){
              if($attrs[item] === undefined || $attrs[item] === null || $attrs[item] == "" ){
                controle = false;
              }
            });
          }catch(error){
            console.error("Directive error: \n Os valores dos dependentes devem estar em um vetor, mesmo que seja somente um valor");
          }
        }
        return controle;
      }
      
      function settingUrl(attrs){
        var urlAtrrs = "";
        
        if (typeof(attrs.dependentsOn) !== "undefined"){
          var dependents = JSON.parse(attrs.dependentsOn);
        
          dependents.map(function(e, i){
            if(i < dependents.length - 1)
              urlAtrrs += attrs[e] + '/';
            else
              urlAtrrs += attrs[e];
          });
        }
        return attrs.entity + '/' + urlAtrrs; 
      }
      
      
      return {
        restrict: 'E',
        replace: true,
        scope: { 
          ngDisabled: '='
        },
        template: function(elem, attrs){
          return  '<div class="wrap-custom-file"> '
                  +      '<input  type="file" image-file id="fileId" accept=".jpg, .png"> '
                  +      '<label  for="fileId" > '
                  +      '<button ng-click="deleteFoto()" class="btn btn-sm btn-danger" ><i class="glyphicon glyphicon-trash" ></i></button>'
                  +            '<i class="fa fa-plus-circle"></i> '
                  +       '</label> '
                  +'</div>';
        },
        link: function(scope, element, attrs) {
          scope.photoUrl = null;
          var imageUrl = "";
          var urlAtrrs = ""; 

          var labelElem = $(element[0].childNodes[3]);
          var filter = attrs.filter;
          attrs.$observe(filter, function(value) {
            scope.photoUrl = null
            
            if(verifyDependents(scope, attrs)){   
              imageUrl = settingUrl(attrs);
              GenericService.getData(imageUrl).then(function(response){
                settingFoto(response, element, true);
                $(element[0].childNodes[1]).prop("disabled", scope.ngDisabled);
              });
            }else{
              labelElem.removeClass('file-ok');
              labelElem.css('background-image', '');
              $(element[0].childNodes[1]).prop("disabled", scope.ngDisabled);
              labelElem.css("opacity", "0.5");
              labelElem.css("cursor", "default");
            }
          });
          
          element.bind("change", function(changeEvent) {
            scope.fileinput = changeEvent.target.files[0];
            var reader = new FileReader();
            reader.onload = function(loadEvent) {
              scope.$apply(function() {
                if(verifyDependents(scope, attrs)){
                  imageUrl = settingUrl(attrs);
                  var _data = {};
                  _data.foto = loadEvent.target.result;
                  if(typeof(attrs.dependentsOn) !== "undefined"){
                    JSON.parse(attrs.dependentsOn).map(function(e){
                      _data[e] = attrs[e];
                    });  
                  }
                  GenericService.putData(imageUrl, _data).then(function(response){
                      settingFoto(response, element, false);
                  });
                }
               
              });
            }
            if(scope.fileinput)  {
              reader.readAsDataURL(scope.fileinput);
            }
          });
          
         scope.deleteFoto = function(){
          if(verifyDependents(scope, attrs)){
           imageUrl = settingUrl(attrs);
           GenericService.deleteData(imageUrl).then(function(){
              GenericService.getData(imageUrl).then(function(response){
                settingFoto(response, element, true);
                $(element[0].childNodes[1]).prop("disabled", scope.ngDisabled);
              });
           });
          }
         } 
          
        }
      }  
    }])
    
    
    
    
    
    
    .directive("imageSelected", ['GenericService', function (GenericService) {
      return {
        restrict: 'A',
        replace: true,
        scope: { 
          photoUrl:'=photoUrl'
        },
        template: '<img class="person-photo panel panel-modal-border" type="text" src="{{photoUrl}}" ng-show="photoUrl"/>',
        link: function(scope, element, attrs) {
          scope.photoUrl = null;
          var imageUrl;
          var urlAtrrs;
          
          attrs.$observe('numdep', function(value) {
            scope.photoUrl = null
            urlAtrrs = attrs.numfunc + '/' + value;
            if(attrs.numfunc != null && attrs.numfunc != "" && value != null && value != ""){
              imageUrl = attrs.entity + '/' + urlAtrrs;
              GenericService.getData(imageUrl).then(function(response){
                if(typeof(response) !== 'undefined' && response !== null && response.foto !== null){
                  scope.photoUrl = "data:image/png;base64," + response.foto;
                }
              });
            }
          });
          attrs.$observe('filter', function(value) {
            scope.photoUrl = null;
            imageUrl = attrs.entity + '/' + value;
            GenericService.getData(imageUrl).then(function(response){
              if(typeof(response) !== 'undefined' && response !== null && response.foto !== null){
                scope.photoUrl = "data:image/png;base64," + response.foto;
              }
            });              
          });
        }
      }  
    }])
    
    .directive("fileInput", ['GenericService', '$location', function (GenericService, $location) {
      return {
        restrict: 'A',
        scope: {
          filePreview: "=",
          filter: "@"
        },
        link: function(scope, element, attrs) {
          var imageUrl;
          imageUrl = attrs.entity;
          attrs.$observe('numdep', function(value) {
            imageUrl = attrs.entity;
            urlAtrrs = imageUrl + '/' + attrs.numfunc + '/' + attrs.numdep;
          });
          element.bind("change", function(changeEvent) {
            scope.fileinput = changeEvent.target.files[0];
            var reader = new FileReader();
            reader.onload = function(loadEvent) {
              scope.$apply(function() {
                if(attrs.numdep || attrs.numfunc){
                  imageUrl = urlAtrrs;
                  var _data = {};
                  _data.foto = loadEvent.target.result;
                  _data.numfunc = attrs.numfunc;
                  _data.numdep = attrs.numdep; 
                  GenericService.putData(imageUrl, _data).then(function(response){
                    if(attrs.filter || attrs.numdep){
                      if(typeof(response) !== 'undefined' && response !== null && response.foto !== null)
                        scope.filePreview = "data:image/png;base64," + response.foto;
                    }
                  });
                } else {
                  var _data = JSON.stringify({
                    numfunc     : attrs.filter,
                    foto        : loadEvent.target.result,
                    nomeArquivo : scope.fileinput.name
                  });
                  GenericService.putData(imageUrl, _data).then(function(response){
                    if(attrs.filter || attrs.numdep){
                      if(typeof(response) !== 'undefined' && response !== null && response.foto !== null)
                        scope.filePreview = "data:image/png;base64," + response.foto;
                    }
                  });
                }
               
              });
            }
            if(scope.fileinput)  {
              reader.readAsDataURL(scope.fileinput);
            }
          });
        }
      }
    }])
    
    //diretiva para gerar relatórios
    .directive("reportGenerator", ['ReportService', '$location', 'Notification', function (ReportService, $location, Notification) {
      return {
        restrict: 'A',
        link: function(scope, element, attrs) {
          
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
          
          //Passa os atributos da diretiva pelo click e chama o service de reports
          element.bind("click", function(event) {
            //scope.params = JSON.parse(attrs.params);
            scope.params = scope.$eval(''+attrs.params+'') || {};
            scope.url = 'api/ws/rest/ergon/v1.0/relatorios/relatorio' + '/' + attrs.entity;
            ReportService.getPDF(scope.params, scope.url).then(ReportService.openPDF, trataErro);
          });
        }
      }
    }])
    
    .directive('numbersOnly', function () {
    return {
        require: 'ngModel',
        link: function (scope, element, attr, ngModelCtrl) {
            function fromUser(text) {
                if (text) {
                    var transformedInput = text.replace(/[^0-9]/g, '');

                    if (transformedInput !== text) {
                        ngModelCtrl.$setViewValue(transformedInput);
                        ngModelCtrl.$render();
                    }
                    return transformedInput;
                }
                return undefined;
            }            
            ngModelCtrl.$parsers.push(fromUser);
        }
      };
    })
    
} (app));