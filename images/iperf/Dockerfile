FROM quay.io/fedora/fedora
RUN dnf install -y iproute bash iperf3 ping net-tools nftables tcpdump
COPY ./monitor.sh .
RUN chmod a+x ./monitor.sh
CMD ["bash"]

