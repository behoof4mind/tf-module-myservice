# Terraform module for myservice app
This module can be used to prepare EC2 instances with Amazon RDS. Was developed as test exercise for [**Myservice**](https://github.com/behoof4mind/myservice)

## How to use
#### Add environment variables
Bash example:
```shell
AWS_DEFAULT_REGION="<YOUR APP REGION>"
AWS_ACCESS_KEY_ID="<YOUR AWS_ACCESS_KEY_ID>"
AWS_SECRET_ACCESS_KEY="<YOUR AWS_SECRET_ACCESS_KEY>"
```
Fish example:
```shell
set -Ux AWS_DEFAULT_REGION <YOUR APP REGION>
set -Ux AWS_ACCESS_KEY_ID <YOUR AWS_ACCESS_KEY_ID>
set -Ux AWS_SECRET_ACCESS_KEY <YOUR AWS_SECRET_ACCESS_KEY>
```

## Contributing

Thanks for considering contributing! There’s information about how to [get started with Myservice module here](CONTRIBUTING.md).

## License

[The MIT License (MIT)](LICENSE.md)

Copyright © 2021 [Denis Lavrushko](https://dlavrushko.de)