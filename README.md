<p align='left'>
<img id="ergon-logo" alt="Project ErgonNG" width="136" height="52" src="/gerj-ergon-web/src/main/webapp/WEB-INF/image/logo_ergon_sigrh.jpg">
</p>

Projeto Ergon NG - Customização Gov RJ (GERJ)

Repositório dos projetos constituintes do Ergon NG da [Techne Eng. de Sistemas](http://www.techne.com.br).



## Primeiros Passos

À seguir, os passos básicos para começar a utilizar este repositório

### Pré-Requisitos

Este projeto utiliza como base o CronosFramework da Techne e assim alguns de seus requisitos seguem os [daquele](https://wiki.techne.com.br/display/tecno/Requisitos+Cronos+2.6.x):

1. JDK 8
2. Git
3. Maven (3.x.y ou superior)

Para que seja possível baixar as dependências deste projeto com Maven é preciso configurar o acesso ao [Repositório de Artefatos](https://artefatos.techne.com.br) no arquivo ${M2_REPO}/settings.xml exemplificado abaixo:

```xml
    <server>
        <id>libs-release</id>
        <username>reader</username>
        <password>APADHH3aXywThCA1hyqyaYKZzZU</password>
    </server>   

    <server>
        <id>libs-snapshot</id>
        <username>reader</username>
        <password>APADHH3aXywThCA1hyqyaYKZzZU</password>
    </server>
```

Também é possível utilizar o settings.xml disponibilizado na raiz deste projeto.

Para efeito de tutorial, iremos considerar ${M2_REPO}/settings.xml.

### Clonando Repositório

Sanados os pré-requisitos anteriores você já estará apto à criar o seu repositório local do Ergon.

Escolha um diretório de sua preferência e execute:

```sh
$ git clone https://github.com/technecloud/gov-erg-gerj
```

Caso não seja desejado baixar todas as branches do repositório:

```sh
$ git clone -b develop --single-branch https://github.com/technecloud/gov-erg-gerj
```

### Compilando...

Para compilar o repositório basta executar o seguinte comando:

```sh
$ gov-erg-gerj> mvn compile
```

Se tudo correr bem você deve visualizar uma mensagem similar à abaixo:

```
[INFO] ------------------------------------------------------------------------
[INFO] Building Ergon NG - GERJ 0.1.0-SNAPSHOT
[INFO] ------------------------------------------------------------------------
[INFO] ------------------------------------------------------------------------
[INFO] Reactor Summary:
[INFO] 
[INFO] gerj-ergon-parent .................................. SUCCESS [  0.468 s]
[INFO] gerj-c_ergon ....................................... SUCCESS [  1.036 s]
[INFO] gerj-c_hades ....................................... SUCCESS [  0.053 s]
[INFO] gerj-ergon-web ..................................... SUCCESS [  6.420 s]
[INFO] gerj-ergon-project ................................. SUCCESS [  0.001 s]
[INFO] Ergon NG - GERJ .................................... SUCCESS [  0.000 s]
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------

```

Em caso de erros concatene um comando 'clean' e habilite o 'debug output':

```sh
$ gov-erg-gerj> mvn clean compile -X
```

### Criando e Alimentando Banco Cronos da Aplicação

Como você já deve saber as aplicações CronosFramework utilizam um banco de dados como repositório de páginas.
Para o ambiente local de desenvolvimento já está pré-configurado um banco de dados H2 em arquivo.

A seguir, vamos carregar a aplicação Ergon para ambiente de desenvolvimento.

Para criar e carregar o banco de dados do Cronos, basta executar:

```sh
$ gov-erg-gerj> ./bin/init-ergon
```

Se tudo correr bem você deve visualizar uma mensagem similar à abaixo:

```
LOG_FILE: init-ergon.log
Compilando Ergon...
DataManager: creating Cronos DB (H2 local)...
DataManager: creating default users...
DataManager: loading Ergon apps...
[init-ergon] Executado com sucesso.

```

Caso contrário, verifique o arquivo de log _init-ergon.log_.

*Nota*: o banco de dados padrão da aplicação é _'erg604des:1521:ergon'_ (ORACLE).

### Rodando uma Aplicação (command line)


---------
>> Preparação
>> Neste passo você irá executar a aplicação com um plugin maven do Tomcat7.
>> Para que ele esteja acessível via "shortname" o settings.xml deve conter:
>>
>>```xml
>>  <pluginGroups>
>>    <pluginGroup>org.apache.tomcat.maven</pluginGroup>
>>  </pluginGroups>
>>```
>>
>> Se não deseja alterar o settings.xml, basta utilizar o nome completo do plugin: 
>> 'org.apache.tomcat.maven:tomcat7-maven-plugin:2.2:run-war'
>> 
>> ao invés de:
>> 
>> tomcat7:run-war
---------


Com todos os passos anteriores executados, seu ambiente já estará pronto para executar a aplicação.

Assim, para executar o Ergon com as configurações padrão de desenvolvimento, basta:

```sh
$ gov-erg-gerj> mvn -pl techne-archon-ergon-web -am package tomcat7:run-war
```

Assim, as dependências do projeto serão empacotadas e um container Tomcat7 será inicializado.

No meio do processo, é possível visualizar a linha abaixo:

```
Running war on http://localhost:8080/
```

Isso indica que o container já foi inicializado e começará a carregar o contexto da aplicação.

Ao final você deverá visualizar em seu console a linha abaixo:

```
INFO: Starting ProtocolHandler ["http-bio-8080"]
```

*PRONTO:* basta acessar em seu browser http://localhost:8080/ usuário: __zeus__ senha: __zeus__

**Nota1:** o processo não deve demorar muito mais que um minuto, em geral é menos.

**Nota2:** não se assuste com os logs, em desenvolvimento deixamos os logs do Cronos e Spring Frameworks ativados.

**Nota3:** se você não conseguir executar os scripts e/ou não estiver muito familiarizado com linha de comando, não se preocupe.
Na wiki você encontrará todos os procedimentos para criar o seu ambiente de desenvolvimento no Eclipse.



## Links Úteis

[Apache Maven](https://maven.apache.org/install.html)

[Oracle JDK 8](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html)

[Command Line Tool For Windows](http://cmder.net/): muito útil para utilizar Git e bash no Windows.

[Ambiente de Desenvolvimento (RUN & DEBUG)](https://github.com/technecloud/gov-erg-ergon/wiki/DevelopmentEnvironment)

