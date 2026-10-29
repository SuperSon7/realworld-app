# Python 의존성 설치
FROM python:3.12-alpine3.24 AS build

WORKDIR /app

RUN apk add --no-cache gcc musl-dev postgresql-dev

RUN python -m venv /opt/venv

COPY pyproject.toml ./

RUN /opt/venv/bin/pip install --no-cache-dir .

# 컴파일 도구를 제외한 실행 환경
FROM python:3.12-alpine3.24

WORKDIR /app

RUN apk add --no-cache libpq

ENV PATH="/opt/venv/bin:$PATH" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

COPY --from=build /opt/venv /opt/venv

COPY . .

EXPOSE 8000

# WSGI 앱 실행, 접근 로그는 표준 출력으로 전달
CMD ["gunicorn", "config.wsgi:application", "--bind", "0.0.0.0:8000", "--access-logfile", "-"]
