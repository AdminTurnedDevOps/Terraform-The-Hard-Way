## Free Terraform Training

If you'd prefer to learn a few of the basics via YouTube, check out the following link:

[Terraform Basics](https://www.youtube.com/watch?v=wybFGCultsk&list=PL8iDDHqmj1oW_JYcEfM21XI0cFnp5b9dP&index=1)

## What Is Terraform?
Terraform is an open-source infrastructure as code software tool created by HashiCorp. Users define and provide data center infrastructure using a declarative configuration language known as HashiCorp Configuration Language (HCL), or optionally

## What Is HCL?

This low-level syntax of the Terraform language is defined in terms of a syntax called HCL, which is also used by configuration languages in other applications, and in particular other HashiCorp products. HCL was created to be human-readable and easier to work with instead of using JSON or YAML. HCL is a functional-based programming language

## Terraform Developer Concepts
- Immutable: Cannot be changed after a resource is created. Instead, it gets replaced/re-created.
- Mutable: Can be changed after a resource is created

## Terraform Terminology

### Programmatic Terminology
- Provider: Providers interact with sources (AWS, Azure, Cloudflare, etc.) at the programmatic level via API calls.
- Module: A folder that contains all of the Terraform resources that you're utilizing. For example, if you have a directory called *s3-bucket* and inside of it is a Terraform resource to create an S3 bucket, that would be a **Module**
- State: The `tfstate` is cached metadata about the configurations that are created/replaced/updated/delete in a Terraform module.
- Data Source: Return information on resources. For example, to return the metadata of an S3 bucket.
- Output Values: Values returned after creating resources via Terraform that can be used for other configurations or just as information.
 - Backend: Defines where and how operations are performed, where state snapshots are stored, etc.
 - Remote State: Store the state in a remote location (S3 bucket for example).

### Creating/Replacing/Updating/Deleted Terraform Resources
- Init: Initialize a Terraform module to be ready to create/replace/update/delete resources. `init` also downloads the Provider and stores it in the Terraform module.
- Plan: Determines what needs to be created/replaced/updated/deleted to move to the desired state.
- Apply: Creates/replaces/updates/deletes the resources via Terraform
- Destroy: Deletes the resources in the Terraform module
- Resources: A block of code to create/replace/update/delete services, servers, etc.. For example, an S3 bucket.
