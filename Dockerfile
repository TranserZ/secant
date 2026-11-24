# SECANT 실행 환경 (CPU 전용)
FROM python:3.12.16-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PYTHONPATH=/workspace \
    MPLBACKEND=Agg

# 1) PyTorch: CPU 전용 휠 (CUDA 휠 대비 이미지 크기 대폭 감소)
ARG TORCH_VERSION=2.14.1
RUN pip install torch==${TORCH_VERSION} --index-url https://download.pytorch.org/whl/cpu

# 2) 나머지 의존성 (requirements.txt가 바뀔 때만 이 레이어부터 다시 빌드)
COPY requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt

# 3) 호스트와 같은 UID/GID의 일반 사용자 → 마운트된 폴더에 생성되는 파일이 root 소유가 되지 않음
ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} secant && useradd -m -u ${UID} -g ${GID} -s /bin/bash secant
USER secant

WORKDIR /workspace
CMD ["bash"]
