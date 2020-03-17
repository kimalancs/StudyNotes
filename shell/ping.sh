ping -c1 www.baidu.com &> /dev/null && echo "website is up" || echo "website is down"

python <<-EOF
print("hello world")
EOF