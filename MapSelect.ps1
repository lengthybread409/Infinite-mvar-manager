cd $PSScriptRoot

$global:Map_Directory = '.\Custom Maps'
$global:Save_Location = ".\__cms__\rtx-new\variants\Test.mvar"
$global:Active_Map_Name = 'active.map'

$global:List_of_Maps = $null
$global:Active_Map = $null

mkdir "$Map_Directory\BackUp" -ErrorAction Ignore

function f_set-current-map{
    Param([Parameter(Mandatory=$true)]$file)
    $tst = try{Test-Path $file.FullName}catch{$false}
    if($tst){
        $Active_Map = $file.Name
        Copy-Item -Path $file.FullName -Destination "$Map_Directory\$Active_Map_Name"
    }
}

function f_update_list{
    $global:List_of_Maps = Get-ChildItem "$Map_Directory\*.mvar"
}

function f_backup_map{
    Param([Parameter(Mandatory=$true)][string]$Name)
    if(Test-Path "$Map_Directory\$name"){
        $list = Get-ChildItem "$Map_Directory\BackUp\$($name.Replace('.mvar',''))-*-BU.mvar"
        $tmp = '001'
        if($list.count -gt 0){
            $tmp = "{0:d3}" -f ([int]($list[-1].name.Substring($list[-1].name.Length-11,3))+1)
        }
        Move-Item -Path "$Map_Directory\$name" -Destination "$Map_Directory\BackUp\$($name.Replace('.mvar',''))-$tmp-BU.mvar"
        return $true
    }else{
        return $false
    }
}

function global:forge{
    Param([Parameter(Mandatory=$true)][string]$Name)
    if('' -eq $Name){write-host -ForegroundColor Red "Please have a name" ;return}
    if(-not $Name.Contains('.mvar')){$name = "$name.mvar"}
    if(Test-Path $Save_Location){
        write-host -ForegroundColor Cyan "Forge file present! Do you want me to save or remove it?"
        $ans = Read-Host "s\r"
        if($ans -eq 'r'){
            Remove-Item -Path $Save_Location
        }
        elseif($ans -eq 's'){
            $a = f_backup_map $name
            move-item -Path $Save_Location -Destination "$Map_Directory\$name"
        }else{
            write-host -ForegroundColor Red "Inavlid answer. Cancled operation" ;return
        }
    }
    write-host -ForegroundColor Yellow "Press Ctrl+C to exit"
    write-host "Map Name: $name"
    do{sleep 1
        if(Test-Path $Save_Location){sleep 1
            $a = f_backup_map $name
            move-item -Path $Save_Location -Destination "$Map_Directory\$name"
            write-host "File saved."
        }   
    }while($true)
}

function global:New_Map{
    f_update_list
    write-host -ForegroundColor Cyan "Select a map from the list below"
    write-host "Index`t| Map Name"
    foreach($map_index in 1..($List_of_Maps.count)){
        write-host "$map_index`t`t| $($List_of_Maps[$map_index-1].Name)"
    }
    $select = read-host "Index"
    try{
        f_set-current-map $List_of_Maps[([int]$select)-1]
    }catch{
        write-host -ForegroundColor Red "Invalid selection" ;return
    } 
}

function global:info{
    write-host "Current Map: $Active_Map"
    write-host "Available commands:"
    write-host "`tNew_Map <- Changes the selected file as the $Active_Map_Name"
    write-host "`tforge <- Continuously monotors for newly saved forge files and moves it into the map list.`n`t`tOld files will be backed up as well"
    write-host "`tinfo <- print this message again"
}
info