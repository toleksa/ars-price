FROM alpine:3.16.0
RUN apk add --no-cache gnuplot

STOPSIGNAL SIGTERM

ENTRYPOINT ["gnuplot"]

