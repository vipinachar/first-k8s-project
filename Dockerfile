FROM nginx 
LABEL maintainer = "Vipin MS <vipinachar2016@gmail.com>"

COPY ./website website 
COPY ./nginx.conf /etc/nginx/nginx.conf