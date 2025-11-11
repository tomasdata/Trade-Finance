#!/usr/bin/env python3
"""Utility to extract structured metrics from FCIB Credit & Collections Survey PDFs.

Current implementation focuses on:
    1. Sales mix (Existing vs New customers)
    2. Average days beyond terms

The parser relies on the layout text extracted via pdfplumber. Many of the
surveys share the same slide template, so we can look for key markers
(“Exisiting/New” tables, “What is the average number…” block, etc.).
As we automate more sections (payment terms, causes, methods), additional
parsing routines can be plugged here.
"""
from __future__ import annotations

import argparse
import csv
import re
from dataclasses import dataclass
from pathlib import Path
from statistics import mean
from typing import Dict, List, Sequence, Tuple

import pdfplumber


@dataclass
class CountryMetrics:
    name: str
    sales_existing_pct: float | None = None
    sales_new_pct: float | None = None
    avg_days_beyond_terms: float | None = None
    payment_terms_no_credit_pct: float | None = None
    payment_terms_1_30_pct: float | None = None
    payment_terms_31_60_pct: float | None = None
    payment_terms_61_90_pct: float | None = None
    payment_terms_90_plus_pct: float | None = None
    payment_delays_staying_pct: float | None = None
    payment_delays_no_delay_pct: float | None = None
    payment_delays_decreasing_pct: float | None = None
    payment_delays_increasing_pct: float | None = None

    # Helper to output as dict with column names we already use elsewhere
    def to_record(self, year: int, month: int) -> Dict[str, float | int | str]:
        return {
            "survey_year": year,
            "survey_month": month,
            "country": self.name,
            "sales_existing_pct": self.sales_existing_pct,
            "sales_new_pct": self.sales_new_pct,
            "avg_days_beyond_terms": self.avg_days_beyond_terms,
            "payment_terms_no_credit_pct": self.payment_terms_no_credit_pct,
            "payment_terms_1_30_pct": self.payment_terms_1_30_pct,
            "payment_terms_31_60_pct": self.payment_terms_31_60_pct,
            "payment_terms_61_90_pct": self.payment_terms_61_90_pct,
            "payment_terms_90_plus_pct": self.payment_terms_90_plus_pct,
            "payment_delays_staying_pct": self.payment_delays_staying_pct,
            "payment_delays_no_delay_pct": self.payment_delays_no_delay_pct,
            "payment_delays_decreasing_pct": self.payment_delays_decreasing_pct,
            "payment_delays_increasing_pct": self.payment_delays_increasing_pct,
        }


def extract_text_with_layout(pdf_path: Path) -> List[str]:
    """Return a list of lines extracted with layout preserved."""
    lines: List[str] = []
    with pdfplumber.open(pdf_path) as pdf:
        for page in pdf.pages:
            extracted = page.extract_text(layout=True) or ""
            lines.extend(extracted.splitlines())
    return lines


def split_columns(line: str) -> List[str]:
    """Split a line by double (or more) spaces preserving single spaces."""
    cleaned = line.replace("\u200b", " ")
    return [p.strip() for p in re.split(r"\s{2,}", cleaned) if p.strip()]


def align_tokens_to_countries(tokens: List[str], candidates: Sequence[str]) -> List[str]:
    """Greedy match tokens to known country names preserving order."""
    if not tokens:
        return []
    normalized = {c.lower(): c for c in candidates}
    result: List[str] = []
    i = 0
    while i < len(tokens):
        match = None
        next_i = i + 1
        for end in range(len(tokens), i, -1):
            candidate = " ".join(tokens[i:end]).lower()
            if candidate in normalized:
                match = normalized[candidate]
                next_i = end
                break
        if not match:
            match = tokens[i]
            next_i = i + 1
        result.append(match)
        i = next_i
    return result


def parse_country_list(lines: List[str]) -> List[str]:
    """Look for the comma-separated country list under the title."""
    for line in lines[:40]:  # first page usually contains the list
        if "," in line and "FCIB Credit" not in line:
            candidates = [re.sub(r"\s+", " ", x.strip()) for x in line.split(",") if x.strip()]
            # guard against sentences (we expect 3-5 country names)
            if 2 <= len(candidates) <= 8 and all(x[0].isalpha() for x in candidates):
                return candidates
    return []


def parse_sales_mix(lines: List[str], known_countries: Sequence[str]) -> Dict[str, Tuple[float, float]]:
    result: Dict[str, Tuple[float, float]] = {}
    for idx, line in enumerate(lines):
        if "Exisiting" in line or "Existing" in line:
            if idx - 1 < 0 or idx + 1 >= len(lines):
                continue
            header_line = lines[idx - 1]
            new_line = lines[idx + 1]
            header_cols = align_tokens_to_countries(split_columns(header_line), known_countries)
            existing_values = split_columns(line.replace("Exisiting", "").replace("Existing", ""))
            new_values = split_columns(new_line.replace("New", ""))
            if not header_cols:
                continue
            if len(existing_values) != len(header_cols) or len(new_values) != len(header_cols):
                continue
            for col, existing, new in zip(header_cols, existing_values, new_values):
                try:
                    ex_pct = float(existing.replace("%", ""))
                    new_pct = float(new.replace("%", ""))
                except ValueError:
                    continue
                result[col] = (ex_pct, new_pct)
            break
    return result


def parse_avg_days(lines: List[str], known_countries: Sequence[str]) -> Dict[str, float]:
    result: Dict[str, float] = {}
    for idx, line in enumerate(lines):
        normalized = re.sub(r"\s+", " ", line.strip().lower())
        if normalized.startswith("what is the average number of days beyond terms"):
            country_line = ""
            values_line = ""
            # skip blank lines if present
            j = idx + 1
            while j < len(lines) and not lines[j].strip():
                j += 1
            if j < len(lines):
                country_line = lines[j]
            j += 1
            while j < len(lines) and not lines[j].strip():
                j += 1
            if j < len(lines):
                values_line = lines[j]
            countries = align_tokens_to_countries(split_columns(country_line), known_countries)
            values = split_columns(values_line)
            if len(countries) != len(values):
                continue
            for c, val in zip(countries, values):
                try:
                    result[c] = float(val)
                except ValueError:
                    continue
            break
    return result


def parse_payment_terms(pdf: pdfplumber.PDF, countries: Sequence[str]) -> Dict[str, Dict[str, float]]:
    result: Dict[str, Dict[str, float]] = {}
    for page in pdf.pages:
        text = page.extract_text(layout=True) or ""
        normalized = " ".join(text.lower().split())
        if "what payment terms" not in normalized:
            continue
        words = page.extract_words()
        for country in countries:
            if country in result:
                continue
            boxes = page.search(country, case=False)
            if not boxes:
                continue
            bbox = boxes[0]
            values = extract_payment_terms_from_box(page, words, bbox)
            if values:
                result[country] = values
    return result


def extract_payment_terms_from_box(page, words, bbox) -> Dict[str, float] | None:
    x_min = max(0.0, bbox['x0'] - 250)
    x_max = min(page.width, bbox['x1'] + 250)
    y_min = bbox['bottom']
    y_max = y_min + 320
    percents = []
    for w in words:
        if not w['text'].endswith('%'):
            continue
        x = w['x0']
        y = w['top']
        if x_min <= x <= x_max and y_min <= y <= y_max:
            try:
                value = float(w['text'].replace('%', ''))
            except ValueError:
                continue
            percents.append((x, value))
    if not percents:
        return None
    axis_x = min(x for x, _ in percents)
    filtered = [(x, val) for x, val in percents if x > axis_x + 15]
    if not filtered:
        return None
    filtered.sort(key=lambda item: item[0])
    clusters: List[Tuple[float, List[float]]] = []
    for x, val in filtered:
        if not clusters or abs(x - clusters[-1][0]) > 20:
            clusters.append((x, [val]))
        else:
            clusters[-1][1].append(val)
    values = [sum(vals) / len(vals) for _, vals in clusters]
    if len(values) != 5:
        return None
    buckets = {
        'payment_terms_no_credit_pct': values[0],
        'payment_terms_1_30_pct': values[1],
        'payment_terms_31_60_pct': values[2],
        'payment_terms_61_90_pct': values[3],
        'payment_terms_90_plus_pct': values[4],
    }
    return {k: round(v, 1) for k, v in buckets.items()}


def parse_payment_delays(pdf: pdfplumber.PDF, countries: Sequence[str]) -> Dict[str, Dict[str, float]]:
    result: Dict[str, Dict[str, float]] = {}
    label_centers = infer_delay_label_centers(pdf)
    if not label_centers:
        return result
    for page in pdf.pages:
        text = page.extract_text(layout=True) or ""
        normalized = " ".join(text.lower().split())
        if "payment delays increasing" not in normalized:
            continue
        words = page.extract_words()
        for country in countries:
            if country in result:
                continue
            boxes = page.search(country, case=False)
            if not boxes:
                continue
            bbox = boxes[0]
            values = extract_payment_delays_from_box(page, words, bbox, label_centers)
            if values:
                result[country] = values
    return result


def infer_delay_label_centers(pdf: pdfplumber.PDF) -> Dict[str, float]:
    phrases = [
        "staying the same",
        "not experiencing payment delays",
        "decreasing",
        "increasing",
    ]
    centers: Dict[str, List[float]] = {p: [] for p in phrases}
    for page in pdf.pages:
        text = page.extract_text(layout=True) or ""
        if "payment delays" not in text.lower():
            continue
        words = page.extract_words()
        for phrase in phrases:
            hits = page.search(phrase, case=False)
            box = hits[0] if hits else None
            if not box:
                first_token = phrase.split()[0]
                for w in words:
                    token = first_token[:4].lower()
                    if w["text"].lower().startswith(token):
                        box = w
                        break
            if box:
                centers[phrase].append((box["x0"] + box["x1"]) / 2)
    result = {}
    for phrase, values in centers.items():
        if values:
            result[phrase] = mean(values)
    return result


def extract_payment_delays_from_box(page, words, bbox, label_centers: Dict[str, float]) -> Dict[str, float] | None:
    x_min = max(0.0, bbox["x0"] - 250)
    x_max = min(page.width, bbox["x1"] + 250)
    y_min = bbox["bottom"]
    y_max = y_min + 430
    percents: List[Tuple[float, float]] = []
    for w in words:
        text = w["text"]
        if not text.endswith("%"):
            continue
        x = w["x0"]
        y = w["top"]
        if x_min <= x <= x_max and y_min <= y <= y_max:
            try:
                value = float(text.replace("%", ""))
            except ValueError:
                continue
            percents.append((x, value))
    if not percents:
        return None
    if not percents:
        return None
    phrase_map = {
        "staying the same": "payment_delays_staying_pct",
        "not experiencing payment delays": "payment_delays_no_delay_pct",
        "decreasing": "payment_delays_decreasing_pct",
        "increasing": "payment_delays_increasing_pct",
    }
    assignments: Dict[str, float] = {}
    for phrase, column in phrase_map.items():
        center = label_centers.get(phrase)
        if center is None:
            continue
        candidates = [(abs(x - center), val) for x, val in percents]
        if not candidates:
            continue
        candidates.sort(key=lambda item: item[0])
        assignments[column] = candidates[0][1]
    if not assignments:
        return None
    buckets = {
        "payment_delays_staying_pct": assignments.get("payment_delays_staying_pct"),
        "payment_delays_no_delay_pct": assignments.get("payment_delays_no_delay_pct"),
        "payment_delays_decreasing_pct": assignments.get("payment_delays_decreasing_pct"),
        "payment_delays_increasing_pct": assignments.get("payment_delays_increasing_pct"),
    }
    return {k: round(v, 1) for k, v in buckets.items()}


REGEX_PATTERNS = [
    re.compile(r"(20\d{2})[-_](\d{2})"),
    re.compile(r"(\d{2})[-_](20\d{2})"),
    re.compile(r"([A-Za-z]+)[-_](20\d{2})"),
]


def infer_period_from_name(pdf_path: Path) -> Tuple[int, int]:
    stem = pdf_path.stem
    for pattern in REGEX_PATTERNS:
        m = pattern.search(stem)
        if not m:
            continue
        groups = m.groups()
        if len(groups) == 2:
            if groups[0].isdigit() and groups[1].isdigit():
                y = int(groups[0]) if len(groups[0]) == 4 else int(groups[1])
                m_val = int(groups[1]) if len(groups[1]) == 2 else int(groups[0])
                return y, m_val
            if groups[0].isalpha() and groups[1].isdigit():
                month_num = month_from_name(groups[0])
                if month_num:
                    return int(groups[1]), month_num
    raise ValueError(f"Cannot infer YYYY-MM from filename: {pdf_path.name}")


def month_from_name(token: str) -> int | None:
    month_map = {
        'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
        'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
    }
    return month_map.get(token[:3].lower())
    if not m:
        raise ValueError(f"Cannot infer YYYY-MM from filename: {pdf_path.name}")
    return int(m.group(1)), int(m.group(2))


def main():
    parser = argparse.ArgumentParser(description="Extract FCIB survey metrics from PDF")
    parser.add_argument("pdf", type=Path, help="Path to FCIB survey PDF")
    parser.add_argument("--output", type=Path, default=Path("data/fcib_credit_collections_panel.csv"),
                        help="CSV file to append results to")
    parser.add_argument("--print", action="store_true", help="Print parsed rows instead of writing")
    args = parser.parse_args()

    lines = extract_text_with_layout(args.pdf)
    year, month = infer_period_from_name(args.pdf)

    known_countries = parse_country_list(lines)
    sales = parse_sales_mix(lines, known_countries)
    avg_days = parse_avg_days(lines, known_countries)

    country_hint: List[str] = known_countries or list({*sales.keys(), *avg_days.keys()})
    payment_terms: Dict[str, Dict[str, float]] = {}
    payment_delays: Dict[str, Dict[str, float]] = {}
    if country_hint:
        with pdfplumber.open(args.pdf) as pdf:
            payment_terms = parse_payment_terms(pdf, country_hint)
            payment_delays = parse_payment_delays(pdf, country_hint)

    if not (sales or avg_days or payment_terms or payment_delays):
        raise RuntimeError("Could not parse expected sections. Please check the PDF layout.")

    all_countries = list({*sales.keys(), *avg_days.keys(), *payment_terms.keys(), *payment_delays.keys()})
    ordered_countries: List[str] = []
    for name in country_hint:
        if name in all_countries and name not in ordered_countries:
            ordered_countries.append(name)
    for name in all_countries:
        if name not in ordered_countries:
            ordered_countries.append(name)

    metrics: List[CountryMetrics] = []
    for country in ordered_countries:
        cm = CountryMetrics(name=country)
        if country in sales:
            cm.sales_existing_pct, cm.sales_new_pct = sales[country]
        if country in avg_days:
            cm.avg_days_beyond_terms = avg_days[country]
        if country in payment_terms:
            term_values = payment_terms[country]
            cm.payment_terms_no_credit_pct = term_values.get("payment_terms_no_credit_pct")
            cm.payment_terms_1_30_pct = term_values.get("payment_terms_1_30_pct")
            cm.payment_terms_31_60_pct = term_values.get("payment_terms_31_60_pct")
            cm.payment_terms_61_90_pct = term_values.get("payment_terms_61_90_pct")
            cm.payment_terms_90_plus_pct = term_values.get("payment_terms_90_plus_pct")
        if country in payment_delays:
            delay_values = payment_delays[country]
            cm.payment_delays_staying_pct = delay_values.get("payment_delays_staying_pct")
            cm.payment_delays_no_delay_pct = delay_values.get("payment_delays_no_delay_pct")
            cm.payment_delays_decreasing_pct = delay_values.get("payment_delays_decreasing_pct")
            cm.payment_delays_increasing_pct = delay_values.get("payment_delays_increasing_pct")
        metrics.append(cm)

    if args.print:
        for record in metrics:
            print(record.to_record(year, month))
        return

    args.output.parent.mkdir(parents=True, exist_ok=True)
    file_exists = args.output.exists()
    with args.output.open("a", newline="") as fh:
        writer = csv.DictWriter(
            fh,
            fieldnames=[
                "survey_year",
                "survey_month",
                "country",
                "sales_existing_pct",
                "sales_new_pct",
                "avg_days_beyond_terms",
                "payment_terms_no_credit_pct",
                "payment_terms_1_30_pct",
                "payment_terms_31_60_pct",
                "payment_terms_61_90_pct",
                "payment_terms_90_plus_pct",
                "payment_delays_staying_pct",
                "payment_delays_no_delay_pct",
                "payment_delays_decreasing_pct",
                "payment_delays_increasing_pct",
            ],
        )
        if not file_exists:
            writer.writeheader()
        for record in metrics:
            writer.writerow(record.to_record(year, month))


if __name__ == "__main__":
    main()
