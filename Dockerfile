FROM python:3

WORKDIR /usr/src
VOLUME /usr/src

COPY FinTrack/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt


CMD ["bash"]