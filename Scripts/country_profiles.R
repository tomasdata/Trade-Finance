# Trade Finance Country Profiles ================================================
# Creates individual country profiles for Brasil, Chile, Perú, and México
# Based on the full datasets in /data/

library(tidyverse)
library(data.table)
library(dtplyr)
library(readxl)
library(readr)
library(viridis)
library(kableExtra)
library(zoo)
library(scales)
library(lubridate)
library(cowplot)
library(ggrepel)

rm(list = ls())
select <- dplyr::select

# Directories -------------------------------------------------------------------
folder <- "."  # Adjust to your working directory
data <- paste0(folder, "/data/")
plots <- paste0(folder, "/tables_and_graphs/")

if (!dir.exists(plots)) dir.create(plots, recursive = TRUE)

# ============================================================================
# 1. BRASIL COUNTRY PROFILE
# ============================================================================

brasil_profile <- function() {
  cat("\n========================================\n")
  cat("BRASIL TRADE FINANCE PROFILE\n")
  cat("========================================\n")
  
  # Load data
  brasil <- fread(paste0(data, "brasil_full.csv"))
  
  # Basic statistics
  cat("\nDataset dimensions:", nrow(brasil), "observations,", ncol(brasil), "variables\n")
  cat("Period: ", min(brasil$data_base, na.rm = TRUE), " to ", max(brasil$data_base, na.rm = TRUE), "\n")
  
  # Time series of active portfolio
  ts_cartera <- brasil %>%
    select(data_base, carteira_ativa, numero_de_operacoes, porte) %>%
    mutate(data_base = as.Date(data_base)) %>%
    group_by(data_base, porte) %>%
    summarise(
      total_portfolio = sum(carteira_ativa, na.rm = TRUE),
      num_operations = sum(numero_de_operacoes, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    arrange(data_base)
  
  cat("\n--- PORTFOLIO BY FIRM SIZE ---\n")
  print(ts_cartera %>% 
    group_by(porte) %>%
    summarise(
      avg_portfolio = mean(total_portfolio, na.rm = TRUE),
      min_portfolio = min(total_portfolio, na.rm = TRUE),
      max_portfolio = max(total_portfolio, na.rm = TRUE),
      .groups = "drop"
    ))
  
  # Sector analysis
  setor_analysis <- brasil %>%
    select(cnae_secao, carteira_ativa, numero_de_operacoes) %>%
    group_by(cnae_secao) %>%
    summarise(
      total_portfolio = sum(carteira_ativa, na.rm = TRUE),
      avg_operations = mean(numero_de_operacoes, na.rm = TRUE),
      n_records = n(),
      .groups = "drop"
    ) %>%
    arrange(desc(total_portfolio)) %>%
    slice_head(n = 10)
  
  cat("\n--- TOP 10 SECTORS (CNAE) ---\n")
  print(setor_analysis)
  
  # NPL ratio
  brasil_agg <- brasil %>%
    group_by(data_base) %>%
    summarise(
      cartera_ativa = sum(carteira_ativa, na.rm = TRUE),
      cartera_vencida = sum(vencido_acima_de_15_dias, na.rm = TRUE),
      cartera_inadimplida = sum(carteira_inadimplida_arrastada, na.rm = TRUE),
      ativo_problematico = sum(ativo_problematico, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(
      npl_ratio = cartera_inadimplida / cartera_ativa,
      data_base = as.Date(data_base)
    ) %>%
    arrange(data_base)
  
  cat("\n--- PORTFOLIO QUALITY ---\n")
  print(brasil_agg %>% 
    summarise(
      avg_portfolio = mean(cartera_ativa, na.rm = TRUE),
      avg_npl_ratio = mean(npl_ratio, na.rm = TRUE),
      max_npl_ratio = max(npl_ratio, na.rm = TRUE),
      .groups = "drop"
    ))
  
  # Plot: Time series of active portfolio
  p1 <- ggplot(ts_cartera, aes(data_base, total_portfolio / 1e6, color = porte)) +
    geom_line(linewidth = 1) +
    facet_wrap(~porte) +
    scale_y_continuous(labels = comma) +
    labs(
      title = "Brasil: TF Active Portfolio by Firm Size",
      x = "Date",
      y = "Portfolio (BRL Trillions)"
    ) +
    theme_minimal() +
    theme(legend.position = "bottom")
  
  ggsave(paste0(plots, "brasil_portfolio_by_size.png"), p1, width = 12, height = 6)
  
  # Plot: NPL ratio over time
  p2 <- ggplot(brasil_agg, aes(data_base, npl_ratio * 100)) +
    geom_line(color = "steelblue", linewidth = 1) +
    geom_smooth(method = "loess", color = "red", alpha = 0.2) +
    labs(
      title = "Brasil: Trade Finance NPL Ratio Over Time",
      x = "Date",
      y = "NPL Ratio (%)"
    ) +
    theme_minimal()
  
  ggsave(paste0(plots, "brasil_npl_ratio.png"), p2, width = 10, height = 6)
  
  cat("\n✓ Brasil profile complete. Plots saved to", plots, "\n")
  
  return(list(
    data = brasil,
    ts_cartera = ts_cartera,
    npl = brasil_agg,
    sectors = setor_analysis
  ))
}

# ============================================================================
# 2. CHILE COUNTRY PROFILE
# ============================================================================

chile_profile <- function() {
  cat("\n========================================\n")
  cat("CHILE TRADE FINANCE PROFILE\n")
  cat("========================================\n")
  
  # Load data
  chile <- fread(paste0(data, "chile_full.csv"))
  
  # Basic statistics
  cat("\nDataset dimensions:", nrow(chile), "observations,", ncol(chile), "variables\n")
  cat("Period: ", min(chile$Anho, na.rm = TRUE), " to ", max(chile$Anho, na.rm = TRUE), "\n")
  
  # Filter for trade finance specific accounts
  tf_accounts <- c("Créditos de comercio exterior",
                   "Créditos comercio exterior exportaciones chilenas",
                   "Créditos comercio exterior importaciones chilenas",
                   "Financiamientos de comercio exterior")
  
  chile_tf <- chile %>%
    filter(DescripcionCuenta %in% tf_accounts) %>%
    mutate(date = as.Date(paste0(Anho, "-", sprintf("%02d", Mes), "-01")))
  
  cat("\nFiltered to", nrow(chile_tf), "TF-specific records\n")
  
  # Time series by operation type
  ts_by_type <- chile_tf %>%
    group_by(date, DescripcionCuenta) %>%
    summarise(
      moneda_total = sum(MonedaTotal, na.rm = TRUE),
      moneda_usd = sum(MonedaExtranjera, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    arrange(date)
  
  cat("\n--- PORTFOLIO BY TF TYPE (Latest 3 months) ---\n")
  print(ts_by_type %>% 
    arrange(desc(date)) %>%
    slice_head(n = 12) %>%
    select(date, DescripcionCuenta, moneda_total, moneda_usd))
  
  # Bank concentration (CR3, CR5)
  chile_agg <- chile_tf %>%
    group_by(date, NombreInstitucion) %>%
    summarise(
      total = sum(MonedaTotal, na.rm = TRUE),
      .groups = "drop"
    )
  
  cr_analysis <- chile_agg %>%
    group_by(date) %>%
    arrange(desc(total)) %>%
    mutate(
      rank = row_number(),
      cum_share = cumsum(total) / sum(total)
    ) %>%
    filter(rank <= 5) %>%
    summarise(
      cr3 = cum_share[rank == 3],
      cr5 = cum_share[rank == 5],
      .groups = "drop"
    )
  
  cat("\n--- BANK CONCENTRATION (CR3, CR5) ---\n")
  print(cr_analysis %>% arrange(desc(date)) %>% slice_head(n = 12))
  
  # Plot: Time series by type
  p1 <- ggplot(ts_by_type, aes(date, moneda_total / 1e9, color = DescripcionCuenta)) +
    geom_line(linewidth = 1) +
    scale_y_continuous(labels = comma) +
    labs(
      title = "Chile: Trade Finance by Operation Type",
      x = "Date",
      y = "Portfolio (CLP Billions)",
      color = "Type"
    ) +
    theme_minimal() +
    theme(legend.position = "bottom", axis.text.x = element_text(angle = 45, hjust = 1))
  
  ggsave(paste0(plots, "chile_tf_by_type.png"), p1, width = 12, height = 6)
  
  # Plot: Concentration trend
  p2 <- ggplot(cr_analysis, aes(date)) +
    geom_line(aes(y = cr3 * 100, color = "CR3"), linewidth = 1) +
    geom_line(aes(y = cr5 * 100, color = "CR5"), linewidth = 1) +
    scale_y_continuous(limits = c(0, 100)) +
    labs(
      title = "Chile: Bank Concentration in Trade Finance",
      x = "Date",
      y = "Concentration Ratio (%)",
      color = "Metric"
    ) +
    theme_minimal()
  
  ggsave(paste0(plots, "chile_concentration.png"), p2, width = 10, height = 6)
  
  cat("\n✓ Chile profile complete. Plots saved to", plots, "\n")
  
  return(list(
    data = chile_tf,
    ts_by_type = ts_by_type,
    concentration = cr_analysis
  ))
}

# ============================================================================
# 3. PERÚ COUNTRY PROFILE
# ============================================================================

peru_profile <- function() {
  cat("\n========================================\n")
  cat("PERÚ TRADE FINANCE PROFILE\n")
  cat("========================================\n")
  
  # Load data
  peru <- fread(paste0(data, "peru_full.csv"))
  
  # Basic statistics
  cat("\nDataset dimensions:", nrow(peru), "observations,", ncol(peru), "variables\n")
  
  # Filter for trade finance
  peru_tf <- peru %>%
    filter(Concepto == "Comercio exterior") %>%
    mutate(date = as.Date(paste0(año, "-", sprintf("%02d", mes), "-01")))
  
  cat("Filtered to", nrow(peru_tf), "TF records\n")
  cat("Period: ", min(peru_tf$año, na.rm = TRUE), " to ", max(peru_tf$año, na.rm = TRUE), "\n")
  
  # Time series by firm size
  ts_by_size <- peru_tf %>%
    group_by(date, size) %>%
    summarise(
      total_amount = sum(amount, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    arrange(date)
  
  cat("\n--- PORTFOLIO BY FIRM SIZE ---\n")
  print(ts_by_size %>%
    group_by(size) %>%
    summarise(
      avg_amount = mean(total_amount, na.rm = TRUE),
      total_amount = sum(total_amount, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    arrange(desc(total_amount)))
  
  # Bank market share
  bank_share <- peru_tf %>%
    select(date, institucion_std, amount) %>%
    group_by(date, institucion_std) %>%
    summarise(total = sum(amount, na.rm = TRUE), .groups = "drop") %>%
    group_by(date) %>%
    arrange(desc(total)) %>%
    slice_head(n = 5)
  
  cat("\n--- TOP 5 BANKS (Latest available date) ---\n")
  latest_date <- max(bank_share$date, na.rm = TRUE)
  print(bank_share %>% filter(date == latest_date))
  
  # Plot: Time series by firm size
  p1 <- ggplot(ts_by_size, aes(date, total_amount / 1e6, color = size)) +
    geom_line(linewidth = 1) +
    facet_wrap(~size) +
    scale_y_continuous(labels = comma) +
    labs(
      title = "Perú: Trade Finance Portfolio by Firm Size",
      x = "Date",
      y = "Portfolio (PEN Millions)"
    ) +
    theme_minimal() +
    theme(legend.position = "bottom")
  
  ggsave(paste0(plots, "peru_portfolio_by_size.png"), p1, width = 12, height = 6)
  
  # Plot: Top banks market share
  top_banks_latest <- bank_share %>%
    filter(date == latest_date) %>%
    arrange(desc(total))
  
  p2 <- ggplot(top_banks_latest, aes(reorder(institucion_std, total), total / 1e6)) +
    geom_col(fill = "steelblue") +
    coord_flip() +
    labs(
      title = paste0("Perú: Top Banks in TF (", format(latest_date, "%Y-%m"), ")"),
      x = "Bank",
      y = "Portfolio (PEN Millions)"
    ) +
    theme_minimal()
  
  ggsave(paste0(plots, "peru_top_banks.png"), p2, width = 10, height = 6)
  
  cat("\n✓ Perú profile complete. Plots saved to", plots, "\n")
  
  return(list(
    data = peru_tf,
    ts_by_size = ts_by_size,
    bank_share = bank_share
  ))
}

# ============================================================================
# 4. MÉXICO COUNTRY PROFILE
# ============================================================================

mexico_profile <- function() {
  cat("\n========================================\n")
  cat("MÉXICO TRADE FINANCE PROFILE\n")
  cat("========================================\n")
  
  # Load data
  mexico <- fread(paste0(data, "mexico_full.csv"))
  
  # Basic statistics
  cat("\nDataset dimensions:", nrow(mexico), "observations,", ncol(mexico), "variables\n")
  
  if (nrow(mexico) == 0) {
    cat("WARNING: Mexico dataset is empty or contains no records\n")
    return(NULL)
  }
  
  cat("Columns available:", paste(colnames(mexico), collapse = ", "), "\n")
  
  # Basic summary
  if (!"date" %in% colnames(mexico)) {
    cat("\nNo standardized date column found. Summary of available data:\n")
    print(head(mexico, 5))
  } else {
    cat("Period:", min(mexico$date, na.rm = TRUE), "to", max(mexico$date, na.rm = TRUE), "\n")
  }
  
  # Create summary table
  summary_table <- mexico %>%
    select_if(is.numeric) %>%
    summarise(across(everything(), list(mean = mean, max = max, min = min), na.rm = TRUE))
  
  cat("\n--- DESCRIPTIVE STATISTICS ---\n")
  print(summary_table)
  
  cat("\n✓ México profile complete (limited data)\n")
  
  return(list(data = mexico))
}

# ============================================================================
# EXECUTE ALL PROFILES
# ============================================================================

brasil <- brasil_profile()
chile <- chile_profile()
peru <- peru_profile()
mexico <- mexico_profile()

cat("\n\n========================================\n")
cat("ALL COUNTRY PROFILES COMPLETED\n")
cat("========================================\n")
cat("Results saved to:", plots, "\n")
