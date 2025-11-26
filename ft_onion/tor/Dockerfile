ARG version
FROM alpine:${version}
ENV LANG C.UTF-8

RUN apk update && apk add --no-cache \
	tor

RUN chown -R tor:nogroup /var/lib/tor
RUN mkdir -pm 700 /var/lib/tor/ft_onion
COPY --chown=tor:nogroup ./ft_onion /var/lib/tor/ft_onion
RUN chown -R tor:nogroup /var/lib/tor/ft_onion
RUN mkdir -pm 700 /var/lib/tor/gitea
COPY --chown=tor:nogroup ./gitea /var/lib/tor/gitea
RUN chown -R tor:nogroup /var/lib/tor/gitea

USER tor
ENTRYPOINT [ "tor", "-f", "/etc/tor/torrc" ]
