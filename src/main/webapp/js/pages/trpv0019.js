/*
function dataFormatada(datainfo){
    var data = datainfo
    var dia = data.getDate();
    if (dia.toString().length == 1)
      dia = "0"+dia;
    var mes = data.getMonth()+1;
    if (mes.toString().length == 1)
      mes = "0"+mes;
    var ano = data.getFullYear();  
    return dia+"-"+mes+"-"+ano;
}

(function ($app) {
    app.controller('execProc', [ 
       '$http',

        function ($http) {
            var url;
            this.geraCombinacao = function (temdireito, finalidade, regjur, categoria, subcategoria, tipovinc, dtini, dtfim, tipoexec) {
                
                vdt1 = dataFormatada(dtini);
                vdt2 = dataFormatada(dtfim);
                
                console.log(vdt1);
                console.log(vdt2);
                
                url = "/api/rest/ergon/ParametrosConta/geraCombinacao/" + temdireito + "/" + finalidade + "/" + regjur + "/" + categoria + "/" + subcategoria + "/" + tipovinc + "/" + vdt1 + "/" + vdt2 + "/" + tipoexec;
                console.log(url);

                this.promise = $http({
                    method: 'POST',
                    url: url,
                    headers: {
                        'Content-Type': 'application/json'
                    }
                }).success(function (response) {
                    callback(response, true);
                }).error(function (response) {
                    callback(response, false);
                })
            }

            function callback(data, done) {
                if (done == true) {
                    combinacoesEmBranco.filter();
                    this.divResposta = "foi com sucesso";
                } else if (done == false) {
                    this.divResposta = "Não foi";
                }
            }

    }]);
}(app));
*/