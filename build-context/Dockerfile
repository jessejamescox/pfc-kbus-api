FROM wagoautomation/pfc-firmware-base:FW19-03.07.14-v0.2.0 as image

COPY resources /
RUN opkg install /home/ipk/json-c_0.12.1+20160607_armhf.ipk
RUN opkg install /home/ipk/mosquitto_2.0.0_armhf.ipk
RUN rm -r /home/ipk
RUN opkg clean

RUN cp -r /home/kbus-api /etc/

RUN mkdir /etc/rc_kbus_api.d/  
RUN cd /etc/rc_kbus_api.d/ 
RUN ln -sf ../init.d/link_devices /etc/rc_kbus_api.d/S01_link_devices

# copy over the bin
RUN mv /home/bin/kbus-api /bin/kbus-api && chmod +x /bin/kbus-api

RUN chmod +x /home/kbus_api/start.sh   

RUN ln -sf ../init.d/link_devices /etc/rc_kbus_api.d/S01_link_devices

RUN rm -rf /usr/bin/qemu-arm-static

FROM scratch
LABEL maintainer="jesse.cox@wago.com"
COPY --from=image / /
LABEL authors="jesse.cox@wago.com"
LABEL org.label-schema.version=${IMAGE_TAG}
LABEL org.label-schema.vendor="WAGO"
LABEL org.label-schema.name="jessejamescox/wago-kbus-api"

ENTRYPOINT ["/home/kbus_api/start.sh"]
