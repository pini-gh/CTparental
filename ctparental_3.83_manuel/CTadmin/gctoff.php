<?php
echo "<TABLE width='100%' border=0 cellspacing=0 cellpadding=0>";
echo "<tr><th>$l_title_gctoff</th></tr>";
echo "<tr bgcolor='#FFCC66'><td><img src='/images/pix.gif' width='1' height='2'></td></tr>";
echo "</table>";
echo "<table width='100%' border=1 cellspacing=0 cellpadding=1>";
if ($GCTOFF == "ON")
	{
	echo "<CENTER><H3>$l_gctoff_on</H3></CENTER>";
 	echo "<FORM action='$_SERVER[PHP_SELF]' method=POST>";
	echo "<input type=hidden name='choix' value=\"gct_Off\">";
	echo "<input type=submit value=\"$l_switch_gctoff_off\">";
	echo "</FORM>";

	
	echo "<tr><td colspan=2 align='center'>";
	echo "$l_gctoff_explain</td></tr>";
	echo "<tr><td align='center' valign='middle'>";
	echo "<FORM action='$_SERVER[PHP_SELF]' method='POST'>";
	echo "<table cellspacing=2 cellpadding=2 border=1>";
	echo "<tr><th>$l_gctoff_username<th></tr>";
	// Read the "CTOFF.conf" file
	exec ("sudo /usr/local/bin/CTparental.sh -gctulist");
	$tab=file($conf_ctoff_file);
	if ($tab)  # the file isn't empty
		{
		foreach ($tab as $line)
			{
			if (trim($line) != '') # the line isn't empty
				{
				$user_lignes=explode(" ", $line);
				$userx=trim($user_lignes[0],"#");
				echo "<tr><td>$userx";
				echo "<td><input type='checkbox' name='chk-$userx'";
				if (preg_match('/^#/',$line, $r)) {
					echo ">";}
				else {
					echo "checked>";}
				echo "</tr>";
				}
			}
		}
	
	echo "</table>";
	echo "<input type='hidden' name='choix' value='change_user'>";
	echo "<input type='submit' value='$l_record'>";
	echo "</form>";
}
else
	{
	echo "<CENTER><H3> $l_gctoff_off</H3></CENTER>";
 	echo "<FORM action='$_SERVER[PHP_SELF]' method=POST>";
	echo "<input type=hidden name='choix' value=\"gct_On\">";
	echo "<input type=submit value=\"$l_switch_gctoff_on\">";
	echo "</FORM>";
	}





