FROM amarburg/matlab-runtime:latest

RUN apt-get update && apt-get install -y python3 python3-pip libgl1-mesa-dev libxt-dev

ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libexpat.so

RUN pip3 install pytest

COPY pycovis-postprocess /root/pycovis/pycovis-postprocess
WORKDIR /root/pycovis/pycovis-postprocess
RUN python3 setup.py install

## Copy in the test functions
COPY test                /root/pycovis/test
COPY scripts             /root/pycovis/scripts

WORKDIR /root/pycovis
RUN  ln -s /root/pycovis/pycovis-postprocess/input .

VOLUME  /input
VOLUME  /output

ENV LD_LIBRARY_PATH=$MATLAB_LD_LIBRARY_PATH:$LD_LIBRARY_PATH

ENTRYPOINT ["python3"]
