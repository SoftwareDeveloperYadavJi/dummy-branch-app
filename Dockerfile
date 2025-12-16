FROM python:3.11-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV VIRTUAL_ENV=/app/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN apt-get update && apt-get install -y --no-install-recommends \
  build-essential \
  libpq-dev \
  && rm -rf /var/lib/apt/lists/*

# Create virtual environment
RUN python -m venv $VIRTUAL_ENV

COPY requirements.txt .
# Use venv pip to install dependencies
RUN $VIRTUAL_ENV/bin/pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

# Default command (can be overridden in docker-compose override files)
# The compose files will provide the actual command with environment-specific settings
CMD ["gunicorn", "-w", "2", "-b", "0.0.0.0:8000", "wsgi:app"]
