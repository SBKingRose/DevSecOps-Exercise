FROM adoptopenjdk:17-jdk-hotspot

WORKDIR /app

COPY . /app

RUN ./mvnw clean package

EXPOSE 8080

ENV NAME World

CMD ["java", "-jar", "target/supermarket-checkout-1.0-SNAPSHOT.jar"]
