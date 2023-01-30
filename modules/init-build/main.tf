terraform {
  required_providers {
   docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.1"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}


resource "docker_image" "example" {
  build {
    context = "/home/hanov/first-demo/"
    
  }
  name = "${var.ecr_name}:latest"
}

resource "null_resource" "push_image" {
  provisioner "local-exec" {
    command =  "aws ecr get-login-password --region eu-west-3 | docker login --username AWS --password-stdin ${var.ecr_name} && docker push ${var.ecr_name}:latest"
    
  }
  triggers = {
    image_id = "${var.ecr_name}:latest"
  }
  depends_on = [docker_image.example]
}