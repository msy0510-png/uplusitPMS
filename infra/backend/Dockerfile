# build
FROM gradle:8.7-jdk17 AS build
WORKDIR /src
COPY . .
RUN gradle clean bootJar -x test --no-daemon
# run
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /src/build/libs/*.jar app.jar
EXPOSE 9090
ENTRYPOINT ["java","-jar","/app/app.jar"]
