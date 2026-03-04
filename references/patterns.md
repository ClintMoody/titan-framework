# Common Software Patterns Reference

> Quick reference for patterns frequently encountered in TITAN-managed projects. Organized by category with when-to-use and when-NOT-to-use guidance.

---

## Architectural Patterns

### MVC / MVP / MVVM
**What:** Separate concerns into Model (data), View (display), Controller/Presenter/ViewModel (logic).
**Use when:** Building UI applications with clear data-display separation.
**Don't use when:** Building pure APIs, libraries, or CLI tools.

### Layered Architecture
**What:** Organize code into horizontal layers: presentation → business logic → data access.
**Use when:** Medium-complexity applications where clear boundaries aid understanding.
**Don't use when:** Very simple apps (overkill) or very complex ones (may need vertical slices).

### Microservices
**What:** Deploy each bounded context as an independent service.
**Use when:** Large teams, independent deployment needed, diverse technology requirements.
**Don't use when:** Solo developer or small team — operational complexity outweighs benefits.

### Monolith (Modular)
**What:** Single deployable unit with well-defined internal modules.
**Use when:** Solo developer, small team, starting a new product, need fast iteration.
**Don't use when:** Independent scaling or deployment of components is a hard requirement.

### Event-Driven
**What:** Components communicate through events/messages instead of direct calls.
**Use when:** Loose coupling needed, async workflows, multiple consumers of same events.
**Don't use when:** Simple CRUD operations, debugging ease is a priority (event flows are harder to trace).

### Serverless
**What:** Deploy individual functions that run on demand, scaling automatically.
**Use when:** Variable workloads, event-triggered processing, minimizing operational overhead.
**Don't use when:** Long-running processes, need for persistent connections, cold start latency matters.

---

## Design Patterns

### Repository
**What:** Abstract data access behind a clean interface.
**Use when:** You want to decouple business logic from database queries.
**Don't use when:** Direct ORM access is sufficient and the layer adds no value.

### Factory
**What:** Centralize object creation logic.
**Use when:** Object creation is complex, involves configuration, or may need different implementations.
**Don't use when:** Simple `new` calls are clear and sufficient.

### Observer / Pub-Sub
**What:** Objects subscribe to events and react when they occur.
**Use when:** One-to-many notifications, decoupled components that react to state changes.
**Don't use when:** Simple one-to-one communication (direct call is clearer).

### Strategy
**What:** Define a family of algorithms, encapsulate each, make them interchangeable.
**Use when:** Multiple algorithms for the same task, need to switch at runtime.
**Don't use when:** Only one algorithm exists or will ever exist.

### Middleware / Pipeline
**What:** Process requests through a chain of handlers, each adding behavior.
**Use when:** Cross-cutting concerns (auth, logging, validation) on HTTP/message processing.
**Don't use when:** Processing is simple and linear with no cross-cutting concerns.

### Decorator / Wrapper
**What:** Add behavior to objects without modifying them.
**Use when:** Adding logging, caching, validation to existing services without changing their code.
**Don't use when:** One or two simple additions (just modify the class directly).

---

## Data Patterns

### CQRS (Command Query Responsibility Segregation)
**What:** Separate read and write models.
**Use when:** Read and write patterns are very different, need independent scaling or optimization.
**Don't use when:** Simple CRUD where reads and writes are symmetric.

### Event Sourcing
**What:** Store state as a sequence of events rather than current values.
**Use when:** Full audit trail needed, temporal queries, event-driven architecture.
**Don't use when:** Simple state management, querying current state is the primary need.

### Repository Pattern
**What:** Abstract data storage behind a collection-like interface.
**Use when:** Multiple data sources, need to test business logic without database.
**Don't use when:** Simple scripts or prototypes where direct queries are fine.

### Unit of Work
**What:** Track changes to objects and commit them as a single transaction.
**Use when:** Multiple related changes that must succeed or fail together.
**Don't use when:** Single, independent operations.

---

## Frontend Patterns

### Component Composition
**What:** Build complex UIs from small, focused, reusable components.
**Use when:** Always, in modern component-based frameworks.
**Don't use when:** Server-rendered pages with minimal interactivity.

### State Management (Local vs. Global)
**What:** Keep state as close to where it's used as possible.
**Use when:** Always start with local state. Lift to global only when multiple unrelated components need it.
**Don't use when:** Don't put everything in global state — it becomes a god object.

### Render Props / Higher-Order Components / Hooks
**What:** Share behavior between components through composition patterns.
**Use when:** Multiple components need the same logic (auth check, data fetching, form handling).
**Don't use when:** The logic is used in only one place (just put it in the component).

### Optimistic Updates
**What:** Update UI immediately, then reconcile with server response.
**Use when:** User actions that should feel instant (likes, toggles, form submissions).
**Don't use when:** Financial transactions or irreversible operations where accuracy > speed.

---

## API Patterns

### Pagination (Cursor vs. Offset)
**Cursor:** Use when data changes frequently, deep pagination needed, performance matters.
**Offset:** Use when data is mostly static, users need to jump to specific pages.

### Rate Limiting
**What:** Limit how many requests a client can make in a time window.
**Use when:** Always, on public-facing APIs. Token bucket or sliding window algorithms.

### Circuit Breaker
**What:** Stop calling a failing service temporarily, fail fast instead.
**Use when:** Calling external services that may be unreliable.
**Don't use when:** Internal function calls that should propagate errors.

### Retry with Backoff
**What:** Retry failed operations with exponentially increasing delays.
**Use when:** Transient failures (network, rate limiting, temporary service issues).
**Don't use when:** Permanent failures (404, 403, validation errors — these won't succeed on retry).
