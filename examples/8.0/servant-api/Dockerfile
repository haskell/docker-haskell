FROM haskell:8

COPY . /opt/servant-api

WORKDIR /opt/servant-api

RUN stack build

CMD ["stack","exec","servant-api-exe"]
