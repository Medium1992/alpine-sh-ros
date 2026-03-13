FROM alpine:latest
ARG TARGETARCH
RUN if [ "$TARGETARCH" = "arm64" ] || [ "$TARGETARCH" = "amd64" ]; then \
        apk add --no-cache ca-certificates tzdata iproute2 iptables iptables-legacy nftables; \
    elif [ "$TARGETARCH" = "arm" ]; then \
        apk add --no-cache ca-certificates tzdata iproute2 iptables iptables-legacy; \
    else \
        echo "Unsupported architecture: $TARGETARCH" && exit 1; \
    fi && \
    rm -f /usr/sbin/iptables /usr/sbin/iptables-save /usr/sbin/iptables-restore && \
    ln -s /usr/sbin/iptables-legacy /usr/sbin/iptables && \
    ln -s /usr/sbin/iptables-legacy-save /usr/sbin/iptables-save && \
    ln -s /usr/sbin/iptables-legacy-restore /usr/sbin/iptables-restore;
CMD ["/bin/sh", "-c", "\
if [ -d /scripts_sh ] && [ \"$(ls -A /scripts_sh 2>/dev/null)\" ]; then \
    for script in /scripts_sh/*; do \
        [ -f \"$script\" ] || continue; \
        echo \"Running $script\"; \
        if [ -x \"$script\" ]; then \
            \"$script\"; \
        else \
            /bin/sh \"$script\"; \
        fi; \
    done; \
else \
    echo \"No scripts found in /scripts_sh/\"; \
    echo \"Mount to directory /scripts_sh/ your scripts sh\"; \
fi"]
