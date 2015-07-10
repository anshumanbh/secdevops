FROM owasp/zap2docker-stable
MAINTAINER Anshuman Bhartiya <anshuman.bhartiya@emc.com>
RUN apt-get update && apt-get install -y \
	python-pip
RUN pip install python-owasp-zap-v2
ADD runzap.py /zap/ZAP_2.4.0/
