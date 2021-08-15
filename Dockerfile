FROM alpine:edge
RUN apk add --no-cache gnuplot

STOPSIGNAL SIGTERM

ENTRYPOINT ["gnuplot"]

