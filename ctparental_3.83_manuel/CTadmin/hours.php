
<?php
echo "<TABLE width='100%' border=0 cellspacing=0 cellpadding=0>";
echo "<tr><th>$l_hours1</th></tr>";
echo "<tr bgcolor='#FFCC66'><td><img src='/images/pix.gif' width=1 height=2></td></tr>";
echo "</TABLE>";
echo "<TABLE width='100%' border=1 cellspacing=0 cellpadding=0>";
echo "<tr><td valign='middle' align='left'>";
if ($HOURSCONNECT == "ON")
	{
	echo "<CENTER><H3>$l_hours_on</H3></CENTER>";
 	echo "<FORM action='$_SERVER[PHP_SELF]' method=POST>";
	echo "<input type=hidden name='choix' value=\"H_Off\">";
	echo "<input type=submit value=\"$l_switch_hours_off\">";
	echo "</FORM>";

	if (isset($_POST['selectuser'])){ $selectuser=$_POST['selectuser']; }


	### on lit est on interprète le fichier CTparental.conf
	echo "<TABLE width='100%' border=0 cellspacing=0 cellpadding=0>";
	exec ("/usr/local/bin/CTparental.sh -listusers 2> /dev/null",$USERSPC); # récupération des utilisateurs du poste.(UID >= 1000)
	echo "<FORM action='$_SERVER[PHP_SELF]' method=POST>";
		echo "<select name=\"selectuser\">";
		if (isset($selectuser)){echo "<option value=\"$selectuser\">$selectuser\n"; }
			else {echo "<option value=\"\">\n"; }
		foreach ($USERSPC as $USERSELECT){echo "<option value=\"$USERSELECT\">$USERSELECT\n";}
		echo " </select>";
	echo "<input type=\"submit\" value=\"$l_select\">";
	echo "</FORM>";
	if (isset($selectuser)) {
		echo "</TABLE>";
		echo "<TABLE width='600' border=0 cellspacing=0 cellpadding=0>";
		echo "<FORM action='$_SERVER[PHP_SELF]' method=POST>";
		echo "<CENTER><H3>$l_selectuser $selectuser</H3></CENTER>";
		
		if (is_file ($hconf_file))
			{
			$tab=file($hconf_file);
			if ($tab)
				{
				foreach ($tab as $line)
					{
							$field=explode("=", $line);
								if ( $field[0] == $selectuser ){
								$field2=explode(":", $field[2]);
							$numday=$field[1];
							$isconfigured=1;
							
							if ( $numday == "admin") { echo "<tr><td>$l_isadmin : <input type='checkbox' name='isadmin' checked></td></tr>";}
							elseif ( $numday == "user") {echo "<tr><td>$l_isadmin : <input type='checkbox' name='isadmin' ></td></tr>";
										if ( intval ($field[2]) == 0 ) { $field[2]="1440"; }
										echo"<tr><td>$tmaxinfo<td><INPUT type=\"text\" size=4 maxlength=4 value=\"$field[2]\"  name=\"tmax\">/1440<td</tr>";	
										}
										
							else {
								if ( isset ($field2[0]) ) {
									echo"<tr><td>$week[$numday]:</td><td><INPUT type=\"text\" size=5 maxlength=5 value=\"$field2[0]\"  name=\"h1$numday\"></td>";
									echo" <td>$to <INPUT type=\"text\" size=5 maxlength=5 value=\"$field2[1]\" name=\"h2$numday\"></td>";
									}
								else {
									echo"<tr><td>$week[$numday]:</td><td><INPUT type=\"text\" size=5 maxlength=5 value=\"\"  name=\"h1$numday\"></td>";
									echo" <td>$to <INPUT type=\"text\" size=5 maxlength=5 value=\"\" name=\"h2$numday\"></td>";
									
								}
								if ( isset ($field2[2]) ) {
										echo" <td>$and <INPUT type=\"text\" size=5 maxlength=5 value=\"$field2[2]\" name=\"h3$numday\"></td>";	
										echo" <td>$to <INPUT type=\"text\" size=5 maxlength=5 value=\"$field2[3]\" name=\"h4$numday\"></td></tr>";
									}
								else {
										echo" <td>$and <INPUT type=\"text\" size=5 maxlength=5 value=\"\" name=\"h3$numday\"></td>";	
										echo" <td>$to <INPUT type=\"text\" size=5 maxlength=5 value=\"\" name=\"h4$numday\"></td></tr>";	
								}
							}
														
						}
							
					}
					
				}
			
			}
		else { echo "$l_error_open_file $hconf_file";}

		if (isset($isconfigured)==0){
			echo "<tr><td>$l_isadmin : <input type='checkbox' name='isadmin' checked=\"checked\"></td></tr>";
		}


		echo "</TABLE>";
		echo "<input type=hidden name='selectuser' value=\"$selectuser\">";
			echo "<input type=hidden name='choix' value=\"MAJ_H\">";
		echo "<input type=\"submit\" value=\"$l_valide\">";
		echo "</FORM>";
	}
	else { echo "<CENTER><H3>$l_userisnotselect</H3></CENTER>";}

}
else
	{
	echo "<CENTER><H3>$l_hours_off</H3></CENTER>";
 	echo "<FORM action='$_SERVER[PHP_SELF]' method=POST>";
	echo "<input type=hidden name='choix' value=\"H_On\">";
	echo "<input type=submit value=\"$l_switch_hours_on\">";
	echo "</FORM>";
	}



?>

