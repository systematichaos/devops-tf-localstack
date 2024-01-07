1. Execute `make up`, which will deploy the necessary pieces for the tasks
    * localstack
    * terraform

2. Execute `make conn`, this will enter the container `terraform`.

1. Execute `make list1`, which should return
```json
{
  "Functions": []
}
```

2. Update [lambda.tf](./app/lambda.tf)

3. Create/Update lambda resources, execute `make apply` for the change.

4. List lambda functions, `make list1` should return

Note: 
- Use `make plan` or `tflocal plan` to test the change.
- Use `make apply` or `tflocal apply --auto-approve` to apply the change.
- Use `make destroy` or `tflocal destroy` to remove the change.