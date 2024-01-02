
## SNS - Topic
resource "aws_sns_topic" "my_sns_topic" {
  name = "${local.name}-${random_pet.this.id}"
}

# # SNS - Subscription
resource "aws_sns_topic_subscription" "my_sns_topic_subscription" {
  topic_arn = aws_sns_topic.my_sns_topic.arn
  protocol  = "email"
  endpoint  = "vaman1650@gmail.com"
}

