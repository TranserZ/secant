# 협업 규칙

## 1. 개발 환경: 모든 실행은 Docker 컨테이너 안에서

팀원 모두 같은 Python·패키지 버전에서 실행하기 위해, 학습·평가·노트북은 **컨테이너 안에서** 실행합니다.

```bash
docker compose build                                   # 최초 1회
docker compose run --rm secant python scripts/check_env.py   # 환경 확인
```

- `requirements.txt` 또는 `Dockerfile`을 바꾸면 **PR에 명시**하고, 병합 후 팀원 모두 `docker compose build`를 다시 실행합니다.
- 패키지를 추가할 때는 반드시 `==버전`으로 고정합니다.

## 2. 브랜치 전략

- `main`: **항상 실행 가능한 상태**. 직접 push 하지 않습니다.
- 작업 브랜치: `main`에서 분기해서 PR로 병합합니다.

| 접두사 | 용도 | 예 |
|---|---|---|
| `feat/` | 새 기능 | `feat/data-pipeline`, `feat/lstm` |
| `fix/` | 버그 수정 | `fix/window-leak` |
| `exp/` | 실험·ablation | `exp/window-length` |
| `docs/` | 문서 | `docs/report-draft` |

```bash
git switch main && git pull
git switch -c feat/data-pipeline
# ... 작업 ...
git push -u origin feat/data-pipeline   # → GitHub에서 PR 생성
```

## 3. Pull Request

- **상대방 리뷰 1회 승인 후 병합**합니다.
- 병합 전 체크리스트:
  - [ ] 컨테이너 안에서 실행 확인
  - [ ] `history/`에 오늘 작업 기록 추가
  - [ ] 인터페이스(입출력 형식)를 바꿨다면 `INFORMATION.md` 갱신

## 4. 커밋 메시지

```
<type>: <무엇을 했는지 한 줄>
```

- type: `feat` `fix` `exp` `docs` `refactor` `chore`
- 예: `feat: add sliding window dataset`, `exp: compare W=24/48/96 for LSTM`

## 5. 작업 기록

push 할 때마다 `history/`에 기록합니다. 규칙은 [history/instruction.md](history/instruction.md)를 따릅니다.
