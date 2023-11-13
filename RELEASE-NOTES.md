## [Versão 1.1.0](https://dev.azure.com/kdop/Dynamics%20Core/_git/devops-templates?version=GT1.1) (2023-11-10)

> Adicionadas novas tarefas de checagem adicionadas no pipeline export-solution, para impedir que sejam adicionadas permissões de exclusão.  
Implementação da opção de alternar o build entre o modelo com aprovação via pull-request e modelo simplificado.

### Upgrade Steps
- Utilizar o pipeline update-pipelines-templates com opção tag e valor 1.1

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