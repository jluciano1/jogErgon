Ext.ns('Techne.Cust');

Techne.Cust.exemploDeFuncao = function(bar) {
	  // bar eh um parametro - foo eh uma variavel local
	  var foo = bar;
	  alert('Exemplo de funcao customizada - ' + bar);
};

Ext.namespace('Techne.Mask');
Techne.Mask.createMaskForFormat('decimal08d02', {
  mask : '99,999.999.99',
  fixedChars : '[,.]',
  replaceChars: {
    ',' : '.'
  },
  type : 'reverse'
});

Techne.Mask.createMaskForFormat('ano4dig', {
     mask : '9999'
  }
);