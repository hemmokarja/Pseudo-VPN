# Pseudo-VPN

## Overview

Pseudo-VPN is a simple VPN-like tool that allows you to browse the internet as if you were in another part of the world. It lets you bypass regional restrictions and access content that may not be available in your current location. By setting up a remote server in AWS and routing your internet traffic through it using Firefox, it gives you a new virtual location in any desired region.

## What You'll Need

Before getting started, make sure you have the following:

- **MacOS or Linux** operating system
- **Firefox** browser installed
- **Terraform** installed (follow the [official installation guide](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli))
- An **AWS account**
- **AWS CLI** installed (follow the [official installation guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html))
- Your **AWS Access Keys** (i.e., `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`) set up as environment variables

## Configure Firefox

1. Open **Settings** in Firefox.
2. Scroll down to the **General** tab and find **Network Settings**.
3. In the **SOCKS Host** field, enter `localhost`.
4. In the **Port** field, enter `8080`.
5. Ensure **SOCKS v5** is selected.
6. Click **OK** to save your settings.

## How to Use

### Prerequisites

Make sure you've configured Firefox as described above.

### Build Resources

- Run `build.sh` to create the necessary resources on AWS. When you run the script, you'll be propmted to select one of the available AWS regions (with `us-east-1` as default). The selected region will determine your new virtual location.
- This script also generates the SSH keys required for connecting to the EC2 instance. The keys will be saved to `.config/.ssh/` in the current directory.

### Browse the Internet

- Run `tunnel.sh` to open an SSH tunnel to your AWS instance. Keep the terminal open while you're browsing. You're ready to browse!
- Open Firefox and go to, e.g., [IPinfo](https://ipinfo.io) to verify your virtual location.

### Closing Down

- The SSH tunnel will close when you close the terminal or interrupt it with `Ctrl+C`.
- Run `destroy.sh` to remove all resources from AWS.

## Costs

Running the remote server incurs a marginal cost, which varies based on the region and is subject to change over time. As of September 14, 2024, the cost for a default EC2 `t3.micro` instance in the `us-east-1` region is $0.0104 per hour. Be sure to check the [latest AWS pricing](https://aws.amazon.com/ec2/pricing/on-demand/) for the most up-to-date information.

## Technical Details

- **Infrastructure**: The project uses Terraform to manage AWS resources. It deploys an EC2 instance in your chosen AWS region. By default, a `t3.micro` instance is used, but this can be adjusted if needed in the `variables.tf` file.
- **SSH Tunnel**: Traffic from your local port `8080` is routed through the EC2 instance using SSH tunneling with a SOCKS proxy.
- **Scripts**:
  - `build.sh`: Initializes the AWS resources and generates the SSH keys needed for connection.
  - `tunnel.sh`: Opens the SSH tunnel.
  - `destroy.sh`: Cleans up the resources after use.

## License

This project is licensed under the [MIT License](https://opensource.org/licenses/MIT). You are free to use, modify, and distribute the software as long as you include the original copyright and license notice. For more details, please refer to the full text of the license.
