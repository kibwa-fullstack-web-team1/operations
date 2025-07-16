# Docker 기반 개발 환경 가이드

이 문서는 `docker-compose`를 사용하여 여러 마이크로서비스를 로컬 환경에서 쉽게 실행하고 관리하는 방법을 안내합니다.

## 새로운 서비스 추가하기

새로운 마이크로서비스를 Docker Compose 환경에 추가하려면 다음 단계를 따르세요.

### 1. 서비스 레포지토리에 `Dockerfile` 작성

각 서비스의 루트 디렉토리에 `Dockerfile`을 생성합니다. 아래는 Python(FastAPI) 기반 서비스의 예시입니다.

```Dockerfile
# 1. 베이스 이미지 선택
FROM python:3.12-slim

# 2. 작업 디렉토리 설정
WORKDIR /app

# 3. 의존성 설치
# requirements.txt 파일을 서비스 레포지토리 루트에 복사하고 설치합니다.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 4. 소스 코드 복사
# 서비스의 소스 코드를 컨테이너의 /app 디렉토리로 복사합니다.
COPY ./app /app

# 5. 포트 노출
# 서비스가 사용하는 포트를 지정합니다.
EXPOSE 8000

# 6. 애플리케이션 실행
# 서비스를 시작하는 명령어를 지정합니다.
# 예: CMD ["python", "user-service_manage.py"]
CMD ["python", "your-service-manage-script.py"]
```

**주요 항목 설명:**

*   `FROM`: 서비스에 맞는 언어와 버전의 공식 이미지를 사용합니다.
*   `WORKDIR`: 컨테이너 내의 작업 디렉토리를 설정합니다.
*   `COPY`: 호스트의 파일/디렉토리를 컨테이너로 복사합니다.
*   `RUN`: 이미지 빌드 시 실행할 명령어를 정의합니다.
*   `EXPOSE`: 컨테이너가 외부에 노출할 포트를 지정합니다.
*   `CMD`: 컨테이너 시작 시 실행될 기본 명령어를 정의합니다.

### 2. `operations/docker-compose.yml` 에 서비스 추가

`operations` 레포지토리의 `docker-compose.yml` 파일을 열고 `services` 섹션에 새로운 서비스를 추가합니다.

```yaml
services:
  # 기존 서비스들...
  user-service:
    build:
      context: ../user-service # 서비스 레포지토리 경로
      dockerfile: Dockerfile
    ports:
      - "8000:8000" # 호스트 포트:컨테이너 포트
    env_file:
      - .env # 환경변수 파일 경로
    networks:
      - app-network
    volumes:
      - ../user-service/app:/app/app # 코드 변경 실시간 반영을 위한 볼륨 마운트

  # ✨ 새로운 서비스 추가 ✨
  new-service: # 1. 서비스 이름 (소문자로 작성)
    build:
      context: ../new-service # 2. 서비스 레포지토리의 상대 경로
      dockerfile: Dockerfile
    ports:
      - "8002:8002" # 3. 서비스의 포트 매핑 (다른 서비스와 겹치지 않게)
    env_file:
      - .env
    networks:
      - app-network
    volumes:
      - ../new-service/app:/app/app # 4. 소스 코드 볼륨 마운트
```

**주요 항목 설명:**

*   `new-service`: 추가하려는 서비스의 이름을 지정합니다.
*   `build.context`: `docker-compose.yml` 파일 기준에서 서비스 레포지토리까지의 상대 경로를 지정합니다.
*   `ports`: 호스트 머신의 포트와 컨테이너의 포트를 매핑합니다.
*   `volumes`: 호스트의 소스 코드와 컨테이너의 소스 코드를 연결하여, 코드 변경 시 컨테이너를 재시작하지 않고도 바로 반영되도록 합니다.

### 3. `operations/sh/rebuild.sh` 실행

서비스 추가가 완료되면, `operations/sh` 디렉토리에서 `rebuild.sh` 스크립트를 실행하여 모든 서비스를 다시 빌드하고 시작합니다.

```bash
./rebuild.sh
```

이 스크립트는 기존 컨테이너를 중지/제거하고, 변경된 사항을 포함하여 모든 이미지를 새로 빌드한 후 컨테이너를 실행합니다.