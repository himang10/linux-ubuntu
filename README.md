# linux-ubuntu

Linux Ubuntu OS 샘플 스크립트 저장소입니다.

Bash 3.0 이상과 호환되는 셸 스크립트들을 포함합니다.

## 스크립트 목록

### 1. system-info.sh - 시스템 정보 스크립트

시스템의 기본 정보를 수집하여 출력합니다.

**기능:**
- OS 정보 (버전, 커널, 아키텍처)
- CPU 정보 (모델, 코어 수)
- 메모리 정보 (총량, 사용 가능)
- 디스크 사용량
- 시스템 가동 시간
- 현재 사용자 정보

**사용법:**
```bash
./scripts/system-info.sh
```

### 2. disk-usage.sh - 디스크 사용량 모니터링 스크립트

디스크 사용량을 모니터링하고 임계값 초과 시 경고를 표시합니다.

**기능:**
- 파티션별 디스크 사용량
- 임계값 초과 파티션 경고
- /var 디렉토리의 대용량 파일 목록
- 디렉토리별 디스크 사용량

**사용법:**
```bash
./scripts/disk-usage.sh [임계값]
# 예시: 기본값 80%
./scripts/disk-usage.sh
# 예시: 90%로 설정
./scripts/disk-usage.sh 90
```

### 3. backup.sh - 백업 스크립트

지정된 디렉토리를 tar.gz 형식으로 백업합니다.

**기능:**
- 디렉토리 압축 백업
- 타임스탬프 기반 파일명 생성
- MD5 체크섬 생성
- 백업 이력 표시

**사용법:**
```bash
./scripts/backup.sh <소스_디렉토리> <백업_디렉토리>
# 예시:
./scripts/backup.sh /home/user/documents /backup
```

### 4. network-info.sh - 네트워크 정보 스크립트

시스템의 네트워크 설정 및 상태를 출력합니다.

**기능:**
- 호스트명 정보
- 네트워크 인터페이스 목록
- IP 주소 정보
- 기본 게이트웨이
- DNS 설정
- 활성 연결 및 리스닝 포트
- 연결 테스트 (로컬, 게이트웨이, 인터넷)

**사용법:**
```bash
./scripts/network-info.sh
```

## 요구사항

- Bash 3.0 이상
- Linux Ubuntu (기타 Linux 배포판에서도 동작 가능)

## 설치

```bash
git clone https://github.com/himang10/linux-ubuntu.git
cd linux-ubuntu
chmod +x scripts/*.sh
```

## 라이선스

MIT License