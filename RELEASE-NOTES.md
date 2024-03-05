## [Versão 1.3.0](https://dev.azure.com/kdop/Dynamics%20Core/_git/devops-templates?version=GT1.3) (2024-03-04)

> Adicionadas novas tarefas de checagem adicionadas no pipeline hotfix, para impedir que soluções contendo componentes que não estejam presentes na sua solução padrão sejam distribuídas.

### Upgrade Steps
- Utilizar o pipeline update-pipelines-templates com opção tag e valor 1.3

### Breaking Changes
- Pipeline hotfix falha caso algum componente presente na solution não esteja contido na solution base ou algum de seus patches.

### New Features
- Nova tarefa Check Hotfix que carrega o script check-hotfix-components.ps1 e invoca o método Test-Hotfix-Components "$(DevServiceConnectionURL)" "$env:MAPPED_SPN_Token" "${{parameters.SolutionName}}"

### Bug Fixes
- N/A

## [Versão 1.2.0](https://dev.azure.com/kdop/Dynamics%20Core/_git/devops-templates?version=GT1.2) (2024-02-28)

> Adicionadas novas tarefas de checagem adicionadas no pipeline export-solution, para impedir que soluções contendo web resources modificados diretamente no ambiente sejam distribuídas.

### Upgrade Steps
- Utilizar o pipeline update-pipelines-templates com opção tag e valor 1.2

### Breaking Changes
- Para utilizar a checagem de autoria dos Web Resources, será necessário adicionar na Library (Grupo de Variáveis) powerplatform-variable-group o valor de configuração para AllowedAuthor.

### New Features
- export-solution falha caso tenham web resources com ultimo autor diferente do usuário do devops.
- Novas tarefas:
    - Check WebResource Author

### Bug Fixes
- N/A

## [Versão 1.1.0](https://dev.azure.com/kdop/Dynamics%20Core/_git/devops-templates?version=GT1.1) (2023-11-10)

> Adicionadas novas tarefas de checagem adicionadas no pipeline export-solution, para impedir que sejam adicionadas permissões de exclusão.  
Implementação da opção de alternar o build entre o modelo com aprovação via pull-request e modelo simplificado.

### Upgrade Steps
- Utilizar o pipeline update-pipelines-templates com opção tag e valor 1.

### Breaking Changes
- N/A

### New Features
- Possibilidade de alternar entre modelo de aprovação por Pull Request e modelo simplificado (gerar release após build sem aprovação).
- Novas tarefas:
    - Check Relationships
    - Check Security Profiles

### Bug Fixes
- Check Solution Publisher recebe o prefixo do publicador como parâmetro.
- SonarCloud Prepare cria o projeto com o Id do repositório no AzDevOps como chave no Sonar.