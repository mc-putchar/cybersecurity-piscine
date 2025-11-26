ARG version
FROM alpine:${version}
ENV LANG C.UTF-8

RUN apk update && apk add --no-cache \
	nginx \
	openssh \
	supervisor

RUN mkdir -p /var/run/sshd && \
	adduser -D onion && \
	mkdir -p /home/onion/.ssh && \
	chmod 700 /home/onion/.ssh && \
	chown -R onion:onion /home/onion/.ssh && \
	ssh-keygen -A && \
	echo "onion:42onion" | chpasswd

RUN mkdir -p /run/nginx && \
	mkdir -p /var/tmp/nginx && \
	chown -R nginx:nginx /run/nginx /var/tmp/nginx

RUN mkdir -p /etc/supervisor.d/
COPY supervisord.conf /etc/supervisord.conf
COPY nginx.supervisor.conf /etc/supervisor.d/
COPY sshd.supervisor.conf /etc/supervisor.d/

COPY healthcheck.sh /usr/bin/healthcheck.sh
RUN chmod +x /usr/bin/healthcheck.sh

EXPOSE 22 80
ENTRYPOINT [ "/usr/bin/supervisord", "-c", "/etc/supervisord.conf" ]
