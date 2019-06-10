nosetests --with-coverage --cover-package=mymath --cover-branches --cover-xml --with-xunit --cover-erase
sed -i 's/classname=\"/classname=\"tests\./g' nosetests.xml
sonar-scanner
