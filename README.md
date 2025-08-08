# Proyecto de Infraestructura con Terraform en Azure

## Descripción

Este proyecto de Terraform crea una infraestructura básica en Microsoft Azure, con una configuración que incluye:

- **Grupos de recursos**.
- **Redes Virtuales (VNets)** para diferentes partes del sistema (Web, Backend, NVA).
- **Subredes** y **interfaces de red (NIC)** asociadas.
- **Tablas de enrutamiento** para asegurar la conectividad entre las diferentes redes.
- **Grupos de seguridad de red (NSG)** para proteger las subredes.
- **Zona DNS privada** para resolver nombres internos entre las redes.

La infraestructura está destinada a un entorno de desarrollo (**dev**) y está diseñada para interconectar distintas partes del sistema a través de redes virtuales, subredes y una configuración de enrutamiento.

## Requisitos

- **Terraform 1.0** o superior.
- Una **cuenta de Azure** y **permisos de administrador** en el **Subscription ID** especificado en el proyecto.
- Conexión de red a Internet para la ejecución de comandos de Terraform y la creación de recursos en Azure.

## Estructura del Proyecto

```bash
terraform-project/
│
├── main.tf          # Configuración principal de los recursos
├── .gitignore       # Archivos a ignorar en git
└── README.md        # Documentación del proyecto
