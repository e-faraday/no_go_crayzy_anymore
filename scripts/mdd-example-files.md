# Example Task Files

These are example MD files showing how to structure different types of tasks.

## Example 1: Feature Implementation

**File:** `.claude/active/example-feature-dark-mode.md`

```markdown
---
type: feature
priority: high
status: in-progress
created: 2025-01-17
updated: 2025-01-17
tags: [ui, accessibility, theme]
---

## Feature: Dark Mode Support

### 🎯 Goal
Add system-wide dark mode toggle with user preference persistence

**User Story:** As a user, I want to switch between light and dark themes so that I can reduce eye strain when using the app at night.

### 🚫 Scope Guard

**IN SCOPE:**
- Theme toggle component in header
- Dark mode CSS classes for all components
- LocalStorage persistence
- System preference detection
- Smooth transition animations

**OUT OF SCOPE:**
- ❌ Don't refactor existing component structure
- ❌ Don't change the authentication system
- ❌ Don't modify API endpoints
- ❌ Don't touch the database schema
- ❌ Don't add color customization (future feature)

### 📐 Technical Approach

**Architecture:**
- React Context for theme state
- CSS custom properties for colors
- Tailwind's dark: modifier for styling
- LocalStorage for persistence
- `prefers-color-scheme` media query for default

**Component Structure:**
```
ThemeProvider (Context)
  └─ App
      ├─ Header
      │   └─ ThemeToggle (new)
      ├─ Main (apply dark classes)
      └─ Footer (apply dark classes)
```

### 📁 Files to Modify

**New files:**
- `src/context/ThemeContext.tsx` - Theme provider and hook
- `src/components/ThemeToggle.tsx` - Toggle button component
- `src/styles/theme.css` - CSS custom properties

**Modified files:**
- `src/App.tsx` - Wrap with ThemeProvider
- `src/components/Header.tsx` - Add ThemeToggle
- `tailwind.config.js` - Enable dark mode
- `src/components/**/*.tsx` - Add dark: classes

### 📊 Implementation Phases

#### Phase 1: Setup (✅ Completed)
- [x] Create ThemeContext
- [x] Add localStorage hooks
- [x] Implement system preference detection
- [x] Write unit tests

**Completed on:** 2025-01-17 10:00

#### Phase 2: UI Components (🏗️ In Progress - 60%)
- [x] Create ThemeToggle component
- [x] Add toggle to Header
- [x] Implement transition animations
- [ ] Add accessibility labels (CURRENT TASK)
- [ ] Test keyboard navigation

**Current focus:** Making toggle fully accessible

#### Phase 3: Styling (📝 Todo)
- [ ] Apply dark: classes to all components
- [ ] Test color contrast ratios
- [ ] Ensure WCAG AA compliance
- [ ] Update color palette if needed

#### Phase 4: Testing & Polish (📝 Todo)
- [ ] Cross-browser testing
- [ ] Mobile responsiveness
- [ ] Performance check
- [ ] Documentation

### ✅ Acceptance Criteria

- [ ] Toggle switches between light and dark modes
- [ ] Preference persists across sessions
- [ ] Respects system preference on first visit
- [ ] Smooth transition animation (300ms)
- [ ] All components properly styled in both modes
- [ ] WCAG AA color contrast compliance
- [ ] Keyboard accessible (Tab + Enter)
- [ ] Screen reader announces state
- [ ] Works on Chrome, Firefox, Safari
- [ ] Mobile responsive
- [ ] Unit tests pass (>90% coverage)
- [ ] No console errors or warnings

### 🧪 Testing Checklist

**Manual Testing:**
- [ ] Toggle in light mode → switches to dark
- [ ] Toggle in dark mode → switches to light
- [ ] Refresh page → preference persists
- [ ] Clear localStorage → respects system preference
- [ ] Tab to toggle → focuses correctly
- [ ] Enter key → activates toggle
- [ ] Screen reader → announces "Dark mode on/off"

**Browser Testing:**
- [ ] Chrome (latest)
- [ ] Firefox (latest)
- [ ] Safari (latest)
- [ ] Edge (latest)
- [ ] Mobile Safari (iOS)
- [ ] Chrome Mobile (Android)

**Automated Testing:**
- [ ] Component unit tests
- [ ] Context hook tests
- [ ] Integration tests
- [ ] E2E tests (optional)

### 📝 Progress Log

**2025-01-17 09:00** - Project kickoff
- Created MD file
- Defined scope and phases
- Set up ThemeContext

**2025-01-17 10:00** - Phase 1 complete
- Context working
- LocalStorage integration done
- System preference detection working
- Tests written and passing

**2025-01-17 14:00** - Phase 2 progress
- Toggle component created
- Basic styling done
- Animations implemented
- Working on accessibility

**2025-01-17 15:30** - Accessibility focus
- Adding ARIA labels
- Testing keyboard navigation
- Next: Screen reader testing

### 🔖 Current Checkpoint

**Where we are:**
- Phase 1: ✅ Done
- Phase 2: 🏗️ 60% done (accessibility in progress)
- Phase 3: 📝 Not started
- Phase 4: 📝 Not started

**Current task:** Add accessibility features to ThemeToggle

**Next up:** Complete Phase 2, then start applying dark: classes

**⚠️ Important:** Don't move to Phase 3 until Phase 2 is fully complete and tested

### 🚨 Known Issues

None currently

### 🔗 Related

- Design mockups: [Figma link]
- Discussion: [Slack thread]
- Similar implementation: [GitHub repo]

### 💡 Notes

- User research showed 67% of users prefer dark mode at night
- System preference detection is crucial for good UX
- Need to ensure smooth transition (not jarring flash)
- Consider adding "Auto" mode in future (system preference)

---

**Last updated:** 2025-01-17 15:30
**Status:** In progress - Phase 2 (Accessibility)
```

## Example 2: Bug Fix

**File:** `.claude/active/example-bug-safari-login.md`

```markdown
---
type: bug
priority: critical
status: fixed
created: 2025-01-16
updated: 2025-01-16
tags: [production, safari, auth]
---

## Bug: Login Fails on Safari 17+

### 🐛 Problem Summary
Users on Safari 17+ cannot log in. Click on login button does nothing.

**Severity:** Critical (P0)  
**Affected Users:** ~15% (Safari users)  
**Reported:** 2025-01-16 14:30  
**Reporter:** user@example.com via support ticket

### 📊 Impact
- **Users affected:** ~500/day
- **Revenue impact:** High (can't complete purchases)
- **Workaround:** Use Chrome (not acceptable)

### 🔍 Symptoms

**User experience:**
1. Enter email and password
2. Click "Login" button
3. Nothing happens - no feedback, no error
4. Button appears to click but no action occurs

**Technical symptoms:**
- Console error: `localStorage is not defined`
- No network requests to login API
- onClick handler never fires
- Other browsers work fine

### 📍 Root Cause

**Location:**
- File: `src/auth/storage.ts`
- Line: 23
- Function: `saveToken()`

**Code:**
```typescript
export const saveToken = (token: string) => {
  localStorage.setItem('auth_token', token); // ❌ Fails in Safari
  return token;
};
```

**Why it fails:**
Safari 17+ blocks `localStorage` in certain privacy modes or with strict tracking prevention. Code assumes localStorage is always available.

**Why only Safari:**
- Chrome/Firefox: localStorage available even in private mode
- Safari: Blocks localStorage in strict privacy mode
- Mobile Safari: Same issue on iOS 17+

### 🚫 What NOT to Touch

**These are working correctly:**
- ❌ Login API endpoint (backend fine)
- ❌ Token generation logic (working)
- ❌ Password validation (working)
- ❌ Auth middleware (working)
- ❌ Database queries (working)
- ❌ UI components (working)

**ONLY FIX:** localStorage access pattern in storage.ts

### ✅ Proposed Solution

**Approach:** Graceful fallback with user notification

```typescript
// New implementation
export const saveToken = (token: string) => {
  try {
    localStorage.setItem('auth_token', token);
    return { success: true, storage: 'localStorage' };
  } catch (error) {
    // Safari blocked localStorage
    sessionStorage.setItem('auth_token', token);
    notifyUser('Session will not persist after browser close');
    return { success: true, storage: 'sessionStorage' };
  }
};
```

**Why this works:**
- Primary: Try localStorage (works in most cases)
- Fallback: Use sessionStorage (always available)
- User feedback: Notify about session limitation
- Graceful degradation: User can still login

**Alternative considered (rejected):**
- In-memory storage: Loses session on page refresh
- Cookie storage: GDPR complications
- Force localStorage: Fails completely

### 🧪 How to Reproduce

**Setup:**
1. Open Safari 17+
2. Enable strict tracking prevention:
   - Safari > Settings > Privacy
   - Enable "Prevent cross-site tracking"
   - Enable "Block all cookies"

**Steps:**
1. Navigate to login page
2. Enter valid credentials
3. Click "Login" button
4. Observe: Nothing happens

**Expected:** User logged in  
**Actual:** No response, console error

### ✅ Verification Steps

After fix, verify:
- [ ] Safari 17+ with strict privacy: Can login
- [ ] Safari normal mode: Can login
- [ ] Chrome/Firefox: Still work (no regression)
- [ ] User sees notification when localStorage blocked
- [ ] Session works but doesn't persist (expected)
- [ ] Other features still work (profile, cart, etc.)
- [ ] Mobile Safari iOS 17+: Can login
- [ ] No console errors

### 📝 Fix Timeline

**2025-01-16 14:30** - Bug reported by user  
**2025-01-16 14:35** - Ticket created, assigned to team  
**2025-01-16 14:45** - Reproduced locally in Safari  
**2025-01-16 15:00** - Root cause identified (localStorage)  
**2025-01-16 15:15** - Solution designed (fallback approach)  
**2025-01-16 15:30** - Fix implemented  
**2025-01-16 15:45** - Tests written  
**2025-01-16 16:00** - Code review approved  
**2025-01-16 16:15** - Deployed to staging  
**2025-01-16 16:30** - QA verified on staging  
**2025-01-16 16:45** - Deployed to production  
**2025-01-16 17:00** - Verified in production  
**2025-01-16 17:15** - User notified, confirmed working

**Total time:** 2h 45min (first report to production fix)

### 🎯 Prevention

**Why this happened:**
- Assumed localStorage always available
- No error handling
- Insufficient browser testing

**How to prevent:**
- [ ] Add localStorage availability check to utils
- [ ] Update coding guidelines: always try/catch storage
- [ ] Add Safari to CI browser matrix
- [ ] Create "Browser Compatibility" checklist
- [ ] Document storage fallback pattern

**Action items:**
- [ ] Audit codebase for other localStorage uses
- [ ] Add utility function: `safeStorage.setItem()`
- [ ] Update PR template to include browser testing
- [ ] Create runbook for storage-related issues

### 📊 Metrics

**Before fix:**
- Login success rate (Safari): 0%
- Support tickets: 15/day
- User complaints: High

**After fix:**
- Login success rate (Safari): 99.5%
- Support tickets: 0/day related to this
- User complaints: None

### 🔗 Related

- Support ticket: #12345
- Slack thread: [link]
- Code review: PR #678
- Production deploy: [link]
- Similar bug: [[bug-cookies-blocked.md]]

---

**Status:** ✅ Fixed and deployed  
**Verified:** 2025-01-16 17:15  
**Can be archived:** Yes
```

## Example 3: Architecture Decision

**File:** `.claude/decisions/example-state-management.md`

```markdown
---
type: decision
status: final
date: 2025-01-15
decision_id: ADR-001
---

## Decision: State Management Solution

### 📅 Decision Date
2025-01-15

### 👥 Decision Makers
- Tech Lead: @alice
- Senior Engineers: @bob, @charlie
- Consulted: Full engineering team

### 🤔 Context

We're building a complex e-commerce application with:
- Shopping cart across multiple pages
- User authentication state
- Real-time inventory updates
- Product filters and search
- Order history

**Current situation:**
- Using component state (useState)
- Prop drilling 5-6 levels deep
- Re-renders causing performance issues
- Hard to debug state changes
- New features increasingly difficult

**Need:** Centralized state management solution

### 🎯 Requirements

**Must have:**
- TypeScript support
- DevTools for debugging
- Good performance
- Minimal boilerplate
- Team learning curve <1 week

**Nice to have:**
- Time-travel debugging
- Persistence options
- Server-side rendering support
- Large ecosystem

### 💡 Options Considered

#### Option 1: Redux Toolkit
**Pros:**
- Industry standard, well-known
- Excellent DevTools
- TypeScript support
- Large ecosystem
- Team has experience
- Time-travel debugging
- Persistence middleware available

**Cons:**
- Some boilerplate (actions, reducers)
- Learning curve for new team members
- Overkill for simple state

**Score:** 9/10

#### Option 2: Zustand
**Pros:**
- Minimal boilerplate
- Simple API
- Good performance
- TypeScript support
- Small bundle size

**Cons:**
- Smaller ecosystem
- No time-travel debugging
- Team unfamiliar
- Less mature DevTools

**Score:** 7/10

#### Option 3: Context API + useReducer
**Pros:**
- No dependencies
- Built into React
- Simple for small state

**Cons:**
- Performance issues with large state
- No DevTools
- More code to maintain
- Prop drilling still needed for optimization

**Score:** 5/10

#### Option 4: MobX
**Pros:**
- Less boilerplate than Redux
- Observable pattern
- Good performance

**Cons:**
- Different paradigm (learning curve)
- Team has no experience
- Smaller ecosystem than Redux

**Score:** 6/10

### ✅ Decision

**We will use: Redux Toolkit**

### 💭 Rationale

**Primary reasons:**
1. **Team experience:** 3/5 engineers have Redux experience
2. **Debugging:** DevTools are crucial for complex state
3. **Ecosystem:** Large plugin ecosystem for future needs
4. **TypeScript:** Excellent TS support
5. **Industry standard:** Easy to hire developers

**Trade-offs accepted:**
- Slightly more boilerplate than Zustand
- Larger bundle size (acceptable for our use case)

**Why not others:**
- Context API: Performance concerns for large app
- Zustand: Team training would take longer
- MobX: Different paradigm, higher risk

### 📊 Expected Impact

**Benefits:**
- Centralized state (no prop drilling)
- Better debugging (DevTools)
- Easier testing (predictable state)
- Better performance (selective re-renders)
- Clearer architecture

**Costs:**
- Initial setup time: ~2 days
- Team training: ~1 week
- Migration effort: ~1 sprint
- Bundle size: +30KB (acceptable)

### 📋 Implementation Plan

**Phase 1: Setup (Week 1)**
- Install Redux Toolkit
- Configure store
- Set up DevTools
- Create example slice
- Team training session

**Phase 2: Migration (Weeks 2-3)**
- Migrate auth state
- Migrate cart state
- Migrate user preferences
- Remove prop drilling
- Update tests

**Phase 3: Optimization (Week 4)**
- Add selectors
- Optimize re-renders
- Add persistence
- Performance testing

### ✅ Success Criteria

- [ ] All team members comfortable with Redux
- [ ] 90% of global state migrated
- [ ] No prop drilling >2 levels
- [ ] DevTools working in all environments
- [ ] Performance metrics improved
- [ ] Zero production bugs from migration

### 🚫 This Decision is FINAL

**Do NOT revisit** unless:
- Major performance issues discovered
- Redux Toolkit deprecated
- Team size changes significantly (>50% turnover)
- Architecture needs fundamental change

**If someone suggests switching:**
Refer them to this document and ask:
"Has the context changed significantly?"

### 📝 Review Schedule

- **3 months:** Check if decision working well
- **6 months:** Evaluate team satisfaction
- **12 months:** Consider if needs have changed

### 🔗 References

- Redux Toolkit docs: https://redux-toolkit.js.org
- Team RFC: [Internal doc]
- Prototype: [GitHub branch]
- Discussion: [Slack thread]

### 📊 Follow-up

**Update 2025-02-15 (1 month later):**
- Migration 100% complete
- Team productivity improved
- DevTools heavily used
- Zero regrets on decision
- Would make same choice again

---

**Decision:** Redux Toolkit  
**Status:** ✅ Final - Implemented successfully  
**Review date:** 2025-04-15
```

---

These examples show:
- ✅ Clear structure
- ✅ Explicit scope
- ✅ Progress tracking
- ✅ Decision rationale
- ✅ Prevention measures

Use them as templates for your own tasks!