FROM python:3

LABEL org.opencontainers.image.source = "https://github.com/sandroklippel/sambura"
LABEL org.opencontainers.image.description = "Karakuri automata"
LABEL org.opencontainers.image.licenses = MIT

WORKDIR /sambura

COPY requirements.txt ./
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

COPY karakuri.py ./

CMD [ "python", "./karakuri.py" ]