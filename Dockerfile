# Stage 1: Build stage with all dependencies
FROM python:3.9.17-slim-buster AS builder

WORKDIR /app

COPY ./requirements.txt /app

# Install dependencies in a virtual environment
RUN python -m venv /app/venv && \
    /app/venv/bin/pip install --no-cache-dir -r requirements.txt

# Copy the application code
COPY ./app /app
COPY ./run.py /app/

# Stage 2: Final stage with only necessary files
FROM python:3.9.17-slim-buster

WORKDIR /app

# Copy virtual environment from the builder stage
COPY --from=builder /app/venv /app/venv
COPY --from=builder /app /app

# Set environment and PATH for virtual environment
ENV PATH="/app/venv/bin:$PATH"
ENV FLASK_APP=run.py
ENV FLASK_RUN_HOST=0.0.0.0
ENV FLASK_RUN_PORT=5000

# Switch to non-root user
RUN useradd -m appuser
USER appuser

EXPOSE 5000
CMD ["flask", "run"]