# terraform-playbook

# printing sample plan
terraform plan  -out=sample.plan

# Show sample plan 
terraform show sample.plan

#  terraform [global options] state <subcommand> [options] [args]
terraform state show aws_s3_bucket.tf_s3

# terraform graph

# use https://dreampuf.github.io/GraphvizOnline