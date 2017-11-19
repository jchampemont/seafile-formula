# seafile-formula
Formula for the Seafile personal cloud (https://www.seafile.com/).

See the full [Salt Formulas installation and usage instructions](http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html).

## Available states
### `seafile.install`
Installs the Seafile personal cloud.

Example pillar:

```
seafile:
  user: deploy
  path: /apps/seafile
  version: 6.2.3
  architecture: x86-64
  config:
    name: seafile
    domain: seafile.exemple.com
    admin: admin@seafile.exemple.com
    password: password
    mysql:
      server: localhost
      user: seafile
      password: password
```
