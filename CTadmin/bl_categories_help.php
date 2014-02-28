<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><!-- written by Rexy -->
<HEAD>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<?php
$bl_dir="/usr/local/etc/CTparental/dnsfilter-available/";
# Choice of language
$Language = 'en';
if(isset($_SERVER['HTTP_ACCEPT_LANGUAGE'])){
  $Langue = explode(",",$_SERVER['HTTP_ACCEPT_LANGUAGE']);
  $Language = strtolower(substr(chop($Langue[0]),0,2)); }
if($Language == 'fr'){
  $l_title = "Catégories de la liste noire";
  $l_error_open_file="Erreur d'ouverture du fichier";
  $l_close="Fermer";
  $l_unknown_cat="Cette catégorie n'est pas décrite";
  $l_nb_domains="Nombre de noms de domaine filtrés :";
  $l_nb_urls="Nombre d'URL filtrés :";
  $l_explain_adult="Sites relatifs à l'érotisme et à la pornographie";
  $l_explain_agressif="Sites extrémistes, racistes, antisémites ou incitant à la haine";
  $l_explain_arjel="Sites de pari en ligne certifies par l'ARJEL (Autorité de Régulation des Jeux En Ligne)";
  $l_explain_astrology="Sites relatifs à l'astrologie";
  $l_explain_bank="Sites de banques en ligne";
  $l_explain_audio_video="Sites de téléchargement de fichiers audio et vidéo";
  $l_explain_blog="Sites d'hébergement de blogs";
  $l_explain_celebrity="Sites « people », stars, etc.";
  $l_explain_chat="Sites de dialogue en ligne";
  $l_explain_child="Sites pour enfants";
  $l_explain_cleaning="Sites relatifs à la mise à jour logicielle ou antivirale";
  $l_explain_dangerous_material="Sites relatifs à la création de produits dangereux (explosif, poison, etc.)";
  $l_explain_dating="Sites de rencontres en ligne";
  $l_explain_drogue="Sites relatifs aux produits stupéfiants";
  $l_explain_filehosting="Entrepôts de fichiers  (vidéo, images, son, logiciels, etc.)";
  $l_explain_financial="Sites d'informations financières, bourses, etc.";
  $l_explain_forums="Sites d'hébergement de forums de discussion";
  $l_explain_gambling="Sites de jeux d'argent en ligne (casino, grattage virtuel, etc.)";
  $l_explain_games="Sites de jeux en ligne";
  $l_explain_hacking="Sites relatifs au piratage informatique";
  $l_explain_jobsearch="Sites de recherche d'emplois";
  $l_explain_liste_bu="Liste de sites éducatifs pour bibliothèque";
  $l_explain_malware="Site relatifs au logiciels malveillants (virus, vers, trojans, etc.)";
  $l_explain_manga="Site de Mangas";
  $l_explain_marketingware="Sites marchands douteux (X, organes, enfants, etc.)";
  $l_explain_mixed_adult="Sites pour adultes (image-choc, gore, guerre, etc.)";
  $l_explain_mobile_phone="Sites relatifs aux mobiles GSM (sonneries, logos, etc.)";
  $l_explain_ossi="Noms de domaine et URLs que vous ajoutez à la liste noire (voir ci-dessous)";
  $l_explain_phishing="Sites relatifs à l'hammeçonnage (pièges bancaires, redirection, etc.)";
  $l_explain_press="Sites de presse";
  $l_explain_publicite="Sites ou bannières publicitaires";
  $l_explain_radio="Sites de radios en ligne ou de podcast";
  $l_explain_reaffected="Sites connus ayant changé de propriétaire (et donc de contenu)";
  $l_explain_redirector="Sites de redirection, d'anonymisation ou de contournement";
  $l_explain_remote_control="Sites permettant la prise de controle a distance";
  $l_explain_sect="Sites sectaires";
  $l_explain_social_networks="Sites de réseaux sociaux";
  $l_explain_sexual_education="Sites relatifs à l'éducation sexuelle";
  $l_explain_shopping="Sites de vente et d'achat en ligne";
  $l_explain_sport="Sites de sport";
  $l_explain_strict_redirector="URL intentionnellement mal formées";
  $l_explain_strong_redirector="URL mal formées dans une requête « google »";
  $l_explain_tricheur="Sites relatifs aux tricheries (examens, concours, etc.)";
  $l_explain_webmail="Site WEB permettant de consultation son courrier électronique";
  $l_explain_warez="Sites relatifs aux logiciels piratés (crackés), aux générateurs de clés, etc.";
}
else {
  $l_title = "Blacklist categories";
  $l_error_open_file="Error opening the file";
  $l_close="Close";
  $l_unknown_cat="This category isn't describe";
  $l_nb_domains="Number of filtered domain names :";
  $l_nb_urls="Number of filtered URL :";
  $l_explain_adult="Sites related to eroticism and pornography";
  $l_explain_agressif="Sites extremist, racist, anti-Semitic or hate";
  $l_explain_arjel="Online gambling sites allowed by the french authority 'ARJEL' (Autorité de Régulation des Jeux En Ligne)";
  $l_explain_astrology="Sites related to astrology";
  $l_explain_audio_video="Sites for downloading audio and video";
  $l_explain_bank="Online bank sites";
  $l_explain_blog="Sites hosting blogs";
  $l_explain_celebrity="Sites « people », stars, etc.";
  $l_explain_chat="Online chat sites";
  $l_explain_child="Sites for children";
  $l_explain_cleaning="Sites related to software update or antiviral";
  $l_explain_dangerous_material="Sites related to the creation of dangerous goods (explosives, poison, etc.)";
  $l_explain_dating="Online dating sites";
  $l_explain_drogue="Sites related to narcotic";
  $l_explain_filehosting="Warehouses of files (video, images, sound, software, etc.)";
  $l_explain_financial="Sites of financial information";
  $l_explain_forums="Sites hosting discussion forums";
  $l_explain_gambling="Online gambling sites (casino, virtual scratching, etc.)";
  $l_explain_games="Online games sites";
  $l_explain_hacking="Sites related to hacking";
  $l_explain_jobsearch="Job search sites";
  $l_explain_liste_bu="List of educational sites for library";
  $l_explain_malware="Malware sites (viruses, worms, trojans, etc.).";
  $l_explain_manga="Manga site";
  $l_explain_marketingware="doubtful commercial sites";
  $l_explain_mixed_adult="Adult sites (shock, gore, war, etc.).";
  $l_explain_mobile_phone="Sites related to GSM mobile (ringtones, logos, etc.)";
  $l_explain_ossi="Domain names and URLs you add to the blacklist (see below)";
  $l_explain_phishing="Phishing sites (traps banking, redirect, etc..)";
  $l_explain_press="News sites";
  $l_explain_publicite="Advertising sites";
  $l_explain_radio="Online radio podcast sites";
  $l_explain_reaffected="Sites that have changed ownership (and therefore content)";
  $l_explain_redirector="redirects, anonymization or bypass sites";
  $l_explain_remote_control="Sites for making remote control";
  $l_explain_sect="Sectarian sites";
  $l_explain_social_networks="Social networks sites";
  $l_explain_sexual_education="Sites related to sex education";
  $l_explain_shopping="Shopping sites and online shopping";
  $l_explain_sport="Sport sites";
  $l_explain_strict_redirector="Intentionally malformed URL";
  $l_explain_strong_redirector="Malformed URL in a 'google' query";
  $l_explain_tricheur="Sites related to cheating (tests, examinations, etc.)";
  $l_explain_webmail="Web sites for e-mail consultation";
  $l_explain_warez="Sites related to cracked softwares";
}
if (isset($_GET['cat'])){$categorie=$_GET['cat'];} 
$bl_categorie_domain_file=$bl_dir.$categorie.".conf";
if (file_exists($bl_categorie_domain_file))
	$nb_domains=exec ("wc -w $bl_categorie_domain_file|cut -d' ' -f1");
else
	$nb_domains=$l_error_openfilei." ".$bl_categorie_domain_file;
if (file_exists($bl_categorie_url_file))
	$nb_urls=exec ("wc -w $bl_categorie_url_file|cut -d' ' -f1");
else
	$nb_urls=$l_error_openfile." ".$bl_categorie_url_file;
echo "<TITLE>$l_title</TITLE>";
?>
<link rel="stylesheet" href="/CTadmin/css/style.css" type="text/css">
</HEAD>
<body>
<TABLE width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><th><?php echo $categorie ;?></th></tr>
	<tr bgcolor="#FFCC66"><td><img src="/images/pix.gif" width="1" height="2"></td></tr>
</TABLE>
<TABLE width="100%" border=1 cellspacing=0 cellpadding=1>
<tr><td valign="middle" align="left">
<?php
$compat_categorie=strtr($categorie,"-","_");
if (!empty(${'l_explain_'.$compat_categorie}))
	echo "<center><b>${'l_explain_'.$compat_categorie}</b></center>";
else echo "$l_unknown_cat";
echo "<br>$l_nb_domains <b>$nb_domains</b><br>";
?>
</td></tr>
</TABLE>
<br>
<center><a href="javascript:window.close();"><b><?php echo "$l_close"; ?></b></a></center>
</BODY>
</HTML>
