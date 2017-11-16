# seafile-formula
Formula for the Seafile personal cloud (https://www.seafile.com/).

## Available states
### `seafile.install`
Installs the Seafile personal cloud.

Example pillar:

```
ghost:
  install_user: deploy
  path: /apps/ghost
  url: https://blog.example.com
  port: 2368
  listen_addr: 0.0.0.0
  db: mysql # or sqlite3
  mysql:
    host: localhost
    user: ghost
    pass: password
    database: ghost
  sqlite: /apps/ghost.db
  themes:
    - name: myblog
      git_repository: https://github.com/jchampemont/myblog-ghost-theme.git
```
