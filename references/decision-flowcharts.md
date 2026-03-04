# Decision Flowcharts

> When you're stuck choosing between options, use these flowcharts to guide your decision. These are starting points — your specific context always takes precedence.

---

## Database Selection

```
What kind of data?
│
├─ Structured with relationships → RELATIONAL
│  ├─ Need maximum reliability? → PostgreSQL
│  ├─ Simple and familiar? → SQLite (small) or MySQL (medium)
│  └─ Managed cloud? → Cloud SQL / RDS / Aurora
│
├─ Flexible/schemaless documents → DOCUMENT
│  ├─ Need full-text search too? → Elasticsearch / Meilisearch
│  └─ General document store? → MongoDB / Firestore
│
├─ Key-value / caching → KEY-VALUE
│  ├─ In-memory speed needed? → Redis
│  └─ Persistent key-value? → DynamoDB / Redis with persistence
│
├─ Time series → TIME SERIES
│  └─ InfluxDB / TimescaleDB (Postgres extension)
│
└─ Graph relationships → GRAPH
   └─ Neo4j / Amazon Neptune
```

**Solo developer rule of thumb:** Start with PostgreSQL. It handles 90% of use cases well.

---

## Frontend Framework

```
What are you building?
│
├─ Static site / blog / docs → STATIC SITE GENERATOR
│  └─ Astro, Hugo, 11ty
│
├─ Marketing / content site → SSG with interactivity
│  └─ Next.js (static export), Astro, SvelteKit
│
├─ Web application (interactive) → WEB APP FRAMEWORK
│  ├─ Team knows React? → Next.js or Remix
│  ├─ Want simplicity + performance? → SvelteKit
│  ├─ Want progressive enhancement? → Remix or SvelteKit
│  └─ Minimal JS needed? → htmx + server templates
│
├─ Dashboard / internal tool → FULL FRAMEWORK
│  └─ Next.js, SvelteKit, or low-code (Retool, Appsmith)
│
└─ Mobile + Web → CROSS-PLATFORM
   ├─ React team? → React Native (mobile) + Next.js (web)
   └─ Want single codebase? → Flutter, Expo
```

**Solo developer rule of thumb:** Pick what you know. If starting fresh, SvelteKit or Next.js.

---

## Monolith vs. Microservices

```
Team size?
│
├─ 1-5 people → MODULAR MONOLITH
│  (You cannot afford microservices operational overhead)
│
├─ 5-20 people
│  ├─ Clear domain boundaries known? → CONSIDER microservices for 1-2 bounded contexts
│  └─ Boundaries unclear? → MODULAR MONOLITH (extract later)
│
└─ 20+ people
   └─ Independent teams need independent deployment? → MICROSERVICES
      └─ But start with a monolith and extract — don't start distributed
```

**Solo developer answer:** Monolith. Always. Microservices are a team-scaling solution, not a technical one.

---

## REST vs. GraphQL

```
Who are the API consumers?
│
├─ Single frontend you control → REST (simpler, more tooling)
│
├─ Multiple frontends with different data needs
│  ├─ Mobile (bandwidth-sensitive) + Web? → GraphQL (fetch only what's needed)
│  └─ All need same data? → REST (simpler)
│
├─ Third-party / public API → REST
│  (Lower barrier to entry, better caching, more widely understood)
│
└─ Rapid prototyping with evolving schema? → GraphQL
   (Add fields without breaking existing consumers)
```

**Solo developer rule of thumb:** REST for most cases. GraphQL when you have multiple clients with very different data needs.

---

## SSR vs. SPA vs. SSG

```
Content type?
│
├─ Mostly static (blog, docs, marketing)
│  └─ SSG — Pre-render at build time
│
├─ SEO-critical dynamic content (e-commerce, news)
│  └─ SSR — Render on the server per request
│
├─ Highly interactive, behind auth (dashboard, app)
│  └─ SPA — Client-side rendering is fine
│     (Search engines don't need to index authenticated content)
│
└─ Mix of all above?
   └─ HYBRID — Most modern frameworks support per-route decisions
      (Next.js, SvelteKit, Nuxt support SSG + SSR + SPA per route)
```

---

## Testing Strategy

```
What to test?
│
├─ Business logic (pure functions, calculations)
│  └─ UNIT TESTS — Fast, isolated, lots of them
│
├─ Component behavior (render, user interaction)
│  └─ COMPONENT TESTS — Testing Library, mount + interact + assert
│
├─ API endpoints (request/response)
│  └─ INTEGRATION TESTS — HTTP tests against running server
│
├─ User workflows (signup → dashboard → action)
│  └─ E2E TESTS — Playwright or Cypress, few critical paths
│
└─ How much?
   ├─ Solo dev, moving fast → Unit tests for logic + E2E for critical paths
   ├─ Growing product → Add integration tests for APIs
   └─ Mature product → Full pyramid (many unit, some integration, few E2E)
```

**Solo developer rule of thumb:** Test business logic thoroughly (unit). Test critical user paths (E2E). Skip the middle until it hurts.

---

## Deployment Strategy

```
What are you deploying?
│
├─ Static site → CDN
│  └─ Vercel, Netlify, Cloudflare Pages
│
├─ Web application (server-rendered)
│  ├─ Want zero ops? → SERVERLESS
│  │  └─ Vercel, Netlify, AWS Lambda
│  ├─ Need more control? → CONTAINER
│  │  └─ Railway, Fly.io, AWS ECS, Google Cloud Run
│  └─ Maximum control? → VPS
│     └─ DigitalOcean, Hetzner, AWS EC2
│
├─ API / Backend service
│  ├─ Simple CRUD → SERVERLESS or PaaS (Railway, Render)
│  ├─ Long-running processes → CONTAINER
│  └─ Background jobs → Container + job queue (Redis, SQS)
│
└─ Mobile app → APP STORE
   └─ Build with Expo EAS, Fastlane, Xcode Cloud, or GitHub Actions
```

**Solo developer rule of thumb:** Start with the simplest option (Vercel/Railway). Move to containers when you need more control.

---

## State Management

```
Where does the state live?
│
├─ Only used by one component → LOCAL STATE
│  └─ useState, $state, reactive()
│
├─ Shared between parent-child → PROP PASSING
│  └─ Pass down 1-2 levels max
│
├─ Shared between siblings/distant components → CONTEXT or STORE
│  ├─ Simple shared state? → Context/provide-inject
│  └─ Complex with actions? → Zustand, Pinia, Svelte stores
│
├─ Server data (API responses) → SERVER STATE LIBRARY
│  └─ TanStack Query, SWR, Apollo Client
│
└─ URL state (filters, pagination, search) → URL PARAMS
   └─ Use the router. URL is the source of truth.
```

**Rule:** Keep state as close as possible to where it's used. Lift only when necessary.
