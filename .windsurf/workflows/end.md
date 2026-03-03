---
description: Session finalization with handoff
---

# /end — Session Finalization (v1.0)

## 1. Collect Session Work

```bash
git log --oneline --since="8 hours ago"
```

## 2. Update TASKS.md

- Mark completed tasks as ✅ with date
- Add file references
- Update task counter in header

## 3. Commit Pending Changes

```bash
git add -A
git status --short
# Commit with conventional message
git commit -m "chore: session N handoff — [summary]"
```

## 4. Push + VPS Sync

```bash
git push origin main
ssh root@217.216.95.126 "cd /opt/bracc && git pull origin main && cd infra && docker compose restart api"
```

## 5. Handoff Summary

Output to user:

- **Session:** Number and duration
- **Completed:** List of tasks done
- **In Progress:** What's still running
- **Blocked:** What needs user input
- **Next:** Recommended priorities for next session

## 6. Persist Knowledge

Use `create_memory` to save important discoveries from this session.
