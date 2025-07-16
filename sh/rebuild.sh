#!/bin/bash

# sh/rebuild.sh

# 스크립트 실행 중 에러가 발생하면 즉시 중단
set -e

echo "🐳 1. 이전 Docker Compose 서비스를 모두 중지하고 제거합니다..."
# -v 옵션은 볼륨까지 삭제하므로, 데이터 유지가 필요하면 빼고 실행
docker compose down

echo "🚀 2. Docker Compose 서비스를 새로 빌드하고 백그라운드에서 시작합니다..."
# --build 옵션: 소스 코드가 변경되지 않았더라도 이미지를 강제로 다시 빌드
# -d 옵션: 백그라운드에서 실행
docker compose up --build -d

echo "-----------------------------------------------------"
echo "✅ 서비스가 성공적으로 시작되었습니다. 현재 실행 중인 컨테이너:"
docker ps
echo "-----------------------------------------------------"

echo "🧹 3. 사용하지 않는 이전 버전의 Docker 이미지를 정리합니다..."
# dangling=true 필터는 이름 없는 중간 이미지들을 찾아 삭제
docker image prune -f --filter "dangling=true"

echo "✨ 모든 작업이 완료되었습니다! ✨"
