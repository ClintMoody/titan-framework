# Mobile Domain Checklist
- [ ] Offline support: core functionality available without network, graceful degradation for online-only features
- [ ] Battery impact: no unnecessary background processing, location/sensor usage minimized when app is inactive
- [ ] Permissions: only request permissions when needed, explain purpose before prompt, handle denial gracefully
- [ ] Deep links: universal links / app links configured, fallback to web for uninstalled users
- [ ] App size: binary size monitored, assets compressed, on-demand resources for non-critical content
- [ ] Accessibility: VoiceOver/TalkBack tested, dynamic type support, minimum 44pt touch targets
- [ ] Orientation: layout adapts to portrait and landscape, no content clipping or overflow
- [ ] Gesture conflicts: custom gestures do not conflict with system gestures (back swipe, notification pull)
