# Audio Domain Checklist
- [ ] No denormals: flush-to-zero enabled on audio processing thread
- [ ] Buffer sizes validated: supported range documented, graceful fallback for unsupported
- [ ] Zero allocations in audio callback/render thread
- [ ] Latency budget documented and measured (target + actual)
- [ ] All standard sample rates handled (44100, 48000, 88200, 96000, 192000)
- [ ] Bypass mode: clean signal pass-through when processing disabled
- [ ] Parameter smoothing: no zipper noise on real-time parameter changes
- [ ] Thread safety: audio thread never blocks on UI/main thread locks
