FROM tomcat:7-jre7

MAINTAINER Matthias Grüter <matthias@grueter.name>

# To update, check https://bintray.com/jfrog/artifactory/artifactory/view
ENV ARTIFACTORY_VERSION 3.4.2
ENV ARTIFACTORY_SHA1 394258c5fc8beffd60de821b6264660f5464b943

# Disable Tomcat's manager application.
RUN rm -rf webapps/*

# Redirect to the Artifactory servlet from root.
RUN mkdir webapps/ROOT
RUN echo '<html><head><meta http-equiv="refresh" content="0;URL=artifactory/"></head><body></body></html>' > webapps/ROOT/index.html

# Fetch and install Artifactory OSS war archive.
RUN \
  echo $ARTIFACTORY_SHA1 artifactory.zip > artifactory.zip.sha1 && \
  curl -L -o artifactory.zip https://bintray.com/artifact/download/jfrog/artifactory/artifactory-${ARTIFACTORY_VERSION}.zip && \
  sha1sum -c artifactory.zip.sha1 && \
  unzip -j artifactory.zip "artifactory-*/webapps/artifactory.war" -d webapps && \
  rm artifactory.zip

# Add hook to install custom artifactory.war (i.e. Artifactory Pro) to replace the default OSS installation.
ONBUILD ADD ./artifactory.war webapps/

# Expose tomcat runtime options through the RUNTIME_OPTS environment variable.
#   Example to set the JVM's max heap size to 256MB use the flag
#   '-e RUNTIME_OPTS="-Xmx256m"' when starting a container.
RUN echo 'export CATALINA_OPTS="$RUNTIME_OPTS"' > bin/setenv.sh

# Artifactory home
RUN mkdir -p /artifactory
ENV ARTIFACTORY_HOME /artifactory

# Expose Artifactories data, log and backup directory.
VOLUME /artifactory/data
VOLUME /artifactory/logs
VOLUME /artifactory/backup

# Expose Tomcat config folder
VOLUME /usr/local/tomcat/conf

WORKDIR /artifactory
