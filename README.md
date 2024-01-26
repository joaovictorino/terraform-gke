# Terraform criando Google Kubernetes Engine no GCP

Pré-requisitos

- gcloud instalado
- Terraform instalado

Logar no GCP via gcloud, o navegador será aberto para que o login seja feito

```sh
gcloud auth application-default login
```

Inicializar o Terraform

```sh
terraform init
```

Executar o Terraform

```sh
terraform apply -auto-approve
```

Adicionar credenciais do GKE no kubectl local

```sh
gcloud container clusters get-credentials  gke-aula-infra --region us-central1
```
