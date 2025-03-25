# Gerenciador de Permissões em Massa para Active Directory

![Versão](https://img.shields.io/badge/Versão-1.0-blue)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue)
![Plataforma](https://img.shields.io/badge/Plataforma-Windows-lightgrey)
![Licença](https://img.shields.io/badge/Licença-AGPLv3-red)

Este aplicativo oferece uma interface gráfica intuitiva para gerenciar permissões de pastas e subpastas no Active Directory de forma rápida e eficiente. Ideal para administradores de rede que precisam configurar acessos específicos para usuários em múltiplas pastas.

<div align="center">
<i>O Gerenciador de Permissões em Massa permite aplicar permissões personalizadas em múltiplas pastas com apenas alguns cliques</i>
</div>

## 📋 Índice

- [Funcionalidades](#-funcionalidades)
- [Requisitos do Sistema](#-requisitos-do-sistema)
- [Instalação](#-instalação)
- [Como Usar](#-como-usar)
- [Cenários de Uso](#-cenários-de-uso)
- [Configurações Avançadas](#-configurações-avançadas)
- [Solução de Problemas](#-solução-de-problemas)
- [Limitações Conhecidas](#-limitações-conhecidas)
- [FAQ](#-perguntas-frequentes)
- [Segurança](#-segurança)
- [Suporte](#-suporte)
- [Licença](#-licença)

## ✨ Funcionalidades

- **Interface Gráfica Amigável**: Gerenciamento visual de permissões em um ambiente intuitivo
- **Navegação em Árvore**: Visualize e selecione pastas e subpastas com facilidade
- **Integração com AD**: Busca e seleção de usuários e grupos diretamente do Active Directory
- **Controle Granular de Permissões**: Configure níveis detalhados de acesso (Ler, Escrever, Modificar, etc.)
- **Aplicação em Lote**: Aplique permissões em múltiplas pastas simultaneamente
- **Propagação Configurável**: Controle como as permissões se aplicam a subpastas e arquivos
- **Modo Remoto**: Conecte-se a servidores AD remotos com autenticação segura
- **Remoção de Permissões**: Remova facilmente permissões concedidas anteriormente

## 💻 Requisitos do Sistema

### Componentes Obrigatórios:
- Windows 10/11 ou Windows Server 2016/2019/2022
- PowerShell 5.1 ou superior
- Módulo Active Directory PowerShell (RSAT-AD-PowerShell)
- .NET Framework 4.5 ou superior
- Privilégios administrativos para modificar ACLs

### Recomendado:
- 4GB de RAM ou mais
- Processador multicore
- Conexão de rede estável (para operação remota)

## 🚀 Instalação

### Instalação do Módulo Active Directory

Se o módulo AD não estiver instalado, execute um dos seguintes comandos em um PowerShell com privilégios administrativos:

**Windows 10/11 (cliente):**
```powershell
# Abra um PowerShell como administrador e execute:
Add-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0
```

**Windows Server:**
```powershell
# Abra um PowerShell como administrador e execute:
Install-WindowsFeature RSAT-AD-PowerShell
```

### Instalação do Aplicativo

1. Faça o download ou clone este repositório para sua máquina:
   ```bash
   git clone https://github.com/Caiolinooo/Bulk_Permission_AD.git
   ```
2. Extraia os arquivos em uma pasta de sua escolha (se baixado como ZIP)
3. Nenhuma instalação adicional é necessária - o aplicativo é portátil

## 📝 Como Usar

### Inicialização

1. Execute o arquivo `Iniciar_BulkPermissionAD.bat` com privilégios administrativos
   - Alternativamente, abra o PowerShell como administrador e execute:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
   .\BulkPermissionAD.ps1
   ```

### Fluxo de Trabalho Básico

1. **Escolha o Modo de Operação**:
   - **Local**: Para execução direta no servidor AD (recomendado)
   - **Remoto**: Para conexão com um servidor AD remoto (requer credenciais)

2. **Selecione a Pasta Principal**:
   - Clique em "Selecionar" e navegue até a pasta raiz onde deseja gerenciar permissões
   - Uma árvore de pastas e subpastas será carregada no painel esquerdo

3. **Selecione o Usuário ou Grupo**:
   - Clique no botão "..." ao lado do campo "Usuário/Grupo"
   - Na janela de busca, digite pelo menos 3 caracteres do nome do usuário/grupo
   - Clique em "Buscar" para encontrar usuários/grupos no Active Directory
   - Selecione o usuário ou grupo desejado na lista de resultados

4. **Marque as Pastas Alvo**:
   - Na árvore de pastas, marque as caixas de seleção das pastas específicas onde deseja aplicar permissões
   - Expanda os nós da árvore para visualizar e selecionar subpastas

5. **Configure as Permissões**:
   - Na seção "Tipo de Acesso", selecione uma ou mais permissões:
     - **Controle Total**: Acesso completo (leitura, escrita, execução, etc.)
     - **Modificar**: Ler, escrever, excluir, mas não controle total
     - **Ler e Executar**: Ler arquivos e executar programas
     - **Ler**: Apenas visualizar arquivos e pastas
     - **Escrever**: Criar novos arquivos e pastas
     - **Listar Conteúdo**: Ver nomes de arquivos e subpastas

6. **Configure a Propagação**:
   - **Aplicar a subpastas**: As permissões serão herdadas por todas as subpastas
   - **Aplicar a arquivos**: As permissões serão aplicadas aos arquivos dentro das pastas

7. **Aplique as Permissões**:
   - Clique em "Aplicar Permissões" para adicionar as permissões selecionadas
   - Uma barra de progresso mostrará o status da operação
   - Confirme a ação na caixa de diálogo que aparecerá

### Remoção de Permissões

1. Selecione o usuário/grupo cujas permissões deseja remover
2. Marque as pastas onde deseja remover as permissões
3. Clique em "Remover Permissões"
4. Confirme a ação na caixa de diálogo de aviso

## 📚 Cenários de Uso

### Cenário 1: Acesso Específico para Usuário

Quando um usuário precisa ter acesso apenas a determinadas pastas dentro de uma estrutura maior:

1. Selecione a pasta principal (ex: `\\servidor\dados\departamentos\`)
2. Na árvore, marque apenas as pastas específicas que o usuário deve acessar (ex: `Projetos2023`, `Relatorios`)
3. Selecione o usuário via busca no AD
4. Configure permissões específicas (geralmente "Ler" e "Listar Conteúdo")
5. Ative "Aplicar a subpastas" e "Aplicar a arquivos"
6. Clique em "Aplicar Permissões"

### Cenário 2: Permissões para Grupo de Trabalho

Para conceder acesso a uma equipe inteira:

1. Selecione a pasta do projeto (ex: `\\servidor\projetos\Projeto-X\`)
2. Marque as pastas relevantes para o grupo (ex: `Documentacao`, `Recursos`, `Planejamento`)
3. Selecione o grupo de AD correspondente à equipe
4. Configure permissões apropriadas ("Modificar" para colaboração completa)
5. Aplique as permissões

### Cenário 3: Atualização em Massa

Para modificar rapidamente permissões em múltiplas pastas:

1. Selecione uma pasta de alto nível
2. Marque todas as pastas que precisam da mesma configuração de permissão
3. Selecione o usuário ou grupo alvo
4. Configure as permissões desejadas
5. Aplique em um único processo

## ⚙️ Configurações Avançadas

### Operação em Modo Remoto

Para gerenciar permissões em um servidor AD remoto:

1. Selecione a opção "Remoto (Requer credenciais)"
2. Clique em "Conectar"
3. Informe o nome do servidor AD (ex: `servidor-ad.dominio.local`)
4. Digite suas credenciais no formato `dominio\usuario`
5. Informe sua senha
6. Clique em "OK" para estabelecer a conexão

### Considerações de Desempenho

- **Operação em Grandes Diretórios**: Ao trabalhar com estruturas de pastas muito grandes, a carga inicial pode demorar. O aplicativo usa carregamento lazy (sob demanda) para melhorar o desempenho.
- **Modo Remoto**: As operações remotas são naturalmente mais lentas do que operações locais. Considere usar o aplicativo diretamente no servidor para melhor desempenho em alterações grandes.

## 🔧 Solução de Problemas

### Problemas Comuns e Soluções

| Problema | Possíveis Causas | Soluções |
|----------|------------------|----------|
| "O módulo Active Directory não está instalado" | RSAT-AD-PowerShell não instalado | Instale o módulo conforme as instruções na seção "Instalação" |
| Erro ao buscar usuários | 1. Sem conexão com o DC<br>2. Permissões insuficientes<br>3. Filtro de busca muito restritivo | 1. Verifique a conectividade de rede<br>2. Use credenciais com permissões adequadas para consultar o AD<br>3. Tente uma busca mais ampla |
| "Acesso negado" ao aplicar permissões | 1. Sem privilégios de administrador<br>2. Proteção do NTFS bloqueando alterações | 1. Execute o aplicativo como administrador<br>2. Verifique as configurações de segurança avançadas da pasta |
| Pastas não aparecem na árvore | 1. Sem permissão para listar conteúdo<br>2. Pastas ocultas | 1. Verifique suas permissões na pasta principal<br>2. Verifique os atributos das pastas |
| Permissões não estão sendo aplicadas | 1. Bloqueio de herança de permissão<br>2. Conflito com outras ACLs<br>3. Permissões NTFS especiais | 1. Verifique "Permissões Avançadas" na pasta<br>2. Considere usar o Explorer para configurações especiais |

### Logs de Diagnóstico

Se você encontrar problemas, ative o registro de diagnóstico:

1. Abra o PowerShell como administrador
2. Execute o script com o parâmetro `-Debug`:
   ```powershell
   .\BulkPermissionAD.ps1 -Debug
   ```
3. Os logs serão salvos em `%TEMP%\BulkPermissionAD_log.txt`

## ⚠️ Limitações Conhecidas

- A aplicação não mostra as permissões existentes nas pastas (somente adiciona ou remove)
- Não é possível configurar permissões de negação explícita (Deny)
- A busca de usuários no AD é limitada aos primeiros 1000 resultados
- Não há suporte direto para permissões especiais do NTFS (como "Tomar posse")
- Não é possível mover permissões entre pastas
- O aplicativo não gerencia permissões de compartilhamento (Share), apenas NTFS

## ❓ Perguntas Frequentes

**P: Posso usar esta ferramenta em ambientes não-AD?**  
R: Não, o aplicativo foi projetado especificamente para ambientes com Active Directory.

**P: É preciso executar o aplicativo com privilégios administrativos?**  
R: Sim, para modificar permissões NTFS é necessário ter privilégios administrativos ou permissões específicas para gerenciar ACLs.

**P: Qual é a diferença entre "Ler" e "Listar Conteúdo"?**  
R: "Listar Conteúdo" permite ver quais arquivos e pastas existem, mas não necessariamente acessar seus conteúdos. "Ler" permite acessar o conteúdo dos arquivos.

**P: O aplicativo suporta autenticação multifator (MFA)?**  
R: Não, o aplicativo utiliza autenticação padrão do Windows.

**P: É possível agendar alterações de permissão para execução futura?**  
R: Não diretamente pelo aplicativo, mas você pode criar um script PowerShell baseado nele e agendá-lo via Agendador de Tarefas do Windows.

## 🔒 Segurança

- **Armazenamento de Credenciais**: As credenciais inseridas no modo remoto são usadas apenas durante a sessão atual e não são armazenadas
- **Privilégios Elevados**: O aplicativo requer privilégios administrativos apenas para modificar ACLs, não para visualizar a estrutura
- **Auditoria**: É recomendável ter políticas de auditoria de alterações de permissão em seu ambiente

## 📞 Suporte

Se você encontrar problemas ou tiver dúvidas:

1. Consulte a seção de "Solução de Problemas" deste documento
2. Verifique as limitações conhecidas
3. Ative o modo de diagnóstico conforme descrito acima
4. Entre em contato com o autor para suporte técnico ou licenciamento:

**Contato:**
- E-mail: caiovaleriogoulartcorreia@gmail.com
- Telefone: +55 22 99784-7289
- GitHub: [Caiolinooo](https://github.com/Caiolinooo)
- LinkedIn: [Caio Goulart](https://www.linkedin.com/in/caio-goulart/)

## 📜 Licença

Este software é distribuído sob a licença GNU Affero General Public License v3.0 (AGPLv3).

**Termos importantes:**

- **Uso Comercial**: Restrito ao autor original do software
- **Uso Privado**: Permitido apenas mediante licenciamento anual
- **Distribuição**: Proibida sem autorização explícita do autor
- **Modificação**: Proibida sem autorização do autor
- **Garantia**: Não há garantia para o programa, na extensão permitida pela lei aplicável

Para obter informações completas sobre licenciamento e aquisição de licenças para uso comercial ou privado, entre em contato com o autor.

**© 2023 Caio Valerio Goulart Correia (Caio Correia) - Todos os direitos reservados.**

Este programa é um software proprietário; você não pode redistribuí-lo nem modificá-lo
sem a autorização expressa do autor.

Este programa é distribuído na esperança de que seja útil, mas SEM NENHUMA GARANTIA;
sem mesmo a garantia implícita de COMERCIALIZAÇÃO ou ADEQUAÇÃO A UM DETERMINADO FIM.