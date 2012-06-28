# Installation

The script deploy.sh at the root of the repository takes care of the nginx/passenger/mysql/rails deployment.

```
wget -O - --no-check-certificate https://raw.github.com/sx4it/4am-ui/v2/deploy.sh | bash deploy.sh --db-install --db-engine mysql
```

