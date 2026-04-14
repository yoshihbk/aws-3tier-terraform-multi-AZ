# ---------------------------------------------------------
# Launch Template for EC2 (Web/App)
# ---------------------------------------------------------
resource "aws_launch_template" "web_lt" {
  name = "web-launch-template"

  image_id      = data.aws_ssm_parameter.al2023.value
  instance_type = "t3.micro"

  vpc_security_group_ids = [
    aws_security_group.ec2_sg.id
  ]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_ssm_profile.name
  }

  user_data = base64encode(<<EOF
#!/bin/bash
dnf update -y
dnf install -y nginx -y
systemctl enable nginx
systemctl start nginx

cat <<'HTML' > /usr/share/nginx/html/index.html
<!DOCTYPE html>
<html lang="ja">

<head>
  <meta charset="UTF-8">
  <title>My Web Server</title>
  <style>
    body {
      background: #f5f5f5;
      font-family: Arial, sans-serif;
      text-align: center;
      padding-top: 80px;
    }

    h1 {
      color: #333;
      font-size: 40px;
    }

    p {
      color: #666;
      font-size: 18px;
    }

    .box {
      background: white;
      padding: 40px;
      margin: auto;
      width: 60%;
      border-radius: 10px;
      box-shadow: 0 0 10px #ccc;
    }
  </style>
</head>

<body>
  <div class="box">
    <h1>Welcome to My Server</h1>
    <p>このページは ALB → EC2 → nginx で配信されています。</p>
  </div>
</body>

</html>
HTML
EOF
  )
}
