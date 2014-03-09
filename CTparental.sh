#!/bin/bash 
# CTparental.sh
#
# par Guillaume MARSAT
# Corrections orthographiques par Pierre-Edouard TESSIER
# une parti du code est tiré du script alcasar-bl.sh créé par Franck BOUIJOUX et Richard REY
# présent dans le code du projet alcasar en version 2.6.1 ; web page http://www.alcasar.net/
 
# This script is distributed under the Gnu General Public License (GPL)
arg1=${1}
if [ $# -ge 1 ];then
if [ $arg1 != "-listusers" ] ; then
if [ ! $UID -le 499 ]; then # considaire comme root tous les utilisateurs avec un uid inferieur ou egale a 499,ce qui permet a apt-get,urpmi,yum... de lance le scripte sans erreur.
   echo "Il vous faut des droits root pour lancer ce script"
   exit 1
fi
fi
fi


noinstalldep="0"
nomanuel="0"
ARGS=($*)
for (( narg=1; narg<=$#; narg++ )) ; do
        case "${ARGS[$narg]}" in
	  -nodep )
	     noinstalldep="1"
	  ;;
	  -nomanuel )
	     nomanuel="1"
	  ;;
	  -dirhtml )
	     narg=$(( $narg +1 ))
	     DIRhtmlPersonaliser=${ARGS[$narg]}
	     if [ ! -d $DIRhtmlPersonaliser ];then
		echo "Chemin de répertoire non valide!"
		exit 0
	     fi
	  ;;
	esac
done
pause () {   # fonction pause pour debugage
      MESSAGE="$*"
      choi=""
      MESSAGE=${MESSAGE:="pour continuer appuyez sur une touche :"}
      echo  "$MESSAGE"
      while (true); do
         read choi
         case $choi in
         * )
         break
         ;;
      esac
      done
}
SED="/bin/sed -i"
DIR_CONF="/usr/local/etc/CTparental"
FILE_CONF="$DIR_CONF/CTparental.conf"
FILE_GCTOFFCONF="$DIR_CONF/GCToff.conf"
FILE_HCOMPT="$DIR_CONF/CThourscompteur"
FILE_HCONF="$DIR_CONF/CThours.conf"
if [ ! -f $FILE_CONF ] ; then
mkdir -p $DIR_CONF
mkdir -p /usr/local/share/CTparental/
cat << EOF > $FILE_CONF
LASTUPDATE=0
DNSMASQ=BLACK
AUTOUPDATE=OFF
HOURSCONNECT=OFF
GCTOFF=OFF
EOF
fi




## imports du plugin de la distributions si il existe
if [ -f $DIR_CONF/dist.conf ];then
	source  $DIR_CONF/dist.conf 
fi

tempDIR="/tmp/alcasar"
tempDIRRamfs="/tmp/alcasarRamfs"
if [ ! -d $tempDIRRamfs ] ; then
mkdir $tempDIRRamfs
fi
RougeD="\033[1;31m"
BleuD="\033[1;36m"
VertD="\033[1;32m"
Fcolor="\033[0m"
GESTIONNAIREDESESSIONS=" login gdm lightdm slim kdm xdm lxdm gdm3 "
FILEPAMTIMECONF="/etc/security/time.conf"
DIRPAM="/etc/pam.d/"
DAYS=${DAYS:="lundi mardi mercredi jeudi vendredi samedi dimanche "}
DAYS=( $DAYS )
DAYSPAM=( Mo Tu We Th Fr Sa Su )
DAYSCRON=( mon tue wed thu fri sat sun )

#### DEPENDANCES par DEFAULT #####
DEPENDANCES=${DEPENDANCES:=" dnsmasq lighttpd php5-cgi libnotify-bin notification-daemon iptables-persistent "}

#### COMMANDES de services par DEFAULT #####
CMDSERVICE=${CMDSERVICE:="service "}
CRONstart=${CRONstart:="$CMDSERVICE cron start "}
CRONstop=${CRONstop:="$CMDSERVICE cron stop "}
CRONrestart=${CRONrestart:="$CMDSERVICE cron restart "}
LIGHTTPDstart=${LIGHTTPDstart:="$CMDSERVICE lighttpd start "}
LIGHTTPDstop=${LIGHTTPDstop:="$CMDSERVICE lighttpd stop "}
LIGHTTPDrestart=${LIGHTTPDrestart:="$CMDSERVICE lighttpd restart "}
DNSMASQstart=${DNSMASQstart:="$CMDSERVICE dnsmasq start "}
DNSMASQstop=${DNSMASQstop:="$CMDSERVICE dnsmasq stop "}
DNSMASQrestart=${DNSMASQrestart:="$CMDSERVICE dnsmasq restart "}
NWMANAGERstop=${NWMANAGERstop:="$CMDSERVICE network-manager stop"}
NWMANAGERstart=${NWMANAGERstart:="$CMDSERVICE network-manager start"}
NWMANAGERrestart=${NWMANAGERrestart:="$CMDSERVICE network-manager restart"}
IPTABLESsave=${IPTABLESsave:="$CMDSERVICE iptables-persistent save"}

#### LOCALISATION du fichier PID lighttpd par default ####
LIGHTTPpidfile=${LIGHTTPpidfile:="/var/run/lighttpd.pid"}

#### COMMANDES D'ACTIVATION DES SERVICES AU DEMARAGE DU PC ####
ENCRON=${ENCRON:=""}
ENLIGHTTPD=${ENLIGHTTPD:=""}
ENDNSMASQ=${ENDNSMASQ:=""}
ENNWMANAGER=${ENNWMANAGER:=""}
#### UID MINIMUM pour les UTILISATEUR
UIDMINUSER=${UIDMINUSER:=1000}

DNSMASQCONF=${DNSMASQCONF:="/etc/dnsmasq.conf"}
MAINCONFHTTPD=${MAINCONFHTTPD:="/etc/lighttpd/lighttpd.conf"}
DIRCONFENABLEDHTTPD=${DIRCONFENABLEDHTTPD:="/etc/lighttpd/conf-enabled"}
CTPARENTALCONFHTTPD=${CTPARENTALCONFHTTPD:="$DIRCONFENABLEDHTTPD/10-CTparental.conf"}
DIRHTML=${DIRHTML:="/var/www/CTparental"}
DIRadminHTML=${DIRadminHTML:="/var/www/CTadmin"}
PASSWORDFILEHTTPD=${PASSWORDFILEHTTPD:="/etc/lighttpd/lighttpd-htdigest.user"}
REALMADMINHTTPD=${REALMADMINHTTPD:="interface admin"}
CMDINSTALL=""

ADDUSERTOGROUP=${ADDUSERTOGROUP:="gpasswd -a "}
DELUSERTOGROUP=${DELUSERTOGROUP:="gpasswd -d "}
if [ $(yum help 2> /dev/null | wc -l ) -ge 50 ] ; then
   ## "Distribution basée sur yum exemple redhat, fedora..."
   CMDINSTALL=${CMDINSTALL:="yum install "}
   CMDREMOVE=${CMDREMOVE:="rpm -e "}
fi
urpmi --help 2&> /dev/null
if [ $? -eq 1 ] ; then
   ## "Distribution basée sur urpmi exemple mandriva..."
   CMDINSTALL=${CMDINSTALL:="urpmi -a --auto "}
   CMDREMOVE=${CMDREMOVE:="rpm -e "}
fi
apt-get -h 2&> /dev/null
if [ $? -eq 0 ] ; then
   ## "Distribution basée sur apt-get exemple debian, ubuntu ..."
   CMDINSTALL=${CMDINSTALL:="apt-get -y --force-yes install "}
   CMDREMOVE=${CMDREMOVE:="dpkg --purge  "}
fi

if [ $( echo $CMDINSTALL | wc -m ) -eq 1 ] ; then
   echo "Aucun gestionner de paquet connu , n'a été détecté."
   set -e
   exit 1
fi




interface_WAN=$(ip route | awk '/^default via/{print $5}' | sort -u ) # suppose que la passerelle est la route par default

DNS1=$(cat /etc/resolv.conf | grep ^nameserver | cut -d " " -f2 | tr "\n" " " | cut -d " " -f1)
DNS2=$(cat /etc/resolv.conf | grep ^nameserver | cut -d " " -f2 | tr "\n" " " | cut -d " " -f2)


PRIVATE_IP="127.0.0.10"

FILE_tmp=${FILE_tmp:="$tempDIRRamfs/filetmp.txt"}
FILE_tmpSizeMax=${FILE_tmpSizeMax:="128M"}  # 70 Min, Recomend 128M 
LOWRAM=${LOWRAM:=0}
if [ $LOWRAM -eq 0 ] ; then
MFILEtmp="mount -t tmpfs -o size=$FILE_tmpSizeMax tmpfs $tempDIRRamfs"
UMFILEtmp="umount $tempDIRRamfs"
else
MFILEtmp=""
UMFILEtmp=""
fi
BL_SERVER="dsi.ut-capitole.fr"
CATEGORIES_ENABLED="$DIR_CONF/categories-enabled"
BL_CATEGORIES_AVAILABLE="$DIR_CONF/bl-categories-available"
WL_CATEGORIES_AVAILABLE="$DIR_CONF/wl-categories-available"
DIR_DNS_FILTER_AVAILABLE="$DIR_CONF/dnsfilter-available"
DIR_DNS_BLACKLIST_ENABLED="$DIR_CONF/blacklist-enabled"
DIR_DNS_WHITELIST_ENABLED="$DIR_CONF/whitelist-enabled"
DNS_FILTER_OSSI="$DIR_CONF/blacklist-local"
DREAB="$DIR_CONF/domaine-rehabiliter" 
THISDAYS=$(expr $(date +%Y) \* 365 + $(date +%j))
MAXDAYSFORUPDATE="7" # update tous les 7 jours
CHEMINCTPARENTLE=$(readlink -f $0)

initblenabled () {
   cat << EOF > $CATEGORIES_ENABLED
adult
agressif
dangerous_material
dating
drogue
gambling
hacking
malware
marketingware
mixed_adult
phishing
redirector
sect
strict_redirector
strong_redirector
tricheur
warez
ossi   
EOF
         

}

addadminhttpd() {
if [ ! -f $PASSWORDFILEHTTPD ] ; then
    echo -n > $PASSWORDFILEHTTPD   
fi
chown root:$USERHTTPD $PASSWORDFILEHTTPD
chmod 640 $PASSWORDFILEHTTPD
USERADMINHTTPD=${1}
pass=${2}
hash=`echo -n "$USERADMINHTTPD:$REALMADMINHTTPD:$pass" | md5sum | cut -b -32`
ligne=$(echo "$USERADMINHTTPD:$REALMADMINHTTPD:$hash")
$SED "/^$USERADMINHTTPD:$REALMADMINHTTPD.*/d" $PASSWORDFILEHTTPD
echo $ligne >> $PASSWORDFILEHTTPD
}

download() {
   rm -rf $tempDIR
   mkdir $tempDIR
   # on attend que la connection remonte suite au redemarage de networkmanager
   echo "attente de connection au serveur de toulouse:"
   i=1
   while [ $(ping -c 1 $BL_SERVER 2> /dev/null | grep -c "1 received"  ) -eq 0 ]
   do
   echo -n .
   sleep 1
   i=$(($i + 1 ))
   if [ $i -ge 40 ];then # si au bout de 40 secondes on a toujours pas de connection on considaire qu'il y a une erreur
		echo "connection a $BL_SERVER impossible."
		set -e
		exit 1
   fi
   done
   echo
   echo "connection établit:"
   
   wget -P $tempDIR http://$BL_SERVER/blacklists/download/blacklists.tar.gz 2>&1 | cat
   if [ ! $? -eq 0 ]; then
      echo "erreur lors du téléchargement, processus interrompu"
      rm -rf $tempDIR
      set -e
      exit 1
   fi
   tar -xzf $tempDIR/blacklists.tar.gz -C $tempDIR
   if [ ! $? -eq 0 ]; then
      echo "erreur d'extraction de l'archive, processus interrompu"
      set -e
      exit 1
   fi
   rm -rf $DIR_DNS_FILTER_AVAILABLE/
   mkdir $DIR_DNS_FILTER_AVAILABLE
}
autoupdate() {
        LASTUPDATEDAY=`grep LASTUPDATE= $FILE_CONF | cut -d"=" -f2`
        LASTUPDATEDAY=${LASTUPDATEDAY:=0}
        DIFFDAY=$(expr $THISDAYS - $LASTUPDATEDAY)
	if [ $DIFFDAY -ge $MAXDAYSFORUPDATE ] ; then
		download
		adapt
		catChoice
		dnsmasqon
                $SED "s?^LASTUPDATE.*?LASTUPDATE=$THISDAYS=`date +%d-%m-%Y\ %T`?g" $FILE_CONF
		exit 0
	fi
}
autoupdateon() {
$SED "s?^AUTOUPDATE.*?AUTOUPDATE=ON?g" $FILE_CONF
echo "*/10 * * * * root $CHEMINCTPARENTLE -aup" > /etc/cron.d/CTparental-autoupdate
$CRONrestart
}

autoupdateoff() {
$SED "s?^AUTOUPDATE.*?AUTOUPDATE=OFF?g" $FILE_CONF
rm -f /etc/cron.d/CTparental-autoupdate
$CRONrestart
}
adapt() {
   echo adapt
   date +%H:%M:%S
   dnsmasqoff
   $MFILEtmp
   if [ ! -f $DNS_FILTER_OSSI ] ; then
            echo > $DNS_FILTER_OSSI
   fi

   if [ -d $tempDIR  ] ; then
	  CATEGORIES_AVAILABLE=$tempDIR/categories_available
	  ls -FR $tempDIR/blacklists | grep '/$' | sed -e "s/\///g" > $CATEGORIES_AVAILABLE
          echo -n > $BL_CATEGORIES_AVAILABLE
          echo -n > $WL_CATEGORIES_AVAILABLE
          if [ ! -f $DIR_DNS_FILTER_AVAILABLE/ossi.conf ] ; then
		echo > $DIR_DNS_FILTER_AVAILABLE/ossi.conf
	  fi
	  for categorie in `cat $CATEGORIES_AVAILABLE` # creation des deux fichiers de categories (BL / WL)
	  do
		if [ -e $tempDIR/blacklists/$categorie/usage ]
		then
			is_whitelist=`grep white $tempDIR/blacklists/$categorie/usage|wc -l`
		else
			is_whitelist=0 # ou si le fichier 'usage' n'existe pas, on considère que la catégorie est une BL
		fi
		if [ $is_whitelist -eq "0" ]
		then
			echo "$categorie" >> $BL_CATEGORIES_AVAILABLE
		else
			echo "$categorie" >> $WL_CATEGORIES_AVAILABLE
		fi
	   done
         echo -n "Toulouse Black and White List migration process. Please wait : "
         for DOMAINE in `cat  $CATEGORIES_AVAILABLE`  # pour chaque catégorie
         do
            echo -n "."
            # suppression des @IP, de caractères acccentués et des lignes commentées ou vide
            cp -f $tempDIR/blacklists/$DOMAINE/domains $FILE_tmp
            $SED -r '/([0-9]{1,3}\.){3}[0-9]{1,3}/d' $FILE_tmp
	    $SED "/[äâëêïîöôüû]/d" $FILE_tmp
	    $SED "/^#.*/d" $FILE_tmp
            $SED "/^$/d" $FILE_tmp
            $SED "s/\.\{2,10\}/\./g" $FILE_tmp # supprime les suite de "." exemple: address=/fucking-big-tits..com/127.0.0.10 devient address=/fucking-big-tits.com/127.0.0.10
	    is_blacklist=`grep $DOMAINE $BL_CATEGORIES_AVAILABLE |wc -l`
	    if [ $is_blacklist -ge "1" ] ; then
            	$SED "s?.*?address=/&/$PRIVATE_IP?g" $FILE_tmp  # Mise en forme dnsmasq des listes noires
		mv $FILE_tmp $DIR_DNS_FILTER_AVAILABLE/$DOMAINE.conf  
            else
		$SED "s?.*?server=/&/#?g" $FILE_tmp  # Mise en forme dnsmasq des listes blanches
		mv $FILE_tmp $DIR_DNS_FILTER_AVAILABLE/$DOMAINE.conf
            fi
         done
   else
         mkdir   $tempDIR
         echo -n "."
 	 # suppression des @IP, de caractères acccentués et des lignes commentées ou vide
         cp -f $DNS_FILTER_OSSI $FILE_tmp
         $SED -r '/([0-9]{1,3}\.){3}[0-9]{1,3}/d' $FILE_tmp
         $SED "/[äâëêïîöôüû]/d" $FILE_tmp 
         $SED "/^#.*/d" $FILE_tmp 
         $SED "/^$/d" $FILE_tmp 
         $SED "s/\.\{2,10\}/\./g" $FILE_tmp # supprime les suite de "." exemple: address=/fucking-big-tits..com/127.0.0.10 devient address=/fucking-big-tits.com/127.0.0.10
         $SED "s?.*?address=/&/$PRIVATE_IP?g" $FILE_tmp  # Mise en forme dnsmasq
         mv $FILE_tmp $DIR_DNS_FILTER_AVAILABLE/ossi.conf
   fi     
   echo
   $UMFILEtmp
   rm -rf $tempDIR
date +%H:%M:%S
}
catChoice() {
#   echo "catChoice"
   rm -rf $DIR_DNS_BLACKLIST_ENABLED/
   mkdir $DIR_DNS_BLACKLIST_ENABLED
   rm -rf  $DIR_DNS_WHITELIST_ENABLED/
   mkdir  $DIR_DNS_WHITELIST_ENABLED
     
      for CATEGORIE in `cat $CATEGORIES_ENABLED` # on affecte les catégories dnsmasq
      do
	 is_blacklist=`grep $CATEGORIE $BL_CATEGORIES_AVAILABLE |wc -l`
	 if [ $is_blacklist -ge "1" ] ; then
		cp $DIR_DNS_FILTER_AVAILABLE/$CATEGORIE.conf $DIR_DNS_BLACKLIST_ENABLED/
         else
		cp $DIR_DNS_FILTER_AVAILABLE/$CATEGORIE.conf $DIR_DNS_WHITELIST_ENABLED/
     	 fi     
      done
      cp $DIR_DNS_FILTER_AVAILABLE/ossi.conf $DIR_DNS_BLACKLIST_ENABLED/
#      echo "fincatChoice"
      reabdomaine
}

reabdomaine () {
echo reabdomaine
date +%H:%M:%S
$MFILEtmp
if [ ! -f $DREAB ] ; then
cat << EOF > $DREAB
www.google.com
www.google.fr
EOF
fi
if [ ! -f $DIR_DNS_BLACKLIST_ENABLED/ossi.conf ] ; then
	echo > $DIR_DNS_BLACKLIST_ENABLED/ossi.conf
fi
echo
echo -n "Application de la liste blanche (domaine réhabilité):"
for CATEGORIE in `cat  $CATEGORIES_ENABLED  `  # pour chaque catégorie
do 
	is_blacklist=`grep $CATEGORIE $BL_CATEGORIES_AVAILABLE |wc -l`
	if [ $is_blacklist -ge "1" ] ; then
		echo -n "."
		for DOMAINE in `cat  $DREAB`
		do
		    cp -f $DIR_DNS_BLACKLIST_ENABLED/$CATEGORIE.conf $FILE_tmp
		    $SED "/$DOMAINE/d" $FILE_tmp
                    cp -f $FILE_tmp $DIR_DNS_BLACKLIST_ENABLED/$CATEGORIE.conf
		done
        fi
done
echo -n "."
cat $DREAB | sed -e "s? ??g" | sed -e "s?.*?server=/&/#?g" >  $DIR_DNS_WHITELIST_ENABLED/whiteliste.ossi.conf
echo
$UMFILEtmp
rm -f $FILE_tmp
date +%H:%M:%S
}

dnsmasqon () {
   categorie1=`sed -n "1 p" $CATEGORIES_ENABLED` # on considère que si la 1ère categorie activée est un blacklist on fonctionne par blacklist.
   is_blacklist=`grep $categorie1 $BL_CATEGORIES_AVAILABLE |wc -l`
   if [ $is_blacklist -ge "1" ] ; then
   $SED "s?^DNSMASQ.*?DNSMASQ=BLACK?g" $FILE_CONF
   cat << EOF > $DNSMASQCONF
         # Configuration file for "dnsmasq with blackhole"
   # Inclusion de la blacklist <domains> de Toulouse dans la configuration
   conf-dir=$DIR_DNS_BLACKLIST_ENABLED
   # conf-file=$DIR_DEST_ETC/alcasar-dns-name   # zone de definition de noms DNS locaux
   interface=lo
   listen-address=127.0.0.1
   no-dhcp-interface=$interface_WAN
   bind-interfaces
   cache-size=1024
   domain-needed
   expand-hosts
   bogus-priv
   port=54
   
EOF
$DNSMASQrestart
else
  dnsmasqwhitelistonly
fi
}
dnsmasqoff () {
   $SED "s?^DNSMASQ.*?DNSMASQ=OFF?g" $FILE_CONF
}
iptableson () {
   # Redirect DNS requests
   # note: http://superuser.com/a/594164
   /sbin/iptables -t nat -N ctparental
   /sbin/iptables -t nat -A OUTPUT -j ctparental
   # Force non priviledged users to use dnsmasq
      for user in `listeusers` ; do
      if  [ $(groups $user | grep -c " ctoff$") -eq 0 ];then
         /sbin/iptables -t nat -A ctparental -m owner --uid-owner "$user" -p tcp --dport 53 -j DNAT --to 127.0.0.1:54 
         /sbin/iptables -t nat -A ctparental -m owner --uid-owner "$user" -p udp --dport 53 -j DNAT --to 127.0.0.1:54
      fi
      done
   # Save configuration so that it survives a reboot
   $IPTABLESsave
}
iptablesoff () {
   /sbin/iptables -t nat -D OUTPUT -j ctparental || /bin/true
   /sbin/iptables -t nat -F ctparental || /bin/true
   /sbin/iptables -t nat -X ctparental || /bin/true
   $IPTABLESsave
}
dnsmasqwhitelistonly  () {
   $SED "s?^DNSMASQ.*?DNSMASQ=WHITE?g" $FILE_CONF
   cat << EOF > $DNSMASQCONF
         # Configuration file for "dnsmasq with blackhole"
   # Inclusion de la blacklist <domains> de Toulouse dans la configuration
   conf-dir=$DIR_DNS_WHITELIST_ENABLED
   # conf-file=$DIR_DEST_ETC/alcasar-dns-name   # zone de definition de noms DNS locaux
   no-dhcp-interface=$interface_WAN
   bind-interfaces
   cache-size=0
   domain-needed
   expand-hosts
   bogus-priv
   server=$DNS1
   server=$DNS2
   address=/#/$PRIVATE_IP #redirige vers $PRIVATE_IP pour tout ce qui n'a pas été resolu dans les listes blanches
EOF

$DNSMASQrestart
}


FoncHTTPDCONF () {
$LIGHTTPDstop
rm -rf $DIRHTML/*
mkdir -v $DIRHTML
if [ ! -z $DIRhtmlPersonaliser ];then
   cp -r $DIRhtmlPersonaliser/* $DIRHTML
else
s="span"
st="style"
c="$c"
cab=";\">"

cat << EOF > $DIRHTML/index.html
 <HTML>
<HEAD>
   <META HTTP-EQUIV="CONTENT-TYPE" CONTENT="text/html; charset=utf-8">
   <TITLE>danger</TITLE>
</HEAD>
<BODY LANG="fr-FR" DIR="LTR">
<CENTER>
<img alt="Site dangereux pour des mineurs"
  HEIGHT="600"   
  src="data:image/png;base64,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
QmCC" />
</CENTER>
</BODY>
</HTML>
EOF

fi
## GENERATION

ln -s  $DIRHTML/index.html $DIRHTML/err404.html
USERHTTPD=$(cat /etc/passwd | grep /var/www | cut -d":" -f1)
GROUPHTTPD=$(cat /etc/group | grep $USERHTTPD | cut -d":" -f1)
chmod 644 $FILE_CONF
chown root:$GROUPHTTPD $FILE_CONF
cat << EOF > $MAINCONFHTTPD
server.modules = (
"mod_access",
"mod_alias",
"mod_redirect",
"mod_auth",	#pour interface admin
"mod_fastcgi",  #pour interface admin (activation du php)
)
auth.debug                 = 0
auth.backend               = "htdigest" 
auth.backend.htdigest.userfile = "$PASSWORDFILEHTTPD" 

server.document-root = "/var/www"
server.upload-dirs = ( "/var/cache/lighttpd/uploads" )
server.errorlog = "/var/log/lighttpd/error.log"
server.pid-file = "$LIGHTTPpidfile"
server.username = "$USERHTTPD"
server.groupname = "$GROUPHTTPD"
server.port = 80
server.bind = "127.0.0.1"


index-file.names = ( "index.php", "index.html" )
url.access-deny = ( "~", ".inc" )
static-file.exclude-extensions = (".php", ".pl", ".fcgi" )

server.tag = ""

include_shell "/usr/share/lighttpd/create-mime.assign.pl"
include_shell "/usr/share/lighttpd/include-conf-enabled.pl"
EOF

mkdir -p /usr/share/lighttpd/

if [ ! -f /usr/share/lighttpd/create-mime.assign.pl ];then
cat << EOF > /usr/share/lighttpd/create-mime.assign.pl
#!/usr/bin/perl -w
use strict;
open MIMETYPES, "/etc/mime.types" or exit;
print "mimetype.assign = (\n";
my %extensions;
while(<MIMETYPES>) {
  chomp;
  s/\#.*//;
  next if /^\w*$/;
  if(/^([a-z0-9\/+-.]+)\s+((?:[a-z0-9.+-]+[ ]?)+)$/) {
    foreach(split / /, \$2) {
      # mime.types can have same extension for different
      # mime types
      next if \$extensions{\$_};
      \$extensions{\$_} = 1;
      print "\".\$_\" => \"\$1\",\n";
    }
  }
}
print ")\n";
EOF
chmod +x /usr/share/lighttpd/create-mime.assign.pl
fi


if [ ! -f /usr/share/lighttpd/include-conf-enabled.pl ];then
cat << EOF > /usr/share/lighttpd/include-conf-enabled.pl
#!/usr/bin/perl -wl

use strict;
use File::Glob ':glob';

my \$confdir = shift || "/etc/lighttpd/";
my \$enabled = "conf-enabled/*.conf";

chdir(\$confdir);
my @files = bsd_glob(\$enabled);

for my \$file (@files)
{
        print "include \"\$file\"";
}
EOF
chmod +x /usr/share/lighttpd/include-conf-enabled.pl 

fi

mkdir -p $DIRCONFENABLEDHTTPD
mkdir -p $DIRadminHTML
cp -rf CTadmin/* $DIRadminHTML/
#if [ $noinstalldep = "1" ]; then
#	addadminhttpd "admin" "admin"
#else
	clear 
	echo "Entrer le login pour l'interface d'administration :"
	while (true); do
		 read loginhttp
		 case $loginhttp in
			 * )
			 echo "login:  $loginhttp" > /root/passwordCTadmin
			 break
			 ;;
		 esac
	done
	clear
	echo "Entrer le mot de passe de $loginhttp :"
	while (true); do
		 read password
		 case $password in
			 * )
			 echo "password: $password" >> /root/passwordCTadmin
		         addadminhttpd "$loginhttp" "$password"
			 break
			 ;;
		 esac
	done
#fi
chmod 700 /root/passwordCTadmin
chown root:root /root/passwordCTadmin
cat << EOF > $CTPARENTALCONFHTTPD

fastcgi.server = (
    ".php" => (
      "localhost" => ( 
        "bin-path" => "/usr/bin/php-cgi",
        "socket" => "/run/lighttpd/php-fastcgi.sock",
        "max-procs" => 4, # default value
        "bin-environment" => (
          "PHP_FCGI_CHILDREN" => "1", # default value
        ),
        "broken-scriptfilename" => "enable"
      ))
)
  fastcgi.map-extensions     = ( ".php3" => ".php",
                               ".php4" => ".php",
                               ".php5" => ".php",
                               ".phps" => ".php",
                               ".phtml" => ".php" )

\$HTTP["url"] =~ ".*CTadmin.*" {
  auth.require = ( "" =>
                   (
                     "method"  => "digest",
                     "realm"   => "$REALMADMINHTTPD",
                     "require" => "user=$USERADMINHTTPD" 
                   )
                 )

}
\$SERVER["socket"] == "$PRIVATE_IP:80" {
server.document-root = "$DIRHTML"
server.errorfile-prefix = "$DIRHTML/err" 
#ssl.engine = "enable" 
#ssl.pemfile = "/etc/lighttpd/ssl/$PRIVATE_IP.pem" 
}

EOF
chown root:$GROUPHTTPD $DREAB
chmod 660 $DREAB
chown root:$GROUPHTTPD $DNS_FILTER_OSSI
chmod 660 $DNS_FILTER_OSSI
chown root:$GROUPHTTPD $CATEGORIES_ENABLED
chmod 660 $CATEGORIES_ENABLED
chmod 660 /etc/sudoers

sudotest=`grep Defaults:$USERHTTPD /etc/sudoers |wc -l`
if [ $sudotest -ge "1" ] ; then
    $SED "s?^Defaults:$USERHTTPD.*requiretty.*?Defaults:$USERHTTPD     \!requiretty?g" /etc/sudoers
else
    echo "Defaults:$USERHTTPD     !requiretty" >> /etc/sudoers
fi

sudotest=`grep "$USERHTTPD ALL=" /etc/sudoers |wc -l`
if [ $sudotest -ge "1" ] ; then
    $SED "s?^$USERHTTPD.*?$USERHTTPD ALL=(ALL) NOPASSWD:/usr/local/bin/CTparental.sh -gctalist,/usr/local/bin/CTparental.sh -gctulist,/usr/local/bin/CTparental.sh -gcton,/usr/local/bin/CTparental.sh -gctoff,/usr/local/bin/CTparental.sh -tlu,/usr/local/bin/CTparental.sh -trf,/usr/local/bin/CTparental.sh -dble,/usr/local/bin/CTparental.sh -ubl,/usr/local/bin/CTparental.sh -dl,/usr/local/bin/CTparental.sh -on,/usr/local/bin/CTparental.sh -off,/usr/local/bin/CTparental.sh -aupon,/usr/local/bin/CTparental.sh -aupoff?g" /etc/sudoers
else
    echo "$USERHTTPD ALL=(ALL) NOPASSWD:/usr/local/bin/CTparental.sh -gctalist,/usr/local/bin/CTparental.sh -gctulist,/usr/local/bin/CTparental.sh -gcton,/usr/local/bin/CTparental.sh -gctoff,/usr/local/bin/CTparental.sh -tlu,/usr/local/bin/CTparental.sh -trf,/usr/local/bin/CTparental.sh -dble,/usr/local/bin/CTparental.sh -ubl,/usr/local/bin/CTparental.sh -dl,/usr/local/bin/CTparental.sh -on,/usr/local/bin/CTparental.sh -off,/usr/local/bin/CTparental.sh -aupon,/usr/local/bin/CTparental.sh -aupoff" >> /etc/sudoers
fi
	

sudotest=`grep %ctoff /etc/sudoers |wc -l`		
if [ $sudotest -ge "1" ] ; then	
   $SED "s?^%ctoff.*?%ctoff ALL=(ALL) NOPASSWD:/usr/local/bin/CTparental.sh -off,/usr/local/bin/CTparental.sh -on?g" /etc/sudoers
else
   echo "%ctoff ALL=(ALL) NOPASSWD:/usr/local/bin/CTparental.sh -off,/usr/local/bin/CTparental.sh -on"  >> /etc/sudoers
fi
sudotest=`grep "ALL  ALL=(ALL) NOPASSWD:/usr/local/bin/CTparental.sh" /etc/sudoers |wc -l`		
if [ $sudotest -ge "1" ] ; then	
	$SED "s?^ALL  ALL=(ALL) NOPASSWD:/usr/local/bin/CTparental.sh.*?ALL  ALL=(ALL) NOPASSWD:/usr/local/bin/CTparental.sh -on?g" /etc/sudoers
else
	echo "ALL  ALL=(ALL) NOPASSWD:/usr/local/bin/CTparental.sh -on" >> /etc/sudoers
fi
unset sudotest
    
chmod 440 /etc/sudoers
if [ ! -f $FILE_HCONF ] ; then 
	echo > $FILE_HCONF 
fi
chown root:$GROUPHTTPD $FILE_HCONF
chmod 660 $FILE_HCONF
listeusers > $FILE_GCTOFFCONF
chown root:$GROUPHTTPD $FILE_GCTOFFCONF
chmod 660 $FILE_GCTOFFCONF
if [ ! -f $FILE_HCOMPT ] ; then
	echo "date=$(date +%D)" > $FILE_HCOMPT
fi
chown root:$GROUPHTTPD $FILE_HCOMPT
chmod 660 $FILE_HCOMPT

chown -R root:$GROUPHTTPD $DIRHTML
chown -R root:$GROUPHTTPD $DIRadminHTML
$LIGHTTPDstart
test=$?
if [ ! $test -eq 0 ];then
	echo "Erreur au lancement du service lighttpd "
	set -e
	exit 1
fi
}

install () {
	groupadd ctoff
	
	if [ $nomanuel -eq 0 ]; then 
		vim -h 2&> /dev/null
		if [ $? -eq 0 ] ; then
		EDIT="vim "
		fi
		mono -h 2&> /dev/null
		if [ $? -eq 0 ] ; then
		EDIT=${EDIT:="mono "}
		fi
		vi -h 2&> /dev/null
		if [ $? -eq 0 ] ; then
		EDIT=${EDIT:="vi "}
		fi
		if [ -f gpl-3.0.fr.txt ] ; then
			cp -f gpl-3.0.fr.txt /usr/local/share/CTparental/
		fi
		if [ -f gpl-3.0.txt ] ; then
			cp -f gpl-3.0.txt /usr/local/share/CTparental/
		fi
		if [ -f CHANGELOG ] ; then
			cp -f CHANGELOG /usr/local/share/CTparental/
		fi
		if [ -f dist.conf ];then
			cp -f dist.conf /usr/local/share/CTparental/dist.conf.orig
			cp -f dist.conf $DIR_CONF/
		fi
		while (true); do
		$EDIT $DIR_CONF/dist.conf
		clear
		cat $EDIT $DIR_CONF/dist.conf | grep -v -E ^#
		echo "Entrer : S pour continuer avec ces parramêtres ."
		echo "Entrer : Q pour Quiter l'installation."
		echo "Entrer tous autre choix pour modifier les parramêtres."
		 read choi
		case $choi in
			 S | s )
				break
			;;
			 Q | q )
				exit
			;;
			esac
		done
			
	fi
	if [ -f $DIR_CONF/dist.conf ];then
		source  $DIR_CONF/dist.conf 
	fi

	if [ -f /etc/NetworkManager/NetworkManager.conf ];then
    		 $SED "s/^dns=dnsmasq/#dns=dnsmasq/g" /etc/NetworkManager/NetworkManager.conf
    		 $NWMANAGERrestart
     		sleep 5
   	fi

      mkdir $tempDIR
      mkdir -p $DIR_CONF
      initblenabled
      cat /etc/resolv.conf > $DIR_CONF/resolv.conf.sav
      if [ $noinstalldep = "0" ]; then
	      $CMDINSTALL $DEPENDANCES
      fi
      if [ ! -f blacklists.tar.gz ]
      then
         download
      else
         tar -xzf blacklists.tar.gz -C $tempDIR
         if [ ! $? -eq 0 ]; then
            echo "Erreur d'extraction de l'archive, processus interrompu"
            uninstall
            set -e
            exit 1
         fi
         rm -rf $DIR_DNS_FILTER_AVAILABLE/
         mkdir $DIR_DNS_FILTER_AVAILABLE
      fi
      adapt
      catChoice
      dnsmasqon
      $SED "s?^LASTUPDATE.*?LASTUPDATE=$THISDAYS=`date +%d-%m-%Y\ %T`?g" $FILE_CONF
      FoncHTTPDCONF
      $ENCRON
      $ENLIGHTTPD
      $ENDNSMASQ
      $ENNWMANAGER


      
}


updatelistgctoff () {
	## on ajoutes tous les utilisateurs manquant dans la liste
	for PCUSER in `listeusers`
	do
		if [ $(cat $FILE_GCTOFFCONF | sed -e "s/#//g" | grep -c -E "^$PCUSER$") -eq 0 ];then
			echo $PCUSER >> $FILE_GCTOFFCONF
		fi
	done
	## on suprime tous ceux qui n'existe plus sur le pc.
	for PCUSER in $(cat $FILE_GCTOFFCONF | sed -e "s/#//g" )
	do
		if [ $( listeusers | grep -c -E "^$PCUSER$") -eq 0 ];then
			$SED "/^$PCUSER$/d" $FILE_GCTOFFCONF
			$SED "/^#$PCUSER$/d" $FILE_GCTOFFCONF
		fi
	done
}
applistegctoff () {
	updatelistgctoff

	$ADDUSERTOGROUP root ctoff 2> /dev/null
	for PCUSER in $(cat $FILE_GCTOFFCONF )
	do
		if [ $(echo $PCUSER | grep -c -v "#") -eq 1 ];then
			$ADDUSERTOGROUP $PCUSER ctoff 2> /dev/null
		else
			$DELUSERTOGROUP $(echo $PCUSER | sed -e "s/#//g" ) ctoff 2> /dev/null
		fi
	done 
}

activegourpectoff () {
   groupadd ctoff
   $ADDUSERTOGROUP root ctoff
   $SED "s?^GCTOFF.*?GCTOFF=ON?g" $FILE_CONF
   applistegctoff
}

desactivegourpectoff () {
   groupdel ctoff
   $SED "s?^GCTOFF.*?GCTOFF=OFF?g" $FILE_CONF
}

uninstall () {
   desactivegourpectoff
   rm -f /etc/cron.d/CTparental*
   $DNSMASQrestart
   $LIGHTTPDstop
   rm -f /var/www/index.lighttpd.html
   rm -rf $tempDIR
   rm -rf $DIRHTML


   rm -rf /usr/local/share/CTparental
   rm -rf /usr/share/lighttpd/*
   rm -f $CTPARENTALCONFHTTPD
   rm -rf $DIRadminHTML
   if [ -f /etc/NetworkManager/NetworkManager.conf ];then
	$SED "s/^#dns=dnsmasq/dns=dnsmasq/g" /etc/NetworkManager/NetworkManager.conf
	$NWMANAGERrestart
  	sleep 5
   fi

   if [ $noinstalldep = "0" ]; then
	 for PACKAGECT in $DEPENDANCES
         do
	 $CMDREMOVE $PACKAGECT 2> /dev/null
         done
   fi

   rm -rf $DIR_CONF
}

choiblenabled () {
echo -n > $CATEGORIES_ENABLED
clear
echo "Voulez-vous filtrer par Blacklist ou Whitelist :"
echo -n " B/W :"
while (true); do
         read choi
         case $choi in
         B | b )
         echo "Vous allez maintenant choisir les \"Black listes\" à appliquer."
		for CATEGORIE in `cat  $BL_CATEGORIES_AVAILABLE`  # pour chaque catégorie
		do   
		      clear
		      echo "Voulez vous activer la categorie :"
		      echo -n "$CATEGORIE  O/N :"
		      while (true); do
			 read choi
			 case $choi in
			 O | o )
			 echo $CATEGORIE >> $CATEGORIES_ENABLED
			 break
			 ;;
			 N | n )
			 break
			 ;;
		      esac
		      done
		done
         break
         ;;
         W | w )
         echo "Vous allez maintenant choisir les \"White listes\" à appliquer."
		for CATEGORIE in `cat  $WL_CATEGORIES_AVAILABLE`  # pour chaque catégorie
		do   
		      clear
		      echo "Voulez vous activer la categorie :"
		      echo -n "$CATEGORIE  O/N :"
		      while (true); do
			 read choi
			 case $choi in
			 O | o )
			 echo $CATEGORIE >> $CATEGORIES_ENABLED
			 break
			 ;;
			 N | n )
			 break
			 ;;
		      esac
		      done
		done
         break
         ;;
      esac
done
}


errortime1 () {
clear
echo -e "L'heure de début doit être strictement inférieure a l'heure de fin: $RougeD$input$Fcolor "
echo "exemple: 08h00 à 23h59 ou 08h00 à 12h00 et 14h00 à 23h59"
echo -e -n "$RougeD$PCUSER$Fcolor est autorisé à se connecter le $BleuD${DAYS[$NumDAY]}$Fcolor de :"
}
errortime2 () {
clear
echo -e "Mauvaise syntaxe: $RougeD$input$Fcolor "
echo "exemple: 08h00 à 23h59 ou 08h00 à 12h00 et 14h00 à 23h59"
echo -e -n "$RougeD$PCUSER$Fcolor est autorisé à se connecter le $BleuD${DAYS[$NumDAY]}$Fcolor de :"
}


timecronalert () {
MinAlert=${1} # temp en minute entre l'alerte et l'action
H=$((10#${2}))
M=$((10#${3}))
D=$((10#${4}))
MinTotalAlert="$(($H*60+$M-$MinAlert))"
if [ $(( $MinTotalAlert < 0 )) -eq 1 ] 
then
	if [ $Numday -eq 0 ] ; then
		D=6
	else
		D=$(( $D -1 ))
	fi
	MinTotalAlert="$(($(($H + 24))*60+$M-$MinAlert))"
fi
Halert=$(($MinTotalAlert/60))
MAlert=$(($MinTotalAlert - $(( $Halert *60 )) ))
echo "$MAlert $Halert * * ${DAYSCRON[$D]}"
}
updatetimelogin () {
	USERSCONECT=$(who | awk '//{print $1}' | sort -u)
   	if [ $(cat $FILE_HCOMPT | grep -c $(date +%D)) -eq 1 ] ; then
			# on incrément le conteur de temps de connection. pour chaque utilisateur connecter
		for PCUSER in $USERSCONECT
		do
		
			if [ $(cat $FILE_HCONF | grep -c ^$PCUSER=user= ) -eq 1 ] ;then
			   if [ $(cat $FILE_HCOMPT | grep -c ^$PCUSER= ) -eq 0 ] ;then
					echo "$PCUSER=1" >> $FILE_HCOMPT
			   else
					count=$(($(cat $FILE_HCOMPT | grep ^$PCUSER= | cut -d"=" -f2) + 1 ))
					$SED "s?^$PCUSER=.*?$PCUSER=$count?g" $FILE_HCOMPT
					temprest=$(($(cat $FILE_HCONF | grep ^$PCUSER=user= | cut -d "=" -f3 ) - $count ))
					echo $temprest
					# si le compteur de l'usager depace la valeur max autoriser on verrouille le compte et on deconnect l'utilisateur.
					if [ $temprest -le 0 ];then
						/usr/bin/skill -KILL -u$PCUSER
						passwd -l $PCUSER
					else
						# On allerte l'usager que sont quota temps arrive a expiration 5-4-3-2-1 minutes avant.
						if [ $temprest -le 5 ];then
						HOMEPCUSER=$(getent passwd "$PCUSER" | cut -d ':' -f6)
						export HOME=$HOMEPCUSER && export DISPLAY=:0.0 && export XAUTHORITY=$HOMEPCUSER/.Xauthority && sudo -u $PCUSER  /usr/bin/notify-send -u critical "Alerte CTparental" "Votre temps de connection restent est de $temprest minutes "
						fi
					fi
			   fi
			   
			else
			# on efface les ligne relative a cette utilisateur
			$SED "/^$PCUSER$/d" $FILE_HCOMPT
			fi

		done	
	else
		# on réactivent tous les comptes
		for PCUSER in `listeusers`
		do
			passwd -u $PCUSER
		done
		# on remait tous les compteurs a zero.
		echo "date=$(date +%D)" > $FILE_HCOMPT
		
	fi
	
}
activetimelogin () {
   TESTGESTIONNAIRE=""
   for FILE in `echo $GESTIONNAIREDESESSIONS`
   do
      if [ -f $DIRPAM$FILE ];then
         if [ $(cat $DIRPAM$FILE | grep -c "account required pam_time.so") -eq 0  ] ; then
            $SED "1i account required pam_time.so"  $DIRPAM$FILE
         fi
         TESTGESTIONNAIRE=$TESTGESTIONNAIRE\ $FILE
      fi
   done
   if [ $( echo $TESTGESTIONNAIRE | wc -m ) -eq 1 ] ; then
      echo "Aucun gestionnaire de session connu n'a été détecté."
      echo " il est donc impossible d'activer le contrôle horaire des connexions"
      desactivetimelogin
      exit 1
   fi
   
   if [ ! -f $FILEPAMTIMECONF.old ] ; then
   cp $FILEPAMTIMECONF $FILEPAMTIMECONF.old
   fi
   echo "*;*;root;Al0000-2400" > $FILEPAMTIMECONF
   for NumDAY in 0 1 2 3 4 5 6
   do
   echo "PATH=$PATH"  > /etc/cron.d/CTparental${DAYS[$NumDAY]}
   done
   for PCUSER in `listeusers`
   do
   HOMEPCUSER=$(getent passwd "$PCUSER" | cut -d ':' -f6)
   $SED "/^$PCUSER=/d" $FILE_HCONF
   echo -e -n "$PCUSER est autorisé a se connecter 7j/7 24h/24 O/N?" 
   choi=""
   while (true); do
   read choi
        case $choi in
         O | o )
	 alltime="O"
         echo "$PCUSER=admin=" >> $FILE_HCONF
   	break
         ;;
	 N| n )
         alltime="N"
         clear
         echo -e "$PCUSER est autorisé a se connecter X minutes par jours" 
         echo -e -n "X (1 a 1440) = " 
         while (true); do
         read choi
         if [ $choi -ge 1 ];then
			if [ $choi -le 1440 ];then
				break
			fi
		 fi	
         echo " X doit prendre un valeur entre 1 et 1440 "
         done
         echo "$PCUSER=user=$choi" >> $FILE_HCONF
		 break
         ;;	
   esac
   done
      HORAIRES=""
      for NumDAY in 0 1 2 3 4 5 6
         do
	 if [ $alltime = "O" ];then	
		break	
	 fi
	 
         clear
         echo "exemple: 00h00 à 23h59 ou 08h00 à 12h00 et 14h00 à 16h50"
         echo -e -n "$RougeD$PCUSER$Fcolor est autorisé à se connecter le $BleuD${DAYS[$NumDAY]}$Fcolor de :"
         while (true); do
            read choi
            input=$choi
            choi=$(echo $choi | sed -e "s/h//g" | sed -e "s/ //g" | sed -e "s/a/-/g" | sed -e "s/et/:/g" ) # mise en forme de la variable choi pour pam   
               if [ $( echo $choi | grep -E -c "^([0-1][0-9]|2[0-3])[0-5][0-9]-([0-1][0-9]|2[0-3])[0-5][0-9]$|^([0-1][0-9]|2[0-3])[0-5][0-9]-([0-1][0-9]|2[0-3])[0-5][0-9]:([0-1][0-9]|2[0-3])[0-5][0-9]-([0-1][0-9]|2[0-3])[0-5][0-9]$" ) -eq 1 ];then
                  int1=$(echo $choi | cut -d ":" -f1 | cut -d "-" -f1)
                  int2=$(echo $choi | cut -d ":" -f1 | cut -d "-" -f2)
                  int3=$(echo $choi | cut -d ":" -f2 | cut -d "-" -f1)
                  int4=$(echo $choi | cut -d ":" -f2 | cut -d "-" -f2)
                  if [ $int1 -lt $int2 ];then
                     if [ ! $(echo $choi | grep -E -c ":") -eq 1 ] ; then
                        if [ $NumDAY -eq 6 ] ; then
                           HORAIRESPAM="$HORAIRESPAM${DAYSPAM[$NumDAY]}$int1-$int2"
                        else
                           HORAIRESPAM="$HORAIRESPAM${DAYSPAM[$NumDAY]}$int1-$int2|"
                        fi
                        m1=$(echo $int1 | sed -e 's/.\{02\}//')
                        h1=$(echo $int1 | sed -e 's/.\{02\}$//') 
                        m2=$(echo $int2 | sed -e 's/.\{02\}//')
                        h2=$(echo $int2 | sed -e 's/.\{02\}$//')
						echo "$PCUSER=$NumDAY=$h1${h}h$m1:$h2${h}h$m2" >> $FILE_HCONF   
                        echo "$m2 $h2 * * ${DAYSCRON[$NumDAY]} root /usr/bin/skill -KILL -u$PCUSER" >> /etc/cron.d/CTparental${DAYS[$NumDAY]}
			for count in 1 2 3 4 5
			do
                        echo "$(timecronalert $count $h2 $m2 $NumDAY) root export HOME=$HOMEPCUSER && export DISPLAY=:0.0 && export XAUTHORITY=$HOMEPCUSER/.Xauthority && sudo -u $PCUSER  /usr/bin/notify-send -u critical \"Alerte CTparental\" \"fermeture de session dans $count minutes \" " >> /etc/cron.d/CTparental${DAYS[$NumDAY]}
			done
                        break
   
                     else   
                        if [ $int2 -lt $int3 ];then
                           if [ $int3 -lt $int4 ];then
                              if [ $NumDAY -eq 6 ] ; then
                                 HORAIRESPAM="$HORAIRESPAM${DAYSPAM[$NumDAY]}$int1-$int2|${DAYSPAM[$NumDAY]}$int3-$int4"
                              else
                                 HORAIRESPAM="$HORAIRESPAM${DAYSPAM[$NumDAY]}$int1-$int2|${DAYSPAM[$NumDAY]}$int3-$int4|"
                              fi
                              m1=$(echo $int1 | sed -e 's/.\{02\}//')
                              h1=$(echo $int1 | sed -e 's/.\{02\}$//')   
                              m2=$(echo $int2 | sed -e 's/.\{02\}//')
                              h2=$(echo $int2 | sed -e 's/.\{02\}$//')  
                              m3=$(echo $int3 | sed -e 's/.\{02\}//')
                              h3=$(echo $int3 | sed -e 's/.\{02\}$//')   
                              m4=$(echo $int4 | sed -e 's/.\{02\}//')
                              h4=$(echo $int4 | sed -e 's/.\{02\}$//')   
                              ## minutes heures jourdumoi moi jourdelasemaine utilisateur  commande
							  echo "$PCUSER=$NumDAY=$h1${h}h$m1:$h2${h}h$m2:$h3${h}h$m3:$h4${h}h$m4" >> $FILE_HCONF
                              echo "$m2 $h2 * * ${DAYSCRON[$NumDAY]} root /usr/bin/skill -KILL -u$PCUSER" >> /etc/cron.d/CTparental${DAYS[$NumDAY]}
			      echo "$m4 $h4 * * ${DAYSCRON[$NumDAY]} root /usr/bin/skill -KILL -u$PCUSER" >> /etc/cron.d/CTparental${DAYS[$NumDAY]}
			      for count in 1 2 3 4 5
			      do
                              echo "$(timecronalert $count $h2 $m2 $NumDAY) root export HOME=$HOMEPCUSER && export DISPLAY=:0.0 && export XAUTHORITY=$HOMEPCUSER/.Xauthority && sudo -u $PCUSER  /usr/bin/notify-send -u critical \"Alerte CTparental\" \"fermeture de session dans $count minutes \" " >> /etc/cron.d/CTparental${DAYS[$NumDAY]}
                              echo "$(timecronalert $count $h4 $m4 $NumDAY) root export HOME=$HOMEPCUSER && export DISPLAY=:0.0 && export XAUTHORITY=$HOMEPCUSER/.Xauthority && sudo -u $PCUSER  /usr/bin/notify-send -u critical \"Alerte CTparental\" \"fermeture de session dans $count minutes\" " >> /etc/cron.d/CTparental${DAYS[$NumDAY]}
			      done
                             
                              break   
                           else
                              errortime1
                           fi
                        else
                           errortime1
                        fi
                     fi
                  else
                     errortime1
   
                  fi
                       
               else
                  errortime2   
               fi
           
         done
     
        done
     	if [ $alltime = "N" ] ; then
		echo "*;*;$PCUSER;$HORAIRESPAM" >> $FILEPAMTIMECONF
	else
		echo "*;*;$PCUSER;Al0000-2400" >> $FILEPAMTIMECONF
	fi
   done
   
   for NumDAY in 0 1 2 3 4 5 6
   do
      echo >> /etc/cron.d/CTparental${DAYS[$NumDAY]}
   done
   echo >> $FILE_HCONF
echo "PATH=$PATH"  > /etc/cron.d/CTparentalmaxtimelogin
echo "*/1 * * * * root /usr/local/bin/CTparental.sh -uctl" >> /etc/cron.d/CTparentalmaxtimelogin
$SED "s?^HOURSCONNECT.*?HOURSCONNECT=ON?g" $FILE_CONF
$CRONrestart
}

desactivetimelogin () {
for FILE in `echo $GESTIONNAIREDESESSIONS`
do
   $SED "/account required pam_time.so/d" $DIRPAM$FILE
done
cat $FILEPAMTIMECONF.old > $FILEPAMTIMECONF
for NumDAY in 0 1 2 3 4 5 6
do
   rm -f /etc/cron.d/CTparental${DAYS[$NumDAY]}
done
rm -f /etc/cron.d/CTparentalmaxtimelogin
$SED "s?^HOURSCONNECT.*?HOURSCONNECT=OFF?g" $FILE_CONF
for PCUSER in `listeusers`
do
	passwd -u $PCUSER
done
# on remait tous les compteurs a zero.
echo "date=$(date +%D)" > $FILE_HCOMPT
echo > $FILE_HCONF
$CRONrestart
}


listeusers () {
TABUSER=( " $(getent passwd | cut -d":" -f1,3) " )
for LIGNES in $TABUSER
do
#echo $(echo $LIGNES | cut -d":" -f2)
if [ $(echo $LIGNES | cut -d":" -f2) -ge $UIDMINUSER ] ;then
	echo $LIGNES | cut -d":" -f1
fi
done
}


readTimeFILECONF () {
   TESTGESTIONNAIRE=""
   for FILE in `echo $GESTIONNAIREDESESSIONS`
   do
      if [ -f $DIRPAM$FILE ];then
         if [ $(cat $DIRPAM$FILE | grep -c "account required pam_time.so") -eq 0  ] ; then
            $SED "1i account required pam_time.so"  $DIRPAM$FILE
         fi
         TESTGESTIONNAIRE=$TESTGESTIONNAIRE\ $FILE
      fi
   done
   if [ $( echo $TESTGESTIONNAIRE | wc -m ) -eq 1 ] ; then
      echo "Aucun gestionnaire de session connu n'a été détecté."
      echo " il est donc impossible d'activer le contrôle horaire des connexions"
      desactivetimelogin
      exit 1
   fi
   
   if [ ! -f $FILEPAMTIMECONF.old ] ; then
   cp $FILEPAMTIMECONF $FILEPAMTIMECONF.old
   fi
   echo "*;*;root;Al0000-2400" > $FILEPAMTIMECONF
   for NumDAY in 0 1 2 3 4 5 6
   do
   echo "PATH=$PATH" > /etc/cron.d/CTparental${DAYS[$NumDAY]}
   done
   
   for PCUSER in `listeusers`
   do
   HOMEPCUSER=$(getent passwd "$PCUSER" | cut -d ':' -f6)
   HORAIRESPAM=""
  	userisconfigured="0"

	while read line
	do
	
			if [ $( echo $line | grep -E -c "^$PCUSER=[0-6]=" ) -eq 1 ] ; then
				echo "$line" 
				NumDAY=$(echo $line | cut -d"=" -f2)
				h1=$(echo $line | cut -d"=" -f3 | cut -d":" -f1 | cut -d"h" -f1)
				m1=$(echo $line | cut -d"=" -f3 | cut -d":" -f1 | cut -d"h" -f2)
				h2=$(echo $line | cut -d"=" -f3 | cut -d":" -f2 | cut -d"h" -f1)
				m2=$(echo $line | cut -d"=" -f3 | cut -d":" -f2 | cut -d"h" -f2)
				h3=$(echo $line | cut -d"=" -f3 | cut -d":" -f3 | cut -d"h" -f1)
				m3=$(echo $line | cut -d"=" -f3 | cut -d":" -f3 | cut -d"h" -f2)
				h4=$(echo $line | cut -d"=" -f3 | cut -d":" -f4 | cut -d"h" -f1)
				m4=$(echo $line | cut -d"=" -f3 | cut -d":" -f4 | cut -d"h" -f2)
				if [ $(echo -n $h3$m3 | wc -c) -gt 2 ]; then
 					if [ $NumDAY -eq 6 ] ; then
		                        	HORAIRESPAM="$HORAIRESPAM${DAYSPAM[$NumDAY]}$h1$m1-$h2$m2|${DAYSPAM[$NumDAY]}$h3$m3-$h4$m4"
						
		                      	else
		                        	HORAIRESPAM="$HORAIRESPAM${DAYSPAM[$NumDAY]}$h1$m1-$h2$m2|${DAYSPAM[$NumDAY]}$h3$m3-$h4$m4|"
		                      	fi
					echo "$m2 $h2 * * ${DAYSCRON[$NumDAY]} root /usr/bin/skill -KILL -u$PCUSER" >> /etc/cron.d/CTparental${DAYS[$NumDAY]}
					echo "$m4 $h4 * * ${DAYSCRON[$NumDAY]} root /usr/bin/skill -KILL -u$PCUSER" >> /etc/cron.d/CTparental${DAYS[$NumDAY]}
					for count in 1 2 3 4 5
					do
					echo "$(timecronalert $count $h2 $m2 $NumDAY) root export HOME=$HOMEPCUSER && export DISPLAY=:0.0 && export XAUTHORITY=$HOMEPCUSER/.Xauthority && sudo -u $PCUSER  /usr/bin/notify-send -u critical \"Alerte CTparental\" \"fermeture de session dans $count minutes \" " >> /etc/cron.d/CTparental${DAYS[$NumDAY]}
					echo "$(timecronalert $count $h4 $m4 $NumDAY) root export HOME=$HOMEPCUSER && export DISPLAY=:0.0 && export XAUTHORITY=$HOMEPCUSER/.Xauthority && sudo -u $PCUSER  /usr/bin/notify-send -u critical \"Alerte CTparental\" \"fermeture de session dans $count minutes \" " >> /etc/cron.d/CTparental${DAYS[$NumDAY]}
					userisconfigured="1"
					done

				else
				        if [ $NumDAY -eq 6 ] ; then
				           HORAIRESPAM="$HORAIRESPAM${DAYSPAM[$NumDAY]}$h1$m1-$h2$m2"
				        else
				           HORAIRESPAM="$HORAIRESPAM${DAYSPAM[$NumDAY]}$h1$m1-$h2$m2|"
				        fi
					for count in 1 2 3 4 5
					do
					echo "$(timecronalert $count $h2 $m2 $NumDAY) root export HOME=$HOMEPCUSER && export DISPLAY=:0.0 && export XAUTHORITY=$HOMEPCUSER/.Xauthority && sudo -u $PCUSER  /usr/bin/notify-send -u critical \"Alerte CTparental\" \"fermeture de session dans $count minutes \" " >> /etc/cron.d/CTparental${DAYS[$NumDAY]}
					done
					echo "$m2 $h2 * * ${DAYSCRON[$NumDAY]} root /usr/bin/skill -KILL -u$PCUSER" >> /etc/cron.d/CTparental${DAYS[$NumDAY]}
					
					userisconfigured="1"
				fi
			fi
	
	
	done < $FILE_HCONF
	if [ $userisconfigured -eq 1 ] ; then
		echo "*;*;$PCUSER;$HORAIRESPAM" >> $FILEPAMTIMECONF
	else
		echo "*;*;$PCUSER;Al0000-2400" >> $FILEPAMTIMECONF
	fi
   done
echo "PATH=$PATH"  > /etc/cron.d/CTparentalmaxtimelogin  
echo "*/1 * * * * root /usr/local/bin/CTparental.sh -uctl" >> /etc/cron.d/CTparentalmaxtimelogin
$SED "s?^HOURSCONNECT.*?HOURSCONNECT=ON?g" $FILE_CONF
$CRONrestart
}



usage="Usage: CTparental.sh    {-i }|{ -u }|{ -dl }|{ -ubl }|{ -rl }|{ -on }|{ -off }|{ -cble }|{ -dble }
                               |{ -tlo }|{ -tlu }|{ -uhtml }|{ -aupon }|{ -aupoff }|{ -aup } 
-i      => Installe le contrôle parental sur l'ordinateur (pc de bureau). Peut être utilisé avec
           un paramètre supplémentaire pour indiquer un chemin de sources pour la page web de redirection.
           exemple : CTparental.sh -i -dirhtml /home/toto/html/
           si pas d'option le \"sens interdit\" est utilisé par défaut.
-u      => désinstalle le contrôle parental de l'ordinateur (pc de bureau)
-dl     => met à jour le contrôle parental à partir de la blacklist de l'université de Toulouse
-ubl    => A faire après chaque modification du fichier $DNS_FILTER_OSSI
-rl     => A faire après chaque modification manuelle du fichier $DREAB
-on     => Active le contrôle parental
-off    => Désactive le contrôle parental
-cble   => Configure le mode de filtrage par liste blanche ou par liste noire (défaut) ainsi que les 
           catégories que l'on veut activer.
-dble   => Remet les catégories actives par défaut et le filtrage par liste noire.
-tlo    => Active et paramètre les restrictions horaires de login pour les utilisateurs.
           Compatible avec les gestionnaire de sessions suivant $GESTIONNAIREDESESSIONS .
-tlu    => Désactive les restrictions horaires de login pour les utilisateurs.
-uhtml  => met à jour la page de redirection à partir d'un répertoire source ou par défaut avec 
            le \"sens interdit\".
            exemples:
                     - avec un repertoire source : CTparental.sh -uhtml -dirhtml /home/toto/html/
   		     - par défaut :              CTparental.sh -uhtml
            permet aussi de changer le couple login, mot de passe de l'interface web.
-aupon  => active la mise à jour automatique de la blacklist de Toulouse (tous les 7 jours).
-aupoff => désactive la mise à jour automatique de la blacklist de Toulouse.
-aup    => comme -dl mais seulement si il n'y a pas eu de mise à jour depuis plus de 7 jours.
-nodep  => si placer aprés -i ou -u permet de ne pas installer/désinstaller les dépendances, utiles si 
            on préfaire les installer a la mains , ou pour le scripte de postinst et prerm 
            du deb.
            exemples:
                     CTparental.sh -i -nodep	
		     CTparental.sh -i -dirhtml /home/toto/html/ -nodep   
		     CTparental.sh -u -nodep 
-nomanuel => utiliser uniquement pour le scripte de postinst et prerm 
            du deb.
-gcton	  => créer un group de privilégier ne subisent pas le filtrage.
			 exemple:CTparental.sh -gctulist
			 editer $FILE_GCTOFFCONF et y commanter tous les utilisateurs que l'on veut filtrer.
			 CTparental.sh -gctalist
-gctoff   => suprime le group de privilégier .
			 tous les utilisateurs du system subisse le filtrages!!
-gctulist => Mes a jour le fichier de conf du group , $FILE_GCTOFFCONF
			 en fonction des utilisateur ajouter ou suprimer du pc.
-gctalist => Ajoute/Suprime les utilisateurs dans le group ctoff en fonction du fichier de conf.
	 
 "
case $arg1 in
   -\? | -h* | --h*)
      echo "$usage"
      exit 0
      ;;
   -i | --install )
      install
      iptablesoff
      iptableson
      exit 0
      ;;
   -u | --uninstall )
      autoupdateoff 
      iptablesoff
      dnsmasqoff
      desactivetimelogin
      uninstall
      exit 0
      ;;
   -dl | --download )
      download
      adapt
      catChoice
      dnsmasqon
      $SED "s?^LASTUPDATE.*?LASTUPDATE=$THISDAYS=`date +%d-%m-%Y\ %T`?g" $FILE_CONF
      exit 0
      ;;
   -ubl | --updatebl )
      adapt
      catChoice
      dnsmasqon
      exit 0
      ;;
   -uhtml | --updatehtml )
      FoncHTTPDCONF
      exit 0
      ;;
   -rl | --reload )
      catChoice
      dnsmasqon
      exit 0
      ;;
   -on | --on )
      dnsmasqon
      iptableson
      exit 0
      ;;
   -off | --off )
      autoupdateoff 
      dnsmasqoff
      iptablesoff
      exit 0
      ;;
   -wlo | --whitelistonly )
      dnsmasqwhitelistonly
      exit 0
      ;;
   -cble | --confblenable )
      choiblenabled
      catChoice
      dnsmasqon
      exit 0
      ;;
    -dble | --defaultblenable )
      initblenabled
      catChoice
      dnsmasqon
      ;;
    -tlo | --timeloginon )
      activetimelogin
      ;;
    -tlu | --timeloginon )
      desactivetimelogin
      ;;
    -trf | --timeloginon )
      readTimeFILECONF
      ;;
    -aupon | --autoupdateon )
      autoupdateon
      ;;
    -aupoff | --autoupdateoff )
      autoupdateoff
      ;;
    -aup | --autoupdate )
      autoupdate
      ;;
    -listusers )
      listeusers
      ;;
    -gcton )
      activegourpectoff
	  iptablesoff
	  iptableson
      ;;
    -gctoff )
	  desactivegourpectoff
	  iptablesoff
	  iptableson
      ;;
    -gctulist )
	  updatelistgctoff
	  iptablesoff
	  iptableson
      ;;
    -gctalist )
	  applistegctoff
	  iptablesoff
	  iptableson
      ;;
    -uctl )
	  # apelet toute les minute par cron pour activer desactiver les usagers ayant des restrictions de temps journalier de connection.
	  updatetimelogin
      ;;      
      
   *)
      echo "Argument inconnu :$1";
      echo "$usage";
      exit 1
      ;;
esac


