#!/bin/bash
set -e

echo "Importando esquema PetVida..."
mysql -uroot -prootpass petvida < /petvida-sql/petvida-v2.sql
mysql -uroot -prootpass petvida < /petvida-sql/procedures.sql
mysql -uroot -prootpass petvida < /petvida-sql/views.sql
mysql -uroot -prootpass petvida < /petvida-sql/security.sql
mysql -uroot -prootpass petvida < /petvida-sql/reports.sql

echo "Importação concluída."
