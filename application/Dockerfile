FROM spark
LABEL maintaniner="alejandro.montero@bsc.es"

WORKDIR /app
COPY wrapper.sh /app
RUN chown root:root /app/wrapper.sh && \
    chmod 700 /app/wrapper.sh

CMD ["/app/wrapper.sh"]
