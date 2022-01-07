FROM alpine
RUN apk --no-cache add openjdk11
COPY jar/spring-petclinic-2.6.0-SNAPSHOT.jar /app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
