(function($app) {

	$app.filter('tel', function() {

		return function(input) {
			var str = input + '';
			str = str.replace(/\D/g, '');
			if (str.length === 11) {
				str = str.replace(/^(\d{2})(\d{5})(\d{4})/, '($1) $2-$3');
			} else {
				str = str.replace(/^(\d{2})(\d{4})(\d{4})/, '($1) $2-$3');
			}
			return str;
		};

	});

	$app.filter('cep', function() {
		return function(input) {
			var str = input + '';
			str = str.replace(/\D/g, '');
			str = str.replace(/^(\d{2})(\d{3})(\d)/, "$1.$2-$3");
			return str;
		};
	});
	
	$app.filter('utcDate', function() {
		return function(val){
		  if (val===null) return null;
		  var date = new Date(val);
      var _utc = new Date(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate(),  date.getUTCHours(), date.getUTCMinutes(), date.getUTCSeconds());
      return _utc;
		};
	});
  
  $app.filter('milliToISO', function() {
    return function(date){
      // Converte unix em ISO86
      var dateInMilli = parseInt(date, 10);
      var pattDate = new Date(dateInMilli);
      isoDate = pattDate.toISOString();
      return isoDate;
    };
  });
  
  $app.filter('diffDays', function() {
    return function(dataInicial, dataFinal){
      //calcula diferença entre duas datas
      var date1 = new Date(dataInicial);        
      var date2 = new Date(dataFinal);
      var timeDiff = Math.abs(date2.getTime() - date1.getTime());
      var diffDays = Math.ceil(timeDiff / (1000 * 3600 * 24));
      return diffDays;
    };
  });
  
  $app.filter('shortISO', function() {
    return function(date){
      // Converte em iso de 10 characteres
      var shortISO = date.substring(0, 10);
      return shortISO;
    };
  });
  
	$app.filter('cnpj', function() {
		return function(input) {
			var str = input + '';
			str = ("00000000000000" + str).slice(-14);
			str = str.replace(/\D/g, '');
			str = str.replace(/^(\d{2})(\d)/, '$1.$2');
			str = str.replace(/^(\d{2})\.(\d{3})(\d)/, '$1.$2.$3');
			str = str.replace(/\.(\d{3})(\d)/, '.$1/$2');
			str = str.replace(/(\d{4})(\d)/, '$1-$2');
			return str;
		};
	});
	
	$app.filter('cpf', function() {
		return function(input) {
			var str = input + '';
			str = ("00000000000" + str).slice(-11);
			str = str.replace(/\D/g, '');
			str = str.replace(/^(\d{3})(\d)/, '$1.$2');
			str = str.replace(/\.(\d{3})(\d)/, '.$1.$2');
			str = str.replace(/\.(\d{3})(\d)/, '.$1-$2');
			return str;
		};
	});

	$app.filter('encodeURIComponent', function() {
		return function(input) {
			return encodeURIComponent(input);
		};
	});

	app.filter('orderByString', function() {
		return function(items, predicate, reverse) {

			items.sort(function(a, b) {
				return a[predicate].localeCompare(b[predicate]);
			});
			if (reverse === true) {
				return items.slice().reverse();
			} else {
				return items;
			}
		};
	});

	app.filter('orderByNumber', function() {
		return function(items, predicate, reverse) {

			items.sort(function(a, b) {
				return a[predicate] - b[predicate];
			});
			if (reverse === true) {
				return items.slice().reverse();
			} else {
				return items;
			}
		};
	});

	app.filter('orderByDate', ['$filter', function ($filter) {
		return function(items, predicate, reverse) {
			return $filter('orderBy')(items, predicate, reverse);
		};
	}]);

	app.filter('ordenarObj', function() {
		return function(items, predicate, objPre, reverse) {
			items
					.sort(function(a, b) {
					  if(typeof(a[predicate][objPre])==='string') {
  						return a[predicate][objPre]
								.localeCompare(b[predicate][objPre]);
					  } else {
					    return a[predicate][objPre]-b[predicate][objPre];
					  }
					});
			if (reverse === true) {
				return items.slice().reverse();
			} else {
				return items;
			}
		};
	});
	
	app.filter('ordenarObjeto', function() {
	  return function(items, predicate, reverse) {
	    var predicatePath = [];
	    if (predicate.match(/\./)) 
	      predicatePath = predicate.split('.');
	    else
	      predicatePath[0] = predicate;
	    items
	        .sort(function(a,b) {
	          var _a = a;
	          var _b = b;
	          for (i=0;i<predicatePath.length;i++) {
	            _a = (_a?_a[predicatePath[i]]||'':'');
	            _b = (_b?_b[predicatePath[i]]||'':'');
	          }
	          if (typeof(_a)==='string')
	            return _a.localeCompare(_b);
	          else
	            return _a-_b;
	        });
	    if (reverse === true) {
				return items.slice().reverse();
			} else {
				return items;
			}
	  }
	});
	
	app.filter('stripBars', function() {
		return function(input) {
		  if (typeof(input) === "undefined")
		    return null;
			var str = input + '';
			return str.replace(/\//g, '\uCEB2').replace(/%/g, '\u0398');
		}
	});
	
	app.filter('parsePercentage', function(numberFilter) {
	  return function(input) {
	    if (!input) return input;
	    if (typeof(input) !== "number") return input;
	    if (input === 0) return numberFilter(input);
	    var abs = Math.abs(input);
	    var absFloor = Math.floor(abs);
	    if (abs === absFloor) return numberFilter(input);
	    abs = Math.abs(input * 100);
	    absFloor = Math.floor(abs);
	    if (abs === absFloor) return numberFilter(input, 2);
	    return numberFilter(input);
	  }
	});
	
	$app.filter('milliToISO', function() {
    return function(date){
    // Converte unix em ISO86
    var dateInMilli = parseInt(date, 10);
    var pattDate = new Date(dateInMilli);
    isoDate = pattDate.toISOString();
    return isoDate;
    };
  });

	app.filter('highlight', ['$sce', function($sce) {
	  // Filtro para retornar HTML destacando os trechos de 'text' que correspondam a 'search' (apenas a primeira ocorrência, case-insensitive)
	  // NÃO FUNCIONA SE UTILIZADO COM O PARSE SIMPLIFICADO DO ANGULARJS: {{ text | highlight:search }}
	  // FORMA CORRETA DE UTILIZAR: <span ng-html-bind="valor | highlight:search"></span>
    return function(text, search) {
      if (!search || typeof(search)==="undefined" || search==='') {
        return $sce.trustAsHtml(text);
      }
      var safetext = text || '';
      return $sce.trustAsHtml(unescape(escape(safetext).replace(new RegExp(escape(search), 'i'), escape('<span class="highlightedText">')+'$&'+escape('</span>'))));
    };
  }]);
  
  app.filter('formatDateTime', function ($filter) {
    return function (date, format) {
        console.log(date.substring(0, 4), date.substring((5, 7), date.substring(8, 10)));
        if (date) {
          return moment(Number(new Date(date.substring(0, 4), (date.substring(5, 7) - 1), date.substring(8, 10)))).format(format || "DD/MM/YYYY");
        }
        else
          return "";
    };
  });

}(app));
