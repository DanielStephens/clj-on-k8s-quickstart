FROM clojure:lein-alpine

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY . /usr/src/app
RUN lein uberjar
CMD ["java", "-jar", "target/service-b-0.0.1-standalone.jar"]
