resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = "${var.name}-vpc"
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.name}-igw"
  })
}

locals {
  public = {
    for i, cidr in var.public_subnet_cidrs :
    "public-${i}" => {
      cidr = cidr
      az   = var.azs[i]
      name = "${var.name}-public-${var.azs[i]}"
    }
  }

  private = {
    for i, cidr in var.private_subnet_cidrs :
    "private-${i}" => {
      cidr = cidr
      az   = var.azs[floor(i / 2)]
      slot = (i % 2) + 1
      name = "${var.name}-private-${var.azs[floor(i / 2)]}-${(i % 2) + 1}"
    }
  }

  private_per_az = length(var.private_subnet_cidrs) / length(var.azs)
}

resource "aws_subnet" "public" {
  for_each = local.public

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = each.value.name
    Tier = "public"
  })
}

resource "aws_subnet" "private" {
  for_each = local.private

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(var.tags, {
    Name = each.value.name
    Tier = "private"
    Slot = tostring(each.value.slot)
  })
}

# Route tables (simple baseline: public has IGW route; private has no default route)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.name}-rt-public"
  })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.name}-rt-private"
  })
}

resource "aws_route_table_association" "private" {
 for_each = aws_subnet.private

  subnet_id = each.value.id

  route_table_id = (
    tonumber(regex("\\d+$", each.key)) % 2 == 0
    ? aws_route_table.private_app[floor(tonumber(regex("\\d+$", each.key)) / local.private_per_az)].id
    : aws_route_table.private_db.id
  )
}

resource "aws_route_table" "private_app" {
  count  = length(var.azs)
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.name}-rt-private-app-${count.index}"
  })
}

resource "aws_route_table" "private_db" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.name}-rt-private-db"
  })
}