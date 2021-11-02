terraform {
    required_providers {
        kubernetes = {
            source = "hashicorp/kubernetes"
        }  
    }
}

provider "kubernetes" {  
    host = var.host
    client_certificate = base64decode(var.client_certificate)  
    client_key = base64decode(var.client_key)  
    cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
}

# Apache Spark Master 
resource "kubernetes_deployment" "spark-master" {
       metadata {
        name = "spark-master"
        labels = {
            app = "spark-master"
        }
    }

    spec{
        replicas = "1"

        selector {
            match_labels = {
                app = "spark-master"
            }
        }

        template{
            metadata{
                labels = {
                    app = "spark-master"
                }
            }

            spec{
                container {
                    image = "bitnami/spark"
                    name = "spark-master"

                    resources {
                        # These don't work locally for some reason... result in pending pod deployment
                        # limits = {
                        #     cpu = "8"
                        #     memory = "16G"
                        # }
                        # requests = {
                        #     cpu = "8"
                        #     memory = "16G"
                        # }
                    }

                    # Environment Variables
                    env {
                        name = "SPARK_MODE"
                        value = "master"
                    }

                    env {
                        name = "SPARK_RPC_AUTHENTICATION_ENABLED"
                        value = "no"
                    }

                    env {
                        name = "SPARK_RPC_ENCRYPTION_ENABLED"
                        value = "no"
                    }

                    env {
                        name = "SPARK_LOCAL_STORAGE_ENCRYPTION_ENABLED"
                        value = "no"
                    }

                    env {
                        name = "SPARK_SSL_ENABLED"
                        value = "no"
                    }

                    port {
                        container_port = "8080"
                        host_port = "8080"
                    }

                    port{
                        container_port = "7077"
                        host_port = "7077"
                    }
                }
            }
        }
    }
}

#Apache Spark Worker
resource "kubernetes_deployment" "spark-worker" {
       metadata {
        name = "spark-worker"
        labels = {
            test = "spark-worker"
        }
    }

    depends_on = [
      kubernetes_deployment.spark-master
    ]

    spec{
        replicas = "1"

        selector {
            match_labels = {
                test = "spark-worker"
            }
        }

        template{
            metadata{
                labels = {
                    test = "spark-worker"
                }
            }

            spec{
                container {
                    image = "bitnami/spark"
                    name = "spark-worker"

                    resources {
                        # These don't work locally for some reason... result in pending pod deployment
                        # limits = {
                        #     cpu = "8"
                        #     memory = "16G"
                        # }
                        # requests = {
                        #     cpu = "8"
                        #     memory = "16G"
                        # }
                    }

                    # Environment Variables
                    env {
                        name = "SPARK_MODE"
                        value = "worker"
                    }

                    env{
                        name = "SPARK_MASTER_URL"
                        value = "spark://spark:7077"
                    }

                    env{
                        name = "SPARK_WORKER_MEMORY"
                        value = "32G"
                    }

                    env{
                        name="SPARK_WORKER_CORES"
                        value = "8"
                    }

                    env {
                        name = "SPARK_RPC_AUTHENTICATION_ENABLED"
                        value = "no"
                    }

                    env {
                        name = "SPARK_RPC_ENCRYPTION_ENABLED"
                        value = "no"
                    }

                    env {
                        name = "SPARK_LOCAL_STORAGE_ENCRYPTION_ENABLED"
                        value = "no"
                    }

                    env {
                        name = "SPARK_SSL_ENABLED"
                        value = "no"
                    }

                    port{
                        container_port = 8081
                        host_port = 8081
                    }

                }
            }
        }
    }
}

#Spark Master Service for internal communication
resource "kubernetes_service" "spark"{
    metadata {
      name="spark"
    }

    spec{
        selector = {
          "app" = kubernetes_deployment.spark-master.metadata.0.labels.app
        }

        port{
            name = "spark"
            port = 7077
        }

    }
}