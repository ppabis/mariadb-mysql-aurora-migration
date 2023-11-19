data "http" "aws-ip-ranges" {
  url = "https://ip-ranges.amazonaws.com/ip-ranges.json"
}

resource "null_resource" "ec2-instance-connect-ip" {
  triggers = {
    # This thing searches for EC2 Instance Conenct IP in AWS IP ranges list
    ip = [
      for prefix in jsondecode(data.http.aws-ip-ranges.response_body)["prefixes"]
      : prefix["ip_prefix"]
      if prefix["service"] == "EC2_INSTANCE_CONNECT"
      && prefix["region"] == "eu-west-1"
    ][0]
  }
}
