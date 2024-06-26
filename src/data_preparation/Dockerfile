FROM ubuntu:18.04

RUN touch /etc/inside-container
RUN apt-get update
RUN apt-get install -y python3 python3-pip wget apt-transport-https software-properties-common git
RUN wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
RUN dpkg -i packages-microsoft-prod.deb
RUN apt-get update
RUN apt-get install -y dotnet-sdk-2.2

COPY ./metadata/popularLibs.txt ./metadata/popularLibs.txt
RUN pip3 install --no-cache-dir -r metadata/popularLibs.txt
RUN pip3 install --no-cache-dir dpu_utils graphviz split
RUN pip3 install --no-cache-dir tensorflow==1.13.2 dpu-utils annoy

# For debugging
# RUN pip3 install --no-cache-dir docopt numpy matplotlib typed-ast

# For some reason, the module "setuptools" confuses pytype adding a cycle in the
# dep graph. Remove it here.
RUN apt-get remove -y python3-setuptools

# Subsequent commands are placed here to avoid rebuilding the previous steps if
# anything in the files below changes.
WORKDIR /usr/src/datasetbuilder
RUN git clone https://github.com/gaarutyunov/typilus.git
RUN git clone --depth=1 https://github.com/microsoft/near-duplicate-code-detector.git
COPY ./metadata ./metadata
COPY ./scripts ./scripts
COPY ./*.spec ./

ENV PYTHONPATH=/usr/src/datasetbuilder/typilus/src:/usr/str/datasetbuilder/scripts:/usr/str/datasetbuilder/near-duplicate-code-detector:$PYTHONPATH
