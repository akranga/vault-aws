backend "consul" {
  address = "{{consul_addr}}:{{consul_port}}"
}

#backend "aws" {
#  access_key = "AKIAJWVN5Z4FOFT7NLNA"
#  secret_key = "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"
#  region = "us-east-1"
#}

listener "tcp" {
  address = "127.0.0.1:8200"
  tls_disable = 1
}
