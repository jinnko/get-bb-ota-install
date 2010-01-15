#!/bin/bash
#
# get-bb-ota-fetch.sh - get the files required to install an app when given a jad url
#
# @author: Jinn Koriech
# @since: 2010-01-10
# @version: $Id: $
#
# vim:set ts=4 sw=4 sts=4 noexpandtab listchars=tab\:|\ ,trail\:_

JAD_URL="$1"
BASE_JAD_URL=`dirname $JAD_URL`
JAD_FILE=`basename ${JAD_URL/\?*/}`

echo "JAD_URL:      ${JAD_URL}"
echo "BASE_JAD_URL: ${BASE_JAD_URL}"
echo "JAD_FILE:     ${JAD_FILE}"

if [ ! -e "${JAD_FILE}" ]; then
	wget --timestamping -q --no-check-certificate \
	--user-agent="BlackBerry8800/sw0/4.3.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 VendorID/107UP.Link/6.2.3.15.0" \
	"$JAD_URL" -O "${JAD_FILE}"
fi

# Create the ALX while we go
ALX_FILE="${JAD_FILE/jad/alx}"
MIDletVendor=`grep MIDlet-Vendor "$JAD_FILE" | cut -d" " -f2- | cat -vet`
MIDletVendor="${MIDletVendor/\^M\$/}"
MIDletName=`grep MIDlet-Name "$JAD_FILE" | cut -d" " -f2- | cat -vet`
MIDletName="${MIDletName/\^M\$/}"
MIDletVersion=`grep MIDlet-Version "$JAD_FILE" | cut -d" " -f2- | cat -vet`
MIDletVersion="${MIDletVersion/\^M\$/}"


cat <<EOF >${ALX_FILE}
<loader version="1.0">
<application id="${MIDletName}:${MIDletVendor}">
<name>${MIDletName}</name>
<description></description>
<version>$MIDletVersion</version>
<vendor>${MIDletVendor}</vendor>
<copyright></copyright>
<fileset Java="1.0">
<files>
EOF

cat -vet "$JAD_FILE" |
grep RIM-COD-URL |
cut -d' ' -f2 |
sed 's/\^M\$//' |
while read COD; do
	echo -n "Downloading ${COD}.."
	wget --timestamping -q --no-check-certificate \
	--user-agent="BlackBerry8800/sw0/4.3.0 Profile/MIDP-2.0 Configuration/CLDC-1.1 VendorID/107UP.Link/6.2.3.15.0" \
	"$BASE_JAD_URL/$COD"
	echo -en "$COD\r\n" >> ${ALX_FILE}
	echo "done."
done

echo

cat <<EOF >> ${ALX_FILE}
</files>
</fileset>
</application>
</loader>
EOF

cat ${ALX_FILE}
