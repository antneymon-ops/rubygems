# AI Insights Platform — Product Vision

## Executive Summary

AI Insights is a **multi-tenant SaaS** that lets teams upload unstructured documents
(PDFs, audio transcripts, web URLs) and ask natural-language questions against them —
powered by Google's Gemini / Vertex AI stack and inspired by Google NotebookLM.

The platform is designed to generate significant, recurring revenue by serving three
distinct customer segments: individual knowledge workers, growing teams, and
enterprise organizations with compliance requirements.

---

## Problem Statement

Knowledge is locked in scattered documents, recordings, and URLs.  Teams waste hours
searching, re-summarizing, and cross-referencing sources.  Existing tools either:

- require full LLM expertise to self-host, or
- offer only consumer-grade, single-user experiences with no governance.

**AI Insights fills the gap**: an enterprise-grade, team-centric knowledge platform
with transparent pricing and data-ownership guarantees.

---

## Target Customers

| Segment | Profile | Key Pain |
|---------|---------|----------|
| **Individual Pro** | Researcher, analyst, consultant | Too many documents, not enough time |
| **Team** | Product/engineering/legal team (5–50 users) | Siloed knowledge, onboarding drag |
| **Enterprise** | 50+ seat orgs with compliance needs | Audit trails, SSO, data residency |

---

## Differentiators

1. **NotebookLM-style source citations** — every answer links back to the exact
   passage in the source document.
2. **Multi-source fusion** — query across dozens of documents simultaneously.
3. **Multilingual** — query in any language supported by Gemini.
4. **Enterprise-ready from day one** — RBAC, audit logs, SSO (SAML/OIDC), data
   retention controls, and SOC 2 roadmap.
5. **Provider-agnostic adapter** — swap Gemini for OpenAI, Anthropic, or a private
   model without changing application code.
6. **Ruby-native** — ships as a self-contained service alongside the existing
   RubyGems ecosystem, lowering adoption friction.

---

## Monetization Model

### Tier Overview

| Plan | Price | Included | Overage |
|------|-------|----------|---------|
| **Free** | $0/mo | 3 notebooks, 50 MB storage, 100 queries/mo | — |
| **Pro** | $29/user/mo | Unlimited notebooks, 5 GB, 2,000 queries/mo | $0.02/query |
| **Team** | $79/seat/mo (min 5) | All Pro + RBAC, shared workspaces, priority support | $0.015/query |
| **Enterprise** | Custom | All Team + SSO, audit logs, data residency, SLA | Negotiated |

### Usage-Based Add-ons

- **Storage expansion**: $5 / 10 GB / mo
- **Query packs**: $10 / 1,000 queries
- **API access**: included from Team; metered per token for Pro

### Revenue Levers

- Annual billing discount (20%) → improves cash flow and reduces churn
- Per-seat expansion via user invites (viral growth loop)
- Enterprise land-and-expand: start with one team, grow org-wide
- Partner/OEM licensing for embedding AI Insights into third-party portals

---

## Key Metrics

| Metric | Description | Target (12 mo) |
|--------|-------------|----------------|
| MRR | Monthly Recurring Revenue | $50K |
| ARR | Annual Recurring Revenue | $600K |
| Paid users | Total paying seats | 1,000 |
| NPS | Net Promoter Score | ≥ 45 |
| Query success rate | Answers rated useful | ≥ 85 % |
| p95 query latency | Time-to-first-token | ≤ 3 s |
| Churn (monthly) | Seat cancellations | ≤ 2 % |
| CAC payback | Months to recover acquisition cost | ≤ 6 mo |

---

## Success Milestones

- **Month 1**: 100 free users, 10 paid conversions, $1K MRR
- **Month 3**: 500 free, 75 paid, $10K MRR, first enterprise pilot
- **Month 6**: 2,000 free, 300 paid, $30K MRR, SOC 2 Type I initiated
- **Month 12**: $50K MRR, first enterprise contract ($50K+ ACV)
