#!/bin/bash
FILE=app-v1.3.zip
curl -v --user 'admin:admin123' --upload-file  ${FILE} http://registry.mercadocrew.ca/repository/binary_repo/${FILE}
