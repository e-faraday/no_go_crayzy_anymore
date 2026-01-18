---
type: feature
priority: medium
status: todo
created: YYYY-MM-DD
tags: []
---

## Feature: [Name]

### 🎯 Goal
What we're building and why

### 🚫 Scope Guard

**IN SCOPE:**
- Feature A
- Feature B

**OUT OF SCOPE:**
- ❌ Don't refactor X
- ❌ Don't touch Y

### 📊 Implementation Plans

#### Plan 1: Setup
- [ ] Task 1
- [ ] Task 2

#### Plan 2: Implementation  
- [ ] Task 1
- [ ] Task 2

### ✅ Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Tests passing

### 📝 Progress Log
**YYYY-MM-DD** - Started

### 🔖 Current Checkpoint
Working on: Plan 1
Next: Plan 2

### 🤖 Subagent Execution (Opsiyonel)

Uzun feature'larda veya çok sayıda plan olduğunda, her plan için fresh AI context'te çalışmak için subagent orchestration kullanabilirsiniz:

**Kullanım:**
```markdown
@feature-[name].md Help me implement Plan 1

[Orchestrator olarak çalışırsınız]
1. Plan 1'i parse edin
2. Task tool ile subagent spawn edin
3. Sonuçları kontrol edin
```

**Avantajları:**
- Her plan fresh 200k token context'te çalışır
- Context rot önlenir
- Ana context hafif kalır (30-40% kullanım)

**Detaylı bilgi:** [SUBAGENT-ORCHESTRATION.md](../../mdd-template/SUBAGENT-ORCHESTRATION.md)

---
**Status:** Todo