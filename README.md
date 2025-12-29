🔐 Sistema de Respaldo, Auditoría Forense y Self-Healing

Protección avanzada de datos clínicos – Arquitectura defensiva automatizada

Este repositorio contiene una solución integral de protección de datos diseñada para entornos críticos (clínicas, PYMEs reguladas), combinando:

📊 Auditoría forense y cadena de custodia

♻️ Auto-recuperación (Self-Healing)

🛡️ Hardening del sistema y control de accesos

☁️ Respaldos inmutables y cifrados en la nube

🚨 Detección y respuesta activa con Wazuh

📁 Componentes del Sistema
1. chain_of_custody.sh – Motor de Auditoría Forense

Descripción
Script núcleo de la trazabilidad forense del sistema. Genera registros de auditoría estructurados en formato JSON ante cada evento crítico (por ejemplo, restauraciones automáticas).

Incluye:

🕒 Timestamp UTC

👤 Usuario ejecutor

🌐 IP de origen

🔑 Hash criptográfico del archivo

✅ Resultado de la operación

Utiliza jq para estandarizar la salida y garantizar consistencia.

Propósito
Asegurar la inmutabilidad, integridad y legibilidad de la evidencia digital, facilitando:

Cumplimiento normativo (Ley 21.459)

Reconstrucción forense de incidentes

Correlación de eventos en SIEM

2. backup_find_restore.sh – Lógica de Auto-Recuperación (Self-Healing)

Descripción
Es el cerebro del sistema de auto-recuperación. Automatiza la restauración de archivos eliminados o corruptos priorizando la velocidad:

🔎 Busca en snapshots locales (Shadow Copies) (<1 segundo)

📦 Si no existe, recupera desde /backups/vault

🔐 Verifica integridad mediante hash

🧾 Registra el evento en chain_of_custody.sh

Propósito
Reducir drásticamente el MTTR (Mean Time To Recovery) sin intervención humana, garantizando que el archivo restaurado sea auténtico e íntegro.

3. custom-heal – Respuesta Activa integrada con Wazuh

Descripción
Script puente entre Wazuh SIEM y la lógica de recuperación automática.

Recibe alertas en tiempo real (JSON)

Extrae metadatos relevantes (ruta, nombre del archivo)

Filtra falsos positivos

Ejecuta backup_find_restore.sh cuando corresponde

Propósito
Transformar Wazuh de una herramienta detectiva a una plataforma de respuesta autónoma, cerrando el ciclo detección → corrección.

4. backup_seguro.sh – Respaldo Inmutable y Replicación en la Nube

Descripción
Automatiza el ciclo completo de respaldo crítico:

📦 Empaquetado local (.tar.gz)

🔒 Inmutabilidad local (chattr +i)

☁️ Replicación cifrada con rclone

🔐 Control de concurrencia con flock

🧾 Reporte de auditoría a chain_of_custody.sh

Propósito
Implementar de forma automática la estrategia 3-2-1, protegiendo los datos contra:

Ransomware

Errores humanos

Desastres físicos

5. sombra_instantanea.service – Snapshots Locales Eficientes

Descripción
Servicio systemd que genera copias incrementales mediante hardlinks (cp -al), permitiendo múltiples versiones históricas con uso mínimo de espacio.

Propósito
Proveer restauraciones ultrarrápidas, base esencial del sistema de Self-Healing.

6. secretos.conf – Bóveda Local de Credenciales

Descripción
Archivo seguro para almacenar credenciales sensibles:

Contraseñas Samba

Claves de cifrado Rclone

Credenciales Wazuh

Consumido por systemd vía EnvironmentFile.

Propósito
Eliminar credenciales hardcodeadas y aplicar seguridad por capas, con permisos restrictivos (chmod 600).

7. smb.conf – Samba Hardenizado con RBAC

Descripción
Configuración avanzada de Samba con:

🔐 SMB2 mínimo (mitiga EternalBlue)

✍️ Firma obligatoria de paquetes

👥 Control de acceso por grupos (RBAC)

🚫 Sin acceso anónimo

🔑 Autenticación NTLMv2

Propósito
Reducir la superficie de ataque y aislar datos clínicos bajo el principio de mínimo privilegio.

8. issue.net – Banner Legal de Advertencia

Descripción
Mensaje legal mostrado antes de la autenticación SSH.

Propósito

Disuasión psicológica

Respaldo legal ante accesos no autorizados

Eliminación de la defensa de “acceso accidental”

9. ossec.conf – Configuración Maestra de Wazuh SIEM

Descripción
Configuración personalizada de Wazuh:

🔍 FIM en tiempo real sobre datos clínicos

🔁 Respuesta Activa integrada con custom-heal

🧾 Ingesta de logs JSON de auditoría

⚙️ Optimización de recursos (desactiva módulos innecesarios)

Propósito
Convertir el servidor en un sistema EDR/SIEM autónomo, enfocado en la protección de datos clínicos.

10. rclone.conf – Respaldo Cifrado en la Nube

Descripción
Define:

Remoto Google Drive

Remoto crypt (boveda_segura) sobre el anterior

Cifrado AES-256 del lado del cliente.

Propósito
Garantizar la confidencialidad absoluta de datos PII/PHI en proveedores externos.

11. sombra_instantanea.service – Demonio Persistente

Descripción
Servicio systemd que mantiene activo el sistema de snapshots:

🔁 Restart=always (24/7)

🛡️ ProtectSystem=full (hardening)

Propósito
Asegurar que la protección local esté siempre operativa, incluso ante fallos.

12 & 13. backup_nube.service + backup_nube.timer – Orquestación Cloud

Descripción
Automatización sin cron:

⏱️ Arranque diferido (15 min)

🔁 Ejecución cada hora

🔐 Respaldo inmutable + replicación cifrada

Propósito
Eliminar el factor humano y asegurar respaldos continuos y confiables.

🧠 Enfoque de Seguridad

Defense in Depth

Zero Trust interno

Automatización total

Cumplimiento legal y forense
