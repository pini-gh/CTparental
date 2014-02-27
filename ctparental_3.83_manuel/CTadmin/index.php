<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><!-- written by Rexy -->
<HEAD>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<TITLE>CTparental DNS filtering</TITLE>
<link rel="stylesheet" href="/CTadmin/css/style.css" type="text/css">
</HEAD>
<body>
<?php
function form_filter ($form_content)
{
// réencodage iso + format unix + rc fin de ligne (ouf...)
	$list = str_replace("\r\n", "\n", utf8_decode($form_content));
	if (strlen($list) != 0){
		if ($list[strlen($list)-1] != "\n") { $list[strlen($list)]="\n";} ;} ;
	return $list;
}
# Choice of language
$Language = 'en';
if(isset($_SERVER['HTTP_ACCEPT_LANGUAGE'])){
  $Langue = explode(",",$_SERVER['HTTP_ACCEPT_LANGUAGE']);
  $Language = strtolower(substr(chop($Langue[0]),0,2)); }
if($Language == 'fr'){
 $l_selectuser="l'utilisateur selectionné est : ";
 $l_userisnotselect="Veuillez selectionner un utilisateur.";
 $l_isadmin = "7j/7 24h/24";
 $l_valide = "Enregistrer";
 $to = " à " ;
 $and = " et " ;
 $l_select = "Sélectionner";
 $l_info1 = "08h00 à 24h00 ou 08h00 à 12h00 et 14h00 à 24h00";
 $week = array( "lundi","mardi","mercredi","jeudi","vendredi","samedi","dimanche");
  $tmaxinfo= "Minutes max /24 heurs";
  $l_switch_LogOFF="Déconnection";
  $l_hours_error1="un mauvais format horaire a été trouvé :exemple 8h30 doit s'écrire 08h30";
  $l_hours_error2="incohérence horaire : ";
  $l_hours_error3="Vous devez rentrer une valeur entre 1 et 1440 minutes.";
  $l_hours_on = "Les horaires de connexion sont actuellement activés";
  $l_hours_off = "Les horaires de connexion sont actuellement désactivés";
  $l_switch_hours_off = "Désactiver les horaires de connexion";
  $l_switch_hours_on = "Activer les horaires de connexion";
  $l_hours1 = "Heures de connexions autorisées";
  $l_switch_Init_bl = "Init Catégories";
  $l_auto_update_on = "La mise à jour de la blacklist de Toulouse tous les 7 jours est activée";
  $l_auto_update_off = "La mise à jour de la blacklist de Toulouse tous les 7 jours est désactivée";
  $l_switch_auto_update_on = "Activer Maj Auto";
  $l_switch_auto_update_off = "Désactiver Maj Auto";
  $l_fmenu_black = "Filtrage par BlackList";
  $l_fmenu_white = "Filtrage par WhiteList";
  $l_title1 = "Filtrage de noms de domaine ";
  $l_error_open_file="Erreur d'ouverture du fichier";
  $l_dnsfilter_on="Le filtrage de noms de domaine est actuellement activé";
  $l_dnsfilter_off="Le filtrage de noms de domaine est actuellement désactivé";
  $l_switch_filtering_on="Activer le filtrage";
  $l_switch_filtering_off="Désactiver le filtrage";
  $l_main_bl="Liste noire/blanche";
  $l_bl_version="Version actuelle :";
  $l_bl_categories_bl="Choix des catégories à filtrer";
  $l_bl_categories_wl="Choix des catégories à autoriser";
  $l_download_bl="Télécharger la dernière version";
  $l_fingerprint="L'empreinte numérique du fichier téléchargé est : ";
  $l_fingerprint2="Vérifiez-là en suivant ce lien (ligne 'blacklists.tar.gz') : ";
  $l_activate_bl="Activer la nouvelle version";
  $l_reject_bl="Rejeter";
  $l_warning="Temps estimé : une minute.";
  $l_specific_filtering="Filtrage spécial";
  $l_forbidden_dns="Noms de domaine filtrés";
  $l_forbidden_dns_explain="Entrez un nom de domaine par ligne (exemple : domaine.org)";
  $l_one_dns="Entrez un nom de domaine par ligne (exemple : domaine.org)";
  $l_rehabilitated_dns="Noms de domaine réhabilités";
  $l_rehabilitated_dns_explain_bl="1-Entrez ici des noms de domaine bloqués par la liste noire <BR> que vous souhaitez réhabiliter.";
  $l_rehabilitated_dns_explain_wl="2-Entrez ici des noms de domaine autorisés en plus de ceux <BR> de la liste blanche de Toulouse.";
  $l_add_to_bl="Noms de domaine ajoutés à la liste noire";
  $l_record="Enregistrer les modifications";
  $l_wait="Une fois validées, 30 secondes sont nécessaires pour traiter vos modifications";
  $l_title_gctoff="Groupe privilégié";
  $l_gctoff_explain="Cocher des utilisateurs ne devant pas subir de filtrage";
  $l_gctoff_username="Nom d'utilisateur";
  $l_gctoff_username_comment="Commentaires";
  $l_switch_gctoff_on="Activer le groupe de privilégiés.";
  $l_switch_gctoff_off="Désactiver le groupe de privilégiés.";
  $l_gctoff_on = "Le Groupe privilégié est actuellement activés";
  $l_gctoff_off = "Le Groupe privilégié est actuellement désactivés";

}
else {
  $l_userisnotselect="Veuillez sélectionner un utilisateur.";
  $l_selectuser="l'utilisateur sélectionné est : ";
  $l_isadmin = "7j/7 24h/24";
  $l_valide = "Enregistrer";
  $l_select = "Select";
  $to = " to " ;
  $and = " and " ;
  $l_info1 = "08h00 à 24h00 ou 08h00 à 12h00 et 14h00 à 24h00";
  $week = array( "lundi","mardi","mercredi","jeudi","vendredi","samedi","dimanche");
  $tmaxinfo= "Minutes max /24 heurs";
  $l_switch_LogOFF="Logout";
  $l_hours_error1="Un mauvais format horaire a été trouvé : exemple 8h30 doit s'écrire 08h30";
  $l_hours_error2="incohérence horaire : ";
  $l_hours_error3="Vous devez rentrer une valeur entre 1 et 1440 minutes.";
  $l_hours_on = "Les horaires de connexion sont actuellement activés";
  $l_hours_off = "Les horaires de connexion sont actuellement désactivés";
  $l_switch_hours_off = "Désactiver les horaires de connexion";
  $l_switch_hours_on = "Activer les horaires de connexion";
  $l_hours1 = "Heures de connexions autorisées";
  $l_switch_Init_bl = "Init Catégories";
  $l_auto_update_on = "La mise à jour de la blacklist de Toulouse tous les 7 jours est activée";
  $l_auto_update_off = "La mise à jour de la blacklist de Toulouse tous les 7 jours est désactivée";
  $l_switch_auto_update_on = "Activer Maj Auto";
  $l_switch_auto_update_off = "Désactiver Maj Auto";
  $l_fmenu_black = "Filtrage par BlackList";
  $l_fmenu_white = "Filtrage par WhiteList";
  $l_title1 = "Domain names filtering";
  $l_error_open_file="Error opening the file";
  $l_dnsfilter_on="Actually, the Domain name filter is on";
  $l_dnsfilter_off="Actually, the Domain name filter is off";
  $l_switch_filtering_on="Switch the Filter on";
  $l_switch_filtering_off="Switch the Filter off";
  $l_main_bl="Blacklist/Whitelist";
  $l_bl_version="Current version : ";
  $l_bl_categories_bl="Choice of filtered categories";
  $l_bl_categories_wl="Choice of authorized categories";
  $l_download_bl="Download the last version";
  $l_fingerprint="The digital fingerprint of the downloaded blacklist is : ";
  $l_fingerprint2="Verify it with this link (line 'blacklists.tar.gz') : ";
  $l_activate_bl="Activate the new version";
  $l_reject_bl="Reject";
  $l_warning="Estimated time : one minute.";
  $l_specific_filtering="Specific filtering";
  $l_forbidden_dns="Filtered domain names";
  $l_forbidden_dns_explain="Enter one domain name per row (exemple : domain.org)";
  $l_one_dns="Enter one domain name per row (example : domain.org)";
  $l_rehabilitated_dns="Rehabilitated domain names";
  $l_rehabilitated_dns_explain_bl="Enter here domain names that are blocked by the blacklist <BR> and you want to rehabilitate.";
  $l_rehabilitated_dns_explain_wl="2-Entrez ici des noms de domaine autorisés en plus de ceux <BR> de la liste blanche de Toulouse.";
  $l_add_to_bl="Domain names to add to blacklist";
  $l_record="Save changes";
  $l_wait="Once validated, 30 seconds is necessary to compute your modifications";
  $l_title_gctoff="Groupe privilégié";
  $l_gctoff_explain="Cocher des utilisateurs ne devant pas subir de filtrage";
  $l_gctoff_username="Username";
  $l_gctoff_username_comment="Comments";
  $l_switch_gctoff_on="Activer le groupe de privilégiés.";
  $l_switch_gctoff_off="Désactiver le groupe de privilégiés.";
  $l_gctoff_on = "Le Groupe privilégié est actuellement activés";
  $l_gctoff_off = "Le Groupe privilégié est actuellement désactivés";

 }
$weeknum = array( 0,1,2,3,4,5,6);
$bl_categories="/usr/local/etc/CTparental/bl-categories-available";
$bl_categories_enabled="/usr/local/etc/CTparental/categories-enabled";
$conf_file="/usr/local/etc/CTparental/CTparental.conf";
$conf_ctoff_file="/usr/local/etc/CTparental/GCToff.conf";
$hconf_file="/usr/local/etc/CTparental/CThours.conf";
$wl_domains="/usr/local/etc/CTparental/domaine-rehabiliter";
$bl_domains="/usr/local/etc/CTparental/blacklist-local";
# default values


if (isset($_POST['choix'])){ $choix=$_POST['choix']; } else { $choix=""; }
switch ($choix)
{
case 'gct_Off' :
	exec ("sudo -u root /usr/local/bin/CTparental.sh -gctoff");
	break;
case 'gct_On' :
	exec ("sudo -u root /usr/local/bin/CTparental.sh -gcton");
	break;
case 'LogOFF' :
	header('HTTP/1.0 401 Unauthorized');
	header('WWW-Authenticate: Digest realm="interface admin"');
	exit;
	break;
case 'BL_On' :
	exec ("sudo -u root /usr/local/bin/CTparental.sh -on");
	break;
case 'BL_Off' :
	exec ("sudo -u root /usr/local/bin/CTparental.sh -off");
	break;
case 'H_On' :
	exec ("sudo -u root /usr/local/bin/CTparental.sh -trf");
	break;
case 'H_Off' :
	exec ("sudo -u root /usr/local/bin/CTparental.sh -tlu");
	break;
case 'AUP_On' :
	exec ("sudo -u root /usr/local/bin/CTparental.sh -aupon");
	break;
case 'AUP_Off' :
	exec ("sudo -u root /usr/local/bin/CTparental.sh -aupoff");
	break;
case 'INIT_BL' :
	exec ("sudo -u root /usr/local/bin/CTparental.sh -dble");
	break;
case 'Download_bl' :
	exec ("sudo -u root /usr/local/bin/CTparental.sh -dl");
	break;
case 'MAJ_cat' :
	$tab=file($bl_categories_enabled);	
	if ($tab)
		{
		$pointeur=fopen($bl_categories_enabled, "w+");
		foreach ($_POST as $key => $value)
			{
                        if (strstr($key,'chk-'))
				{	
				$line=str_replace('chk-','',$key)."\n";
				fwrite($pointeur,$line);
				}
			}
		fclose($pointeur);
		}
	else {echo "$l_error_open_file $bl_categories_enabled";}
	$fichier=fopen($bl_domains,"w+");
	fputs($fichier, form_filter($_POST['OSSI_bl_domains']));
	fclose($fichier);
	unset($_POST['OSSI_bl_domains']);
	$fichier=fopen($wl_domains,"w+");
	fputs($fichier, form_filter($_POST['OSSI_wl_domains']));
	fclose($fichier);
	unset($_POST['OSSI_wl_domains']);
	exec ("sudo -u root /usr/local/bin/CTparental.sh -ubl");
	break;
case 'MAJ_H' :
	$formatheuresok=1;
	if (isset($_POST['selectuser'])){ $selectuser=$_POST['selectuser']; }
	#echo "$selectuser";
	$tab=file($hconf_file);	
	if ($tab)
	{
		$pointeur=fopen($hconf_file, "w+");	
		foreach ($tab as $line)
		{
			if (strstr($line,$selectuser) == false)
			{
				fwrite($pointeur,$line); # on reécrit toutes les lignes ne correspondant pas à l'utilisateur sélectionné
			}
	
		}
	}
	else {echo "$l_error_open_file $hconf_file";}
	if (isset($_POST["isadmin"])){fwrite($pointeur,"$selectuser=admin="."\n"); } 
	else 
	{
		if (isset($_POST["tmax"])){
			if ( preg_match( "/^[1-9]$|^[1-9][0-9]$|^[1-9][0-9][0-9]$|^1[0-3][0-9][0-9]$|^14[0-3][0-9]$|^1440$/", $_POST["tmax"] ) == 1  )
			{fwrite($pointeur,"$selectuser=user=".$_POST["tmax"]."\n");}
			else {fwrite($pointeur,"$selectuser=user=1440"."\n"); 
				  echo "<H3>$l_hours_error3</H3>";}
		}
		else {fwrite($pointeur,"$selectuser=user=1440"."\n"); }
		foreach ($weeknum as $numday)
		{
			$formatheuresok=1;
			if (isset($_POST["h1$numday"])){ $h1[$numday]=$_POST["h1$numday"]; } else { $h1[$numday]="00h00"; }
			if (isset($_POST["h2$numday"])){ $h2[$numday]=$_POST["h2$numday"]; } else { $h2[$numday]="23h59"; }
			if (isset($_POST["h3$numday"])){ $h3[$numday]=$_POST["h3$numday"]; } else { $h3[$numday]=""; }
			if (isset($_POST["h4$numday"])){ $h4[$numday]=$_POST["h4$numday"]; } else { $h4[$numday]=""; }
			if (preg_match("/^[0-1][0-9]h[0-5][0-9]$|^2[0-3]h[0-5][0-9]$/",$h1[$numday])!=1){$formatheuresok=0;}
			if (preg_match("/^[0-1][0-9]h[0-5][0-9]$|^2[0-3]h[0-5][0-9]$/",$h2[$numday])!=1){$formatheuresok=0;}
			if ($h3[$numday]=="")
			{	
	
				if ($formatheuresok == 1)
				{
					$t1=explode("h", $h1[$numday]);
					$t2=explode("h", $h2[$numday]);
					$v1="$t1[0]$t1[1]";
					$v2="$t2[0]$t2[1]";
					if ( $v1 < $v2)
					{
						fwrite($pointeur,"$selectuser=$numday=$h1[$numday]:$h2[$numday]"."\n");
					}
					else
					{
						fwrite($pointeur,"$selectuser=$numday=00h00:23h59"."\n");
						echo "<H3>$week[$numday] : $l_hours_error2 $h1[$numday]>=$h2[$numday]</H3>";
					}
				}
				else 
				{
					fwrite($pointeur,"$selectuser=$numday=00h00:23h59"."\n");
					echo "<H3>$week[$numday] : $l_hours_error1</H3>";
				}
			}
			else 
			{
				if (preg_match("/^[0-1][0-9]h[0-5][0-9]$|^2[0-3]h[0-5][0-9]$/",$h3[$numday])!=1){$formatheuresok=0;}
				if (preg_match("/^[0-1][0-9]h[0-5][0-9]$|^2[0-3]h[0-5][0-9]$/",$h4[$numday])!=1){$formatheuresok=0;}
				if ($formatheuresok == 1)
				{
					$t1=explode("h", $h1[$numday]);
					$t2=explode("h", $h2[$numday]);
					$t3=explode("h", $h3[$numday]);
					$t4=explode("h", $h4[$numday]);
					$v1="$t1[0]$t1[1]";
					$v2="$t2[0]$t2[1]";
					$v3="$t3[0]$t3[1]";
					$v4="$t4[0]$t4[1]";
					if ( $v1 < $v2 && $v2 < $v3 && $v3 < $v4)
					{
					fwrite($pointeur,"$selectuser=$numday=$h1[$numday]:$h2[$numday]:$h3[$numday]:$h4[$numday]"."\n");
					}
					else
					{
						fwrite($pointeur,"$selectuser=$numday=00h00:23h59"."\n");
						echo "<H3>$week[$numday] : $l_hours_error2 $h1[$numday]>=$h2[$numday]>=$h3[$numday]>=$h4[$numday]</H3>";
					}
				}
				else 
				{
					fwrite($pointeur,"$selectuser=$numday=00h00:23h59"."\n");
					echo "<H3>$week[$numday] : $l_hours_error1</H3>";
					
				}
			}

		}
	}
	
	fclose($pointeur);
	exec ("sudo -u root /usr/local/bin/CTparental.sh -trf");
	break;
	
case 'change_user' :
$tab=file($conf_ctoff_file);
	if ($tab)
		{
		$pointeur=fopen($conf_ctoff_file,"w+");
		foreach ($tab as $ligne)
			{
			$CONF_CTOFF1 = str_replace('#','',$ligne);
			$actif = False ;	
			foreach ($_POST as $key => $value)
				{
					if (strstr($key,'chk-'))
					{
						$CONF_CTOFF2 = str_replace('chk-','',$key);
						if ( trim($CONF_CTOFF1) == trim($CONF_CTOFF2) )
						{ 
							$actif = True; 
							break;
						}
					}
				}

			if (! $actif) {	$line="#$CONF_CTOFF1";}
			else { $line="$CONF_CTOFF1";}
			fwrite($pointeur,$line);
				
			}
		fclose($pointeur);
		}
	exec ("sudo -u root /usr/local/bin/CTparental.sh -gctalist");
	break;

}

echo "<TABLE width='100%' border=0 cellspacing=0 cellpadding=0>";
echo "<tr><th>$l_title1</th></tr>";
echo "<tr bgcolor='#FFCC66'><td><img src='/images/pix.gif' width=1 height=2></td></tr>";
echo "</TABLE>";
echo "<TABLE width='100%' border=1 cellspacing=0 cellpadding=0>";
echo "<tr><td valign='middle' align='left'>";
echo "<CENTER>";
echo "<FORM action='$_SERVER[PHP_SELF]' method=POST>";
echo "<input type=hidden name='choix' value=\"LogOFF\">";
echo "<input type=submit value=\"$l_switch_LogOFF\">";
echo "</FORM>";
echo "</CENTER>";
if (is_file ($conf_file))
	{
	$tab=file($conf_file);
	if ($tab)
		{
		foreach ($tab as $line)
			{
			$field=explode("=", $line);
			if ($field[0] == "LASTUPDATE")	{$LASTUPDATE=trim($field[2]);}
			if ($field[0] == "DNSMASQ")		{$DNSMASQ=trim($field[1]);}
			if ($field[0] == "AUTOUPDATE")		{$AUTOUPDATE=trim($field[1]);}
			if ($field[0] == "HOURSCONNECT")	{$HOURSCONNECT=trim($field[1]);}
            if ($field[0] == "GCTOFF")	{$GCTOFF=trim($field[1]);}            
			}
		}
	}
else { echo "$l_error_open_file $conf_file";}

include 'dns.php';

include 'hours.php';

include 'gctoff.php';

//echo "</td></tr>";
?>
</BODY>
</HTML>
