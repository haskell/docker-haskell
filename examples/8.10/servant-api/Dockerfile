FROM haskell:8.10

COPY . /opt/servant-api

WORKDIR /opt/servant-api

RUN stack build

CMD ["stack","exec","servant-api-exe"]
