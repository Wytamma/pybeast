import pandas as pd
import glob
import re
from pathlib import Path
import matplotlib.pyplot as plt
import argparse
import seaborn as sns

custom_params = {"axes.spines.right": False, "axes.spines.top": False}
sns.set_theme(style="ticks", rc=custom_params)


parser = argparse.ArgumentParser(description="Process the output from a BETS analysis.")
parser.add_argument(
    "directory", type=Path, help="The output directory of the BETS analysis."
)

args = parser.parse_args()

directory = args.directory

title = Path(directory).stem
directory_plus_wildcards = str(directory) + "/*/*/*.out"

paths = [Path(path) for path in glob.glob(directory_plus_wildcards)]

data = []
for path in paths:
    with open(path) as f:
        lines = f.readlines()
    lines = [l for l in lines if l.startswith("Marginal likelihood:")]
    line = lines[-2]
    ML = line.split(" ")[2]
    match = re.search("SD=\(.*\)", line).group(0)
    SD = match[4:-1]
    data.append(
        {
            "Name": path.stem,
            "Marginal likelihood": float(ML),
            "Standard deviation": float(SD),
        }
    )

df = pd.DataFrame(data).sort_values("Name").reset_index()

fig, ax = plt.subplots()
ax.set_title(f"BETS for {title}")
ax.errorbar(
    data=df,
    y="Name",
    x="Marginal likelihood",
    xerr="Standard deviation",
    fmt="o",
    ecolor="lightgray",
    color="black",
)

plt.savefig(f"{directory}/BETS.svg", bbox_inches="tight")
plt.savefig(f"{directory}/BETS.png", bbox_inches="tight")
df.to_csv(f"{directory}/BETS.csv")
