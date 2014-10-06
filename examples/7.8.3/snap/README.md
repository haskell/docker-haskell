# docker-library snap-example

## Build Example:

```
docker build -t hsnap .
```

## Run Example:

This command will run the example interactively mapping port 8000
in the container to 8000 on the host.

```
docker run -i -t -p 8000:8000 hsnap
```