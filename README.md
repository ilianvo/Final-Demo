# pipeapp

Tool versions:

    Terraform - 1.3.7
    AWS CLI - 1.22.34
    Docker - 20.10.23
    AWS provider - 4.50.0

## Deploy

How to deploy.

```
terraform init
terraform plan
terraform apply -var-file="secret.tfvars" -auto-approve
terraform init -force-copy
```

## Change
Make change in your application then: 
```
git add.
git commit -m "your comment"
git push
```
See if the webhook is triggered and the change is implemented

## Destroy
1.In main.tf change the value of ```terraform_backend_config_file_path ``` to this:
```
 module "remote-state" {
   terraform_backend_config_file_path = ""
   force_destroy                      = true
 }
```
2.```terraform apply -target module.remote-state -auto-approve```. This implements the above modifications by deleting the ```backend.tf``` file and enabling deletion of the S3 state bucket.

3.```terraform init -force-copy```. Terraform detects that you want to move your Terraform state from the S3 backend to local files, and it does so per ```-auto-approve```. Now the state is once again stored locally and the S3 state bucket can be safely deleted.

4. Set force_delete value in ```module.ecr``` to ```true```

5. ```terraform apply -target module.ecr -auto-approve```

6. ```terraform destroy -auto-approve```

7. Done
