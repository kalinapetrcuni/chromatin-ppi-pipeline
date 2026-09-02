import os
from alphajudge.runner import process_many
from pathlib import Path

run_dir = str(os.environ["MULTIMER_OUTPUT_DIR"])
output_csv = str(Path(os.environ["INPUT_CSV"]).resolve().parent / "interfaces_summary.csv")

process_many(
    [str(run_dir)],
    contact_thresh=8.0,
    pae_filter=100.0,
    models_to_analyse="best",
    recursive=True,
    summary_csv=output_csv,
)

print(f"Wrote Alphajudge summary table to {output_csv}")