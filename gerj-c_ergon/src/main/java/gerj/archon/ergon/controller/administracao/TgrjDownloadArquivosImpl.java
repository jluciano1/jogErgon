package gerj.archon.ergon.controller.administracao;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.UUID;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import org.springframework.stereotype.Service;

import techne.DataMap;
import techne.TechneApplicationException;
import techne.archon.security.ArchonConnection;
import techne.security.ContextSecurityConnection;

@Service("tgrjDownloadArq")
public class TgrjDownloadArquivosImpl implements TgrjDownloadArquivos {

	// Constantes
	static final int TAMANHO_BUFFER = 4096; // 4kb

	@Override
	public void compactarListaDeArquivos(String[] listaDeArquivos, String caminho) {
		// TODO Auto-generated method stub

	}

	@Override
	/**
	 * O método downloadMult foi criado para ser utilizado no controle fileDownload para realizar
	 * o download de múltiplos arquivos, compactando estes arquivos e realizando o download do arquivo ZIP gerado.
	 * Para executar o método, cadastrar na propriedade "rotina" do fileDownload a seguinte sintaxe:
	 * java:tgrjDownloadArq.downloadMult(String, String, String[])
	 * Abaixo, é descrito os parâmetros do método que devem ser cadastrados na propriedade "parameters" do fileDownload:
	 * 
	 * @param arquivoZip
	 * 				String com o nome que será dado ao arquivo ZIP que será baixado.
	 * 				Por convenção, deve ser o nome da página. Por exemplo: RJadm00027.
	 * 				Mas se necessário, poderá ser qualquer outro nome.
	 * @param pastaOrigem
	 * 				String com o caminho onde estão os múltiplos arquivos que serão baixados.
	 * 				Se o caminho dos arquivos for junto ao nome do arquivo no parâmetro listaDeArquivos, 
	 * 				o valor deste parâmetro deve ser "null".
	 * 				Se o caminho dos arquivos não for junto ao nome do arquivo no parâmetro listaDeArquivos, 
	 * 				deve-se fornecer este caminho neste parÇametro. Exemplo: c:\temp.
	 * 				Observe que no último cenário, todos os arquivos deverão estar nesta pasta.
	 * @param listaDeArquivos
	 * 				Array de strings que deverá conter a lista dos arquivos que o usuário deseja baixar.
	 * 				Essa lista pode conter apenas o nome dos arquivos. Exemplo: [relatorio1.pdf],[relatorio2.pdf],etc...
	 * 				Observe que neste caso, o parâmetro pastaOrigem deve ser fornecido.
	 * 				Essa lista pode conter além do nome dos arquivos, também, o pasta de origem de cada arquivo. 
	 * 				Exemplo: [c:\temp\relatorio1.pdf],[c:\temp\relatorio2.pdf],[d:\local\relatorio3.pdf],etc...	 
	 * 				Observe que neste caso, o parâmetro pastaOrigem deve ser null.
	 */
	public DataMap downloadMult(String arquivoZip, String pastaOrigem, String[] listaDeArquivos) {

		if (listaDeArquivos == null) {
			throw new TechneApplicationException("Nenhum arquivo selecionado foi selecionado.");
		} else if (listaDeArquivos.length == 0) {
			throw new TechneApplicationException("Nenhum arquivo selecionado foi selecionado.");
		}

		String pastaTemp = null;
		String oracleDirectory = null;

		ArchonConnection con;

		// Obtendo o caminho dos arquivos da opção genérica DIRTEMP_NG
		try {
			con = (ArchonConnection) ContextSecurityConnection.get();
			String sql = "SELECT PACK_HADES.GET_OPCAO('Hades','WEB','DIRTEMP_NG') OPCAO FROM DUAL";

			PreparedStatement stat = con.preparaConsulta(sql);

			String coluna = null;
			try {
				ResultSet resultados = stat.executeQuery();

				while (resultados.next()) {
					coluna = resultados.getString(1);
					if (coluna != null) {
						oracleDirectory = coluna;
					}
				}

			} finally {
				stat.close();
			}

		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		if (oracleDirectory == null) {
			throw new TechneApplicationException("A opção genárica DIRTEMP_NG não foi parametrizada.");
		}

		// Pegando o PATH temporário
		try {
			con = (ArchonConnection) ContextSecurityConnection.get();
			String sql = "SELECT DIRECTORY_PATH FROM ALL_DIRECTORIES";

			PreparedStatement stat = con.preparaConsulta(sql);

			String coluna = null;
			try {
				ResultSet resultados = stat.executeQuery();

				while (resultados.next()) {
					coluna = resultados.getString(1);
					if (coluna != null) {
						pastaTemp = coluna;
					}
				}

			} finally {
				stat.close();
			}

		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		if (pastaTemp == null) {
			throw new TechneApplicationException("Pasta definida na opção genérica DIRTEMP_NG não encontrada.");
		}

		// pastaTemp = "d:\\d";

		// Nomeando o arquivo ZIP
		UUID uuid = UUID.randomUUID();

		String nomeArquivoZip = arquivoZip + uuid + ".zip";

		try {
			this.compactarMultiplosArquivosParaZip(pastaOrigem, pastaTemp, listaDeArquivos, nomeArquivoZip);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			throw new TechneApplicationException("Erro ao compactar os arquivo: " + e.getMessage());
		}

		// Lendo o arquivo zip gerado para adicionar no DataMap
		FileInputStream streamDeEntrada = null;

		try {
			File file = new File(pastaTemp + File.separator + nomeArquivoZip);
			streamDeEntrada = new FileInputStream(file);
		} catch (IOException e) {
			throw new TechneApplicationException("Erro ao baixar os arquivo: " + e.getMessage());
		}

		DataMap map = new DataMap();
		InputStream dataStream = streamDeEntrada;
		map.put("dataStream", dataStream);

		String fileName = arquivoZip + ".zip";
		map.put("fileName", fileName);

		String contentType = "application/octet-stream";
		map.put("contentType", contentType);

		return map;
	}

	@Override
	// método para compactar arquivo
	public void compactarParaZip(String arqSaida, String arqEntrada) throws IOException {
		int cont;
		byte[] dados = new byte[TAMANHO_BUFFER];

		BufferedInputStream origem = null;
		FileInputStream streamDeEntrada = null;
		FileOutputStream destino = null;
		ZipOutputStream saida = null;
		ZipEntry entry = null;

		try {
			destino = new FileOutputStream(new File(arqSaida));
			saida = new ZipOutputStream(new BufferedOutputStream(destino));
			File file = new File(arqEntrada);
			streamDeEntrada = new FileInputStream(file);
			origem = new BufferedInputStream(streamDeEntrada, TAMANHO_BUFFER);
			entry = new ZipEntry(file.getName());
			saida.putNextEntry(entry);

			while ((cont = origem.read(dados, 0, TAMANHO_BUFFER)) != -1) {
				saida.write(dados, 0, cont);
			}
			origem.close();
			saida.close();
		} catch (IOException e) {
			throw new IOException(e.getMessage());
		}
	}

	@Override
	public void compactarMultiplosArquivosParaZip(String pastaOrigem, String pastaDoZip, String[] listaDeArquivos,
			String arqSaida) throws IOException {
		int cont;
		byte[] dados = new byte[TAMANHO_BUFFER];

		BufferedInputStream origem = null;
		FileInputStream streamDeEntrada = null;
		FileOutputStream destino = null;
		ZipOutputStream saida = null;
		ZipEntry entry = null;
		// ArrayList<String> listaDeArquivos = new ArrayList<String>();
		ArrayList<File> listFiles = new ArrayList<File>();

		try {
			destino = new FileOutputStream(new File(pastaDoZip + File.separator + arqSaida));
			saida = new ZipOutputStream(new BufferedOutputStream(destino));

			String arquivoEntrada = null;

			// Lendo múltiplos arquivos da pasta
			for (String nomeArquivo : listaDeArquivos) {
				if (pastaOrigem != null) {
					arquivoEntrada = pastaOrigem + File.separator + nomeArquivo;
				} else
					arquivoEntrada = nomeArquivo;

				File file = new File(arquivoEntrada);
				listFiles.add(file);
			}

			for (File file : listFiles) {
				streamDeEntrada = new FileInputStream(file);
				origem = new BufferedInputStream(streamDeEntrada, TAMANHO_BUFFER);
				entry = new ZipEntry(file.getName());
				saida.putNextEntry(entry);

				while ((cont = origem.read(dados, 0, TAMANHO_BUFFER)) != -1) {
					saida.write(dados, 0, cont);
				}

			}

			origem.close();
			saida.close();

		} catch (IOException e) {
			throw new IOException(e.getMessage());
		} finally {

			try {
				origem.close();
			} catch (Exception e) {
				// TODO: handle exception
			}

			try {
				saida.close();
			} catch (Exception e) {
				// TODO: handle exception
			}

		}
	}

}
