#!/usr/bin/env python3
"""
Extract Trade Finance Metrics from Development Banks PDFs
==========================================================

This script extracts key TF metrics from development bank annual reports:
- Portfolio size (total outstanding, new disbursements)
- Product mix (LC, export credit, guarantees, insurance)
- Firm size distribution (SME %)
- Sectoral breakdown (export sectors)
- Regional concentration (HHI)

Extracted data feeds into data/dev_banks_tf_panel.csv

Usage:
    python3 Scripts/extract_devbanks_metrics.py --institution BNDES --year 2023
    python3 Scripts/extract_devbanks_metrics.py --all  # Process all available PDFs
"""

import json
import re
from pathlib import Path
from typing import Dict, List, Optional, Tuple
import pdfplumber
import pandas as pd
from dataclasses import dataclass, asdict

@dataclass
class DevBankMetrics:
    """Development bank TF metrics container"""
    year: int
    country: str
    institution: str

    # Portfolio metrics (USD millions)
    tf_portfolio_outstanding_usd: Optional[float] = None  # Total TF outstanding
    tf_new_disbursements_usd: Optional[float] = None  # New disbursements in year

    # Product mix
    lc_volume_usd: Optional[float] = None  # Letters of credit
    export_credit_volume_usd: Optional[float] = None  # Direct export credit
    guarantee_volume_usd: Optional[float] = None  # Guarantees issued
    insurance_volume_usd: Optional[float] = None  # Trade credit insurance
    factoring_volume_usd: Optional[float] = None  # Factoring operations

    # Firm size distribution (%)
    sme_pct: Optional[float] = None  # % of TF to SMEs
    large_firm_pct: Optional[float] = None  # % of TF to large firms

    # Sectors (top 3)
    sector_1: Optional[str] = None
    sector_1_pct: Optional[float] = None
    sector_2: Optional[str] = None
    sector_2_pct: Optional[float] = None
    sector_3: Optional[str] = None
    sector_3_pct: Optional[float] = None

    # Regional concentration
    regional_concentration_hhi: Optional[float] = None  # Herfindahl-Hirschman Index
    coastal_vs_inland_ratio: Optional[float] = None  # Coastal/inland TF ratio

    # Growth metrics
    ytoy_growth_pct: Optional[float] = None  # Year-over-year growth %

    # Crisis response
    covid_impact_2020_pct: Optional[float] = None  # Change 2019-2020
    recovery_2021_pct: Optional[float] = None  # Change 2020-2021

    # Data quality
    data_source: str = ""  # PDF section found in
    extraction_confidence: str = "LOW"  # LOW/MEDIUM/HIGH
    notes: str = ""

class DevBankExtractor:
    """Extract metrics from development bank PDFs"""

    # Map of institution identifiers
    INSTITUTIONS = {
        "BNDES": {"country": "Brasil", "sectors": ["agropecuaria", "manufactura", "servicios"]},
        "CORFO": {"country": "Chile", "sectors": ["minería", "agricultura", "manufactura"]},
        "NAFIN": {"country": "México", "sectors": ["manufactura", "agricultura", "servicios"]},
        "Bancomext": {"country": "México", "sectors": ["manufactura", "agricultura"]},
        "Bancóldex": {"country": "Colombia", "sectors": ["manufactura", "agricultura", "servicios"]},
        "Finagro": {"country": "Colombia", "sectors": ["agricultura", "ganadería"]},
        "Findeter": {"country": "Colombia", "sectors": ["infraestructura", "territorio"]},
        "FNG": {"country": "Colombia", "sectors": ["SME", "general"]},
        "BICE": {"country": "Argentina", "sectors": ["manufactura", "agricultura", "servicios"]},
        "COFIDE": {"country": "Perú", "sectors": ["manufactura", "agricultura", "turismo"]},
        "BDP": {"country": "Bolivia", "sectors": ["agricultura", "manufactura", "artesanía"]},
        "AFD": {"country": "Paraguay", "sectors": ["agricultura", "manufactura", "agropecuaria"]},
        "BDE": {"country": "Ecuador", "sectors": ["agricultura", "manufactura", "turismo"]},
        "ANDE": {"country": "Uruguay", "sectors": ["tecnología", "manufactura", "agricultura"]},
        "SBD": {"country": "Costa Rica", "sectors": ["turismo", "agricultura", "tecnología"]},
        "CAF": {"country": "Multilateral", "sectors": ["infraestructura", "integración regional"]},
        "FONPLATA": {"country": "Multilateral", "sectors": ["MERCOSUR trade"]},
        "CABEI": {"country": "Multilateral", "sectors": ["Central America"]},
    }

    def __init__(self, pdf_path: Path):
        """Initialize with PDF file"""
        self.pdf_path = pdf_path
        self.text = self._extract_text()
        self.institution = self._identify_institution()
        self.year = self._extract_year()

    def _extract_text(self) -> str:
        """Extract all text from PDF"""
        text = ""
        try:
            with pdfplumber.open(self.pdf_path) as pdf:
                for page in pdf.pages:
                    text += page.extract_text() or ""
        except Exception as e:
            print(f"⚠️  Error reading {self.pdf_path}: {e}")
        return text.lower()

    def _identify_institution(self) -> str:
        """Identify institution from PDF filename or content"""
        for inst in self.INSTITUTIONS.keys():
            if inst.lower() in self.pdf_path.name.lower():
                return inst
        return "UNKNOWN"

    def _extract_year(self) -> int:
        """Extract year from PDF filename or content"""
        year_match = re.search(r'20\d{2}', self.pdf_path.name)
        if year_match:
            return int(year_match.group())

        # Try to find "2023" or "2024" in content
        year_match = re.search(r'(20\d{2})', self.text)
        if year_match:
            return int(year_match.group(1))

        return 2023  # Default

    def _extract_float(self, patterns: List[str], section_text: Optional[str] = None) -> Optional[float]:
        """Extract float value from text using multiple pattern attempts"""
        search_text = section_text or self.text

        for pattern in patterns:
            matches = re.finditer(pattern, search_text, re.IGNORECASE)
            for match in matches:
                try:
                    # Try to extract number from match
                    num_str = re.search(r'[\d,.]+(?:\s+(?:millones|mil|million|billion|mmd|usd))?',
                                       match.group(), re.IGNORECASE)
                    if num_str:
                        num = num_str.group().replace(',', '').replace('.', '')
                        # Detect scale (millones, mil, billion, etc.)
                        if 'billion' in num_str.group().lower() or 'mmd' in num_str.group().lower():
                            return float(num) * 1000
                        elif 'millones' in num_str.group().lower() or 'million' in num_str.group().lower():
                            return float(num)
                        else:
                            return float(num) / 1e6  # Assume original currency, convert to USD millions
                except (ValueError, AttributeError):
                    continue

        return None

    def extract_metrics(self) -> DevBankMetrics:
        """Extract all available metrics from PDF"""

        metrics = DevBankMetrics(
            year=self.year,
            country=self.INSTITUTIONS.get(self.institution, {}).get("country", "Unknown"),
            institution=self.institution,
            data_source=self.pdf_path.name,
            extraction_confidence="LOW"  # Default low, increase if data found
        )

        # Extract portfolio metrics
        portfolio_patterns = [
            r'(?:cartera|portfolio|saldo|outstanding|vigente).*?[\d,.]+\s*(?:millones|million)',
            r'(?:desembolsos|disbursements|prestamos|loans).*?[\d,.]+\s*(?:millones|million)',
        ]

        metrics.tf_portfolio_outstanding_usd = self._extract_float([
            r'cartera\s+(?:vigente|total|pendiente).*?[\d,.]+',
            r'portfolio\s+outstanding.*?[\d,.]+',
        ])

        # Extract product volumes
        metrics.lc_volume_usd = self._extract_float([
            r'(?:cartas?|letters)\s+(?:de\s+)?cr[ée]dito.*?[\d,.]+',
            r'documentary.*?credits?.*?[\d,.]+',
        ])

        metrics.export_credit_volume_usd = self._extract_float([
            r'cr[ée]dito\s+(?:a\s+)?(?:la\s+)?exportaci[óo]n.*?[\d,.]+',
            r'export\s+(?:credit|financing).*?[\d,.]+',
        ])

        metrics.guarantee_volume_usd = self._extract_float([
            r'(?:garant[ií]as?|guarantees?).*?[\d,.]+',
            r'(?:fondo\s+de\s+)?garant[ií]a.*?[\d,.]+',
        ])

        # Extract SME percentage (harder - look for specific sections)
        sme_patterns = [
            r'(?:mipyme|smae?|pyme).*?(\d+\.?\d*)\s*%',
            r'(\d+\.?\d*)\s*%.*?(?:mipyme|smae?|pyme)',
        ]
        metrics.sme_pct = self._extract_float(sme_patterns)

        # Extract growth metric
        growth_patterns = [
            r'crecimiento.*?(\d+\.?\d*)\s*%',
            r'grow(?:th|ing).*?(\d+\.?\d*)\s*%',
        ]
        metrics.ytoy_growth_pct = self._extract_float(growth_patterns)

        # Confidence assessment
        if metrics.tf_portfolio_outstanding_usd or metrics.tf_new_disbursements_usd:
            metrics.extraction_confidence = "MEDIUM"

        if metrics.sme_pct and metrics.guarantee_volume_usd:
            metrics.extraction_confidence = "HIGH"

        return metrics

def main():
    """Process all development bank PDFs"""

    base_dir = Path("/Users/tomasfernandez/Documents/Tomas/Trade-Finance/pre-data/banca-desarrollo")
    output_file = Path("/Users/tomasfernandez/Documents/Tomas/Trade-Finance/data/dev_banks_tf_panel.csv")

    print("🏦 EXTRAYENDO DATOS DE BANCOS DE DESARROLLO")
    print("=" * 60)

    # Find all PDFs
    pdf_files = sorted(base_dir.rglob("*.pdf"))

    if not pdf_files:
        print("❌ No PDF files found in banca-desarrollo/")
        print("   Download PDFs manually using instructions in SOURCES_AND_URLS.md")
        return

    print(f"\n📄 Found {len(pdf_files)} PDF files")

    all_metrics = []

    for pdf_path in pdf_files:
        print(f"\n  Processing: {pdf_path.name}")

        try:
            extractor = DevBankExtractor(pdf_path)
            metrics = extractor.extract_metrics()
            all_metrics.append(metrics)

            print(f"    Institution: {metrics.institution} ({metrics.country})")
            print(f"    Year: {metrics.year}")
            print(f"    Confidence: {metrics.extraction_confidence}")

            if metrics.tf_portfolio_outstanding_usd:
                print(f"    TF Portfolio: ${metrics.tf_portfolio_outstanding_usd:,.0f}M")

            if metrics.sme_pct:
                print(f"    SME %: {metrics.sme_pct:.1f}%")

        except Exception as e:
            print(f"    ❌ Error: {e}")

    if not all_metrics:
        print("\n⚠️  No metrics could be extracted")
        print("   PDFs may need manual inspection or OCR processing")
        return

    # Create DataFrame and save
    df = pd.DataFrame([asdict(m) for m in all_metrics])

    # Ensure output directory exists
    output_file.parent.mkdir(parents=True, exist_ok=True)

    df.to_csv(output_file, index=False)

    print(f"\n✅ Extracted {len(df)} records")
    print(f"   Saved to: {output_file}")
    print(f"\nSummary by Institution:")
    print(df.groupby('institution').size())

    print(f"\nSummary by Confidence:")
    print(df.groupby('extraction_confidence').size())

if __name__ == "__main__":
    main()
