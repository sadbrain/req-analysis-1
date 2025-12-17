data "aws_iam_policy_document" "nat_instance_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "nat_instance_role" {
  name               = "${var.project}-${var.env}-nat-instance-role"
  assume_role_policy = data.aws_iam_policy_document.nat_instance_assume.json
}

resource "aws_iam_role_policy_attachment" "nat_instance_ssm" {
  role       = aws_iam_role.nat_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "nat_instance_profile" {
  name = "${var.project}-${var.env}-nat-instance-profile"
  role = aws_iam_role.nat_instance_role.name
}
