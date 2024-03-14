# terraform_basecode
Código base para clase demostrativa de Terraform

## Variables requeridas
En un archivo .env en la raíz del proyecto agregar/modificar/poblar las siguientes variables:

```
instance_type="t2.small"
min_instances_count="1"
max_instances_count="2"
desired_instances_count="1"
environment="testing"
vpc_cidr_block="10.10.0.0/16"
network_subnets_cidr_block={ "public1": "10.10.0.0/24", "public2": "10.10.1.0/24", "public3": "10.10.4.0/24", "private1": "10.10.2.0/24", "private2": "10.10.3.0/24", "private3": "10.10.6.0/24" }
network_availability_zone_name={ "public1": "us-east-1a", "public2": "us-east-1b", "public3": "us-east-1c", "private1": "us-east-1a", "private2": "us-east-1b", "private3": "us-east-1c" }
memory_value_to_scale_cluster="75"
cpu_value_to_scale_cluster="75"
memory_value_to_scale_services="100"
cpu_value_to_scale_services="75"
max_containers="2"
min_containers="1"
app_version="0.0.1"
docker_image=""

###AWS Variables###
AWS_ACCESS_KEY_ID=""
AWS_DEFAULT_REGION=""
AWS_SECRET_ACCESS_KEY=""
```

### Comandos para desplegar

Inicializar Terraform:
- ```terraform init```

Revisión de cambios a aplicar:
- ```terraform plan -var-file=.env```
 
Aplicación de los cambios y creación de los recursos:
- ```terraform apply -var-file=.env```

Destrucción de los recursos:
- ```terraform destroy -var-file=.env```
