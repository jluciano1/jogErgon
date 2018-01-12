package gerj.archon.ergon.controller.administracao;

import java.io.IOException;

import techne.DataMap;

public interface TgrjDownloadArquivos {

	/**
	 * @author Pimentel
	 *
	 */
	public void compactarListaDeArquivos(String[] listaDeArquivos, String caminho);
	
	public DataMap downloadMult(String arquivoZip, String pastaOrigem, String[] listaDeArquivos);

	public void compactarParaZip(String arqSaida, String arqEntrada) throws IOException;

	public void compactarMultiplosArquivosParaZip(String pastaOrigem, String pastaDoZip,  String[] listaDeArquivos,
			String arqSaida) throws IOException;

}
