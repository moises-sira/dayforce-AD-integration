$user=$env:USER
$password=$env:PASSWORD
$table_name=$env:SOURCE_TABLE
$dburl="postgresql://"+$user+":"+$password+"@stage-postgres-01.chaxpheegiww.us-west-2.rds.amazonaws.com:5432/dayforce_hr"
$csv="select * from $table_name"| psql --csv $dburl | ConvertFrom-Csv -UseCulture

ForEach ($item In $csv){
$mail_manager=""
#Find and match manager id with email
    ForEach($item2 in $csv){
        if ($item."second_level_manager_id" -eq $item2."id"){$mail_manager = $item2."value"
        break
    }
}

$email = $item."value"
$Display_Name = $item."first_name"+" "+$item."last_name"
$username = $email.Split("@")
$manager_user = $mail_manager.Split("@")
    
    #depends on employment_status "Active or Terminated"
    if ($item."employment_status" -eq "Active"){
    #control
    write-host $email "| aduser:" $username[0] "| manager email: " $mail_manager " | manager ADuser:"$manager_user[0]
    
###################### Updating users... ###################################
    
    # id
    Set-ADUser -Identity $username[0] -employeeID $item."id" 

    # employee_number
    Set-ADUser -Identity $username[0] -employeeNumber $item."employee_number" 

    # manager
    Set-ADUser -Identity $username[0] -Manager $manager_user[0]

    # email
    Set-ADUser -Identity $username[0] -email $email

    # Job title
    Set-ADUser -Identity $username[0] -Title $item."job"

    # description | position
    Set-ADUser -Identity $username[0] -description $item."position"

    # department
    Set-ADUser -Identity $username[0] -department $item."department"

    # Office 
    Set-ADUser -Identity $username[0] -Office $item."location"
      
    # company | legal_entity_name
    Set-ADUser -Identity $username[0] -company $item."legal_entity_name"
          
    # First name
    Set-ADUser -Identity $username[0] -GivenName $item."first_name"
              
    # Surename
    Set-ADUser -Identity $username[0] -Surname $item."last_name"
               
    # DisplayName
    Set-ADUser -Identity $username[0] -DisplayName $Display_Name                 

    ## -GivenName, -Surname, -DisplayName office address????? 

    }
}
