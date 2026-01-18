---
name: MDD Workflow Senaryosu - Manuel ve Otomatik Adımlar
overview: Feature task oluşturma, planlama, implementasyon, arşivleme için tam workflow senaryosu. Manuel ve otomatik adımları net bir şekilde ayırır.
todos:
  - id: workflow-doc
    content: Workflow senaryosunu dokümante et - Manuel ve otomatik adımları net bir şekilde ayır
    status: pending
  - id: example-workflow
    content: Tam bir örnek workflow senaryosu oluştur - Baştan sona tüm adımları içeren
    status: pending
    dependencies:
      - workflow-doc
  - id: daily-routine
    content: Günlük rutin senaryolarını dokümante et - Sabah, gün içi, akşam rutinleri
    status: pending
    dependencies:
      - workflow-doc
---

# MDD Workflow Senaryosu - Manuel ve Otomatik Adımlar

## Genel Bakış

Bu plan, bir feature task'ın oluşturulmasından arşivlenmesine kadar tüm adımları içerir. Manuel işler (kullanıcı veya Claude ile) ve otomatik işler (script'lerle) net bir şekilde ayrılmıştır.

## Workflow Akışı

### Faz 1: Task Oluşturma ve Planlama

#### 1.1 Task Oluşturma (Otomatik)

```bash
./scripts/new-task.sh feature "Add dark mode"
```

**Ne yapar:**

- Template'den task dosyası oluşturur
- Frontmatter'ı doldurur (type, priority, status, created date)
- Dosya: `.claude/active/feature-add-dark-mode.md`

#### 1.2 Task Detaylarını Doldurma (Manuel - Claude veya Manuel)

**Manuel düzenleme gereken bölümler:**

- **Goal:** Ne yapıyoruz ve neden?
- **Scope Guard:** IN SCOPE ve OUT OF SCOPE listeleri
- **Implementation Phases:** Phase'ler ve her phase'deki task'lar (checkbox'lar)
- **Acceptance Criteria:** Kriterler (checkbox'lar)

**Claude ile doldurma:**

```
@.claude/active/feature-add-dark-mode.md 
Help me fill in the Goal, Scope Guard, Implementation Phases, and Acceptance Criteria for this feature.
```

**Manuel doldurma:**

- Dosyayı editor'de aç ve bölümleri doldur

#### 1.3 Priority ve Tag Ayarlama (Parametrik - Manuel)

```bash
# Priority ayarla
./scripts/set-priority.sh .claude/active/feature-add-dark-mode.md high

# Tag'ler ekle
./scripts/add-tags.sh .claude/active/feature-add-dark-mode.md ui theme frontend
```

### Faz 2: Task'a Başlama

#### 2.1 Task'ı Başlatma (Parametrik - Manuel)

```bash
./scripts/start-task.sh .claude/active/feature-add-dark-mode.md "Starting Phase 1: Setup"
```

**Ne yapar:**

- Status'u `in-progress` yapar
- Progress Log'a kayıt ekler
- Tarih/saat ekler

### Faz 3: Implementation

#### 3.1 Claude ile Çalışma (Manuel)

```
@.claude/active/feature-add-dark-mode.md Help me implement Phase 1
```

#### 3.2 Checkbox İşaretleme (Parametrik - Manuel)

Claude checkbox'ları işaretlemediyse:

```bash
./scripts/check-task.sh .claude/active/feature-add-dark-mode.md "Create ThemeContext"
./scripts/check-task.sh .claude/active/feature-add-dark-mode.md "Add localStorage hook"
```

#### 3.3 Progress Kaydetme (Parametrik - Manuel)

```bash
./scripts/update-progress.sh .claude/active/feature-add-dark-mode.md "ThemeContext created and tested"
```

#### 3.4 Otomatik Güncellemeler (Otomatik)

Her checkbox işaretledikten veya progress kaydettikten sonra:

```bash
./scripts/auto-sync.sh .claude/active/feature-add-dark-mode.md
```

**Ne yapar:**

1. Phase'leri kontrol eder, tamamlananları işaretler
2. Status'u günceller (checkbox durumuna göre)
3. Checkpoint'i günceller (en aktif phase'e göre)
4. Task tamamlanmışsa işaretler

### Faz 4: Phase Tamamlama

#### 4.1 Phase'deki Tüm Task'ları İşaretleme (Manuel)

```bash
# Phase 1'deki tüm task'ları işaretle
./scripts/check-task.sh .claude/active/feature-add-dark-mode.md "Task 1"
./scripts/check-task.sh .claude/active/feature-add-dark-mode.md "Task 2"
# ... diğer task'lar
```

#### 4.2 Otomatik Phase Tamamlama (Otomatik)

```bash
./scripts/auto-sync.sh .claude/active/feature-add-dark-mode.md
```

**Sonuç:** Phase başlığına "(✅ COMPLETED)" eklenir

#### 4.3 Yeni Phase'e Geçiş (Parametrik - Manuel)

```bash
./scripts/start-task.sh .claude/active/feature-add-dark-mode.md "Starting Phase 2: UI Components"
```

### Faz 5: Task Tamamlama

#### 5.1 Tüm Phase'leri Tamamlama (Manuel)

Tüm phase'lerdeki checkbox'ları işaretle

#### 5.2 Otomatik Task Tamamlama (Otomatik)

```bash
./scripts/auto-sync.sh .claude/active/feature-add-dark-mode.md
```

**Sonuç:**

- Status `completed` olur
- Current Checkpoint "✅ All phases completed" olur
- Progress Log'a final kayıt eklenir

### Faz 6: Git İşlemleri (Manuel)

#### 6.1 Git Add ve Commit

```bash
git add .claude/active/feature-add-dark-mode.md
git commit -m "feat: Add dark mode feature"
```

### Faz 7: Arşivleme

#### 7.1 Completed Task'ları Arşivleme (Otomatik)

```bash
./scripts/archive-completed.sh
```

**Ne yapar:**

- `status: completed` olan tüm task'ları bulur
- `.claude/completed/YYYY-MM/` dizinine taşır
- Git'te tracked ise `git mv` kullanır

## Günlük Rutin Senaryoları

### Sabah Rutini

```bash
# 1. Günlük özeti görüntüle
./scripts/daily-summary.sh

# 2. Bugün çalışacağınız task'a başla
./scripts/start-task.sh .claude/active/feature-add-dark-mode.md "Starting work today"
```

### Gün İçinde

```bash
# Checkbox işaretle
./scripts/check-task.sh .claude/active/feature-add-dark-mode.md "Task name"

# Progress kaydet
./scripts/update-progress.sh .claude/active/feature-add-dark-mode.md "Progress message"

# Otomatik güncellemeleri yap
./scripts/auto-sync.sh .claude/active/feature-add-dark-mode.md
```

### Akşam Rutini

```bash
# 1. Tüm task'ları senkronize et
./scripts/sync-all-tasks.sh

# 2. Completed task'ları arşivle
./scripts/archive-completed.sh

# 3. Günlük özeti tekrar kontrol et
./scripts/daily-summary.sh
```

## Manuel vs Otomatik Özet

### Manuel İşler (Kullanıcı veya Claude ile)

1. ✅ Task detaylarını doldurma (Goal, Scope Guard, Phases, Acceptance Criteria)
2. ✅ Priority ve tag ayarlama (parametrik script'lerle)
3. ✅ Task'a başlama (start-task.sh ile)
4. ✅ Implementation (Claude ile çalışma)
5. ✅ Checkbox işaretleme (check-task.sh ile veya Claude ile)
6. ✅ Progress kaydetme (update-progress.sh ile)
7. ✅ Git commit (manuel)

### Otomatik İşler (Script'lerle)

1. ✅ Task oluşturma (new-task.sh)
2. ✅ Status güncelleme (auto-update-status.sh)
3. ✅ Phase completion işaretleme (auto-complete-phases.sh)
4. ✅ Task completion (auto-complete-task.sh)
5. ✅ Checkpoint güncelleme (auto-update-checkpoint.sh)
6. ✅ Tüm otomatik güncellemeler (auto-sync.sh)
7. ✅ Toplu senkronizasyon (sync-all-tasks.sh)
8. ✅ Arşivleme (archive-completed.sh)

## Örnek Tam Workflow

```bash
# 1. Task oluştur (Otomatik)
./scripts/new-task.sh feature "Add dark mode"

# 2. Task detaylarını doldur (Manuel - Claude ile)
# @.claude/active/feature-add-dark-mode.md Help me fill in the details

# 3. Priority ve tag ayarla (Parametrik)
./scripts/set-priority.sh .claude/active/feature-add-dark-mode.md high
./scripts/add-tags.sh .claude/active/feature-add-dark-mode.md ui theme

# 4. Task'a başla (Parametrik)
./scripts/start-task.sh .claude/active/feature-add-dark-mode.md "Starting Phase 1"

# 5. Implementation (Manuel - Claude ile)
# @.claude/active/feature-add-dark-mode.md Help me implement Phase 1

# 6. Checkbox işaretle (Parametrik)
./scripts/check-task.sh .claude/active/feature-add-dark-mode.md "Create ThemeContext"

# 7. Progress kaydet (Parametrik)
./scripts/update-progress.sh .claude/active/feature-add-dark-mode.md "ThemeContext created"

# 8. Otomatik güncellemeleri yap (Otomatik)
./scripts/auto-sync.sh .claude/active/feature-add-dark-mode.md

# 9. Phase tamamlandığında tekrar sync (Otomatik)
./scripts/auto-sync.sh .claude/active/feature-add-dark-mode.md

# 10. Tüm phase'ler tamamlandığında otomatik task completion (Otomatik)
./scripts/auto-sync.sh .claude/active/feature-add-dark-mode.md

# 11. Git commit (Manuel)
git add .claude/active/feature-add-dark-mode.md
git commit -m "feat: Add dark mode feature"

# 12. Arşivle (Otomatik)
./scripts/archive-completed.sh
```

## Önemli Notlar

1. **auto-sync.sh** her checkbox işaretledikten veya progress kaydettikten sonra çalıştırılmalı
2. **sync-all-tasks.sh** gün sonunda tüm task'ları toplu senkronize etmek için kullanılır
3. **archive-completed.sh** sadece `status: completed` olan task'ları arşivler
4. Checkbox işaretleme manuel veya Claude ile yapılabili