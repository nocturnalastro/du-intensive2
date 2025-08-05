FROM docker.io/curlimages/curl

USER curl_user
WORKDIR /home/curl_user
COPY --chown=curl_user curl.sh /home/curl_user/poll.sh
RUN ls -la /home/curl_user
RUN chmod a+x /home/curl_user/poll.sh

CMD /home/curl_user/poll.sh

