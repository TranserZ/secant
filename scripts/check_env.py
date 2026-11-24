"""환경 점검: 팀원 모두 같은 버전이 나오는지 확인한다.

    docker compose run --rm secant python scripts/check_env.py
"""
import platform
import sys

import matplotlib
import numpy
import pandas
import sklearn
import torch
import yaml

print(f"python       {sys.version.split()[0]} ({platform.machine()})")
for name, mod in [("torch", torch), ("numpy", numpy), ("pandas", pandas),
                  ("matplotlib", matplotlib), ("scikit-learn", sklearn), ("pyyaml", yaml)]:
    print(f"{name:<12} {mod.__version__}")
print(f"cuda         {torch.cuda.is_available()}")

x = torch.randn(2, 8, 1)
out, _ = torch.nn.LSTM(1, 4, batch_first=True)(x)
assert out.shape == (2, 8, 4)
print("LSTM forward OK")
