app.userEvents.reiniciaDatasourceOnAfterCreate = function(datasource) {
	datasource.startInserting();
}

app.userEvents.supressNotFound = function(event) {
	return function(DatasourceManager, error) {
		if (error != "Not Found") {
			Notification(error);
		}
	};
}

app.userEvents.trpv0023GeraCombinacoesPFOnAfterCreate = function(event) {
	// Your code goes here...
	ParamFinalidade.refreshLastFilter();
	return true;
}

// app.userEvents.trpv0021GeraCombinacoesParametrosContaOnAfterCreate = function(event) {
// 	// Your code goes here...
// 	GeraCombinacoesParametrosConta.refreshLastFilter();
// 	return true;
// }

app.userEvents.trpv0021GeraCombinacoesParametrosContaOnAfterCreate = function(event) {
	// Your code goes here...
	ParametrosConta.refreshLastFilter();
	return true;
}

app.userEvents.trpv0019DocumentosOnAfterCreate = function(event) {
	// Your code goes here...
	DataSigla.refreshLastFilter();
	return true;
}

app.userEvents.trpv0019DocumentosOnAfterUpdate = function(event) {
	// Your code goes here...
	DataSigla.refreshLastFilter();
	return true;
}

app.userEvents.trpv0019DocumentosOnAfterDelete = function(event) {
	// Your code goes here...
	DataSigla.refreshLastFilter();
	return true;
}


app.userEvents.trpv0012DatasourceOnAfterCreate = function(event) {
	Eventos.refreshLastFilter();
	return true;
}

app.userEvents.trpv0018DatasourceOnBeforeCreate = function(event) {
	// Your code goes here...
	alert('trpv0018DatasourceOnBeforeCreate');
	return true;
}

app.userEvents.trpv0056PosLoad = function(event) {
  for (var i = 0; i < event.$scope.$parent.$parent.$parent.$parent.listInativos.data.length; i++)
  {
      var camposVant = [];  //Array para ordenar os campos seq dos info
      if (event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosValor !== null)
      {
        camposVant.push(event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosValor.seq);
      }
      if (event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosValor2 !== null)
      {
        camposVant.push(event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosValor2.seq);
      }
      if (event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosValor3 !== null)
      {
        camposVant.push(event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosValor3.seq);
      }
      if (event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosValor4 !== null)
      {
        camposVant.push(event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosValor4.seq);
      }
      if (event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosValor5 !== null)
      {
        camposVant.push(event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosValor5.seq);
      }
      if (event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosValor6 !== null)
      {
        camposVant.push(event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosValor6.seq);
      }
      if (event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosInfo !== null)
      {
        if (event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosInfo.edata === "S")
        {
          if(event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info.includes("/"))
          {
            event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info = 
            new Date(event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info.substring(6, 10), 
                    event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info.substring(3, 5),
                    event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info.substring(0, 2));
          }
          else
          {
            event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info = 
            new Date(event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info.substring(4, 8), 
                    event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info.substring(2, 4),
                    event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info.substring(0, 2));
          }
        }
        camposVant.push(event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosInfo.seq);
      }
      if (event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosInfo2 !== null)
      {
        if (event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosInfo2.edata === "S")
        {
          if(event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info2.includes("/"))
          {
            event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info2 = 
            new Date(event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info2.substring(6, 10), 
                    event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info2.substring(3, 5),
                    event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info2.substring(0, 2));
          }
          else
          {
            event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info2 = 
            new Date(event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info2.substring(4, 8), 
                    event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info2.substring(2, 4),
                    event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info2.substring(0, 2));
          }
        }
        camposVant.push(event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosInfo2.seq);
      }
      if (event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosInfo3 !== null)
      {
        if (event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosInfo3.edata === "S")
        {
          if(event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info3.includes("/"))
          {
            event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info3 = 
            new Date(event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info3.substring(6, 10), 
                    event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info3.substring(3, 5),
                    event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info3.substring(0, 2));
          }
          else
          {
            event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info3 = 
            new Date(event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info3.substring(4, 8), 
                    event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info3.substring(2, 4),
                    event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info3.substring(0, 2));
          }
        }
        camposVant.push(event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosInfo3.seq);
      }
      if (event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosInfo4 !== null)
      {
        if (event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosInfo4.edata === "S")
        {
          if(event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info4.includes("/"))
          {
            event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info4 = 
            new Date(event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info4.substring(6, 10), 
                    event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info4.substring(3, 5),
                    event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info4.substring(0, 2));
          }
          else
          {
            event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info4 = 
            new Date(event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info4.substring(4, 8), 
                    event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info4.substring(2, 4),
                    event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info4.substring(0, 2));
          }
        }
        camposVant.push(event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosInfo4.seq);
      }
      if (event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosInfo5 !== null)
      {
        if (event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosInfo5.edata === "S")
        {
          if(event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info5.includes("/"))
          {
            event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info5 = 
            new Date(event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info5.substring(6, 10), 
                    event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info5.substring(3, 5),
                    event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info5.substring(0, 2));
          }
          else
          {
            event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info5 = 
            new Date(event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info5.substring(4, 8), 
                    event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info5.substring(2, 4),
                    event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info5.substring(0, 2));
          }
        }
        camposVant.push(event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosInfo5.seq);
      }
      if (event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosInfo6 !== null)
      {
        if (event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosInfo6.edata === "S")
        {
          if(event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info6.includes("/"))
          {
            event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info6 = 
            new Date(event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info6.substring(6, 10), 
                    event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info6.substring(3, 5),
                    event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info6.substring(0, 2));
          }
          else
          {
            event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info6 = 
            new Date(event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info6.substring(4, 8), 
                    event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info6.substring(2, 4),
                    event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].info6.substring(0, 2));
          }
        }
        camposVant.push(event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosInfo6.seq);
      }
      //percorrendo o array que foi levantado para ordenar os seq de info, 
      //insere um novo valor e ordena o array para determinar o CampoVant de acordo com a posição a apresentar na tela
      var camposVantOrd = camposVant.sort();
      var indiceVetorCamposVant = 1;
      for (var j = 1; j < 13; j++)
      {
        if (event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosInfo !== null)
        {
          if (event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosInfo.seq === j)
          {
            event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosInfo.campoVantIndexado = indiceVetorCamposVant;
            indiceVetorCamposVant++;
          }
        }
        if (event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosInfo2 !== null)
        {
          if (event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosInfo2.seq === j)
          {
            event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosInfo2.campoVantIndexado = indiceVetorCamposVant;
            indiceVetorCamposVant++;
          }
        }
        if (event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosInfo3 !== null)
        {
          if (event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosInfo3.seq === j)
          {
            event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosInfo3.campoVantIndexado = indiceVetorCamposVant;
            indiceVetorCamposVant++;
          }
        }
        if (event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosInfo4 !== null)
        {
          if (event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosInfo4.seq === j)
          {
            event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosInfo4.campoVantIndexado = indiceVetorCamposVant;
            indiceVetorCamposVant++;
          }
        }
        if (event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosInfo5 !== null)
        {
          if (event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosInfo5.seq === j)
          {
            event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosInfo5.campoVantIndexado = indiceVetorCamposVant;
            indiceVetorCamposVant++;
          }
        }
        if (event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosInfo6 !== null)
        {
          if (event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosInfo6.seq === j)
          {
            event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosInfo6.campoVantIndexado = indiceVetorCamposVant;
            indiceVetorCamposVant++;
          }
        }
        if (event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosValor !== null)
        {
          if (event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosValor.seq === j)
          {
            event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosValor.campoVantIndexado = indiceVetorCamposVant;
            indiceVetorCamposVant++;
          }
        }
        if (event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosValor2 !== null)
        {
          if (event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosValor2.seq === j)
          {
            event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosValor2.campoVantIndexado = indiceVetorCamposVant;
            indiceVetorCamposVant++;
          }
        }
        if (event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosValor3 !== null)
        {
          if (event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosValor3.seq === j)
          {
            event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosValor3.campoVantIndexado = indiceVetorCamposVant;
            indiceVetorCamposVant++;
          }
        }
        if (event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosValor4 !== null)
        {
          if (event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosValor4.seq === j)
          {
            event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosValor4.campoVantIndexado = indiceVetorCamposVant;
            indiceVetorCamposVant++;
          }
        }
        if (event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosValor5 !== null)
        {
          if (event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosValor5.seq === j)
          {
            event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosValor5.campoVantIndexado = indiceVetorCamposVant;
            indiceVetorCamposVant++;
          }
        }
        if (event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosValor6 !== null)
        {
          if (event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosValor6.seq === j)
          {
            event.$scope.$parent.$parent.$parent.$parent.listInativos.data[i].atributosValor6.campoVantIndexado = indiceVetorCamposVant;
            indiceVetorCamposVant++;
          }
        }
      }
  }
}

app.userEvents.trpv0056PosLoadTipoVantagem = function(event) {
  //Configurar os auxilires do seq, para atributo em inserção
  for (var i = 0; i < event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data.length; i++)
  {
      var camposVant = [];  //Array para ordenar os campos seq dos info
      if (event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosValor !== null)
      {
        camposVant.push(event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosValor.seq);
      }
      if (event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosValor2 !== null)
      {
        camposVant.push(event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosValor2.seq);
      }
      if (event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosValor3 !== null)
      {
        camposVant.push(event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosValor3.seq);
      }
      if (event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosValor4 !== null)
      {
        camposVant.push(event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosValor4.seq);
      }
      if (event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosValor5 !== null)
      {
        camposVant.push(event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosValor5.seq);
      }
      if (event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosValor6 !== null)
      {
        camposVant.push(event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosValor6.seq);
      }
      if (event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosInfo !== null)
      {
        camposVant.push(event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosInfo.seq);
      }
      if (event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosInfo2 !== null)
      {
        camposVant.push(event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosInfo2.seq);
      }
      if (event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosInfo3 !== null)
      {
        camposVant.push(event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosInfo3.seq);
      }
      if (event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosInfo4 !== null)
      {
        camposVant.push(event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosInfo4.seq);
      }
      if (event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosInfo5 !== null)
      {
        camposVant.push(event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosInfo5.seq);
      }
      if (event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosInfo6 !== null)
      {
        camposVant.push(event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosInfo6.seq);
      }
      //percorrendo o array que foi levantado para ordenar os seq de info, 
      //insere um novo valor e ordena o array para determinar o CampoVant de acordo com a posição a apresentar na tela
      var camposVantOrd = camposVant.sort();
      var indiceVetorCamposVant = 1;
      for (var j = 1; j < 13; j++)
      {
        if (event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosInfo !== null)
        {
          if (event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosInfo.seq === j)
          {
            event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosInfo.campoVantIndexado = indiceVetorCamposVant;
            indiceVetorCamposVant++;
          }
        }
        if (event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosInfo2 !== null)
        {
          if (event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosInfo2.seq === j)
          {
            event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosInfo2.campoVantIndexado = indiceVetorCamposVant;
            indiceVetorCamposVant++;
          }
        }
        if (event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosInfo3 !== null)
        {
          if (event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosInfo3.seq === j)
          {
            event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosInfo3.campoVantIndexado = indiceVetorCamposVant;
            indiceVetorCamposVant++;
          }
        }
        if (event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosInfo4 !== null)
        {
          if (event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosInfo4.seq === j)
          {
            event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosInfo4.campoVantIndexado = indiceVetorCamposVant;
            indiceVetorCamposVant++;
          }
        }
        if (event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosInfo5 !== null)
        {
          if (event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosInfo5.seq === j)
          {
            event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosInfo5.campoVantIndexado = indiceVetorCamposVant;
            indiceVetorCamposVant++;
          }
        }
        if (event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosInfo6 !== null)
        {
          if (event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosInfo6.seq === j)
          {
            event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosInfo6.campoVantIndexado = indiceVetorCamposVant;
            indiceVetorCamposVant++;
          }
        }
        if (event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosValor !== null)
        {
          if (event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosValor.seq === j)
          {
            event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosValor.campoVantIndexado = indiceVetorCamposVant;
            indiceVetorCamposVant++;
          }
        }
        if (event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosValor2 !== null)
        {
          if (event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosValor2.seq === j)
          {
            event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosValor2.campoVantIndexado = indiceVetorCamposVant;
            indiceVetorCamposVant++;
          }
        }
        if (event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosValor3 !== null)
        {
          if (event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosValor3.seq === j)
          {
            event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosValor3.campoVantIndexado = indiceVetorCamposVant;
            indiceVetorCamposVant++;
          }
        }
        if (event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosValor4 !== null)
        {
          if (event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosValor4.seq === j)
          {
            event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosValor4.campoVantIndexado = indiceVetorCamposVant;
            indiceVetorCamposVant++;
          }
        }
        if (event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosValor5 !== null)
        {
          if (event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosValor5.seq === j)
          {
            event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosValor5.campoVantIndexado = indiceVetorCamposVant;
            indiceVetorCamposVant++;
          }
        }
        if (event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosValor6 !== null)
        {
          if (event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosValor6.seq === j)
          {
            event.$scope.$parent.$parent.$parent.$parent.tipoVantagem.data[i].atributosValor6.campoVantIndexado = indiceVetorCamposVant;
            indiceVetorCamposVant++;
          }
        }
      }
  }
}