# SECANT

**SE**rver **C**pu **A**nalysis and a**N**omaly de**T**ection
LSTM-based Forecasting and Anomaly Detection for Server CPU Utilization

> 할선(secant line)은 곡선 위의 두 점을 잇는 직선입니다.
> 과거의 관측 점들로 곡선이 다음에 어디로 갈지 가늠하듯, SECANT는 과거 CPU 사용률로 다음 값을 예측합니다.

## 개요

서버 CPU 사용률이 **다음에 어떻게 될지 LSTM으로 예측**하고, 예측이 크게 빗나가는 순간을 **이상(장애)** 으로 탐지합니다.

```
과거 W개 관측 ──▶ LSTM ──▶ 예측값 ŷ
                              │
         실제값 y ────────────┤
                              ▼
               오차 |y − ŷ| > 임계값 ?  ──▶ 이상 탐지
```

- **데이터**: [NAB (Numenta Anomaly Benchmark)](https://github.com/numenta/NAB): AWS EC2 서버 CPU 사용률 등 실제 시계열과, 이상 구간 정답 라벨
- **모델**: LSTM (main) vs. Persistence / Moving Average / Window MLP / Vanilla RNN (baselines)
- **평가**: 예측 성능(MAE, RMSE)과 이상 구간 단위 탐지 성능(Precision, Recall, F1)

자세한 구조, 모델, 설계 결정은 [INFORMATION.md](INFORMATION.md)를 참고하세요.

## 실행 방법

[Docker](https://docs.docker.com/get-docker/)와 Docker Compose만 있으면 됩니다. Python·PyTorch 등은 컨테이너 안에 설치됩니다.

### 1. 환경 구축 (최초 1회)

```bash
git clone https://github.com/TranserZ/secant.git
cd secant
docker compose build
docker compose run --rm secant python scripts/check_env.py   # 버전 출력 + "LSTM forward OK" 확인
```

> ⚠️ 아래 2~5단계는 구현 진행 중입니다. 명령은 예정된 인터페이스이며, 구현되면 갱신합니다.

### 2. 데이터 다운로드

```bash
docker compose run --rm secant python scripts/download_nab.py   # data/raw/ 에 CSV와 라벨 저장
```

### 3. 학습

```bash
docker compose run --rm secant python -m src.train --config configs/default.yaml
```

### 4. 이상 탐지 및 평가

```bash
docker compose run --rm secant python -m src.evaluate --config configs/default.yaml
```

결과는 `results/metrics/`(수치), `results/figures/`(그래프)에 저장됩니다.

### 5. 시각화 (Jupyter)

```bash
docker compose up jupyter     # 브라우저에서 http://localhost:8888 접속, 종료는 Ctrl+C
```

### (선택) VS Code Dev Container

VS Code + Dev Containers 확장 설치 후, 명령 팔레트에서 **Dev Containers: Reopen in Container**를 실행하면 컨테이너 안에서 바로 개발할 수 있습니다.

### (대안) Docker 없이 로컬 실행

```bash
python3.12 -m venv .venv && source .venv/bin/activate
pip install torch==2.14.1 --index-url https://download.pytorch.org/whl/cpu
pip install -r requirements.txt
```

협업 규칙은 [CONTRIBUTING.md](CONTRIBUTING.md)를 참고하세요.

## 팀 / 과목

- SWE-3052 Introduction to Deep Neural Networks, Fall 2026, SKKU
