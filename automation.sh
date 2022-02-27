
service="ramya"
bucket_name="upgrad-ramya"
pkgs='apache2'
pathname=/tmp/
timestamp=$(date '+%d%m%Y-%H%M%S')
logname=${service}-httpd-logs-${timestamp}.tar
file=${pathname}${logname}
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

