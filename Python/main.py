import subprocess
import sys
from pathlib import Path



PYTHON_DIR = Path(__file__).resolve().parent
RUN_PROFILER = PYTHON_DIR / "run_profiler.py"

TABLES = [
    "Customer",
    "Product",
    "Store",
    "Employee",
    "SalesTransaction",
    "ReturnTransaction",
    "SalesTarget",
    "ProductPriceHistory",
]


def main():
    
    for table in TABLES:
        print(f"\n{'=' * 60}", flush=True)
        print(f"Starting profiling for {table}", flush=True)
        print(f"{'=' * 60}", flush=True)

        result = subprocess.run(
            [sys.executable, str(RUN_PROFILER), table], cwd=str(PYTHON_DIR), check=False
        )

        if result.returncode != 0:
            raise SystemExit(f"Profiling failed for {table}. " "Stopping the process.")


    print("\nAll table profiling completed successfully.", flush=True)


if __name__ == "__main__":
    main()
