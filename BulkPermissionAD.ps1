# Gerenciador de Permissões em Massa para Active Directory
# Autor: Claude
# Data: 2023
# Versão: 1.0

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Verifica e importa o módulo ActiveDirectory se disponível
function Test-ADModule {
    if (Get-Module -ListAvailable -Name ActiveDirectory) {
        try {
            Import-Module -Name ActiveDirectory -ErrorAction Stop
            return $true
        } catch {
            return $false
        }
    } else {
        return $false
    }
}

# Inicializa a aplicação
function Initialize-App {
    $hasADModule = Test-ADModule
    
    # Formulário principal
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Gerenciador de Permissões em Massa para AD"
    $form.Size = New-Object System.Drawing.Size(800, 600)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
    $form.MaximizeBox = $false
    $form.Icon = [System.Drawing.SystemIcons]::Shield
    
    # Painel para modo de operação
    $gbOperationMode = New-Object System.Windows.Forms.GroupBox
    $gbOperationMode.Location = New-Object System.Drawing.Point(20, 20)
    $gbOperationMode.Size = New-Object System.Drawing.Size(750, 60)
    $gbOperationMode.Text = "Modo de Operação"
    
    $rbLocal = New-Object System.Windows.Forms.RadioButton
    $rbLocal.Location = New-Object System.Drawing.Point(20, 25)
    $rbLocal.Size = New-Object System.Drawing.Size(200, 20)
    $rbLocal.Text = "Local (Execução no servidor AD)"
    $rbLocal.Checked = $true
    
    $rbRemote = New-Object System.Windows.Forms.RadioButton
    $rbRemote.Location = New-Object System.Drawing.Point(230, 25)
    $rbRemote.Size = New-Object System.Drawing.Size(200, 20)
    $rbRemote.Text = "Remoto (Requer credenciais)"
    
    $btnConnect = New-Object System.Windows.Forms.Button
    $btnConnect.Location = New-Object System.Drawing.Point(440, 22)
    $btnConnect.Size = New-Object System.Drawing.Size(100, 25)
    $btnConnect.Text = "Conectar"
    $btnConnect.Enabled = $false
    $btnConnect.Add_Click({
        # Lógica para conectar ao AD remoto
        $credForm = New-Object System.Windows.Forms.Form
        $credForm.Text = "Autenticação"
        $credForm.Size = New-Object System.Drawing.Size(300, 200)
        $credForm.StartPosition = "CenterParent"
        
        $lblServer = New-Object System.Windows.Forms.Label
        $lblServer.Location = New-Object System.Drawing.Point(10, 20)
        $lblServer.Size = New-Object System.Drawing.Size(280, 20)
        $lblServer.Text = "Servidor AD:"
        $credForm.Controls.Add($lblServer)
        
        $txtServer = New-Object System.Windows.Forms.TextBox
        $txtServer.Location = New-Object System.Drawing.Point(10, 40)
        $txtServer.Size = New-Object System.Drawing.Size(260, 20)
        $credForm.Controls.Add($txtServer)
        
        $lblUsername = New-Object System.Windows.Forms.Label
        $lblUsername.Location = New-Object System.Drawing.Point(10, 70)
        $lblUsername.Size = New-Object System.Drawing.Size(280, 20)
        $lblUsername.Text = "Usuário (dominio\usuario):"
        $credForm.Controls.Add($lblUsername)
        
        $txtUsername = New-Object System.Windows.Forms.TextBox
        $txtUsername.Location = New-Object System.Drawing.Point(10, 90)
        $txtUsername.Size = New-Object System.Drawing.Size(260, 20)
        $credForm.Controls.Add($txtUsername)
        
        $lblPassword = New-Object System.Windows.Forms.Label
        $lblPassword.Location = New-Object System.Drawing.Point(10, 120)
        $lblPassword.Size = New-Object System.Drawing.Size(280, 20)
        $lblPassword.Text = "Senha:"
        $credForm.Controls.Add($lblPassword)
        
        $txtPassword = New-Object System.Windows.Forms.MaskedTextBox
        $txtPassword.Location = New-Object System.Drawing.Point(10, 140)
        $txtPassword.Size = New-Object System.Drawing.Size(260, 20)
        $txtPassword.PasswordChar = '*'
        $credForm.Controls.Add($txtPassword)
        
        $btnOK = New-Object System.Windows.Forms.Button
        $btnOK.Location = New-Object System.Drawing.Point(190, 170)
        $btnOK.Size = New-Object System.Drawing.Size(80, 25)
        $btnOK.Text = "OK"
        $btnOK.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $credForm.Controls.Add($btnOK)
        
        $btnCancel = New-Object System.Windows.Forms.Button
        $btnCancel.Location = New-Object System.Drawing.Point(100, 170)
        $btnCancel.Size = New-Object System.Drawing.Size(80, 25)
        $btnCancel.Text = "Cancelar"
        $btnCancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
        $credForm.Controls.Add($btnCancel)
        
        $credForm.AcceptButton = $btnOK
        $credForm.CancelButton = $btnCancel
        
        $result = $credForm.ShowDialog()
        
        if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
            try {
                $securePassword = ConvertTo-SecureString $txtPassword.Text -AsPlainText -Force
                $credential = New-Object System.Management.Automation.PSCredential ($txtUsername.Text, $securePassword)
                $script:RemoteServer = $txtServer.Text
                $script:RemoteCredential = $credential
                
                [System.Windows.Forms.MessageBox]::Show("Conexão estabelecida com sucesso!", "Sucesso", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
                $statusBar.Text = "Conectado ao servidor remoto: $($txtServer.Text)"
                $btnSelectFolder.Enabled = $true
                $btnSelectUser.Enabled = $true
            }
            catch {
                [System.Windows.Forms.MessageBox]::Show("Falha ao estabelecer conexão: $_", "Erro", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            }
        }
    })
    
    $gbOperationMode.Controls.Add($rbLocal)
    $gbOperationMode.Controls.Add($rbRemote)
    $gbOperationMode.Controls.Add($btnConnect)
    
    # Quando o modo de operação mudar
    $rbRemote.Add_CheckedChanged({
        $btnConnect.Enabled = $rbRemote.Checked
        if (-not $rbRemote.Checked) {
            $btnSelectFolder.Enabled = $true
            $btnSelectUser.Enabled = $true
        } else {
            $btnSelectFolder.Enabled = $false
            $btnSelectUser.Enabled = $false
        }
    })
    
    # Painel para seleção de pasta
    $gbFolderSelection = New-Object System.Windows.Forms.GroupBox
    $gbFolderSelection.Location = New-Object System.Drawing.Point(20, 90)
    $gbFolderSelection.Size = New-Object System.Drawing.Size(750, 60)
    $gbFolderSelection.Text = "Pasta"
    
    $txtFolderPath = New-Object System.Windows.Forms.TextBox
    $txtFolderPath.Location = New-Object System.Drawing.Point(20, 25)
    $txtFolderPath.Size = New-Object System.Drawing.Size(600, 20)
    $txtFolderPath.ReadOnly = $true
    
    $btnSelectFolder = New-Object System.Windows.Forms.Button
    $btnSelectFolder.Location = New-Object System.Drawing.Point(640, 22)
    $btnSelectFolder.Size = New-Object System.Drawing.Size(90, 25)
    $btnSelectFolder.Text = "Selecionar"
    $btnSelectFolder.Add_Click({
        $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
        $folderBrowser.Description = "Selecione a pasta principal"
        $folderBrowser.ShowNewFolderButton = $false
        
        if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $txtFolderPath.Text = $folderBrowser.SelectedPath
            $statusBar.Text = "Pasta selecionada: $($folderBrowser.SelectedPath)"
            Update-FolderTree $folderBrowser.SelectedPath
        }
    })
    
    $gbFolderSelection.Controls.Add($txtFolderPath)
    $gbFolderSelection.Controls.Add($btnSelectFolder)
    
    # Painel para visualização de pastas e subpastas
    $gbFolderView = New-Object System.Windows.Forms.GroupBox
    $gbFolderView.Location = New-Object System.Drawing.Point(20, 160)
    $gbFolderView.Size = New-Object System.Drawing.Size(360, 330)
    $gbFolderView.Text = "Estrutura de Pastas"
    
    $treeView = New-Object System.Windows.Forms.TreeView
    $treeView.Location = New-Object System.Drawing.Point(20, 25)
    $treeView.Size = New-Object System.Drawing.Size(320, 290)
    $treeView.CheckBoxes = $true
    
    $gbFolderView.Controls.Add($treeView)
    
    # Função para atualizar a árvore de pastas
    function Update-FolderTree($rootPath) {
        $treeView.Nodes.Clear()
        
        if (-not (Test-Path $rootPath)) {
            [System.Windows.Forms.MessageBox]::Show("Caminho não encontrado: $rootPath", "Erro", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            return
        }
        
        $rootNode = New-Object System.Windows.Forms.TreeNode
        $rootNode.Text = (Get-Item $rootPath).Name
        $rootNode.Tag = $rootPath
        $treeView.Nodes.Add($rootNode)
        
        Add-ChildFolders $rootNode $rootPath
        $rootNode.Expand()
    }
    
    # Função para adicionar pastas filhas à árvore
    function Add-ChildFolders($parentNode, $path) {
        try {
            $folders = Get-ChildItem -Path $path -Directory -ErrorAction Stop
            
            foreach ($folder in $folders) {
                $childNode = New-Object System.Windows.Forms.TreeNode
                $childNode.Text = $folder.Name
                $childNode.Tag = $folder.FullName
                
                $parentNode.Nodes.Add($childNode)
                
                # Adicionar um nó fictício para permitir expansão posterior
                $dummyNode = New-Object System.Windows.Forms.TreeNode
                $dummyNode.Text = "Carregando..."
                $childNode.Nodes.Add($dummyNode)
            }
        }
        catch {
            $statusBar.Text = "Erro ao listar pastas: $_"
        }
    }
    
    # Evento para quando um nó é expandido
    $treeView.Add_BeforeExpand({
        $node = $_.Node
        
        # Se o nó tem apenas o nó fictício, carregue as subpastas reais
        if ($node.Nodes.Count -eq 1 -and $node.Nodes[0].Text -eq "Carregando...") {
            $node.Nodes.Clear()
            Add-ChildFolders $node $node.Tag
        }
    })
    
    # Painel para configuração de permissões
    $gbPermissions = New-Object System.Windows.Forms.GroupBox
    $gbPermissions.Location = New-Object System.Drawing.Point(400, 160)
    $gbPermissions.Size = New-Object System.Drawing.Size(370, 330)
    $gbPermissions.Text = "Permissões"
    
    # Seleção de usuário
    $lblUser = New-Object System.Windows.Forms.Label
    $lblUser.Location = New-Object System.Drawing.Point(20, 25)
    $lblUser.Size = New-Object System.Drawing.Size(100, 20)
    $lblUser.Text = "Usuário/Grupo:"
    
    $txtUser = New-Object System.Windows.Forms.TextBox
    $txtUser.Location = New-Object System.Drawing.Point(130, 25)
    $txtUser.Size = New-Object System.Drawing.Size(200, 20)
    
    $btnSelectUser = New-Object System.Windows.Forms.Button
    $btnSelectUser.Location = New-Object System.Drawing.Point(330, 23)
    $btnSelectUser.Size = New-Object System.Drawing.Size(25, 25)
    $btnSelectUser.Text = "..."
    $btnSelectUser.Add_Click({
        # Abrir diálogo de seleção de usuário do AD
        # Esta é uma implementação simplificada; em um ambiente real
        # você deve usar um controle mais robusto para pesquisar no AD
        $userForm = New-Object System.Windows.Forms.Form
        $userForm.Text = "Selecionar Usuário/Grupo"
        $userForm.Size = New-Object System.Drawing.Size(400, 300)
        $userForm.StartPosition = "CenterParent"
        
        $lblSearch = New-Object System.Windows.Forms.Label
        $lblSearch.Location = New-Object System.Drawing.Point(10, 20)
        $lblSearch.Size = New-Object System.Drawing.Size(100, 20)
        $lblSearch.Text = "Pesquisar:"
        $userForm.Controls.Add($lblSearch)
        
        $txtSearch = New-Object System.Windows.Forms.TextBox
        $txtSearch.Location = New-Object System.Drawing.Point(110, 20)
        $txtSearch.Size = New-Object System.Drawing.Size(180, 20)
        $userForm.Controls.Add($txtSearch)
        
        $btnSearch = New-Object System.Windows.Forms.Button
        $btnSearch.Location = New-Object System.Drawing.Point(300, 18)
        $btnSearch.Size = New-Object System.Drawing.Size(80, 25)
        $btnSearch.Text = "Buscar"
        $userForm.Controls.Add($btnSearch)
        
        $listUsers = New-Object System.Windows.Forms.ListView
        $listUsers.Location = New-Object System.Drawing.Point(10, 50)
        $listUsers.Size = New-Object System.Drawing.Size(370, 180)
        $listUsers.View = [System.Windows.Forms.View]::Details
        $listUsers.FullRowSelect = $true
        $listUsers.MultiSelect = $false
        $listUsers.Columns.Add("Nome", 150)
        $listUsers.Columns.Add("Tipo", 100)
        $listUsers.Columns.Add("SAMAccountName", 110)
        $userForm.Controls.Add($listUsers)
        
        $btnOK = New-Object System.Windows.Forms.Button
        $btnOK.Location = New-Object System.Drawing.Point(300, 235)
        $btnOK.Size = New-Object System.Drawing.Size(80, 25)
        $btnOK.Text = "OK"
        $btnOK.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $userForm.Controls.Add($btnOK)
        
        $btnCancel = New-Object System.Windows.Forms.Button
        $btnCancel.Location = New-Object System.Drawing.Point(210, 235)
        $btnCancel.Size = New-Object System.Drawing.Size(80, 25)
        $btnCancel.Text = "Cancelar"
        $btnCancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
        $userForm.Controls.Add($btnCancel)
        
        $userForm.AcceptButton = $btnOK
        $userForm.CancelButton = $btnCancel
        
        # Função para buscar usuários/grupos no AD
        $btnSearch.Add_Click({
            $listUsers.Items.Clear()
            
            if ($txtSearch.Text.Length -lt 3) {
                [System.Windows.Forms.MessageBox]::Show("Digite pelo menos 3 caracteres para pesquisar", "Aviso", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
                return
            }
            
            try {
                # Verificar modo de operação
                if ($rbRemote.Checked -and $script:RemoteCredential) {
                    # Buscar via sessão remota
                    $searchResults = Invoke-Command -ComputerName $script:RemoteServer -Credential $script:RemoteCredential -ScriptBlock {
                        param($searchTerm)
                        $filter = "Name -like '*$searchTerm*' -or SamAccountName -like '*$searchTerm*'"
                        Get-ADObject -Filter $filter -Properties Name, ObjectClass, SamAccountName | Select-Object Name, ObjectClass, SamAccountName
                    } -ArgumentList $txtSearch.Text
                } else {
                    # Buscar localmente
                    $filter = "Name -like '*$($txtSearch.Text)*' -or SamAccountName -like '*$($txtSearch.Text)*'"
                    $searchResults = Get-ADObject -Filter $filter -Properties Name, ObjectClass, SamAccountName | Select-Object Name, ObjectClass, SamAccountName
                }
                
                foreach ($result in $searchResults) {
                    $item = New-Object System.Windows.Forms.ListViewItem($result.Name)
                    $item.SubItems.Add($result.ObjectClass)
                    $item.SubItems.Add($result.SamAccountName)
                    $item.Tag = $result
                    $listUsers.Items.Add($item)
                }
                
                if ($searchResults.Count -eq 0) {
                    [System.Windows.Forms.MessageBox]::Show("Nenhum resultado encontrado", "Informação", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
                }
            }
            catch {
                [System.Windows.Forms.MessageBox]::Show("Erro ao pesquisar: $_", "Erro", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            }
        })
        
        $result = $userForm.ShowDialog()
        
        if ($result -eq [System.Windows.Forms.DialogResult]::OK -and $listUsers.SelectedItems.Count -gt 0) {
            $selectedUser = $listUsers.SelectedItems[0].Tag
            $txtUser.Text = $selectedUser.SamAccountName
        }
    })
    
    # Configuração de permissões
    $gbAccessType = New-Object System.Windows.Forms.GroupBox
    $gbAccessType.Location = New-Object System.Drawing.Point(20, 60)
    $gbAccessType.Size = New-Object System.Drawing.Size(330, 100)
    $gbAccessType.Text = "Tipo de Acesso"
    
    $cbFullControl = New-Object System.Windows.Forms.CheckBox
    $cbFullControl.Location = New-Object System.Drawing.Point(20, 20)
    $cbFullControl.Size = New-Object System.Drawing.Size(150, 20)
    $cbFullControl.Text = "Controle Total"
    
    $cbModify = New-Object System.Windows.Forms.CheckBox
    $cbModify.Location = New-Object System.Drawing.Point(20, 40)
    $cbModify.Size = New-Object System.Drawing.Size(150, 20)
    $cbModify.Text = "Modificar"
    
    $cbReadExecute = New-Object System.Windows.Forms.CheckBox
    $cbReadExecute.Location = New-Object System.Drawing.Point(20, 60)
    $cbReadExecute.Size = New-Object System.Drawing.Size(150, 20)
    $cbReadExecute.Text = "Ler e Executar"
    
    $cbRead = New-Object System.Windows.Forms.CheckBox
    $cbRead.Location = New-Object System.Drawing.Point(20, 80)
    $cbRead.Size = New-Object System.Drawing.Size(150, 20)
    $cbRead.Text = "Ler"
    
    $cbWrite = New-Object System.Windows.Forms.CheckBox
    $cbWrite.Location = New-Object System.Drawing.Point(180, 20)
    $cbWrite.Size = New-Object System.Drawing.Size(150, 20)
    $cbWrite.Text = "Escrever"
    
    $cbListFolder = New-Object System.Windows.Forms.CheckBox
    $cbListFolder.Location = New-Object System.Drawing.Point(180, 40)
    $cbListFolder.Size = New-Object System.Drawing.Size(150, 20)
    $cbListFolder.Text = "Listar Conteúdo"
    
    $gbAccessType.Controls.Add($cbFullControl)
    $gbAccessType.Controls.Add($cbModify)
    $gbAccessType.Controls.Add($cbReadExecute)
    $gbAccessType.Controls.Add($cbRead)
    $gbAccessType.Controls.Add($cbWrite)
    $gbAccessType.Controls.Add($cbListFolder)
    
    # Configuração de herança e propagação
    $gbInheritance = New-Object System.Windows.Forms.GroupBox
    $gbInheritance.Location = New-Object System.Drawing.Point(20, 170)
    $gbInheritance.Size = New-Object System.Drawing.Size(330, 80)
    $gbInheritance.Text = "Herança e Propagação"
    
    $cbApplyToSubfolders = New-Object System.Windows.Forms.CheckBox
    $cbApplyToSubfolders.Location = New-Object System.Drawing.Point(20, 20)
    $cbApplyToSubfolders.Size = New-Object System.Drawing.Size(300, 20)
    $cbApplyToSubfolders.Text = "Aplicar a subpastas"
    $cbApplyToSubfolders.Checked = $true
    
    $cbApplyToFiles = New-Object System.Windows.Forms.CheckBox
    $cbApplyToFiles.Location = New-Object System.Drawing.Point(20, 40)
    $cbApplyToFiles.Size = New-Object System.Drawing.Size(300, 20)
    $cbApplyToFiles.Text = "Aplicar a arquivos"
    $cbApplyToFiles.Checked = $true
    
    $gbInheritance.Controls.Add($cbApplyToSubfolders)
    $gbInheritance.Controls.Add($cbApplyToFiles)
    
    # Botões de ação
    $btnApply = New-Object System.Windows.Forms.Button
    $btnApply.Location = New-Object System.Drawing.Point(20, 260)
    $btnApply.Size = New-Object System.Drawing.Size(150, 30)
    $btnApply.Text = "Aplicar Permissões"
    $btnApply.Add_Click({
        if (-not $txtUser.Text) {
            [System.Windows.Forms.MessageBox]::Show("Selecione um usuário ou grupo", "Aviso", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            return
        }
        
        $selectedNodes = New-Object System.Collections.ArrayList
        
        # Função recursiva para obter nós selecionados
        function Get-SelectedNodes($nodes) {
            foreach ($node in $nodes) {
                if ($node.Checked) {
                    $selectedNodes.Add($node)
                }
                
                if ($node.Nodes.Count -gt 0) {
                    Get-SelectedNodes $node.Nodes
                }
            }
        }
        
        Get-SelectedNodes $treeView.Nodes
        
        if ($selectedNodes.Count -eq 0) {
            [System.Windows.Forms.MessageBox]::Show("Selecione pelo menos uma pasta", "Aviso", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            return
        }
        
        # Configurar permissões baseadas nas seleções
        $fileSystemRights = 0
        
        if ($cbFullControl.Checked) { $fileSystemRights = $fileSystemRights -bor [System.Security.AccessControl.FileSystemRights]::FullControl }
        if ($cbModify.Checked) { $fileSystemRights = $fileSystemRights -bor [System.Security.AccessControl.FileSystemRights]::Modify }
        if ($cbReadExecute.Checked) { $fileSystemRights = $fileSystemRights -bor [System.Security.AccessControl.FileSystemRights]::ReadAndExecute }
        if ($cbRead.Checked) { $fileSystemRights = $fileSystemRights -bor [System.Security.AccessControl.FileSystemRights]::Read }
        if ($cbWrite.Checked) { $fileSystemRights = $fileSystemRights -bor [System.Security.AccessControl.FileSystemRights]::Write }
        if ($cbListFolder.Checked) { $fileSystemRights = $fileSystemRights -bor [System.Security.AccessControl.FileSystemRights]::ListDirectory }
        
        if ($fileSystemRights -eq 0) {
            [System.Windows.Forms.MessageBox]::Show("Selecione pelo menos um tipo de permissão", "Aviso", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            return
        }
        
        # Confirmar operação
        $message = "Você está prestes a modificar permissões para $($txtUser.Text) em $($selectedNodes.Count) pasta(s). Continuar?"
        $result = [System.Windows.Forms.MessageBox]::Show($message, "Confirmação", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
        
        if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
            $progressBar.Value = 0
            $progressBar.Maximum = $selectedNodes.Count
            $progressBar.Visible = $true
            
            # Configurar propagação
            $inheritanceFlags = [System.Security.AccessControl.InheritanceFlags]::None
            $propagationFlags = [System.Security.AccessControl.PropagationFlags]::None
            
            if ($cbApplyToSubfolders.Checked) {
                $inheritanceFlags = $inheritanceFlags -bor [System.Security.AccessControl.InheritanceFlags]::ContainerInherit
            }
            
            if ($cbApplyToFiles.Checked) {
                $inheritanceFlags = $inheritanceFlags -bor [System.Security.AccessControl.InheritanceFlags]::ObjectInherit
            }
            
            $count = 0
            $errors = 0
            
            foreach ($node in $selectedNodes) {
                try {
                    $path = $node.Tag
                    
                    if ($rbRemote.Checked -and $script:RemoteCredential) {
                        # Aplicar permissões remotamente
                        Invoke-Command -ComputerName $script:RemoteServer -Credential $script:RemoteCredential -ScriptBlock {
                            param($path, $user, $rights, $type, $inheritance, $propagation)
                            
                            $acl = Get-Acl $path
                            $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($user, $rights, $inheritance, $propagation, $type)
                            $acl.SetAccessRule($accessRule)
                            Set-Acl $path $acl
                        } -ArgumentList $path, $txtUser.Text, $fileSystemRights, "Allow", $inheritanceFlags, $propagationFlags
                    } else {
                        # Aplicar permissões localmente
                        $acl = Get-Acl $path
                        $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($txtUser.Text, $fileSystemRights, $inheritanceFlags, $propagationFlags, "Allow")
                        $acl.SetAccessRule($accessRule)
                        Set-Acl $path $acl
                    }
                    
                    $count++
                }
                catch {
                    $errors++
                    $statusBar.Text = "Erro em $path`: $_"
                }
                
                $progressBar.Value++
                [System.Windows.Forms.Application]::DoEvents()
            }
            
            $progressBar.Visible = $false
            
            if ($errors -eq 0) {
                [System.Windows.Forms.MessageBox]::Show("Permissões aplicadas com sucesso em $count pasta(s)", "Sucesso", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
                $statusBar.Text = "Permissões aplicadas com sucesso"
            } else {
                [System.Windows.Forms.MessageBox]::Show("Permissões aplicadas em $count pasta(s) com $errors erro(s)", "Aviso", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            }
        }
    })
    
    $btnRemove = New-Object System.Windows.Forms.Button
    $btnRemove.Location = New-Object System.Drawing.Point(180, 260)
    $btnRemove.Size = New-Object System.Drawing.Size(150, 30)
    $btnRemove.Text = "Remover Permissões"
    $btnRemove.Add_Click({
        if (-not $txtUser.Text) {
            [System.Windows.Forms.MessageBox]::Show("Selecione um usuário ou grupo", "Aviso", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            return
        }
        
        $selectedNodes = New-Object System.Collections.ArrayList
        
        # Função recursiva para obter nós selecionados
        function Get-SelectedNodes($nodes) {
            foreach ($node in $nodes) {
                if ($node.Checked) {
                    $selectedNodes.Add($node)
                }
                
                if ($node.Nodes.Count -gt 0) {
                    Get-SelectedNodes $node.Nodes
                }
            }
        }
        
        Get-SelectedNodes $treeView.Nodes
        
        if ($selectedNodes.Count -eq 0) {
            [System.Windows.Forms.MessageBox]::Show("Selecione pelo menos uma pasta", "Aviso", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            return
        }
        
        # Confirmar operação
        $message = "Você está prestes a REMOVER permissões para $($txtUser.Text) em $($selectedNodes.Count) pasta(s). Continuar?"
        $result = [System.Windows.Forms.MessageBox]::Show($message, "Confirmação", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Warning)
        
        if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
            $progressBar.Value = 0
            $progressBar.Maximum = $selectedNodes.Count
            $progressBar.Visible = $true
            
            $count = 0
            $errors = 0
            
            foreach ($node in $selectedNodes) {
                try {
                    $path = $node.Tag
                    
                    if ($rbRemote.Checked -and $script:RemoteCredential) {
                        # Remover permissões remotamente
                        Invoke-Command -ComputerName $script:RemoteServer -Credential $script:RemoteCredential -ScriptBlock {
                            param($path, $user)
                            
                            $acl = Get-Acl $path
                            $accessRules = $acl.Access | Where-Object { $_.IdentityReference.Value -eq $user }
                            
                            foreach ($rule in $accessRules) {
                                $acl.RemoveAccessRule($rule)
                            }
                            
                            Set-Acl $path $acl
                        } -ArgumentList $path, $txtUser.Text
                    } else {
                        # Remover permissões localmente
                        $acl = Get-Acl $path
                        $accessRules = $acl.Access | Where-Object { $_.IdentityReference.Value -eq $txtUser.Text }
                        
                        foreach ($rule in $accessRules) {
                            $acl.RemoveAccessRule($rule)
                        }
                        
                        Set-Acl $path $acl
                    }
                    
                    $count++
                }
                catch {
                    $errors++
                    $statusBar.Text = "Erro em $path`: $_"
                }
                
                $progressBar.Value++
                [System.Windows.Forms.Application]::DoEvents()
            }
            
            $progressBar.Visible = $false
            
            if ($errors -eq 0) {
                [System.Windows.Forms.MessageBox]::Show("Permissões removidas com sucesso em $count pasta(s)", "Sucesso", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
                $statusBar.Text = "Permissões removidas com sucesso"
            } else {
                [System.Windows.Forms.MessageBox]::Show("Permissões removidas em $count pasta(s) com $errors erro(s)", "Aviso", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            }
        }
    })
    
    $gbPermissions.Controls.Add($lblUser)
    $gbPermissions.Controls.Add($txtUser)
    $gbPermissions.Controls.Add($btnSelectUser)
    $gbPermissions.Controls.Add($gbAccessType)
    $gbPermissions.Controls.Add($gbInheritance)
    $gbPermissions.Controls.Add($btnApply)
    $gbPermissions.Controls.Add($btnRemove)
    
    # Barra de progresso
    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Location = New-Object System.Drawing.Point(20, 505)
    $progressBar.Size = New-Object System.Drawing.Size(750, 20)
    $progressBar.Visible = $false
    
    # Barra de status
    $statusBar = New-Object System.Windows.Forms.StatusBar
    $statusBar.Text = "Pronto"
    
    # Adicionar controles ao formulário
    $form.Controls.Add($gbOperationMode)
    $form.Controls.Add($gbFolderSelection)
    $form.Controls.Add($gbFolderView)
    $form.Controls.Add($gbPermissions)
    $form.Controls.Add($progressBar)
    $form.Controls.Add($statusBar)
    
    # Verificar módulo Active Directory
    if (-not $hasADModule) {
        [System.Windows.Forms.MessageBox]::Show(
            "O módulo Active Directory não está instalado. Algumas funcionalidades podem não funcionar corretamente. Para instalar o módulo, execute: 'Install-WindowsFeature RSAT-AD-PowerShell' em um PowerShell com privilégios administrativos.",
            "Aviso", 
            [System.Windows.Forms.MessageBoxButtons]::OK, 
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )
    }
    
    # Mostrar o formulário
    [void]$form.ShowDialog()
}

# Iniciar a aplicação
Initialize-App 