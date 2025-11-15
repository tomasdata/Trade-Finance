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
    margin_x = 130
    margin_y = 220
    x_min = max(0.0, bbox["x0"] - margin_x)
    x_max = min(page.width, bbox["x1"] + margin_x)
    y_min = bbox["bottom"]
    y_max = y_min + margin_y
    percents: List[Tuple[float, float]] = []
    for w in words:
        text = w["text"]
        if not text.endswith("%"):
            continue
        x_center = (w["x0"] + w["x1"]) / 2
        y_center = (w["top"] + w["bottom"]) / 2
        if not (x_min <= x_center <= x_max and (y_min + 20) <= y_center <= y_max):
            continue
        try:
            value = float(text.replace("%", ""))
        except ValueError:
            continue
        percents.append((x_center, value))
    if not percents:
        return None
    percents.sort(key=lambda item: item[0])
    clusters: List[Tuple[float, float]] = []
    for x, val in percents:
        if not clusters or abs(x - clusters[-1][0]) > 25:
            clusters.append((x, val))
        else:
            prev_x, prev_val = clusters[-1]
            clusters[-1] = ((prev_x + x) / 2, (prev_val + val) / 2)
    values = [round(val, 1) for _, val in clusters]
    if len(values) < 5:
        return None
    values = values[:5]
    total = sum(values)
    if not (90 <= total <= 110):
        return None
    buckets = {
        "payment_terms_no_credit_pct": values[0],
        "payment_terms_1_30_pct": values[1],
        "payment_terms_31_60_pct": values[2],
        "payment_terms_61_90_pct": values[3],
        "payment_terms_90_plus_pct": values[4],
    }
    return buckets


def parse_payment_delays(pdf: pdfplumber.PDF, countries: Sequence[str]) -> Dict[str, Dict[str, float]]:
    result: Dict[str, Dict[str, float]] = {}
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
            values = extract_payment_delays_from_box(page, words, bbox)
            if values:
                result[country] = values
    return result


DELAY_LABELS = [
    ("staying the same", "payment_delays_staying_pct"),
    ("not experiencing payment delays", "payment_delays_no_delay_pct"),
    ("decreasing", "payment_delays_decreasing_pct"),
    ("increasing", "payment_delays_increasing_pct"),
]


def extract_payment_delays_from_box(page, words, bbox) -> Dict[str, float] | None:
    margin_x = 130
    margin_y = 230
    x_min = max(0.0, bbox["x0"] - margin_x)
    x_max = min(page.width, bbox["x1"] + margin_x)
    y_min = bbox["bottom"]
    y_max = y_min + margin_y

    def label_centers() -> Dict[str, float]:
        centers: Dict[str, float] = {}
        for phrase, key in DELAY_LABELS:
            hits = page.search(phrase, case=False)
            if not hits:
                continue
            for hit in hits:
                center = (hit["x0"] + hit["x1"]) / 2
                y_center = (hit["top"] + hit["bottom"]) / 2
                if x_min - 40 <= center <= x_max + 40 and y_center >= y_max - 60:
                    centers[key] = center
                    break
        return centers

    centers = label_centers()

    percents: List[Tuple[float, float]] = []
    for w in words:
        text = w["text"]
        if not text.endswith("%"):
            continue
        x_center = (w["x0"] + w["x1"]) / 2
        y_center = (w["top"] + w["bottom"]) / 2
        if not (x_min <= x_center <= x_max and (y_min + 20) <= y_center <= y_max):
            continue
        try:
            value = float(text.replace("%", ""))
        except ValueError:
            continue
        percents.append((x_center, value))
    if not percents:
        return None
    percents.sort(key=lambda item: item[0])
    clusters: List[Tuple[float, float]] = []
    for x, val in percents:
        if not clusters or abs(x - clusters[-1][0]) > 25:
            clusters.append((x, val))
        else:
            prev_x, prev_val = clusters[-1]
            clusters[-1] = ((prev_x + x) / 2, (prev_val + val) / 2)

    values_by_key: Dict[str, float] = {}
    if centers:
        for cluster_x, cluster_val in clusters:
            best_key = None
            best_dist = float("inf")
            for key, center in centers.items():
                dist = abs(cluster_x - center)
                if dist < best_dist:
                    best_dist = dist
                    best_key = key
            if best_key and best_key not in values_by_key:
                values_by_key[best_key] = round(cluster_val, 1)
    else:
        ordered_keys = [key for _, key in DELAY_LABELS]
        for key, cluster in zip(ordered_keys, clusters):
            values_by_key[key] = round(cluster[1], 1)

    if not values_by_key:
        return None

    total = sum(values_by_key.values())
    if total and not (90 <= total <= 110):
        return None

    return {
        "payment_delays_staying_pct": values_by_key.get("payment_delays_staying_pct"),
        "payment_delays_no_delay_pct": values_by_key.get("payment_delays_no_delay_pct"),
        "payment_delays_decreasing_pct": values_by_key.get("payment_delays_decreasing_pct"),
        "payment_delays_increasing_pct": values_by_key.get("payment_delays_increasing_pct"),
    }


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
