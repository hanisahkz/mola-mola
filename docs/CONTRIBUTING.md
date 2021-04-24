# Contributing to Mola Mola

A few ideas for contributions:

* Add scripts in other languages: `python`, `js`, `go`. Refer **Section: Add support for new language**.
* Add more scenarios data seeding
* Optimize image used for container

# Add support for new language

1. Define a new service in `docker-compose.yml` with its respective `Dockerfile`.
  Example below is for `python`

    ```diff
    + python_scripts:
    +    build:
    +      context: .
    +      dockerfile: Dockerfile_python
    +    container_name: python_scripts
    +    restart: always
    ```

1. Add a new `Dockerfile` called `Dockerfile_python`. Refer [Dockerfile_sample](../Dockerfile_sample) to get
started on customizing the container environment.