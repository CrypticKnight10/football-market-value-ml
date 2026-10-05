# Football Market Value ML

A machine-learning project that predicts football player market value in millions of euros from player profiles, season performance, and historical market value.

## Problem

Player valuation is influenced by age, performance, historical valuation, and broader market context. This project tests how much of a player's seasonal market value can be estimated from structured player and match data using a time-based machine-learning evaluation.

The main analysis is in [`football_market_value.ipynb`](football_market_value.ipynb). The project is exploratory and is not a production valuation system.

## Dataset

The notebook expects these local compressed CSV files:

- `data/players.csv.gz` — player profile information
- `data/appearances.csv.gz` — match appearances and performance
- `data/player_valuations.csv.gz` — historical market valuations

These raw/local files are ignored by Git because they are relatively large. They are published as part of the [`dcaribou/transfermarkt-datasets`](https://github.com/dcaribou/transfermarkt-datasets) project, which identifies the underlying source as Transfermarkt. The repository includes a curl-based download script, so a fresh clone can set up the data with:

```bash
bash scripts/download_data.sh
```

The script downloads only files that are missing from `data/`. To download the files manually:

```bash
mkdir -p data
curl -L --fail -o data/players.csv.gz https://pub-e682421888d945d684bcae889b0ec20.r2.dev/data/players.csv.gz
curl -L --fail -o data/appearances.csv.gz https://pub-e682421888d945d684bcae889b0ec20.r2.dev/data/appearances.csv.gz
curl -L --fail -o data/player_valuations.csv.gz https://pub-e682421888d945d684bcae889b0ec20.r2.dev/data/player_valuations.csv.gz
```

The upstream project notes that its published data is not continuously refreshed, so results can change if the files are updated. The notebook’s reported results were produced from the local files used in this project.

## Data preparation and pipeline

The notebook:

1. Loads player, appearance, and valuation data with pandas.
2. Converts dates into football seasons.
3. Selects player-seasons with at least one appearance in the seven specified leagues: England, Spain, Italy, Germany, France, Portugal, and the Netherlands.
4. Aggregates all recorded competitions into player-season totals for appearances, goals, assists, and minutes.
5. Adds player profile information, readable league labels, and age at the start of the season.
6. Keeps the latest valuation within each season, converts values to millions of euros, and keeps player-seasons with at least 450 minutes.
7. Uses a time-based split: training on 2016/17–2022/23 and testing on 2023/24–2025/26.

The V3 and V4 comparisons use the subset with a known previous-season market value. The target is log-transformed for V2–V4, and predictions are converted back to euros before calculating mean absolute error (MAE).

## Model progression and results

| Version | Main change | Test MAE |
| --- | --- | ---: |
| V1 | Linear Regression on the raw target | €8.16M |
| V2 | Log-transformed target | €7.53M |
| V3 | Added previous-season market value | €3.72M |
| V4 | Random Forest using V3 features | **€3.29M** |

V1 uses age, appearances, goals, assists, and minutes. V2 keeps the same features but predicts log market value. V3 adds previous-season market value. V4 applies a Random Forest Regressor to the V3 feature set.

The strongest improvement came from historical market value. V4 still struggles with the most expensive players and can extrapolate poorly for superstar values.

## Repository structure

```text
.
├── football_market_value.ipynb  # Complete analysis and model comparison
├── scripts/download_data.sh     # Downloads the required datasets
├── requirements.txt             # Python dependencies
├── .gitignore                   # Local data and environment exclusions
└── README.md                   # Project documentation
```

## Limitations

- The valuation timing is treated as an approximate end-of-season value; potential temporal leakage has not been fully redesigned.
- The league label uses the latest Top-7 appearance in a season and is a simplification for players who move leagues.
- The features do not include contracts, wages, reputation, transfer demand, injuries, or other market signals.
- V1 can produce negative predictions, while V3/V4 can overestimate superstar values.
- Results are reported on one time-based split and should not be treated as a general production benchmark.

## Technologies

- Python
- Jupyter Notebook
- pandas and NumPy for data preparation
- scikit-learn for Linear Regression, Random Forest Regression, and MAE evaluation

## Running the notebook

1. Create and activate a Python environment.
2. Install the dependencies from [`requirements.txt`](requirements.txt).
3. Download the datasets with `bash scripts/download_data.sh`.
4. Open `football_market_value.ipynb` in Jupyter or VS Code and run the cells in order.

## Possible extensions

Future experiments could add position and club context, improve valuation timing to prevent leakage, include contract and transfer features, evaluate additional time splits, and use models better suited to the heavily right-skewed market-value distribution.
