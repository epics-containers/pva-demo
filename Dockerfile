FROM ghcr.io/epics-containers/ioc-adsimdetector-developer:2024.11.1 AS developer

# get some dependencies
RUN pip install p4p
RUN apt install net-tools

COPY /services /services
COPY /pvagw /pvagw
RUN ln -s /services/bl01t-ea-ioc-02/config /epics/ioc/config

# run this container interactively
ENTRYPOINT ["/bin/bash", "-c", "/pvagw/pvagw-launch.sh"]
