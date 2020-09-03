resource "local_file" "hello" {
  content  = "Hello, Terraform"
  filename = "hello.txt"
}
