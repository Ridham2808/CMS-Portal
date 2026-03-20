# Stage 1: Build the Maven Project
FROM maven:3.8.4-openjdk-11 AS build
WORKDIR /app
# Copy the pom.xml and source code
COPY pom.xml .
COPY src ./src
# Build the .war file
RUN mvn clean package

# Stage 2: Setup Tomcat and Deploy
FROM tomcat:9.0-jdk11
# Remove default Tomcat apps (optional but keeps it clean)
RUN rm -rf /usr/local/tomcat/webapps/*
# Copy the built WAR file from Stage 1 into the Tomcat webapps folder as ROOT.war 
# (ROOT.war means it will open directly on your custom domain, e.g., myapp.render.com/)
COPY --from=build /app/target/complaint-management-system-1.0-SNAPSHOT.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
