# D365 Pipelines

## Instruções Gerais
Todos os repositórios tem um conjunto de 3 pipelines (export, validate e build), para exportar uma solução do Dynamics você deve acionar o pipeline export-solution localizado na pasta da solução que deseja exportar.
> Você também pode encontrar o pipeline buscando por: [atendimento/secretaria]-[nomedafeature]-dynamics

## Estrutura padrão dos repositórios
```
├── [SolutionName]  
│   ├── Other  
│   │   ├── solution.xml  
│   ├── PastaA  
│   ├── PastaB  
│   ├── PastaC  
├── Settings  
│   │  environment-qa.json  
│   │  environment-hml.json   
│   │  environment-prod.json   
├── src  
│   ├── Plugins  
│   │   ├── **/*.cs  
│   ├── WebResources  
│   │   ├── **/*.js   
├── README.md  
├── validate-solution.yml  
├── export-solution.yml  
├── build-solution.yml  
├── build-plugins.yml  
├── build-webresources.yml  
└── .gitignore  
```

## Instalação
Para instalar e utilizar os scripts de devops você deve seguir a instruções abaixo:

### Pipelines de build
- No seu projeto, clicar em **Repos**, em seguida clicar em **Import Repository**, preencher os dados conforme instruções abaixo:
    - Repository Type: Git
    - Clone URL: https://kdop@dev.azure.com/kdop/Dynamics%20Core/_git/devops-templates
    - Requires Authentication: true
    - Username: seu e-mail
    - Password/PAT: Seu PAT (Personal Access Token)
- Para cada solução que deseja controlar o ciclo de vida deve ser criado um novo repositório, mantendo a estrutura descrita na sessão **Estrutura padrão dos repositórios**.
- Na raiz do repositório das soluções, copiar os arquivos abaixo, modificando os valores dos tokens (marcados com <>) de acordo com os valores do seu projeto/solução.
    - export-sample-solution.yml
    - validate-sample-solution.yml
    - build-sample-solution.yml
    - build-sample-plugins.yml
    - build-sample-webresources.yml
- Criar uma Library (Grupo de variáveis) chamada **powerplatform-variable-group**, liberar acesso a todos os pipelines clicando em **Pipeline permissions** > **Open Access**
- Adicionar na library os valores conforme tabela abaixo:

<table>
  <tr>
    <td>Nome</td>
    <td>Descrição</td>
    <td colspan="3">Exemplo</td>
  </tr>
  <tr>
    <td>ApprovedSolutionNames</td>
    <td>Expressão regular que define as soluções do projeto</td>
    <td>^(Athenas_Configuration|Athenas_ClientExtensions)</td>
  </tr>
  <tr>
    <td>BaseSolutions</td>
    <td>Soluções base separadas por vírgula</td>
    <td>Athenas,Athenas_ClientExtensions,AthenasVariaveis,Athenas_Security</td>
  </tr>
  <tr>
    <td>ConnectionReferenceDisplayNamePattern</td>
    <td>Expressão regular que valida o nome das connection references</td>
    <td>^athenas-[\w-]+$</td>
  </tr>
  <tr>
    <td>ConnectionReferenceLogicalNamePattern</td>
    <td>Expressão regular que valida o nome lógico das connection references</td>
    <td>^kcs_[\w_]+$</td>
  </tr>
  <tr>
    <td>DevServiceConnectionName</td>
    <td>Nome da Service Connection do ambiente de DEV</td>
    <td>KrotonDEV - MFA</td>
  </tr>
  <tr>
    <td>DevServiceConnectionURL</td>
    <td>URL do ambiente de DEV</td>
    <td>https://krotondev.crm2.dynamics.com</td>
  </tr>
  <tr>
    <td>PublisherPrefix</td>
    <td>Prefixo do publicador</td>
    <td>kcs</td>
  </tr>
  <tr>
    <td>SonarCloud</td>
    <td></td>
    <td>SonarCloudCogna-Athenas</td>
  </tr>
  <tr>
    <td>SonarOrganization</td>
    <td></td>
    <td>cogna-educacao</td>
  </tr>
  <tr>
    <td>AllowedWRAuthor</td>
    <td>systemuserid do usuário do devops</td>
    <td>9C225051-2E38-EC11-8C64-00224837D840</td>
  </tr>
</table>

### Pipelines de release
- Criar uma release definition em branco para cada repositório.
- Configurar o gatilho para acionamento a cada build bem sucedido do pipeline build-solution do repositório da solution.
- Adicionar como artefato do tipo repositório git a branch master do repositório devops-templates.
- Criar os stages correspondentes a cada ambiente do Dynamics.
- Adicionar as Libraries padrão do projeto como Grupo de Variáveis tendo como escopo os respectivos estágios.
- Em cada stage incluir as tarefas abaixo:
    - Power Platform Tool Installer
    - PowerShell (Skip Solution Import)
    - Power Platform Import Solution 
    - Power Platform Apply Solution Upgrade 
    - PowerShell (Sync Changes to next branch)

### Power Platform Tool Installer
Selecionar Task version = 2.*

### Skip Solution Import
- Definir tipo para File Path e escolher o arquivo **skip-solution-import.ps1** do repositório devops-templates.
- Definir o campo Arguments com os valores abaixo:
```
-tenantId $(TenantId) -applicationId $(DynamicsClientId) -clientSecret $(DynamicsClientSecret) -solutionName $(SolutionName) -url $(DynamicsDomain)
```
- Configurar na aba Advanced a Working Folder para a pasta Scripts do repositório devops-templates.

### Power Platform Import Solution 
- Marcar a opção **Use deployment settings file** e localizar o arquivo correspondente ao ambiente nos artefatos.
- Na aba **Advanced**, marcar as opções abaixo:
    - Import as a holding solution
    - Activate Plugins
    - Skip product update dependencies
- Na aba **Control Options**, marcar a opção **Run this task** com o valor **Custom conditions** e definir a condição abaixo:
```
and(succeeded(), eq(variables['SkipSolutionImport'], false))
```

### Power Platform Apply Solution Upgrade
- Marcar a opção **Apply Solution Upgrade as asynchronous operation**

### Sync Changes to next branch
- Definir tipo para File Path e escolher o arquivo **PullRequestScript.ps1** do repositório devops-templates.
- Definir o campo Arguments com os valores abaixo:
```
-repoName $(repoName) -accessToken $(System.AccessToken)
```
- Configurar na aba Advanced a Working Folder para a pasta Scripts do repositório devops-templates.

## Atualizar versão do DevOps
Para atualizar a versão crie um pipeline baseado no arquivo update-pipeline-repo.yml e rode ele de acordo com os parâmetros da nova versão que deseja trazer para seu projeto.

> É recomendado testar as novas versões de tasks e pipelines antes de fazer merge com a sua branch principal (main/master), para isso você pode definir uma branch temporária e apontar um dos seus pipelines para ela e realizar os testes.


## Pipelines de Build

### export-solution
Esse pipeline é utilizado para exportar a solução do dynamics, durante o processo é possível realizar o merge caso hajam patches, fazer as checagens de padrões de projeto e gravar as alterações no repositório git correspondente a solução.
> Para selecionar que tarefas serão feitas durante o processo de extração dos pacotes consulte a sessão **Tarefas**.

### validate-solution
Esse pipeline é utilizado para empacotar a solução não gerenciada e submeter a avaliação do solution checker.
> O acionamento desse pipeline é feito de maneira automática, sempre que um novo pull request é feito ou alterado para a branch de QA dos repositórios de solutions.

### build-solution
Esse pipeline é utilizado para empacotar a solução como gerenciada e produzir os artefatos que serão utilizados no release.
> O acionamento desse pipeline ocorre de maneira automática, quando um pull request é aceito e ocorre o merge das branches com sucesso.

### hotfix
Esse pipeline deve ser utilizado para exportar soluções de hotfix para correções urgentes nos ambientes de HML e PROD, requer que seja passado como parâmetro o nome lógico da solução.
> A permanência dos hotfixes nos ambientes é temporária, devendo ser excluído cada vez que houver um deploy de sprint que contiver os componentes alterados no hotfix.

### build-plugin
Esse pipeline deve ser utilizado para realizar o build dos Pacotes de Plugin e subir no Plugin Registration os arquivos nuget que são o resultado do build.
> Para preencher os valores da propriedade **PluginPackages** no pipeline build-plugins.yml, é necessário registrar o Pacote de Plugin no Plugin Registration previamente e buscar o id gerado na tabela pluginpackages através da ferramenta SQL4CDS.

### build-webresources
Esse pipeline é responsável por subir todos os recursos da web contidos na pasta WebResources do repositório, permitindo que seja feita uma checagem de processo no momento do export-solution.

## Tarefas Customizadas

### Merge Solution Patches
**Uso**: export-solution  
**Variável**: MergeSolutionBeforeExport  
**Valor Padrão**: true  
**Descrição**: Essa tarefa realiza o clone solution, juntando os pacthes com a solução base, é utilizada antes de exportar a solução no pipeline export-solution.

### Check Solution Name Pattern
**Uso**: export-solution  
**Variável**: CheckSolutionNamePattern  
**Valor Padrão**: false  
**Descrição**: Essa tarefa avalia se o nome da solução está dentro de um conjunto de soluções permitidas/aprovadas de acordo com uma expressão regular.

### Check Solution Publisher
**Uso**: export-solution  
**Variável**: N/A  
**Valor Padrão**: N/A  
**Descrição**: Essa tarefa avalia se o publicador da solução é o esperado.

### Check Connection References
**Uso**: export-solution  
**Variável**: CheckConnectionReferences  
**Valor Padrão**: false  
**Descrição**: Essa tarefa avalia se a solução contém referências de conexão diferentes das que foram definidas como padrão no projeto.

### Check Solution Components
**Uso**: export-solution  
**Variável**: CheckSolutionComponentTypes  
**Valor Padrão**: false  
**Descrição**: Essa tarefa valida se existem componentes não permitidos no pacote, para definir os tipos de componentes deve-se preencher o parâmetro **AllowedSolutionComponentTypes**.

### Check Table Behavior
**Uso**: export-solution  
**Variável**: CheckTableBehavior  
**Valor Padrão**: false  
**Descrição**: Essa tarefa valida se existem tabelas com comportamento "Incluir todos os componentes" na solução, esse comportamento provoca a inclusão de componentes de forma não intencional à medida que novas customizações são feitas.

### Check Environment Variables
**Uso**: export-solution  
**Variável**: CheckEnvironmentVariables  
**Valor Padrão**: false  
**Descrição**: Essa tarefa analisa se os arquivos de configuração contém os valores para as variáveis de ambiente incluídas na solução, caso esteja faltando algum valor, será adicionada um entrada nos arquivos com valor em branco e a tarefa irá falhar.

### Skip Solution Import
**Uso**: Releases 
**Variável**: N/A  
**Valor Padrão**: N/A  
**Descrição**: Essa tarefa avalia se há uma solução de Upgrade aguardando para aplicar atualizações no ambiente de destino, caso haja, a próxima tarefa que seria Import Solution é pulada e o pipeline executa a Apply Solution Upgrade.

### Create Pull Request
**Uso**: export-solution e Releases  
**Variável**: N/A  
**Valor Padrão**: N/A  
**Descrição**: Essa tarefa faz a abertura de um pull request no repositório da solução. Durante a extração da solução essa tarefa é utilizada para criar um pull request da branch de dev para qa, durante os releases o pipeline analisa que stage está rodando e faz o pull request entre a branch do stage atual e a branch correspondente ao próximo stage.

### Change Solution Type
**Uso**: build-solution  
**Variável**: ChangeSolutionType  
**Valor Padrão**: true  
**Descrição**: Essa tarefa atualiza a propriedade managed no arquivo solution.xml, essa mudança transforma o pacote gerado em gerenciado.

### Change Forms Name
**Uso**: build-solution  
**Variável**: ChangeSolutionType  
**Valor Padrão**: true  
**Descrição**: Essa tarefa renomeia os formulários para o padrão requerido de soluções gerenciadas, é utilizada em conjunto com a tarefa **Change Solution Type**.

### Delete Missing Depencies Node
**Uso**: build-solution  
**Variável**: N/A  
**Valor Padrão**: N/A  
**Descrição**: Essa tarefa remove o nó MissingDependencies do arquivo solution.xml para evitar erros na avaliação de dependências feita antes de importar a solução.

### Disable SLA
**Uso**: Release (atendimento-roteamentoesla-dynamics)  
**Variável**: N/A  
**Valor Padrão**: N/A  
**Descrição**: Essa tarefa desativa os SLAs informados na variável **slaList**, é necessário durante o processo de upgrade de SLAs existentes.

### Enable SLA
**Uso**: Release (atendimento-roteamentoesla-dynamics)  
**Variável**: N/A  
**Valor Padrão**: N/A  
**Descrição**: Essa tarefa ativa os SLAs informados na variável **slaList**, essa tarefa é utilizada após realizar o upgrade da solução.

### Disable Routing Rule Set
**Uso**: Release (atendimento-roteamentoesla-dynamics)  
**Variável**: N/A  
**Valor Padrão**: N/A  
**Descrição**: Essa tarefa desabilita o Routing Rule Set informada na variável **routingRuleId**, é necessário durante o processo de upgrade de Routing Rule Sets existentes.

### Enable Routing Rule Set
**Uso**: Release (atendimento-roteamentoesla-dynamics)  
**Variável**: N/A  
**Valor Padrão**: N/A  
**Descrição**: Essa tarefa ativa o Routing Rule Set informado na variável **routingRuleId**, essa tarefa é utilizada após realizar o upgrade da solução.

### Check Table Behavior
**Uso**: export-solution  
**Variável**: CheckTableBehavior  
**Valor Padrão**: true  
**Descrição**: Essa tarefa identifica se há tabelas com o comportamento **Incluir todos os componentes** na solução, caso exista a tarefa produz uma falha na build.

### Check Security Profiles
**Uso**: export-solution  
**Variável**: CheckSecurityRoles  
**Valor Padrão**: false  
**Descrição**: Essa tarefa procura por perfis de segurança com permissão de delete definida com o valor **Global**, caso encontre a build irá falhar.

### Check Relationships
**Uso**: export-solution  
**Variável**: CheckRelationships  
**Valor Padrão**: false  
**Descrição**: Essa tarefa verifica se existem relacionamentos com a opção de **Cascade Delete** definida com o valor **Cascade**, caso encontre pelo menos uma a build falha.

### Check Webresource Author
**Uso**: export-solution  
**Variável**: CheckWebresourceAuthor  
**Valor Padrão**: true  
**Descrição**: Essa tarefa verifica se existem web resources cujo ultimo a modificar não foi o usiário padrão do devops, esse padrão indica um desvio de processo, manipulação direta no ambiente de dev do we resource.  