## Loops

A `for` loop creates a type value by transforming another type value. The verbiage is pretty much like:

"for `this thing` in `that thing` do something with the data

Example:
```
output "instances_by_availability_zone" {
  value = {
    for instance in aws_instance.example:
    instance.availability_zone => instance.id
  }
}
```

## Operators
Operators in Terraform are anything from "add these two values together" to "greater than, less than, or equal to". When thinking about operators, think mathematical operators.

Arithmetic operators in Terraform expect number values and in-turn ensures that the result is a number value

- a + b returns the result of adding a and b together.
- a - b returns the result of subtracting b from a.
- a * b returns the result of multiplying a and b.
- a / b returns the result of dividing a by b.
- a % b returns the remainder of dividing a by b. This operator is generally useful only when used with whole numbers.
- -a returns the result of multiplying a by -1.

The equality operators take two values of any type and produce boolean values as results.

- a == b returns true if a and b both have the same type and the same value, or false otherwise.
- a != b is the opposite of a == b.

The comparison operators expect number values and produce boolean values as results.

- a < b returns true if a is less than b, or false otherwise.
- a <= b returns true if a is less than or equal to b, or false otherwise.
- a > b returns true if a is greater than b, or false otherwise.
- a >= b returns true if a is greater than or equal to b, or false otherwise.

The logical operators expect bool values and produce bool values as results.

a || b returns true if either a or b is true, or false if both are false.
a && b returns true if both a and b are true, or false if either one is false.
!a returns true if a is false, and false if a is true.

## More Information
For more info, check out the following links:
- https://www.terraform.io/docs/language/expressions/operators.html
- https://www.terraform.io/docs/language/expressions/for.html
- https://www.terraform.io/docs/language/expressions/types.html
- https://www.hashicorp.com/blog/hashicorp-terraform-0-12-preview-for-and-for-each