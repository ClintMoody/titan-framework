# Game Domain Checklist
- [ ] Frame budget: target frame time documented (16.6ms for 60fps), profiler confirms no spikes above budget
- [ ] Memory pools: pre-allocated pools for frequently created/destroyed objects, no runtime allocations in hot path
- [ ] Input latency: input-to-screen response measured, below 100ms for action games, below 200ms for strategy
- [ ] Save/load: game state serialization tested, backward compatibility with older save formats
- [ ] Physics determinism: fixed timestep for physics, deterministic across platforms if multiplayer
- [ ] Asset streaming: level-of-detail transitions smooth, no visible pop-in during normal gameplay
- [ ] LOD: distance-based mesh/texture quality scaling, configurable quality presets
- [ ] Audio mixing: dynamic priority system, critical sounds never culled, volume ducking for speech
