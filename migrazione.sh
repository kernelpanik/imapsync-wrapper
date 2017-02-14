#!/bin/bash

##############################################################################################################
# File name - migrazione.sh                                                                                  #
# Descrizione - Bash script per automatizzare migrazione email accounts                                      #
#                                                                                                            #
# Richiede - accounts.txt                                                                                    #
# 																	                                                                         #
# 																		                                                                       #
# Il carattere separatore del file accounts.txt e' un punto e virgola ";" e puo' essere sostituito           #
# da qualsiasi carattere. Basta modificare la variabile IFS=';' dei vari cicli while		                     #
#  																								                                                     			 #
# Ogni riga del file accounts.txt contiene 4 colonne, le colonne sono i parametri:                           #
# --user1 --password1 --user2 --password2                                                                    #
#																										                                                      	 #
#  RICORDARSI:                                                                                               #
#																										                                                         #
# --useuid  si usa solo la prima volta per copiare tutte le email                                            #
# Per sincronizzare una seconda volta scegliare l'opzione (no --useuid)                                      #
##############################################################################################################  																								 #


#VARIABILI GLOBALI
############################################################################################################
#SYNCLOGFILE="/home/user/Desktop/imapsync-prog/synclog.log"
#cambiare anche variabile al punto 3, impostare cron
SYNCLOGFOLDER="/home/user/Desktop/imapsync-prog/log/"
PATHFILECRON="/etc/cron.d/imapsync"
PATHFILESCRIPTFOLDER="/tmp/"
PATHFILE="/home/user/accounts.txt"



#DEFINIZIONE DELLE ESPRESSIONI REGOLARI
export REG1="--regextrans2 s/Bozze$/Drafts/"
export REG2="--regextrans2 s/Cestino$/Trash/"
export REG3=" --regextrans2 s/(.)*Posta(.)*$/Sent/"
###
##      REG3 diventa REG3CRON dichiarata nell opzione 3 per permettere echo su script
###
REG4=""
REG5=""
###############################


#COLORI
###
###
red='\e[0;31m'
NC='\e[0m' # No Color
green='\e[;32m'
####
###############################





echo -e "\n*** Tool per migrazione mail accounts ***\n"


if [ "$(whoami)" != 'root' ]; then
        echo -e "\nNon puoi utilizzare $0 come utente normale. Devi essere root."
        sleep 2
        exit 1;

        else
        echo -e "\nOK! Sei root, puoi procedere..."
        sleep 1
fi

command -v imapsync >/dev/null 2>&1 || { echo >&2 "Il programma imapsync non e' installato.  Uscita."; exit 1; }

MENU="
Menu:
 1)  Esegui una prima migrazione (--useuid)
 2)  Esegui una seconda sincronizzazione (no --useuid)
 3)  Mantieni sync con cron e script temporaneo/i
 4)  Rimuovi ora sync con cron e lo script temporaneo/i
 5)  Imposta ora/giorno di rimozione con at
 6)  Analizza i file di log in cerca di errori
 9)  Esci

Scelta: "

while true ; do
clear
echo -en "${red}$MENU${NC}"

read OPTIONS


case $OPTIONS in


1)
PRIMA="
  #############################################################
  # PRIMA Migrazione                (--useuid)                #
  #                                                           #
  # Copia tutte le email dal vecchio account al nuovo account #
  #############################################################
"

echo "$PRIMA"
echo -ne "${green}Nome del server dal quale migrare le mail: ${NC}"
read SERVER1
echo -ne "\n${green}Nome del server verso il quale migrare le mail: ${NC}"
read SERVER2

echo -ne "\n${green}Prefisso delle cartelle dell'host1 da rimuovere nell'host2
(ex. 'mail/' o 'INBOX.' , senza apici.): ${NC}"
read PREFISSO1
PRE1="--prefix1 $PREFISSO1"


#echo -ne "\nAggiungi questo prefisso a tutte le cartelle dell'host2
#(di solito vuoto '', due apici ): "
#read PREFISSO2
#PRE2="--prefix2 $PREFISSO2"

#echo -ne "\nL'host1 utilizza SSL? (si|no): "
#read CONSS1

#if [ $CONSS1 == "si" ]; then CONS1="--ssl1"
#else CONS1=""
#fi

#echo -ne "\nL'host2 utilizza SSL? (si|no): "
#read CONSS2
#if [ $CONSS2 == "si" ]; then CONS2="--ssl2"
#else CONS2=""
#fi

#echo -ne "\nL'host1 utilizza TSL? (si|no): "
#read CONTL1
#if [ $CONTL1 == "si" ]; then CONST1="--tls1"
#else CONST1=""
#fi

#echo -ne "\nL'host2 utilizza TSL? (si|no): "
#read CONTL2
#if [ $CONTL2 == "si" ]; then CONST2="--tls2"
#else CONST2=""
#fi


SERVEXP="\n${green}Utilizzare le reg exp?
1) Si
2) No
3) Ritorna al menu

Scelta: ${NC}"

while true ; do
echo -en "$SERVEXP"
read EXPR
case $EXPR in

1|si|Si|SI)
echo -e "\nOK! RegExp aggiunte!  "
sleep 1
#############################################################################
# vecchio ciclo per inserire reg exp, probl con inserimento spazi
#si)
#echo -en "\nQuante regexp aggiungere? (in numero, max 5): "
#read REGNUM
# assenga a ogni REGEXP1,2,3, valore corrispondente
	#for ((i=1; i<=$REGNUM; i++)); do
	#echo -en "\nAggiungi regexp $i (ex 's/Bozze$/Drafts/' ) , con gli apici: "
	#read "REGEXP$i"
    #d=REGEXP$i
    #echo -e "\n"
	#export EXPRE$i="--regextrans2 ${!d}"
	#done
#############################################################################


echo -e "\n${green}Checking $PATHFILE . . . \n${NC}"


if [ -f $PATHFILE ];
then
   sed -i '/^[[:space:]]*$/d;s/[[:space:]]*$//' -i $PATHFILE
   echo -e "Totale accounts: $(cat $PATHFILE | wc -l)"
   echo -e "\n${green}Controllo che USERNAME coincidano. . . \n ${NC}"
   awk -F ";" '{if ($1!=$3) {print $0, "  ------> ", "ERRORE!  brunoooooooo"}}' $PATHFILE
   if [ $(awk -F ";" '{if ($1!=$3) print $0}' $PATHFILE | wc -l) -eq 0 ] ; then  echo -e "OK"
   else
   echo -e "\n"
   exit
   fi

   echo -e "\n${green}Controllo che PASSWORD coincidano. . . \n ${NC}"
   #echo -e "\n"
   awk -F ";" '{if ($2!=$4) {print $0, "  ------> ", "ERRORE!  brunoooooooo"}}' $PATHFILE
   if [ $(awk -F ";" '{if ($2!=$4) print $0}' $PATHFILE | wc -l) -eq 0 ] ; then  echo -e "OK"
   else
   echo -e "\n"
   exit
   fi
   sleep 1
else
   echo -e "\n${green}Il file NON ESISTE o la directory e' SBAGLIATA!\n${NC}"
   exit;
fi

DRYMENUUNO="\n${green}Modalita' --dry:
1) Si
2) No
3) Ritorna al menu' precedente

Scelta:  ${NC}"

while true; do
echo -en "$DRYMENUUNO"
read DRYSEC14

case $DRYSEC14 in

1|si|Si|SI)
echo -e "\n${green}Pronti a partire . . .\n${NC}"
sleep 1


{ while IFS=';' read  u1 p1 u2 p2
    do
        { echo "$u1" | egrep "^#" ; } > /dev/null && continue # salta eventuali commenti nel file accounts.txt
        echo "==== Syncing user $u1 to user $u2 ===="
        imapsync --host1 $SERVER1 --user1 "$u1" --password1 "$p1" \
                 --host2 $SERVER2 --user2 "$u2" --password2 "$p2"  \
                 $PRE1 $REG1 $REG2 $REG3 $REG4 $REG5 \
                 --useuid --dry --tls1 --tls2  2>&1 | tee $SYNCLOGFOLDER$u1\-"$(date)".log
                 #--regextrans2 's/Bozze$/Drafts/' \
                 #--regextrans2 's/Posta inviata$/Sent/' \
                 #--regextrans2 's/Cestino$/Trash/'
                 #tenute per comodita'
        echo -e "\n==== Sincronizzazione finita ====\n"
        sleep 1
    done
} < $PATHFILE
echo Premi RETURN per continuare
read
break 2
;;

2|no|No|NO)
echo -e "\n****   NO DRY MODE ****   FA ATTENZIONE!!!\n"
echo -e "${green}Pronti a partire......\n${NC}"
sleep 1

{ while IFS=';' read  u1 p1 u2 p2
    do
        { echo "$u1" | egrep "^#" ; } > /dev/null && continue
        echo "==== Syncing user $u1 to user $u2 ===="
        imapsync --host1 $SERVER1 --user1 "$u1" --password1 "$p1" \
                 --host2 $SERVER2 --user2 "$u2" --password2 "$p2"  \
                 $PRE1 $REG1 $REG2 $REG3 $REG4 $REG5 \
                 --useuid 2>&1 | tee $SYNCLOGFOLDER$u1\-"$(date)".log
                 #--regextrans2 's/Bozze$/Drafts/' \
                 #--regextrans2 's/Posta inviata$/Sent/' \
                 #--regextrans2 's/Cestino$/Trash/' --useuid
        echo -e "\n==== Sincronizzazione finita ====\n"
        sleep 1
    done
} < $PATHFILE

echo Premi RETURN per continuare
read
break 2
;;

3)
break
;;

*)
echo -e "\nTasto sbagliato";
sleep 1;
;;
esac
done

#sleep 1
#echo press RETURN to continue
#read
;;


2|no|No|NO)
echo -e "\nContinuiamo senza regexp . . . "

echo -e "\n${green}Checking $PATHFILE . . . \n${NC}"


if [ -f $PATHFILE ];
then
   sed -i '/^[[:space:]]*$/d;s/[[:space:]]*$//' -i $PATHFILE
   echo -e "Totale accounts: $(cat $PATHFILE | wc -l)"
   echo -e "\n${green}Controllo che username coincidano. . . \n ${NC}"
   awk -F ";" '{if ($1!=$3) {print $0, "  ------> ", "ERRORE!  brunoooooooo"}}' $PATHFILE
   if [ $(awk -F ";" '{if ($1!=$3) print $0}' $PATHFILE | wc -l) -eq 0 ] ; then  echo -e "OK"
   else
   echo -e "\n"
   exit
   fi

   echo -e "\n${green}Controllo che password coincidano. . . \n ${NC}"
   #echo -e "\n"
   awk -F ";" '{if ($2!=$4) {print $0, "  ------> ", "ERRORE!  brunoooooooo"}}' $PATHFILE
   if [ $(awk -F ";" '{if ($2!=$4) print $0}' $PATHFILE | wc -l) -eq 0 ] ; then  echo -e "OK"
   else
   echo -e "\n"
   exit
   fi
   sleep 1
else
   echo -e "\nIl file non ESISTE o la directory e' SBAGLIATA!\n"
   exit;
fi


DRYMENUDUE="\n${green}Modalita' --dry:
1) Si
2) No
3) Ritorna al menu' precedente

Scelta:  ${NC}"

while true; do
echo -en "$DRYMENUDUE"
read DRY12

case $DRY12 in

1|si|Si|SI)

echo -e "\n${green}Pronti a partire......\n${NC}"
sleep 1

{ while IFS=';' read  u1 p1 u2 p2
    do
        { echo "$u1" | egrep "^#" ; } > /dev/null && continue # salta eventuali commenti nel file accounts.csv
        echo "==== Syncing user $u1 to user $u2 ===="
        imapsync --host1 $SERVER1 --user1 "$u1" --password1 "$p1" \
                 --host2 $SERVER2 --user2 "$u2" --password2 "$p2"  \
                 $PRE1 --useuid --dry  2>&1 | tee $SYNCLOGFOLDER$u1\-"$(date)".log

        echo -e "\n==== Sincronizzazione finita ====\n"

    done
} < $PATHFILE

echo Premi RETURN per continuare
read
break 2
;;

2|no|No|NO)

echo -e "\n**** NO DRY MODE ****   FA ATTENZIONE!!!\n"
echo -e "${green}Pronti a partire......\n${NC}"
sleep 2


{ while IFS=';' read  u1 p1 u2 p2
    do
        { echo "$u1" | egrep "^#" ; } > /dev/null && continue # salta eventuali commenti nel file accounts.csv
        echo "==== Syncing user $u1 to user $u2 ===="
        imapsync --host1 $SERVER1 --user1 "$u1" --password1 "$p1" \
                 --host2 $SERVER2 --user2 "$u2" --password2 "$p2"  \
                 $PRE1 --useuid  2>&1 | tee $SYNCLOGFOLDER$u1\-"$(date)".log

        echo -e "\n==== Sincronizzazione finita ====\n"

    done
} < $PATHFILE

echo Premi RETURN per continuare
read
break 2
;;

3)
break
;;

*)
echo -e "\nTasto sbagliato";
sleep 1
;;
esac
done

;;


3)
break
;;

*)
echo -e "\nTasto sbagliato";
sleep 1;
;;
esac

done

;;

2)

SECONDA="
  #############################################################
  # SECONDA Migrazione      (no --useuid)                     #
  #                                                           #
  # Mantiene sincronizzate le cartelle                        #
  #############################################################
"

echo "$SECONDA"

echo -ne "${green}Nome del server dal quale migrare le mail: ${NC}"
read SERVERDUE1

echo -ne "\n${green}Nome del server verso il quale migrare le mail: ${NC}"
read SERVERDUE2


echo -ne "\n${green}Prefisso delle cartelle dell'host1 da rimuovere nell'host2
(ex. 'mail/' o 'INBOX.' , senza apici.): ${NC}"
read PREFISSODUE1
PREDUE1="--prefix1 $PREFISSODUE1"

#echo -ne "\nAggiungi questo prefisso a tutte le cartelle dell'host2
#(di solito vuoto '', due apici ): "
#read PREFISSODUE2
#PREDUE2="--prefix2 $PREFISSODUE2"

#echo -ne "\nL'host1 utilizza SSL? (si|no): "
#read CONSSDUE1

#if [ $CONSSDUE1 == "si" ]; then CONSDUE1="--ssl1"
#else CONSDUE1=""
#fi

#echo -ne "\nL'host2 utilizza SSL? (si|no): "
#read CONSSDUE2
#if [ $CONSSDUE2 == "si" ]; then CONSDUE2="--ssl2"
#else CONSDUE2=""
#fi

#echo -ne "\nL'host1 utilizza TSL? (si|no): "
#read CONTLDUE1
#if [ $CONTLDUE1 == "si" ]; then CONSTDUE1="--tls1"
#else CONSTDUE1=""
#fi

#echo -ne "\nL'host2 utilizza TSL? (si|no): "
#read CONTLDUE2
#if [ $CONTLDUE2 == "si" ]; then CONSTDUE2="--tls2"
#else CONSTDUE2=""
#fi



SINO="\n${green}Utilizzare lo switch --maxage:
(Non sincronizzare mail piu' vecchie di N giorni)
1) Si
2) No
3) Torna al menu

Scelta:  ${NC}"
while true; do
echo -en "$SINO"
read SINOSCELTA

case $SINOSCELTA in

1|si|Si|SI)
echo -en "${green}Di quanti giorni? (n.intero):
Es. 0  - seleziona solamente messaggi spediti oggi
    1  - seleziona solamente messaggi spediti ieri ed oggi

Numero: ${NC}"
read GIORNI
export GIORNIOK="--maxage $GIORNI"
echo -e "\nFATTO"
break
;;

2|no|No|NO)
echo -e "\nOk. . .niente"
GIORNIOK=""
sleep 1
break
;;

3)
continue 2
;;

*)
echo -e "\nTasto sbagliato"
sleep 1
;;

esac
done



SERVEXP2="\n${green}Utilizzare le reg exp:
1) Si
2) No
3) Ritorna al menu' principale

Scelta: ${NC}"
while true ; do
echo -en "$SERVEXP2"
read EXPR2
case $EXPR2 in


1|si|Si|SI)
echo -e "\nOK! RegExp aggiunte!  "
sleep 1

#si)
#echo -en "\nQuante regexp aggiungere? (in numero): "
#read REGNUMDUE


    ######################
    ## assenga a ogni REGEXP1,2,3, valore corrispondente

	#for ((i=1; i<=$REGNUMDUE; i++)); do
	#echo -en "\nAggiungi regexp $i (ex 's/Bozze$/Drafts/' ) , con gli apici: "
	#read "REGEXPDUE$i"
    #d=REGEXPDUE$i
    #echo -e "\n"
	#export EXPREDUE$i="--regextrans2 ${!d}"
	#done

    ###########

echo -e "\n${green}Checking $PATHFILE . . . \n${NC}"


if [ -f $PATHFILE ];
then
   sed -i '/^[[:space:]]*$/d;s/[[:space:]]*$//' -i $PATHFILE
   echo -e "Totale accounts: $(cat $PATHFILE | wc -l)"

   echo -e "\n${green}Controllo che username coincidano. . . \n ${NC}"
   awk -F ";" '{if ($1!=$3) {print $0, "  ------> ", "ERRORE!  brunoooooooo"}}' $PATHFILE
   if [ $(awk -F ";" '{if ($1!=$3) print $0}' $PATHFILE | wc -l) -eq 0 ] ; then  echo -e "OK"
   else
   echo -e "\n"
   exit
   fi

   echo -e "\n${green}Controllo che password coincidano. . . \n ${NC}"
   #echo -e "\n"
   awk -F ";" '{if ($2!=$4) {print $0, "  ------> ", "ERRORE!  brunoooooooo"}}' $PATHFILE
   if [ $(awk -F ";" '{if ($2!=$4) print $0}' $PATHFILE | wc -l) -eq 0 ] ; then  echo -e "OK"
   else
   echo -e "\n"
   exit
   fi
   sleep 1
else
   echo -e "\nIl file non ESISTE o la directory e' SBAGLIATA!\n"
   exit;
fi

DRYYOU="\n${green}Modalita' --dry:
1) Si
2) No
3) Ritorna al menu' precedente

Scelta: ${NC}"
while true; do
echo -ne "$DRYYOU"
read DRYDUE14

case $DRYDUE14 in

1|si|Si|SI)
echo -e "\n${green}Pronti a partire......\n${NC}"
sleep 1

{ while IFS=';' read  u1 p1 u2 p2
    do
        { echo "$u1" | egrep "^#" ; } > /dev/null && continue # salta eventuali commenti nel file accounts.csv
        echo "==== Syncing user $u1 to user $u2 ===="
        imapsync --host1 $SERVERDUE1 --user1 "$u1" --password1 "$p1" \
                 --host2 $SERVERDUE2 --user2 "$u2" --password2 "$p2"  \
                 $PREDUE1 $REG1 $REG2 $REG3 $REG4 $REG5 $GIORNIOK  \
                 --dry 2>&1 | tee $SYNCLOGFOLDER$u1\-"$(date)".log
                 #--regextrans2 's/Bozze$/Drafts/' \
                 #--regextrans2 's/Posta inviata$/Sent/' \
                 #--regextrans2 's/Cestino$/Trash/'
                 #tenute per comodita'

        echo -e "\n==== Sincronizzazione finita ====\n"
        sleep 1
    done
} < $PATHFILE
echo Premi RETURN per continuare
read
break 2
;;

2|no|No|NO)
echo -e "\n****   NO DRY MODE ****   FA ATTENZIONE!\n"
echo -e "${green}Pronti a partire......\n${NC}"
sleep 1

{ while IFS=';' read  u1 p1 u2 p2
    do
        { echo "$u1" | egrep "^#" ; } > /dev/null && continue # salta eventuali commenti nel file accounts.csv
        echo "==== Syncing user $u1 to user $u2 ===="
        imapsync --host1 $SERVERDUE1 --user1 "$u1" --password1 "$p1" \
                 --host2 $SERVERDUE2 --user2 "$u2" --password2 "$p2"  \
                 $PREDUE1 $REG1 $REG2 $REG3 $REG4 $REG5 $GIORNIOK 2>&1 | tee $SYNCLOGFOLDER$u1\-"$(date)".log
                 #--regextrans2 's/Bozze$/Drafts/' \
                 #--regextrans2 's/Posta inviata$/Sent/' \
                 #--regextrans2 's/Cestino$/Trash/' --useuid

        echo -e "\n==== Sincronizzazione finita ====\n"

    done
} < $PATHFILE
echo Premi RETURN per continuare
read
break 2
;;

3)
break
;;

*)
echo -e "\nTasto sbagliato\n";
sleep 1;
;;
esac
done

;;


2|no|No|NO)
echo -e "\nContinuiamo senza regexp . . . "

echo -e "\n${green}Checking $PATHFILE . . . \n${NC}"


if [ -f $PATHFILE ];
then
   sed -i '/^[[:space:]]*$/d;s/[[:space:]]*$//' -i $PATHFILE
   echo -e "Totale accounts: $(cat $PATHFILE | wc -l)"

   echo -e "\n${green}Controllo che username coincidano. . . \n ${NC}"
   awk -F ";" '{if ($1!=$3) {print $0, "  ------> ", "ERRORE!  brunoooooooo"}}' $PATHFILE
   if [ $(awk -F ";" '{if ($1!=$3) print $0}' $PATHFILE | wc -l) -eq 0 ] ; then  echo -e "OK"
   else
   echo -e "\n"
   exit
   fi

   echo -e "\n${green}Controllo che password coincidano. . . \n ${NC}"
   #echo -e "\n"
   awk -F ";" '{if ($2!=$4) {print $0, "  ------> ", "ERRORE!  brunoooooooo"}}' $PATHFILE
   if [ $(awk -F ";" '{if ($2!=$4) print $0}' $PATHFILE | wc -l) -eq 0 ] ; then  echo -e "OK"
   else
   echo -e "\n"
   exit
   fi
   sleep 1
else
   echo -e "\nIl file non ESISTE o la directory e' SBAGLIATA!\n"
   exit;
fi

DRYYOUTWO="\n${green}Modalita' --dry:
1) Si
2) No
3) Ritorna al menu' precedente

Scelta: ${NC} "

while true; do
echo -en "$DRYYOUTWO"
read DRYDUE12

case $DRYDUE12 in

1|si|Si|SI)

echo -e "\n${green}Pronti a partire......\n${NC}"
sleep 1

{ while IFS=';' read  u1 p1 u2 p2
    do
        { echo "$u1" | egrep "^#" ; } > /dev/null && continue # salta eventuali commenti nel file accounts.csv
        echo "==== Syncing user $u1 to user $u2 ===="
        imapsync --host1 $SERVERDUE1 --user1 "$u1" --password1 "$p1" \
                 --host2 $SERVERDUE2 --user2 "$u2" --password2 "$p2"  \
                 $PREDUE1  $GIORNIOK --dry  2>&1 | tee $SYNCLOGFOLDER$u1\-"$(date)".log

        echo -e "\n==== Sincronizzazione finita ====\n"

    done
} < $PATHFILE
echo Premi RETURN per continuare
read
break 2
;;

2|no|No|NO)

echo -e "\n**** NO DRY MODE ****   FA ATTENZIONE!!!\n"
echo -e "${green}Pronti a partire......\n${NC}"
sleep 2

{ while IFS=';' read  u1 p1 u2 p2
    do
        { echo "$u1" | egrep "^#" ; } > /dev/null && continue # salta eventuali commenti nel file accounts.csv
        echo "==== Syncing user $u1 to user $u2 ===="
        imapsync --host1 $SERVERDUE1 --user1 "$u1" --password1 "$p1" \
                 --host2 $SERVERDUE2 --user2 "$u2" --password2 "$p2"  \
                 $PREDUE1 $GIORNIOK  2>&1 | tee $SYNCLOGFOLDER$u1\-"$(date)".log


        echo -e "\n==== Sincronizzazione finita ====\n"

    done
} < $PATHFILE
echo Premi RETURN per continuare
read
break 2
;;

3)
break
;;

*)
echo -e "\nTasto sbagliato\n";
sleep 1
;;
esac
done
;;

3)
break
;;


*)
echo -e "\nTasto sbagliato\n";
sleep 1;
;;
esac
done
;;



3)

TERZA="
  #############################################################################
  # Imposta un CronJob per sincronizzare i due account                        #
  # Copia tutte le ultime email arrivate dal vecchio account al nuovo account #
  # ATTENZIONE:  --dry disabilitata di default                                #
  #############################################################################
"

echo "$TERZA"

echo -ne "\n${green}Server (host1) dal quale migrare le mail: ${NC}"
read CRONHOSTUNO

echo -ne "\n${green}Server (host2) verso il quale migrare le mail: ${NC}"
read CRONHOSTDUE


echo -ne "\n${green}Prefisso delle cartelle dell'host1 da rimuovere nell'host2
(ex. 'mail/' o 'INBOX.' , senza apici.): ${NC}"
read PREFISSOTRE1
PRETRE1="--prefix1 $PREFISSOTRE1"

#echo -ne "\nAggiungi questo prefisso a tutte le cartelle dell'host2
#(di solito vuoto '', due apici ): "
#read PREFISSOTRE2
#PRETRE2="--prefix2 $PREFISSOTRE2"

#echo -ne "\nL'host1 utilizza SSL? (si|no): "
#read CONSSTRE1

#if [ $CONSSTRE1 == "si" ]; then CONSTRE1="--ssl1"
#else CONSTRE1=""
#fi

#echo -ne "\nL'host2 utilizza SSL? (si|no): "
#read CONSSTRE2
#if [ $CONSSTRE2 == "si" ]; then CONSTRE2="--ssl2"
#else CONSTRE2=""
#fi

#echo -ne "\nL'host1 utilizza TSL? (si|no): "
#read CONTLTRE1
#if [ $CONTLTRE1 == "si" ]; then CONSTTRE1="--tls1"
#else CONSTTRE1=""
#fi

#echo -ne "\nL'host2 utilizza TSL? (si|no): "
#read CONTLTRE2
#if [ $CONTLTRE2 == "si" ]; then CONSTTRE2="--tls2"
#else CONSTTRE2=""
#fi

######################



SINOTRE="\n${green}Utilizzare lo switch --maxage:
(Non sincronizzare mail piu' vecchie di N giorni)
1) Si
2) No

Scelta:  ${NC}"

while true; do
echo -en "$SINOTRE"
read SINOSCELTATRE

case $SINOSCELTATRE in

1|si|Si|SI)
echo -en "\n${green}Di quanti giorni? (n.intero):
Es. 0  - seleziona solamente messaggi spediti oggi
    1  - seleziona solamente messaggi spediti ieri ed oggi

Numero: ${NC}"
read GIORNITRE
export GIORNIOKTRE="--maxage $GIORNITRE"
break
;;
2|no|No|NO)
echo -e "\nOk. . .niente"
export GIORNIOKTRE=""
sleep 1
break
;;

*)
echo -e "\nTasto sbagliato"
sleep 1
;;

esac
done




echo -en "\n${green}Definisci il nome dello script, es. 'nome.sh': ${NC}"
read PATHFILESCRIPTNAME

export PATHFILESCRIPT="$PATHFILESCRIPTFOLDER$PATHFILESCRIPTNAME"

SERVEXP3="\n${green}Utilizzare le reg exp:
1) Si
2) No

Scelta: ${NC}"

while true ; do
echo -en "$SERVEXP3"
read EXPR3
case $EXPR3 in

1|si|Si|SI)

echo -e "\nOK! RegExp aggiunte!  "
sleep 1
#si)
#echo -en "\nQuante regexp aggiungere? (in numero, max 5): "
#read REGNUM3


    ######################
    ## assenga a ogni REGEXP1,2,3, valore corrispondente

	#for ((z=1; z<=$REGNUM3; z++)); do
	#echo -en "\nAggiungi regexp $i (ex 's/Bozze$/Drafts/' ) , con gli apici: "
	#read "REGEXPTRE$z"
    #c=REGEXPTRE$z
    #echo -e "\n"
	#export EXPRETRE$z="--regextrans2 ${!c}"
	#done

    ###########

break
;;


2|no|No|NO)
echo -e "\nContinuiamo senza regexp . . . \n"
break
;;

#3)
#break 2
#;;

*)
echo -e "\nTasto sbagliato\n";
sleep 1;
;;
esac

done



#########################

echo -e "\n${green}Checking $PATHFILE . . . \n${NC}"


if [ -f $PATHFILE ];
then
   sed -i '/^[[:space:]]*$/d;s/[[:space:]]*$//' -i $PATHFILE
   echo -e "Totale accounts: $(cat $PATHFILE | wc -l)"
   echo -e "\n${green}Controllo che username coincidano. . . \n ${NC}"
   awk -F ";" '{if ($1!=$3) {print $0, "  ------> ", "ERRORE!  brunoooooooo"}}' $PATHFILE
   if [ $(awk -F ";" '{if ($1!=$3) print $0}' $PATHFILE | wc -l) -eq 0 ] ; then  echo -e "OK"
   else
   echo -e "\n"
   exit
   fi

   echo -e "\n${green}Controllo che password coincidano. . . \n ${NC}"
   #echo -e "\n"
   awk -F ";" '{if ($2!=$4) {print $0, "  ------> ", "ERRORE!  brunoooooooo"}}' $PATHFILE
   if [ $(awk -F ";" '{if ($2!=$4) print $0}' $PATHFILE | wc -l) -eq 0 ] ; then  echo -e "OK"
   else
   echo -e "\n"
   exit
   fi
   sleep 1
else
   echo -e "\nIl file non ESISTE o la directory e' SBAGLIATA!\n"
   exit;
fi




echo -e "\n${green}Controllo se /etc/cron.d/imapsync esiste gia'... ...${NC}"
sleep 1
if [ -f $PATHFILECRON ];
then
   echo -e "\nIl file /etc/cron.d/imapsync ESISTE"

   RIMFILE="\n${green}Opzioni:
1) Il CronJob viene aggiunto al file esistente
2) Il file viene rimosso e ricreato. vengono eliminati script.

Scelta: ${NC}"

   while true ; do
   echo -en "$RIMFILE"
   read OPTIONSEC

   case $OPTIONSEC in

2|no|No|NO)
   echo -e "\n${green}Rimozione del file /etc/cron.d/imapsync${NC}"
   rm -rf /etc/cron.d/imapsync
   touch /etc/cron.d
   echo -e "FATTO"
   sleep 1
   echo -e "\n${green}Rimozione script temporaneo/i in $PATHFILESCRIPTFOLDER${NC}"
   rm -rf $PATHFILESCRIPTFOLDER*.sh
   echo -e "FATTO"
   sleep 1
   break
   ;;

1|si|Si|SI)
   echo -e "\nCronJob verra' aggiunto. Verra' creato un nuovo script temporaneo"
   sleep 1
   break
   ;;

   *)
   echo -e "\nTasto sbagliato\n";
   sleep 1
   ;;
esac

  done
  fi

   echo -e "\n${green}Procediamo..."

   echo -ne "\nOgni quante ore eseguire il cronjob?: ${NC}"
   read CRONHOUR
   CRONORA="*/$CRONHOUR"


REG3=" --regextrans2 s/(.)*Posta(.)*$/Sent/"
REG3CRON="--regextrans2 's/(.)*Posta(.)*$/Sent/'"

touch $PATHFILESCRIPT && chmod 775 $PATHFILESCRIPT

echo '#!/bin/bash' >> $PATHFILESCRIPT
echo "{ while IFS=';' read  u1 p1 u2 p2" >> $PATHFILESCRIPT
echo "do" >> $PATHFILESCRIPT
echo "imapsync --host1 $CRONHOSTUNO --user1 \"\$u1\" --password1 \"\$p1\" --host2 $CRONHOSTDUE --user2 \"\$u2\" --password2 \"\$p2\" $PRETRE1 $REG1 $REG2 "$REG3CRON" $REG4 $REG5 $REG6 $REG7 $REG8 $REG9 $GIORNIOKTRE > $SYNCLOGFOLDER\$u1\-\"\$(date)\".log 2>&1 "  >> $PATHFILESCRIPT
echo "done"  >> $PATHFILESCRIPT
echo "} < $PATHFILE " >> $PATHFILESCRIPT

cd /etc/cron.d/ && touch imapsync && chmod 644 /etc/cron.d/imapsync
echo "*	$CRONORA	*	*	*	root	$PATHFILESCRIPT"  >> /etc/cron.d/imapsync
#echo "*/2	*	*	*	*	root	$PATHFILESCRIPT " >> /etc/cron.d/imapsync
touch /etc/cron.d


sleep 1
echo -e "\n"
echo -en "${green}CronJob IMPOSTATO!${NC}"
echo -e "\n"
echo Premi RETURN per continuare
read
;;


4)
QUARTA="
  ##########################################################################
  #      Rimuovi ora:                                                      #
  #      - job in /etc/cron.d/imapsync                                     #
  #      - script temporaneo/i                                             #
  #      - file di log                                                     #
  ##########################################################################
"

echo "$QUARTA"

#echo -e "\nChecking /etc/cron.d/imapsync . . . "

# if [[ -f /etc/cron.d/imapsync ]]; then

    RIGA="MENU
1) Visualizza file di cron
2) Visualizza script temporanei
3) Visualizza file di log
4) Cancella file di cron, script e log - tutto!
5) Cancella solo i file di log
6) Cancella file di cron e script uno alla volta
7) Ritorna al menu'

Scelta: "

    while true ; do
    echo -en "\n${green}$RIGA${NC}"
    read DELSCELTA

    case $DELSCELTA in

    1)
    echo -e "\n"
    cat /etc/cron.d/imapsync 2> /dev/null
    echo -e "\n"
    if [ $? == 1 ] ; then echo -e "\nFILE NON TROVATO\n"
    fi
    echo Premi RETURN per continuare
    read
    ;;

     2)
    TROVASCRIPT=$(find $PATHFILESCRIPTFOLDER -name '*.sh' -printf "\n%f")
    if [ $(find $PATHFILESCRIPTFOLDER -name '*.sh' -printf "\n%f" | wc -l ) -eq 0 ] ; then echo -en "\nScript NON TROVAT0/I\n\n"
    else
    echo -e "\n$TROVASCRIPT\n"
    fi

    echo Premi RETURN per continuare
    read
     ;;
     3)
    TROVALOG=$(find $SYNCLOGFOLDER -name '*.log' -printf "\n%f")
    if [ $(find $SYNCLOGFOLDER -name '*.log' -printf "\n%f" | wc -l ) -eq 0 ] ; then echo -en "\nLog NON TROVATI\n\n"
    else
    echo -e "$TROVALOG\n"
    fi
    echo Premi RETURN per continuare
    read
     ;;
    4)
    echo -e "\n${green}Cancello /etc/cron.d/imapsync${NC}"
    if [ -f "/etc/cron.d/imapsync" ] ; then rm -rf /etc/cron.d/imapsync && touch /etc/cron.d
    echo -e "${green}FATTO${NC}\n"
    else
    echo -en "/etc/cron.d/imapsync NON TROVAT0\n\n"
    fi


    echo -e "${green}Rimuovo gli srcipt temporanei${NC}"
    if [ $(find $PATHFILESCRIPTFOLDER -name '*.sh' -printf "\n%f" | wc -l ) -eq 0 ] ; then echo -en "Script NON TROVAT0/I\n\n"
    else
    rm -rf $PATHFILESCRIPTFOLDER*.sh
    echo -e "${green}FATTO${NC}\n"
    fi

    echo -e "${green}Cancello i file di log${NC}"
    if [ $(find $SYNCLOGFOLDER -name '*.log' -printf "\n%f" | wc -l ) -eq 0 ] ; then echo -en "Log NON TROVAT0\I\n\n"
    else
    rm -rf  $SYNCLOGFOLDER*.log
    echo -e "${green}FATTO${NC}\n"
    fi
    echo Premi RETURN per continuare
    read
    ;;
    5)
    echo -e "\n${green}Cancello i file di log${NC}"
    if [ $(find $SYNCLOGFOLDER -name '*.log' -printf "\n%f" | wc -l ) -eq 0 ] ; then echo -en "Log NON TROVAT0\I\n\n"
    else
    rm -rf  $SYNCLOGFOLDER*.log
    echo -e "${green}FATTO${NC}\n"
    fi
    echo Premi RETURN per continuare
    read
    ;;
    6)
    if [ $(find $PATHFILESCRIPTFOLDER -name '*.sh' -printf "\n%f" | wc -l ) -eq 0 ] ; then echo -en "\nScript NON TROVAT0/I\n\n"
    echo Premi RETURN per continuare
     read
    break
    else
    echo -en "\n${green}Digita nome dello script, es. nomescript.sh: ${NC}"
    read DELSCRIPT
     sed -n "/$DELSCRIPT/!p" -i /etc/cron.d/imapsync && touch /etc/cron.d
     rm -rf $PATHFILESCRIPTFOLDER$DELSCRIPT*
     echo -e "\n{green}FATTO${NC}\n"
    fi
     if [ $(cat /etc/cron.d/imapsync | wc -l) -eq 0 ]; then
     rm -rf /etc/cron.d/imapsync && touch /etc/cron.d
     break
     else
     continue
     fi
     echo Premi RETURN per continuare
     read
       ;;
    7)
    break
    ;;

    *)
    echo -e "\nTasto sbagliato\n"
    sleep 1
    ;;

    esac
    done

 #   else
  #  echo -e "NON TROVATO! . . ."
  #  sleep 1

#fi



###########################################################3


##echo -e "\nControllo che il file /etc/cron.d/imapsync non esista"

#if [[  -f /etc/cron.d/imapsync ]]; then
    #echo -e "\nFile in /etc/cron.d/imapsync ancora presente. \n"
    #sleep 1
    #else
    #echo "Test: OK"
#fi

##echo -e "\nControllo che non ci siano script temporanei in $PATHFILESCRIPT "

#if [ $(find $PATHFILESCRIPTFOLDER -name '*.sh' | wc -l) -eq 0 ]; then
    #echo "Test: OK"
    #else
    #echo -e "\nScript in $PATHFILESCRIPTFOLDER ancora presente/i. \n"
    #sleep 1
#fi

##echo -e "\nControllo che il file di log $SYNCLOGFILE non esista"

#if [[  -f $SYNCLOGFILE ]]; then
    #echo -e "\nFile di log in $SYNCLOGFILE ancora presente. \n"
    #sleep 1
    #else
    #echo -e "Test: OK\n"
#fi

#sleep 1
#echo Press RETURN to continue
#read

;;

5)
QUINTA="
  ######################################################################
  #      Imposta giorno/ora di rimozione di:                           #
  #      - job in /etc/cron.d/imapsync                                 #
  #      - script temporaneo/i                                         #
  ######################################################################
"

echo "$QUINTA"

if [ $(find $PATHFILESCRIPTFOLDER -name '*.sh' | wc -l) -gt 0 ]
then

   SCRIPTMENUAT="MENU'
1) Visualizza script esistenti
2) Imposta at per la rimozione degli script
3) Ritorna al menu'

Scelta:  "

   while true ; do
   echo -en "\n${green}$SCRIPTMENUAT${NC}"

   read CANCAT

   case $CANCAT in

   1)
     find $PATHFILESCRIPTFOLDER -name '*.sh' -printf "\n%f"
     echo -e "\n"
     echo Press RETURN to continue
     ;;

   3)
    break
   ;;


  2)
    echo -en "\n${green}Digita il nome dello script che vuoi eliminare es: nomescript.sh \n
Nome dello script: ${NC}"
   read NOMESCRIPTAT
   echo -en "${green}Quale mese/giorno/anno? (form_ingl: mm/gg/aaaa): ${NC}"
   read GIORNO
   echo -en "${green}Quale ora? (hh:mm): ${NC}"
   read ORA

   at $ORA $GIORNO  <<< "rm -rf $PATHFILESCRIPTFOLDER$NOMESCRIPTAT ; sed -n '/$NOMESCRIPTAT/!p' -i /etc/cron.d/imapsync && touch /etc/cron.d "
   echo -e "\nFATTO\n"
   sleep 1
   if [ $(find $PATHFILESCRIPTFOLDER -name '*.sh' | wc -l) -eq 0 ]; then
  break
  else
  continue
  fi
   echo Premi RETURN per continuare
   read
   ;;


  *)
   echo -e "\nTasto sbagliato\n"
   sleep 1
   ;;
   esac
   done

else
   echo "Script NON TROVATI. . .torno al menu'. . . "
   sleep 1
fi

;;

6)
SESTA="
  ######################################################################
  #                                                                    #
  #      Analizza il file di LOG in cerca di errori                    #
  #                                                                    #
  ######################################################################
"

echo "$SESTA"


echo -e "\nChecking $SYNCLOGFOLDER . . . "
if [ $(find $SYNCLOGFOLDER -name '*.log' | wc -l) -eq 0 ]
    then
    echo -e "\nFile di log NON TROVATI . . . continuo. . .\n"
    sleep 1

    else
    echo -e "File di log TROVATI. . ."
    echo -e "\n"
    SCESEI="Menu
1) Vedi i file di log
2) Analizza tutti insieme
3) Analizza uno alla volta
4) Ritorna al menu

Scelta: "

    while true; do
    echo -en "${green}$SCESEI${NC}"
    read RIMSEI

    case $RIMSEI in

    1)
    find $SYNCLOGFOLDER -name '*.log' -printf "\n%f"
    echo -e "\n"
    echo Press RETURN to continue
    read
    ;;

    2)
    echo -e "\nAnalizzo. . . \n"
    egrep -i --color "errors|warn|failure|critic|failure|bad|unable"  $SYNCLOGFOLDER*
    if [ $? == 1 ] ; then sleep 1 && echo -e "\nNessun errore trovato\n"
    fi
    echo -e "\n"
    echo Press RETURN to continue
    read
    ;;

    3)
    find $SYNCLOGFOLDER -name '*.log' -printf "\n%f"
    echo -e "\n"
    echo -en "\nPrime lettere del nome del file: "
    read NOMELOGSEI
    echo -e "\n"
    egrep -i --color "errors|warn|fail|critic|failure|bad|unable"  $SYNCLOGFOLDER$NOMELOGSEI*
    if [ $? == 1 ] ; then sleep 1 && echo -e "\nNessun errore trovato\n"
    fi
    echo -e "\n"
    echo Press RETURN to continue
    read
    ;;

   4)
   break
   ;;

   *)
   echo -e "\nTasto sbagliato\n"
   sleep 1
   ;;
   esac
   done

fi


#sleep 1
#echo Press RETURN to continue
#read
;;


9|0|q|Q)
echo -e "\nCiao!\n"
exit 0
;;


*)
clear
echo -e "\nTasto sbagliato\n"
sleep 1
;;
esac

done
