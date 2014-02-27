<?php

if ($DNSMASQ <> "OFF")
	{
	echo "<CENTER><H3>$l_dnsfilter_on</H3></CENTER>";
 	echo "<FORM action='$_SERVER[PHP_SELF]' method=POST>";
	echo "<input type=hidden name='choix' value=\"BL_Off\">";
	echo "<input type=submit value=\"$l_switch_filtering_off\">";
	echo "</FORM>";

	if (isset($_GET['filtragemode'])){ $filtragemode=$_GET['filtragemode']; } else {$filtragemode=$DNSMASQ;}
	if ($filtragemode == 'WHITE')
	{
	$bl_categories="/usr/local/etc/CTparental/wl-categories-available";
	}
	else { $bl_categories="/usr/local/etc/CTparental/bl-categories-available";}

	$filtragemode = urlencode($filtragemode);
	echo "<table border=0 width=400 cellpadding=0 cellspacing=2>";
	echo "<tr valign=top>";
	echo "<td align=center"; if ( $filtragemode == "BLACK" ) { echo " bgcolor=\"#FFCC66\"";} echo ">";
	echo "<a href=\"$_SERVER[PHP_SELF]?filtragemode=BLACK\" title=\"\"><font color=\"black\"><b>$l_fmenu_black</b></font></a></td>";
	echo "<td align=center"; if ( $filtragemode == "WHITE" ) { echo " bgcolor=\"#FFCC66\"";} echo ">";
	echo "<a href=\"$_SERVER[PHP_SELF]?filtragemode=WHITE\" title=\"\"><font color=\"black\"><b>$l_fmenu_white</b></font></a></td>";
	echo "</tr>";
	echo" </table>";
	echo "</td></tr>";


	function echo_file ($filename)
		{
		if (file_exists($filename))
			{
			if (filesize($filename) != 0)
				{
				$pointeur=fopen($filename,"r");
				$tampon = fread($pointeur, filesize($filename));
				fclose($pointeur);
				echo $tampon;
				}
			}
		else
			{
			echo "$l_error_openfile $filename";
			}
		}

	echo "<TABLE width='100%' border=1 cellspacing=0 cellpadding=1>";
	echo "<CENTER><H3>$l_main_bl</H3></CENTER>";
	echo "<tr><td valign='middle' align='left' colspan=10>";
	echo "<FORM action='$_SERVER[PHP_SELF]' method=POST>";
	echo "<center>$l_bl_version $LASTUPDATE";
	echo "</center><BR>";
		echo "<input type='hidden' name='choix' value='Download_bl'>";
		echo "<input type='submit' value='$l_download_bl'>";
		echo " ($l_warning)";

	echo "</FORM>";
	echo "<FORM action='$_SERVER[PHP_SELF]' method=POST>";
	echo "<input type='hidden' name='choix' value='INIT_BL'>";
	echo "<input type='submit' value='$l_switch_Init_bl'>";
	echo "</FORM>";
	if ($AUTOUPDATE == "ON")
		{
		echo "<CENTER><H3>$l_auto_update_on</H3></CENTER>";
		echo "<FORM action='$_SERVER[PHP_SELF]' method=POST>";
		echo "<input type=hidden name='choix' value=\"AUP_Off\">";
		echo "<input type=submit value=\"$l_switch_auto_update_off\">";
	}
	else
		{
		echo "<CENTER><H3>$l_auto_update_off</H3></CENTER>";
		echo "<FORM action='$_SERVER[PHP_SELF]' method=POST>";
		echo "<input type=hidden name='choix' value=\"AUP_On\">";
		echo "<input type=submit value=\"$l_switch_auto_update_on\">";
		}
	echo "</FORM>";
	echo "</td></tr>";
	echo "<tr><td valign=\"middle\" align=\"left\" colspan=10>";
	echo "<FORM action='$_SERVER[PHP_SELF]' method=POST>";
	echo "<input type='hidden' name='choix' value='MAJ_cat'>";
	if ($filtragemode == "BLACK"){echo "<center>$l_bl_categories_bl</center></td></tr>";}
	else {echo "<center>$l_bl_categories_wl</center></td></tr>";}

	//on lit et on interprète le fichier de catégories
	$cols=1; 
	if (file_exists($bl_categories))
		{
		$pointeur=fopen($bl_categories,"r");
		while (!feof ($pointeur))
			{
			$ligne=fgets($pointeur, 4096);
			if ($ligne)
				{
				if ($cols == 1) { echo "<tr>";}
				$categorie=trim(basename($ligne));
				echo "<td><a href='bl_categories_help.php?cat=$categorie' target='cat_help' onclick=window.open('bl_categories_help.php','cat_help','width=600,height=150,toolbar=no,scrollbars=no,resizable=yes') title='categories help page'>$categorie</a><br>";
				echo "<input type='checkbox' name='chk-$categorie'";
				// la catégorie n'existe pas dans le fichier de catégorie activé -> categorie non selectionnée
							$str = file_get_contents($bl_categories_enabled);
				if (strpos($str, $categorie)===false) { echo ">";}
				else { echo "checked>"; }
				echo "</td>";
				$cols++;
				if ($cols > 10) {
					echo "</tr>";
					$cols=1; }
				}
			}
		fclose($pointeur);
		}
	else	{
		echo "$l_error_open_file $bl_categories";
		}
	echo "</td></tr>";
	echo "<tr><td valign='middle' align='left' colspan=10></td></tr>";
	echo "<tr><td colspan=5 align=center>";
	if ($filtragemode == "BLACK"){echo "<H3>$l_rehabilitated_dns</H3>$l_rehabilitated_dns_explain_bl<BR>$l_one_dns<BR>";}
	else {echo "<H3>$l_rehabilitated_dns</H3>$l_rehabilitated_dns_explain_wl<BR>$l_one_dns<BR>";}
	echo "<textarea name='OSSI_wl_domains' rows=5 cols=40>";
	echo_file ($wl_domains);
	echo "</textarea></td>";
	if ( $filtragemode == "BLACK" ) {
	echo "<td colspan=5 align=center>";
	echo "<H3>$l_forbidden_dns</H3>$l_forbidden_dns_explain<BR>";
	echo "<textarea name='OSSI_bl_domains' rows=5 cols=40>";
	echo_file ($bl_domains);
	echo "</textarea></td>";
	}
	echo "</tr><tr><td colspan=10>";

	echo "<input type='submit' value='$l_record'>";
	echo "</form> ($l_wait)";

	echo "</td></tr>";
	echo "</TABLE>";
	echo "</TABLE>";


}
else
	{
	echo "<CENTER><H3>$l_dnsfilter_off</H3></CENTER>";
 	echo "<FORM action='$_SERVER[PHP_SELF]' method=POST>";
	echo "<input type=hidden name='choix' value=\"BL_On\">";
	echo "<input type=submit value=\"$l_switch_filtering_on\">";
	echo "</FORM>";
	echo "</td></tr>";
	}




?>
