# package-lab

[![Deploy on Back4app](https://img.shields.io/badge/Deploy%20on-Back4app-1568B8?style=for-the-badge&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCI+PHBhdGggZmlsbD0iI2ZmZiIgZD0iTTEyIDJMMiA3djEwbDEwIDUgMTAtNVY3eiIvPjwvc3ZnPg==)](https://www.back4app.com/signup?utm_source=github&utm_medium=repo&utm_campaign=package-lab)

The same four features — login, a database, file uploads and e-mail — built two
ways, with everything counted from the lockfile after a real install. Then: what
an install step is allowed to do, and whether a plausible package name is free.

**Measured with npm in node:22-alpine on Docker 29.4.3 and the live npm
registry, 29 October 2026. Identical across two consecutive clean runs.**

> **Read the article:** [You Asked for 12 Packages and Installed 175: What a Dependency List Actually Costs](https://www.back4app.com/blog/what-npm-install-actually-installs?utm_source=github&utm_medium=repo&utm_campaign=package-lab)

## Run it

```
./run.sh
```

Needs Docker and an internet connection.

## What it found

| how you build them | you asked for | you installed | on disk | run code on install |
| --- | --- | --- | --- | --- |
| assembled from libraries | 12 | **175** | 44M | 2 — `bcrypt`, `sharp` |
| the backend already has them | 1 | 10 | 24M | 1 — `core-js-pure` |

Not zero on either row. The question is not whether you trust anybody; it is how
many strangers the answer covers.

### What an install is allowed to do

```
npm install                       it ran
  it ran, before any of your own code did
  environment variables it could read that look like credentials: 3
    GITHUB_TOKEN, PROVIDER_API_KEY, DATABASE_PASSWORD
  it also had the network, the file system, and your shell
npm install --ignore-scripts      it did not run
```

Nothing imported that file. It ran because installing is an action, not a
download — and `bcrypt` and `sharp` genuinely need their scripts, which is why
the flag is not free.

### Whether the name is free

```
expresssession            404         nobody owns this name
@express/session          404         nobody owns this name
bcrypt-js                 404         nobody owns this name
```

3 of the 8 names checked are unregistered. **These names are constructed by hand
in `registry.sh`, from shapes that get confused with real ones. They are not
harvested from a model's output and this lab does not claim they were.**

## The pieces

| file | what it does |
| --- | --- |
| `count.sh` | installs both versions and counts from the lockfile |
| `install-scripts.sh` | runs a package whose only content is an install hook |
| `evil-package/` | that package — it writes a note, nothing else |
| `registry.sh` | asks the live registry which plausible names are free |
