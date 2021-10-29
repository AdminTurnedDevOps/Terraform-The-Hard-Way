## Modules In Terraform

A module is simply a directory with Terraform code in it. 

By definition, they are containers (a directory) for multiple resources (terraform files like `terraform.tf`) that are used together.

A module consists of a collection of Terraform files, as shown in the screenshot below.

![](images/module_dir.jpg)

The "module" in the screenshot is the directory called **sample-module**.

## Root Module
All Terraform configurations for any environment have at least one module. If you have a GitHub repo and you put Terraform configuration files inside of it, that's a module. If you have a repo that has multiple directories in it that contain Terraform configuration files, you have a repo full of modules.

## Child Modules
A child module is a module being called by another module.

For example, let's say that the root module is the **sample-module**

![](images/module_dir.jpg)

Then, there's another module called **s3-bucket**

![](images/s3-module.jpg)

If the `terraform.tf` file inside of the **sample-module** module called upon (use Terraform resources from) the **s3-bucket** module, that means that the **s3-bucket** module is the child module

## Another Module Reference

If you're familar with Python or another programming language, you have `imports`. The `imports` are how you use other SDKs, frameworks, etc. AKA other peoples code to enhance your code and have more options available.

When you do an `import` of a SDK or module, you're importing a module. It's the same concept as when a Terraform root module calls upon resources in a child module. The root module is *importing* the resources from the child module.



To learn more about modules, check out week 2 of my Terraform For all course on YouTube where we talk about modules and why they're used. You can find it ![here](https://www.youtube.com/watch?v=PR3RnimYd2k&t=1s)