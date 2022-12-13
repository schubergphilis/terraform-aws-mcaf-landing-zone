# Updating

To update the `all_enforced_services` local variable, copy all services from the [services and resource types that support enforcement](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_supported-resources-enforcement.html) page into a file called `all-services-page.txt` and run the following:

```shell
grep '^\"' all-services-page.txt | awk -F':' '{ print $1":*\"\," }' | sort -n | uniq
```
