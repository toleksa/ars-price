FROM alpine:3.16.2
RUN apk add --no-cache gnuplot

STOPSIGNAL SIGTERM

ENTRYPOINT ["gnuplot"]

