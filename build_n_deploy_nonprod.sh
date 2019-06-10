#!/bin/sh

if [ ! -e Dockerfile ]; then 
 echo "There is no Dockerfile"; 
 exit 1; 
fi

FIRST_BUILD=`docker pull ${NEXUS_SERVER}/${IMAGE_NAME}:${CI_COMMIT_REF_NAME}-latest > /dev/null 2>&1; echo $?`

if [ "${FIRST_BUILD}" == "1" ]; then
 echo "This is the first build of the image."
 docker build -t ${NEXUS_SERVER}/${IMAGE_NAME}:${IMAGE_TAG} -t ${NEXUS_SERVER}/${IMAGE_NAME}:${CI_COMMIT_REF_NAME}-latest .
else
 echo "This is a subsequent build of the project. Using last image as source of cache"
 docker build --cache-from ${NEXUS_SERVER}/${IMAGE_NAME}:${CI_COMMIT_REF_NAME}-latest \
      -t ${NEXUS_SERVER}/${IMAGE_NAME}:${IMAGE_TAG} -t ${NEXUS_SERVER}/${IMAGE_NAME}:${CI_COMMIT_REF_NAME}-latest .
fi

docker push ${NEXUS_SERVER}/${IMAGE_NAME}:${IMAGE_TAG}
docker push ${NEXUS_SERVER}/${IMAGE_NAME}:${CI_COMMIT_REF_NAME}-latest
if [ "${CI_COMMIT_REF_NAME}" == "develop" ]; then
 echo "Deploy to DEV environment. Execute deployment instructions here."
fi
if echo "${CI_COMMIT_REF_NAME}" | grep -q "^release/"; then
 echo -e "Deploy image $IMAGE\:$IMAGE_TAG to PREPROD Openshift using the following steps\n
      1. Download oc client\n
      2. Login to Openshift project\n
      3. Login to Openshift Registry\n
      4. Re-tag ${IMAGE}\:${IMAGE_TAG} with the tag latest\n
      5. Push ${IMAGE}\:latest\"

  echo ${OC_PASSWORD} | docker login -u ${OC_USERNAME} --password-stdin"  # mimic logging in to OpenShift
  echo "Follow above steps."
fi
