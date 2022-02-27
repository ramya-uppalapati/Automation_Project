
service="ramya"
bucket_name="upgrad-ramya"
pkgs='apache2'
pathname=/tmp/
timestamp=$(date '+%d%m%Y-%H%M%S')
logname=${service}-httpd-logs-${timestamp}.tar
file=${pathname}${logname}
sitepath="/var/www/html"
cronpath=/etc/cron.d/Automation

sudo apt update -y
if ! dpkg -s $pkgs >/dev/null 2>&1; then
  sudo apt-get install $pkgs
fi

if systemctl is-active --quiet $pkgs; then
    echo "apache 2 running"
else
    systemctl start $pkgs
    echo "started apache2"
fi

if systemctl is-enabled $pkgs; then
    echo "apache2 is enabled"
else
    systemctl enable $pkgs
fi

cd /var/log/apache2
tar -cf ${file} *.log

if test -f "$file"; then
    echo "copying to s3";
    aws s3 cp ${file} s3://${bucket_name}/${logname}
    echo "completed upload";
fi

if test -f "${sitepath}/inventory.html"; then
    echo "inventory exists";
else
    echo "creating inventory";
    echo -e 'Log Type\t-\tTime Created\t-\tType\t-\tSize' > ${sitepath}/inventory.html
fi

if test -f "${sitepath}/inventory.html"; then
    echo "updating inventory";
    size=$(du -h ${file} | awk '{print $1}')
	echo -e "httpd-logs\t-\t${timestamp}\t-\ttar\t-\t${size}" >> ${sitepath}/inventory.html
fi

if test -f ${cronpath}; then
    echo "cron job exists";
else
    echo " * * * * * root/Automation_Project/automation.sh" >> ${cronpath}
fi
