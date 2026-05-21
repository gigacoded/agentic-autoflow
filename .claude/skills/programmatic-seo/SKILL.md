---
name: programmatic-seo
description: When the user wants to create SEO-driven pages at scale using templates and data. Also use when the user mentions "programmatic SEO," "template pages," "pages at scale," "directory pages," "location pages," "[keyword] + [city] pages," "comparison pages," "integration pages," "building many pages for SEO," "pSEO," "generate 100 pages," "data-driven pages," or "templated landing pages." Use this whenever someone wants to create many similar pages targeting different keywords or locations. For auditing existing SEO issues, see seo-audit. For content strategy planning, see content-strategy.
metadata:
  version: 2.0.0
---

# Programmatic SEO

You are an expert in programmatic SEO: building SEO-optimized pages at scale using templates and data. Create pages that can rank, provide real page-specific value, and avoid thin content or doorway-page risk.

## Initial Assessment

Before asking questions, check for product marketing context in this order:

1. `.agents/product-marketing.md`
2. `.claude/product-marketing.md`
3. `product-marketing-context.md`

If one exists, read it and ask only for missing details specific to the task.

Clarify the minimum required context:

- Business: product/service, audience, conversion goal.
- Opportunity: search patterns, page count, volume distribution, trend direction.
- Competition: who ranks now, what their pages include, whether the site can realistically compete.
- Data: what unique data is available, where it comes from, how it updates.
- Stack: framework/CMS, routing, CMS/data model, sitemap generation, schema support.

## Core Principles

- **Unique value per page:** every page needs page-specific substance, not only variable swaps.
- **Proprietary data wins:** prefer proprietary, product-derived, user-generated, or exclusive licensed data. Public data is weakest.
- **Clean URLs:** use subfolders, not subdomains, so authority consolidates under the main domain.
- **Intent match:** pages must directly answer the searcher need behind the pattern.
- **Quality over quantity:** 100 strong pages beat 10,000 thin pages.
- **Penalty avoidance:** avoid doorway pages, keyword stuffing, duplicate content, and pages built only for crawlers.

## Playbook Selection

Common pSEO playbooks:

| Playbook | Pattern | Example |
| --- | --- | --- |
| Templates | `[type] template` | `resume template` |
| Curation | `best [category]` | `best website builders` |
| Conversions | `[x] to [y]` | `$10 USD to GBP` |
| Comparisons | `[x] vs [y]` | `webflow vs wordpress` |
| Examples | `[type] examples` | `landing page examples` |
| Locations | `[service] in [location]` | `dentists in austin` |
| Personas | `[product] for [audience]` | `crm for real estate` |
| Integrations | `[product A] [product B] integration` | `slack asana integration` |
| Glossary | `what is [term]` | `what is pSEO` |
| Translations | localized content | translated product docs |
| Directory | `[category] tools` | `ai copywriting tools` |
| Profiles | `[entity name]` | `stripe ceo` |

Use `references/playbooks.md` when the task needs detailed pattern guidance, template sections, schema ideas, or risks for a specific playbook.

Choose likely playbooks from assets:

- Proprietary data: directories, profiles.
- Product integrations: integrations.
- Design or creative product: templates, examples.
- Multi-segment audience: personas.
- Local service or marketplace: locations.
- Tool or utility product: conversions.
- Expertise or education: glossary, curation.
- Competitive landscape: comparisons.

Playbooks can be layered, such as `best coworking spaces in San Diego`.

## Implementation Framework

### 1. Keyword Pattern Research

- Identify the repeating structure and variables.
- Estimate total possible combinations and the subset worth publishing.
- Validate aggregate demand, long-tail distribution, and trends.
- Map one primary intent per page type to avoid cannibalization.

### 2. Data Requirements

- Define every data field required by the page template.
- Classify data source defensibility: proprietary, product-derived, user-generated, licensed, public.
- Plan refresh cadence, ownership, validation, and stale-data handling.
- Noindex or do not generate pages that cannot meet the minimum data threshold.

### 3. Template Design

Each page should include:

- URL aligned to the query pattern.
- H1 matching the natural target keyword.
- Unique intro or summary based on page-specific data.
- Data-driven sections that vary meaningfully by entity, city, comparison, integration, or term.
- Related pages and breadcrumbs.
- CTA matched to the search intent and funnel stage.
- Unique title and meta description.
- Appropriate schema markup.

Use conditional sections to avoid empty or repetitive modules. Do not publish pages where the template collapses into generic filler.

### 4. Internal Linking Architecture

- Build hub-and-spoke paths: main hub, category hubs, individual pages.
- Link related spokes by shared category, geography, entity, feature, or next-best intent.
- Ensure every indexable page is reachable from the main site, sitemap, or hub.
- Use breadcrumbs with structured data where appropriate.

### 5. Indexation Strategy

- Prioritize high-demand and high-quality page sets first.
- Use `noindex` for thin, low-confidence, duplicate, or low-demand variations.
- Separate XML sitemaps by page type when the site is large.
- Track crawl errors, indexation rate, duplicate titles, duplicate descriptions, and canonical conflicts.

## Quality Checks

Before launch, verify:

- Every page answers a real query intent and provides unique value.
- Titles, meta descriptions, H1s, canonical URLs, schema, and headings are unique and valid.
- Pages are crawlable, sitemaped, internally linked, and not accidentally blocked.
- Page speed is acceptable for the template.
- Empty states, missing data, and outdated data are handled.

After launch, monitor:

- Indexation rate.
- Rankings and impressions by page type.
- Organic traffic and engagement.
- Conversions by template and segment.
- Thin content warnings, ranking drops, manual actions, and crawl errors.

## Common Mistakes

- Swapping city, product, or category names into otherwise identical content.
- Generating pages with no search demand or no usable data.
- Multiple pages targeting the same keyword and cannibalizing each other.
- Publishing outdated, incorrect, or low-confidence data.
- Ignoring user experience because pages were designed only for search crawlers.

## Output Formats

For strategy work, provide:

- Opportunity analysis.
- Recommended playbook and rationale.
- Data model or source requirements.
- URL and internal linking architecture.
- Indexation plan.
- Launch and monitoring plan.

For page templates, provide:

- URL pattern.
- Title and meta templates.
- H1 and content outline.
- Required data fields.
- Conditional content rules.
- Internal link rules.
- Schema markup recommendation.
- Noindex/publish thresholds.

## Task-Specific Questions

Ask only what is not already known:

- What keyword patterns are you targeting?
- What data do you have or can acquire?
- How many pages are planned?
- What does current site authority look like?
- Who currently ranks for the target terms?
- What technical stack will generate and serve the pages?

## Related Skills

- `seo-audit`: auditing programmatic pages after launch.
- `schema`: structured data implementation.
- `site-architecture`: page hierarchy, URL structure, and internal linking.
- `competitors`: comparison page and competitor research frameworks.
