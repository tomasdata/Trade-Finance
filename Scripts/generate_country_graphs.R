# Generate Country Profile Graphs and Tables
# Author: Trade Finance Research Team
# Date: 2025-11-11
# Purpose: Create all visualizations and data tables for country profiles

library(tidyverse)
library(data.table)
library(scales)
library(viridis)
library(lubridate)

# Setup directories
base_dir <- "/Users/tomasfernandez/Documents/Tomas/Trade-Finance"
data_dir <- file.path(base_dir, "data")
out_dir <- file.path(base_dir, "tables_and_graphs")

# Helper function to save plot and data
save_plot_and_data <- function(plot_obj, data_obj, country, filename_base, width = 10, height = 6) {
  country_dir <- file.path(out_dir, country)

  # Save plot
  ggsave(
    filename = file.path(country_dir, paste0(filename_base, ".png")),
    plot = plot_obj,
    width = width,
    height = height,
    dpi = 300
  )

  # Save data
  fwrite(data_obj, file.path(country_dir, paste0(filename_base, "_data.csv")))

  cat("✓ Saved:", country, "-", filename_base, "\n")
}

# ============================================================================
# BRAZIL
# ============================================================================
cat("\n=== BRAZIL ===\n")

# Load Brazil data
brasil <- fread(file.path(data_dir, "brasil_full.csv"))

# 1. TF by Firm Size
cat("1. TF by Firm Size...\n")
tf_size <- brasil %>%
  group_by(porte) %>%
  summarise(
    records = n(),
    carteira_ativa_total = sum(carteira_ativa, na.rm = TRUE) / 1e6,  # Convert to billions
    .groups = "drop"
  ) %>%
  mutate(
    pct_records = records / sum(records) * 100,
    pct_carteira = carteira_ativa_total / sum(carteira_ativa_total) * 100
  ) %>%
  arrange(desc(carteira_ativa_total))

p1 <- ggplot(tf_size, aes(x = reorder(porte, carteira_ativa_total), y = carteira_ativa_total)) +
  geom_col(fill = "#2B8CBE") +
  geom_text(aes(label = paste0(round(pct_carteira, 1), "%")),
            hjust = -0.1, size = 3.5) +
  coord_flip() +
  scale_y_continuous(labels = comma, expand = expansion(mult = c(0, 0.15))) +
  labs(
    title = "Brazil: Trade Finance Portfolio by Firm Size",
    subtitle = "Active portfolio in billions of BRL (2012-2024)",
    x = NULL,
    y = "Active Portfolio (BRL billions)"
  ) +
  theme_minimal(base_size = 12)

save_plot_and_data(p1, tf_size, "Brazil", "01_tf_by_firm_size")

# 2. TF by Sector (Top 10)
cat("2. TF by Sector...\n")
tf_sector <- brasil %>%
  group_by(cnae_secao) %>%
  summarise(
    records = n(),
    carteira_ativa_total = sum(carteira_ativa, na.rm = TRUE) / 1e6,
    .groups = "drop"
  ) %>%
  arrange(desc(carteira_ativa_total)) %>%
  head(10)

p2 <- ggplot(tf_sector, aes(x = reorder(cnae_secao, carteira_ativa_total), y = carteira_ativa_total)) +
  geom_col(fill = "#31A354") +
  coord_flip() +
  scale_y_continuous(labels = comma) +
  labs(
    title = "Brazil: Trade Finance by Economic Sector (Top 10)",
    subtitle = "Active portfolio in billions of BRL (2012-2024)",
    x = NULL,
    y = "Active Portfolio (BRL billions)"
  ) +
  theme_minimal(base_size = 12) +
  theme(axis.text.y = element_text(size = 9))

save_plot_and_data(p2, tf_sector, "Brazil", "02_tf_by_sector")

# 3. TF by State (Top 10)
cat("3. TF by State...\n")
tf_state <- brasil %>%
  group_by(uf) %>%
  summarise(
    records = n(),
    carteira_ativa_total = sum(carteira_ativa, na.rm = TRUE) / 1e6,
    .groups = "drop"
  ) %>%
  arrange(desc(carteira_ativa_total)) %>%
  head(10)

p3 <- ggplot(tf_state, aes(x = reorder(uf, carteira_ativa_total), y = carteira_ativa_total)) +
  geom_col(fill = "#756BB1") +
  geom_text(aes(label = comma(round(carteira_ativa_total, 0))),
            hjust = -0.1, size = 3) +
  coord_flip() +
  scale_y_continuous(labels = comma, expand = expansion(mult = c(0, 0.15))) +
  labs(
    title = "Brazil: Trade Finance by State (Top 10)",
    subtitle = "Active portfolio in billions of BRL (2012-2024)",
    x = "State (UF)",
    y = "Active Portfolio (BRL billions)"
  ) +
  theme_minimal(base_size = 12)

save_plot_and_data(p3, tf_state, "Brazil", "03_tf_by_state")

# 4. Maturity Structure
cat("4. Maturity Structure...\n")
maturity_data <- brasil %>%
  summarise(
    `0-90 days` = sum(a_vencer_ate_90_dias, na.rm = TRUE) / 1e9,
    `91-360 days` = sum(a_vencer_de_91_ate_360_dias, na.rm = TRUE) / 1e9,
    `361-1080 days` = sum(a_vencer_de_361_ate_1080_dias, na.rm = TRUE) / 1e9,
    `1081-1800 days` = sum(a_vencer_de_1081_ate_1800_dias, na.rm = TRUE) / 1e9,
    `1801-5400 days` = sum(a_vencer_de_1801_ate_5400_dias, na.rm = TRUE) / 1e9,
    `>5400 days` = sum(a_vencer_acima_de_5400_dias, na.rm = TRUE) / 1e9
  ) %>%
  pivot_longer(everything(), names_to = "maturity_bucket", values_to = "amount") %>%
  mutate(
    pct = amount / sum(amount) * 100,
    maturity_bucket = factor(maturity_bucket, levels = c("0-90 days", "91-360 days",
                                                          "361-1080 days", "1081-1800 days",
                                                          "1801-5400 days", ">5400 days"))
  )

p4 <- ggplot(maturity_data, aes(x = maturity_bucket, y = amount)) +
  geom_col(fill = "#E67E22") +
  geom_text(aes(label = paste0(round(pct, 1), "%")), vjust = -0.5, size = 3.5) +
  scale_y_continuous(labels = comma, expand = expansion(mult = c(0, 0.12))) +
  labs(
    title = "Brazil: Trade Finance Maturity Structure",
    subtitle = "Portfolio by maturity bucket in trillions of BRL (2012-2024)",
    x = "Maturity Bucket",
    y = "Amount (BRL trillions)"
  ) +
  theme_minimal(base_size = 12) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

save_plot_and_data(p4, maturity_data, "Brazil", "04_maturity_structure")

# 5. Temporal Evolution
cat("5. Temporal Evolution...\n")
temporal <- brasil %>%
  mutate(year_month = as.Date(data_base)) %>%
  group_by(year_month) %>%
  summarise(
    carteira_ativa = sum(carteira_ativa, na.rm = TRUE) / 1e9,
    numero_operacoes = sum(numero_de_operacoes, na.rm = TRUE),
    .groups = "drop"
  )

p5 <- ggplot(temporal, aes(x = year_month, y = carteira_ativa)) +
  geom_line(color = "#2B8CBE", size = 1) +
  geom_smooth(method = "loess", se = TRUE, color = "#E74C3C", linetype = "dashed") +
  scale_y_continuous(labels = comma) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  labs(
    title = "Brazil: Trade Finance Portfolio Evolution",
    subtitle = "Monthly active portfolio in trillions of BRL (2012-2024)",
    x = NULL,
    y = "Active Portfolio (BRL trillions)"
  ) +
  theme_minimal(base_size = 12) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

save_plot_and_data(p5, temporal, "Brazil", "05_temporal_evolution")

# 6. NPL Analysis
cat("6. NPL Analysis...\n")
npl_data <- brasil %>%
  summarise(
    carteira_ativa = sum(carteira_ativa, na.rm = TRUE) / 1e6,
    vencido_15_dias = sum(vencido_acima_de_15_dias, na.rm = TRUE) / 1e6,
    inadimplida = sum(carteira_inadimplida_arrastada, na.rm = TRUE) / 1e6,
    problematico = sum(ativo_problematico, na.rm = TRUE) / 1e6
  ) %>%
  mutate(
    npl_ratio_15d = vencido_15_dias / carteira_ativa * 100,
    npl_ratio_inadim = inadimplida / carteira_ativa * 100,
    problem_ratio = problematico / carteira_ativa * 100
  ) %>%
  select(npl_ratio_15d, npl_ratio_inadim, problem_ratio) %>%
  pivot_longer(everything(), names_to = "indicator", values_to = "ratio")

p6 <- ggplot(npl_data, aes(x = indicator, y = ratio)) +
  geom_col(fill = "#E74C3C") +
  geom_text(aes(label = paste0(round(ratio, 2), "%")), vjust = -0.5, size = 4) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
  labs(
    title = "Brazil: Credit Quality Indicators",
    subtitle = "NPL ratios as % of active portfolio (2012-2024)",
    x = NULL,
    y = "Ratio (%)"
  ) +
  scale_x_discrete(labels = c("NPL >15 days", "Rolled-over NPL", "Problem Assets")) +
  theme_minimal(base_size = 12)

save_plot_and_data(p6, npl_data, "Brazil", "06_npl_analysis")

# ============================================================================
# CHILE
# ============================================================================
cat("\n=== CHILE ===\n")

# Load Chile data
chile <- fread(file.path(data_dir, "chile_full.csv"))

# 1. TF by Operation Type
cat("1. TF by Operation Type...\n")
tf_operations <- chile %>%
  filter(grepl("comercio exterior|export|import", DescripcionCuenta, ignore.case = TRUE)) %>%
  mutate(
    operation_type = case_when(
      grepl("export.*chilena", DescripcionCuenta, ignore.case = TRUE) ~ "Chilean Exports",
      grepl("import.*chilena", DescripcionCuenta, ignore.case = TRUE) ~ "Chilean Imports",
      grepl("terceros", DescripcionCuenta, ignore.case = TRUE) ~ "Third-Country Trade",
      grepl("comercio exterior", DescripcionCuenta, ignore.case = TRUE) ~ "General Foreign Trade",
      TRUE ~ "Other TF"
    )
  ) %>%
  group_by(operation_type) %>%
  summarise(
    amount_clp = sum(MonedaTotal, na.rm = TRUE) / 1e12,  # Trillions CLP
    amount_fx = sum(MonedaExtranjera, na.rm = TRUE) / 1e12,
    .groups = "drop"
  ) %>%
  arrange(desc(amount_clp))

p7 <- ggplot(tf_operations, aes(x = reorder(operation_type, amount_clp), y = amount_clp)) +
  geom_col(fill = "#D35400") +
  coord_flip() +
  scale_y_continuous(labels = comma) +
  labs(
    title = "Chile: Trade Finance by Operation Type",
    subtitle = "Total amount in trillions of CLP (2015-2024)",
    x = NULL,
    y = "Amount (CLP trillions)"
  ) +
  theme_minimal(base_size = 12)

save_plot_and_data(p7, tf_operations, "Chile", "01_tf_by_operation")

# 2. Bank Concentration (Top 10)
cat("2. Bank Concentration...\n")
bank_concentration <- chile %>%
  filter(MonedaExtranjera > 0) %>%
  group_by(NombreInstitucion) %>%
  summarise(
    amount_fx = sum(MonedaExtranjera, na.rm = TRUE) / 1e12,
    .groups = "drop"
  ) %>%
  arrange(desc(amount_fx)) %>%
  head(10) %>%
  mutate(
    market_share = amount_fx / sum(amount_fx) * 100,
    cumulative_share = cumsum(market_share)
  )

p8 <- ggplot(bank_concentration, aes(x = reorder(NombreInstitucion, amount_fx), y = amount_fx)) +
  geom_col(fill = "#16A085") +
  geom_text(aes(label = paste0(round(market_share, 1), "%")),
            hjust = -0.1, size = 3) +
  coord_flip() +
  scale_y_continuous(labels = comma, expand = expansion(mult = c(0, 0.15))) +
  labs(
    title = "Chile: Top 10 Banks by Foreign Currency TF",
    subtitle = "Total foreign currency in trillions of CLP (2015-2024)",
    x = NULL,
    y = "Foreign Currency TF (CLP trillions)"
  ) +
  theme_minimal(base_size = 12) +
  theme(axis.text.y = element_text(size = 9))

save_plot_and_data(p8, bank_concentration, "Chile", "02_bank_concentration")

# 3. Currency Composition
cat("3. Currency Composition...\n")
currency_comp <- chile %>%
  summarise(
    `Chilean Peso` = sum(MonedaChilenaNoReajustable, na.rm = TRUE) / 1e15,
    `Foreign Currency` = sum(MonedaExtranjera, na.rm = TRUE) / 1e15,
    `IPC-indexed` = sum(MonedaReajustable, na.rm = TRUE) / 1e15
  ) %>%
  pivot_longer(everything(), names_to = "currency_type", values_to = "amount") %>%
  mutate(pct = amount / sum(amount) * 100)

p9 <- ggplot(currency_comp, aes(x = "", y = pct, fill = currency_type)) +
  geom_col(width = 1) +
  coord_polar("y", start = 0) +
  geom_text(aes(label = paste0(round(pct, 1), "%")),
            position = position_stack(vjust = 0.5), size = 4) +
  scale_fill_brewer(palette = "Set2") +
  labs(
    title = "Chile: Trade Finance Currency Composition",
    subtitle = "Distribution by currency type (2015-2024)",
    fill = "Currency Type"
  ) +
  theme_void() +
  theme(legend.position = "bottom")

save_plot_and_data(p9, currency_comp, "Chile", "03_currency_composition")

# 4. Temporal Evolution
cat("4. Temporal Evolution...\n")
chile_temporal <- chile %>%
  mutate(year_month = ymd(paste(Anho, Mes, "01", sep = "-"))) %>%
  filter(grepl("comercio exterior", DescripcionCuenta, ignore.case = TRUE)) %>%
  group_by(year_month) %>%
  summarise(
    amount_total = sum(MonedaTotal, na.rm = TRUE) / 1e12,
    amount_fx = sum(MonedaExtranjera, na.rm = TRUE) / 1e12,
    .groups = "drop"
  )

p10 <- ggplot(chile_temporal, aes(x = year_month)) +
  geom_line(aes(y = amount_total, color = "Total"), size = 1) +
  geom_line(aes(y = amount_fx, color = "Foreign Currency"), size = 1) +
  scale_color_manual(values = c("Total" = "#2C3E50", "Foreign Currency" = "#E67E22")) +
  scale_y_continuous(labels = comma) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  labs(
    title = "Chile: Trade Finance Evolution",
    subtitle = "Monthly TF portfolio in trillions of CLP (2015-2024)",
    x = NULL,
    y = "Amount (CLP trillions)",
    color = "Currency"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "bottom"
  )

save_plot_and_data(p10, chile_temporal, "Chile", "04_temporal_evolution")

# ============================================================================
# PERU
# ============================================================================
cat("\n=== PERU ===\n")

# Load Peru data
peru <- fread(file.path(data_dir, "peru_full.csv"))

# 1. TF by Firm Size
cat("1. TF by Firm Size...\n")
peru_size <- peru %>%
  filter(Concepto == "Comercio exterior") %>%
  group_by(size) %>%
  summarise(
    amount_pen = sum(amount_pen, na.rm = TRUE) / 1e6,  # Millions
    amount_usd = sum(amount_usd, na.rm = TRUE) / 1e6,
    .groups = "drop"
  ) %>%
  arrange(desc(amount_pen)) %>%
  mutate(
    pct = amount_pen / sum(amount_pen) * 100,
    size = factor(size, levels = c("Corporate", "Large", "Medium", "Small", "Micro"))
  )

p11 <- ggplot(peru_size, aes(x = size, y = amount_pen)) +
  geom_col(fill = "#C0392B") +
  geom_text(aes(label = paste0(round(pct, 1), "%")), vjust = -0.5, size = 4) +
  scale_y_continuous(labels = comma, expand = expansion(mult = c(0, 0.15))) +
  labs(
    title = "Peru: Trade Finance by Firm Size",
    subtitle = "Amount in millions of PEN (2010-2024)",
    x = "Firm Size",
    y = "Amount (PEN millions)"
  ) +
  theme_minimal(base_size = 12)

save_plot_and_data(p11, peru_size, "Peru", "01_tf_by_firm_size")

# 2. Credit Type Distribution
cat("2. Credit Type Distribution...\n")
peru_credit_type <- peru %>%
  group_by(Concepto) %>%
  summarise(
    amount_pen = sum(amount_pen, na.rm = TRUE) / 1e6,
    .groups = "drop"
  ) %>%
  arrange(desc(amount_pen)) %>%
  mutate(pct = amount_pen / sum(amount_pen) * 100)

p12 <- ggplot(peru_credit_type, aes(x = reorder(Concepto, amount_pen), y = amount_pen)) +
  geom_col(fill = "#8E44AD") +
  geom_text(aes(label = paste0(round(pct, 1), "%")), hjust = -0.1, size = 3) +
  coord_flip() +
  scale_y_continuous(labels = comma, expand = expansion(mult = c(0, 0.15))) +
  labs(
    title = "Peru: Commercial Credit Portfolio by Type",
    subtitle = "Amount in millions of PEN (2010-2024)",
    x = NULL,
    y = "Amount (PEN millions)"
  ) +
  theme_minimal(base_size = 12) +
  theme(axis.text.y = element_text(size = 9))

save_plot_and_data(p12, peru_credit_type, "Peru", "02_credit_type_distribution")

# 3. Bank Concentration
cat("3. Bank Concentration...\n")
peru_banks <- peru %>%
  filter(Concepto == "Comercio exterior") %>%
  group_by(institucion_std) %>%
  summarise(
    amount_pen = sum(amount_pen, na.rm = TRUE) / 1e6,
    .groups = "drop"
  ) %>%
  arrange(desc(amount_pen)) %>%
  head(10) %>%
  mutate(
    market_share = amount_pen / sum(amount_pen) * 100,
    cumulative = cumsum(market_share)
  )

p13 <- ggplot(peru_banks, aes(x = reorder(institucion_std, amount_pen), y = amount_pen)) +
  geom_col(fill = "#27AE60") +
  geom_text(aes(label = paste0(round(market_share, 1), "%")), hjust = -0.1, size = 3) +
  coord_flip() +
  scale_y_continuous(labels = comma, expand = expansion(mult = c(0, 0.15))) +
  labs(
    title = "Peru: Top 10 Banks in Trade Finance",
    subtitle = "TF amount in millions of PEN (2010-2024)",
    x = NULL,
    y = "TF Amount (PEN millions)"
  ) +
  theme_minimal(base_size = 12)

save_plot_and_data(p13, peru_banks, "Peru", "03_bank_concentration")

# 4. Temporal Evolution
cat("4. Temporal Evolution...\n")
peru_temporal <- peru %>%
  filter(Concepto == "Comercio exterior") %>%
  mutate(year_month = as.Date(year_month)) %>%
  group_by(year_month) %>%
  summarise(
    amount_pen = sum(amount_pen, na.rm = TRUE) / 1e6,
    amount_usd = sum(amount_usd, na.rm = TRUE) / 1e6,
    .groups = "drop"
  )

p14 <- ggplot(peru_temporal, aes(x = year_month, y = amount_usd)) +
  geom_line(color = "#E74C3C", size = 1) +
  geom_smooth(method = "loess", se = TRUE, color = "#3498DB", linetype = "dashed") +
  scale_y_continuous(labels = comma) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  labs(
    title = "Peru: Trade Finance Evolution",
    subtitle = "Monthly TF portfolio in millions of USD (2010-2024)",
    x = NULL,
    y = "Amount (USD millions)"
  ) +
  theme_minimal(base_size = 12) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

save_plot_and_data(p14, peru_temporal, "Peru", "04_temporal_evolution")

# 5. TF Penetration by Firm Size
cat("5. TF Penetration by Size...\n")
peru_penetration <- peru %>%
  group_by(size) %>%
  summarise(
    total_credit = sum(total_pen, na.rm = TRUE) / 1e6,
    tf_amount = sum(ifelse(Concepto == "Comercio exterior", amount_pen, 0), na.rm = TRUE) / 1e6,
    .groups = "drop"
  ) %>%
  mutate(
    tf_penetration = tf_amount / total_credit * 100,
    size = factor(size, levels = c("Corporate", "Large", "Medium", "Small", "Micro"))
  ) %>%
  filter(!is.na(size))

p15 <- ggplot(peru_penetration, aes(x = size, y = tf_penetration)) +
  geom_col(fill = "#F39C12") +
  geom_text(aes(label = paste0(round(tf_penetration, 2), "%")), vjust = -0.5, size = 4) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
  labs(
    title = "Peru: TF Penetration by Firm Size",
    subtitle = "Trade Finance as % of total credit portfolio (2010-2024)",
    x = "Firm Size",
    y = "TF Penetration (%)"
  ) +
  theme_minimal(base_size = 12)

save_plot_and_data(p15, peru_penetration, "Peru", "05_tf_penetration")

# ============================================================================
# MEXICO
# ============================================================================
cat("\n=== MEXICO ===\n")

# Load Mexico data
mexico <- fread(file.path(data_dir, "mexico_full.csv"))

# 1. LC Evolution
cat("1. LC Evolution...\n")
mexico_temporal <- mexico %>%
  mutate(year_month = as.Date(year_month)) %>%
  group_by(year_month) %>%
  summarise(
    lc_usd = sum(amount_usd_thousands, na.rm = TRUE) / 1e3,  # Millions
    .groups = "drop"
  )

p16 <- ggplot(mexico_temporal, aes(x = year_month, y = lc_usd)) +
  geom_line(color = "#16A085", size = 1.2) +
  geom_smooth(method = "loess", se = TRUE, color = "#E74C3C", linetype = "dashed") +
  scale_y_continuous(labels = comma) +
  scale_x_date(date_breaks = "6 months", date_labels = "%b %Y") +
  labs(
    title = "Mexico: Letters of Credit Evolution",
    subtitle = "Monthly LC portfolio in millions of USD (2022-2025)",
    x = NULL,
    y = "LC Amount (USD millions)"
  ) +
  theme_minimal(base_size = 12) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

save_plot_and_data(p16, mexico_temporal, "Mexico", "01_lc_evolution")

# 2. Bank Concentration
cat("2. Bank Concentration...\n")
mexico_banks <- mexico %>%
  group_by(institucion) %>%
  summarise(
    lc_usd = sum(amount_usd_thousands, na.rm = TRUE) / 1e3,
    .groups = "drop"
  ) %>%
  arrange(desc(lc_usd)) %>%
  head(10) %>%
  mutate(
    market_share = lc_usd / sum(lc_usd) * 100,
    cumulative = cumsum(market_share)
  )

p17 <- ggplot(mexico_banks, aes(x = reorder(institucion, lc_usd), y = lc_usd)) +
  geom_col(fill = "#C0392B") +
  geom_text(aes(label = paste0(round(market_share, 1), "%")), hjust = -0.1, size = 3) +
  coord_flip() +
  scale_y_continuous(labels = comma, expand = expansion(mult = c(0, 0.15))) +
  labs(
    title = "Mexico: Top 10 Banks by Letters of Credit",
    subtitle = "Total LC in millions of USD (2022-2025)",
    x = NULL,
    y = "LC Amount (USD millions)"
  ) +
  theme_minimal(base_size = 12)

save_plot_and_data(p17, mexico_banks, "Mexico", "02_bank_concentration")

# 3. Annual LC Volume
cat("3. Annual LC Volume...\n")
mexico_annual <- mexico %>%
  group_by(year) %>%
  summarise(
    lc_usd = sum(amount_usd_thousands, na.rm = TRUE) / 1e6,  # Billions
    .groups = "drop"
  ) %>%
  mutate(yoy_growth = (lc_usd / lag(lc_usd) - 1) * 100)

p18 <- ggplot(mexico_annual, aes(x = factor(year), y = lc_usd)) +
  geom_col(fill = "#3498DB") +
  geom_text(aes(label = paste0("$", round(lc_usd, 2), "B")), vjust = -0.5, size = 4) +
  scale_y_continuous(labels = comma, expand = expansion(mult = c(0, 0.15))) +
  labs(
    title = "Mexico: Annual Letters of Credit Volume",
    subtitle = "Total LC in billions of USD (2022-2025*)",
    caption = "*2025 includes only Jan-Aug",
    x = "Year",
    y = "LC Volume (USD billions)"
  ) +
  theme_minimal(base_size = 12)

save_plot_and_data(p18, mexico_annual, "Mexico", "03_annual_lc_volume")

# 4. LC Seasonality
cat("4. LC Seasonality...\n")
mexico_seasonality <- mexico %>%
  group_by(month) %>%
  summarise(
    avg_lc_usd = mean(amount_usd_thousands, na.rm = TRUE) / 1e3,
    .groups = "drop"
  ) %>%
  mutate(
    month = factor(month, levels = 1:12, labels = month.abb),
    index = avg_lc_usd / mean(avg_lc_usd) * 100
  )

p19 <- ggplot(mexico_seasonality, aes(x = month, y = index, group = 1)) +
  geom_line(color = "#E67E22", size = 1.2) +
  geom_point(color = "#E67E22", size = 3) +
  geom_hline(yintercept = 100, linetype = "dashed", color = "gray50") +
  scale_y_continuous(expand = expansion(mult = c(0.05, 0.05))) +
  labs(
    title = "Mexico: Letters of Credit Seasonality",
    subtitle = "Monthly LC index (Average = 100)",
    x = "Month",
    y = "Seasonality Index"
  ) +
  theme_minimal(base_size = 12)

save_plot_and_data(p19, mexico_seasonality, "Mexico", "04_lc_seasonality")

# 5. Market Concentration (Lorenz Curve)
cat("5. Market Concentration...\n")
mexico_lorenz <- mexico %>%
  group_by(institucion) %>%
  summarise(lc_usd = sum(amount_usd_thousands, na.rm = TRUE), .groups = "drop") %>%
  arrange(lc_usd) %>%
  mutate(
    cum_banks = row_number() / n() * 100,
    cum_lc = cumsum(lc_usd) / sum(lc_usd) * 100
  )

p20 <- ggplot(mexico_lorenz, aes(x = cum_banks, y = cum_lc)) +
  geom_line(color = "#8E44AD", size = 1.2) +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "gray50") +
  labs(
    title = "Mexico: LC Market Concentration (Lorenz Curve)",
    subtitle = "Cumulative LC share vs. cumulative bank share (2022-2025)",
    x = "Cumulative % of Banks",
    y = "Cumulative % of LC Volume"
  ) +
  theme_minimal(base_size = 12)

save_plot_and_data(p20, mexico_lorenz, "Mexico", "05_market_concentration")

# ============================================================================
# Summary
# ============================================================================
cat("\n=== GENERATION COMPLETE ===\n")
cat("Total graphs generated: 20\n")
cat("Total CSV files generated: 20\n")
cat("\nFiles saved in:\n")
cat("  - Brazil: ", file.path(out_dir, "Brazil"), "\n")
cat("  - Chile:  ", file.path(out_dir, "Chile"), "\n")
cat("  - Peru:   ", file.path(out_dir, "Peru"), "\n")
cat("  - Mexico: ", file.path(out_dir, "Mexico"), "\n")
