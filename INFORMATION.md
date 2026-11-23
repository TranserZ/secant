# SECANT 상세 정보

README에 담기엔 깊지만 프로젝트를 이해하는 데 중요한 내용을 정리한 문서입니다.
구현이 진행되면 각 섹션을 갱신합니다.

---

## 1. 디렉토리 구조

```
secant/
├── README.md              프로젝트 개요 + 실행 방법
├── INFORMATION.md         (이 문서) 상세 정보
├── requirements.txt       파이썬 의존성
├── .gitignore
├── configs/
│   └── default.yaml       실험 설정 (W, h, hidden size, lr, 임계값 등)
├── data/
│   ├── raw/               NAB 원본 CSV + 라벨 JSON (수정 금지)
│   └── processed/         전처리된 중간 데이터
├── scripts/
│   └── download_nab.py    NAB 데이터 다운로드
├── src/
│   ├── __init__.py
│   ├── data.py            로드 → 시간순 분할 → 정규화 → 슬라이딩 윈도우
│   ├── train.py           학습 루프 (MSE, gradient clipping, early stopping)
│   ├── detect.py          예측 오차 → 평활(EWMA) → 임계값 판정
│   ├── evaluate.py        MAE/RMSE + 이상 구간 단위 Precision/Recall/F1
│   ├── utils.py           시드 고정, config 로드, 경로·로깅
│   └── models/            ★ 모델 하나당 파일 하나
│       ├── __init__.py    모델 레지스트리 (이름 → 클래스)
│       ├── base.py        공통 인터페이스
│       ├── persistence.py
│       ├── moving_average.py
│       ├── mlp.py
│       ├── rnn.py
│       └── lstm.py
├── notebooks/             EDA, 결과 시각화 (계산은 src/에서 import)
├── results/
│   ├── checkpoints/       학습된 가중치 (.pt)
│   ├── figures/           보고서·영상용 그래프
│   └── metrics/           모델·설정별 수치 결과 (CSV)
└── history/               날짜별 작업 기록 (사용법: history/instruction.md)
```

### 데이터 흐름

```
scripts/download_nab.py → src/data.py → src/models/* + src/train.py → src/detect.py → src/evaluate.py
      (데이터 받기)        (윈도우 생성)          (예측 모델 학습)           (이상 판정)       (채점)
```

---

## 2. 모델

모든 모델은 `src/models/base.py`의 공통 인터페이스를 따릅니다.
입력 윈도우 `(batch, W, features)`를 받아 예측값 `(batch, h)`를 냅니다.
그래서 학습·탐지·평가 코드는 모델 종류와 상관없이 동일합니다.

| 모델 | 파일 | 학습 | 역할 | 상태 |
|---|---|---|---|---|
| Persistence | `persistence.py` | ✗ | ŷ = x_t. 가장 단순한 기준선 | ⬜ 예정 |
| Moving Average | `moving_average.py` | ✗ | ŷ = 윈도우 평균 | ⬜ 예정 |
| Window MLP | `mlp.py` | ✓ | 윈도우 평탄화 후 FC. 고정 문맥의 한계 확인 | ⬜ 예정 |
| Vanilla RNN | `rnn.py` | ✓ | 은닉 상태 순환. 기울기 소실 비교 대상 | ⬜ 예정 |
| **LSTM** | `lstm.py` | ✓ | **메인 모델**. 게이트 + cell state | ⬜ 예정 |

### 새 모델 추가 방법

1. `src/models/<model_name>.py` 파일을 새로 만든다.
2. `base.py`의 인터페이스를 따르는 클래스를 구현한다.
3. `src/models/__init__.py` 레지스트리에 등록한다.
4. `configs/`에서 `model.name: <model_name>`으로 선택한다.
5. 이 문서의 모델 표와 `history/`에 기록한다.

---

## 3. 데이터

- **출처**: NAB (Numenta Anomaly Benchmark), `realAWSCloudwatch/`, `realKnownCause/`
- **형식**: CSV (`timestamp`, `value`), 5분 간격
- **라벨**: `labels/combined_windows.json`: 파일별 이상 구간 `[시작, 끝]` 목록
- **사용 파일**: EDA 후 확정 예정

---

## 4. 주요 설계 결정

| 결정 | 이유 |
|---|---|
| 시간 순서대로 train/val/test 분할 (셔플 X) | 미래 정보로 과거를 학습하는 누수 방지 |
| 정규화 통계는 train 구간에서만 계산 | 테스트 데이터 정보 누수 방지 |
| 이상 판정 = \|실제 − 예측\| > 임계값 | 정상 패턴을 학습한 모델이 크게 빗나가는 지점이 이상 (강의 슬라이드 8) |
| 탐지 평가는 이상 구간(window) 단위 | 이상 라벨이 매우 적어 점 단위 F1은 불안정 |
| 예측 모델과 탐지 규칙 분리 (`models/` vs `detect.py`) | 모델 × 임계값 방식 조합 실험을 코드 수정 없이 수행 |

---

## 5. 실험 계획

- **Baseline 비교**: 5개 모델의 예측 성능 및 탐지 성능
- **Ablation**:
  - 윈도우 길이 W
  - 예측 horizon h
  - 오차 평활 유무
  - 정적 vs 동적 임계값
  - gradient clipping 유무

---

## 6. 참고문헌

- Lavin & Ahmad (2015). *Evaluating Real-time Anomaly Detection Algorithms: the Numenta Anomaly Benchmark.*
- Malhotra et al. (2015). *Long Short Term Memory Networks for Anomaly Detection in Time Series.* ESANN.
- Hundman et al. (2018). *Detecting Spacecraft Anomalies Using LSTMs and Nonparametric Dynamic Thresholding.* KDD.
- Hochreiter & Schmidhuber (1997). *Long Short-Term Memory.* Neural Computation.
