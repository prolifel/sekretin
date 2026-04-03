# sekretin

## quick setup

### 1. local development (pre-commit)

**install:**

```bash
pre-commit install
```

**configuration** (`.pre-commit-config.yaml`):

```yaml
repos:
  - repo: local
    hooks:
      - id: secret-scan
        name: scan for secrets
        entry: bash -c 'curl -ssl https://cdn.jsdelivr.net/gh/prolifel/sekretin@main/secret-scan.sh | bash -s -- --staged --exit-code 1'
        language: system
        pass_filenames: false
        always_run: true
```

**done!** every `git commit` will now scan for secrets automatically.

**test it:**

```bash
echo "aws_access_key_id=akiaiosfodnn7example" > test.txt
git add test.txt
git commit -m "test"
# commit will be blocked
```

---

### 2. gitlab ci

the `.gitlab-ci.yml` is already configured. just push to gitlab:

```bash
git push
```

the `secret-detection` job will run automatically on every push.

**configuration** (`.gitlab-ci.yml`):

```yaml
stages:
  - test
  - secret-detection

secret_detection:
  stage: secret-detection
  image: alpine:latest
  allow_failure: false
  before_script:
    - apk add --no-cache bash git curl
    - curl -ssl "https://cdn.jsdelivr.net/gh/prolifel/sekretin@main/secret-scan.sh" -o /tmp/secret-scan.sh
    - chmod +x /tmp/secret-scan.sh
  script:
    - /tmp/secret-scan.sh --all --exit-code 1 --verbose
  rules:
    - if: $ci_pipeline_source == "push"
```

---

## detected secrets

- aws access key
- aws secret key
- github token
- github oauth
- github app token
- github refresh token
- gitlab token
- generic api key
- private key
- jwt
- gcp api key
- gcp service account
- gcp oauth token
- alibaba access key id
- alibaba secret key
- amazon oauth client id
- anthropic api key
- artifactory api key
- artifactory identity token
- atlassian api key
- atlassian api token
- atlassian user api token
- aws bedrock key
- aws bedrock short lived key
- azure api management gateway key
- azure api management direct key
- azure entra client secret
- azure entra client id token
- azure functions api key
- azure openai api key
- azure personal access token
- bitbucket client id
- bitbucket client secret
- datadog api key
- discord api key
- discord client id
- discord client secret
- docker personal access token
- gcp vertex express mode key
- gitlab cicd job token
- gitlab deploy token
- gitlab feature flags client token

secrets are **masked** in output (e.g., `akia************mple`).
