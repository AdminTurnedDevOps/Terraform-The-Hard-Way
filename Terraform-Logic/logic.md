## For Expressions/Loops

Different types of loops:
- `count`
- `for` expressions
- `for_each` meta argument

### For
For loops have a core functionality to transform type values. The expression after the `in` keyword can either be of type `list`, `map`, or it can be a `set` or an object.

The syntax isn't what you'd expect if you're used to general-purpose programming languages, but just think of anything after `:` as what's in your curly brackets (the actual logic and what's happening in the code)

```
list = ["test1", "test2", "test3"]

[for s in var.list : upper(s)]
```

You can also add `for` loops as `blocks`.
```
variable "users" {
  type = map(object({
    is_admin = boolean
  }))
}

locals {
  admin_users = {
    for name, user in var.users : name => user
    if user.is_admin
  }
  regular_users = {
    for name, user in var.users : name => user
    if !user.is_admin
  }
}
```

### For-Each
`for_each` feels a little bit more "human-readable" when it comes to looping.

Notice how to call the key and value in a `for_each` block; by using the `each` keyword.

```
resource "azurerm_resource_group" "rg" {
  for_each = {
    a_group = "eastus"
    another_group = "westus2"
  }
  name     = each.key
  location = each.value
}
```


## Conditionals/if statements

If you're used to programming with a general-purpose programming language, you'll probably notice how `if` statements in Terraform aren't exactly comparable. The logic is definitely there, but it's relatively watered down if you're used to `if/elif/else`

The logic is `CONDITION ? TRUEVAL : FALSEVAL`

The "desired/true" value is on the left and the "undesired/false" value is on the right.

```
${var.create_elastic_ip_address == true ? 1 : 0}
```