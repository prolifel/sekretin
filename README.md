# Secret Scan Setup Guide

## Quick Setup

### 1. Local Development (Pre-commit)

**Install:**
```bash
pre-commit install
```

**Done!** Every `git commit` will now scan for secrets automatically.

**Test it:**
```bash
echo "AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE" > test.txt
git add test.txt
git commit -m "test"
# Commit will be blocked
```

---

### 2. GitLab CI

The `.gitlab-ci.yml` is already configured. Just push to GitLab:

```bash
git push
```

The `secret-detection` job will run automatically on every push.

---

## How It Works

| Component | What It Does |
|-----------|--------------|
| Pre-commit | Scans staged files before each commit |
| GitLab CI | Scans entire git history on every push |

Both fetch `secret-scan.sh` from: `https://cdn.jsdelivr.net/gh/prolifel/sekretin@main/secret-scan.sh`

---

## Detected Secrets

- AWS Access Keys (`AKIA...`)
- AWS Secret Keys (40 chars)
- GitHub Tokens (`ghp_`, `gho_`, `ghu_`, `ghs_`, `ghr_`)
- GitLab Tokens (`glpat-...`)
- API Keys
- Private Keys
- JWTs

Secrets are **masked** in output (e.g., `AKIA************MPLE`).

---

## Troubleshooting

**Commit blocked but no secrets?**
- Check the scan output for the detected pattern
- False positives can happen - review the matched content

**404 Error?**
- Ensure `prolifel/sekretin` repo is public
- Verify `secret-scan.sh` exists at repo root

**Reinstall hooks:**
```bash
pre-commit uninstall && pre-commit install
```

---

## For Administrators

To host your own scanner:

1. Upload `secret-scan.sh` to a public GitHub repo
2. Update URLs in:
   - `.pre-commit-config.yaml` (line 6)
   - `.gitlab-ci.yml` (line 11)

CDN URL format:
```
https://cdn.jsdelivr.net/gh/USERNAME/REPO@main/secret-scan.sh
```
