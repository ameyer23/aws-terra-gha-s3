# aws-terra-gha-s3

# Terraform AWS Infrastructure Setup and GitHub Actions Integration

## Summary of Steps

1. **Create Repo and Clone to Local Machine**  
   Created a new repository and cloned it locally for development.

2. **Add AWS Access Keys as GitHub Secrets**  
   - Navigated to **Settings > Secrets > Actions** in the GitHub repo.  
   - Created two repository secrets:  
     - `AWS_ACCESS_KEY_ID` with the AWS access key value.  
     - `AWS_SECRET_ACCESS_KEY` with the AWS secret key value.  
   This allows GitHub Actions (GHA) to interact with AWS securely.

3. **Build Infrastructure with Terraform Locally**  
   - Created a `src` folder to contain Terraform template code.  
   - Inside `src`, created `main.tf` file with AWS provider setup:
     ```hcl
     terraform {
       required_version = ">=0.13.0"
       required_providers {
         aws = {
           source  = "hashicorp/aws"
           version = "~>3.0"
         }
       }
     }

     provider "aws" {
       region = "us-east-1"
     }
     ```

4. **Create Modules for Terraform State Management**  
   - Inside `src`, created `modules/tfstate` folder.  
   - In `modules/tfstate`, created:  
     - `main.tf` with Terraform provider setup (same as above).  
     - `tfstate.tf` defining S3 bucket, versioning, encryption, and DynamoDB table for state locking:  
       - S3 bucket resource with versioning and AES256 encryption.  
       - DynamoDB table `terraform-state-locking` for Terraform state lock management.  
     - `variables.tf` for bucket name and related variables.

5. **Add Terraform Module in `src/main.tf`**  
   - Added the `tfstate` module reference in `src/main.tf`.

6. **Run Terraform Locally**  
   - Initialized, validated, and applied infrastructure with:  
     ```bash
     terraform init
     terraform validate
     terraform apply
     ```
   - Encountered a naming conflict with the S3 bucket.  
   - Resolved by using Terraform random resources to create unique bucket names.  
   - When configuring the remote backend, variables were not allowed, so the bucket name was hardcoded with a unique value.

7. **Configure Remote Backend**  
   - Added an S3 backend block to `src/main.tf` to use the remote state bucket.  
   - Ran `terraform init` again to reconfigure the backend.

8. **Push Code to GitHub Main Branch**  
   - Initial push failed due to large files (Terraform providers, etc.).  
   - Fixed by adding `.terraform/` and state files to `.gitignore` to exclude them from Git.

9. **Work From Main Branch Only**  
   - All work was done on the `main` branch without additional branches.

10. **Create VPC Infrastructure Module**  
    - Inside `modules` folder, created `vpc` folder with:  
      - `main.tf`  
      - `variables.tf`  
      - `outputs.tf`  
      - `vpc.tf` files defining VPC resources.

11. **Reference VPC Module in `src`**  
    - Created a `locals.tf` file in `src` to define local variables for referring to the VPC module outputs.

12. **Initialize VPC Module**  
    - Ran `terraform init` in `src` to initialize new module.

13. **Set Up GitHub Actions (GHA) for Terraform Automation**  
    - Created `.github/workflows` folder at the root of the repo.  
    - Added `terraform.yml` workflow file for GHA to run Terraform commands automatically.

14. **Push Workflow to GitHub**  
    - Ran:  
      ```bash
      git add -A
      git commit -m "Add Terraform workflow"
      git push
      ```
    - Checked the **Actions** tab on GitHub.

15. **Fix Terraform Format Error in GHA**  
    - The initial GHA run failed due to code formatting.  
    - Fixed locally by running:  
      ```terraform fmt
      ```  
    - Committed and pushed the formatted code again.

---

## Notes

- Remote backend configuration requires the S3 bucket to exist before initializing Terraform state.  
- Variables cannot be used in the backend block; bucket names must be hardcoded or templated before backend initialization.  
- `.gitignore` should exclude `.terraform/`, `.tfstate` files, and provider binaries to avoid large file errors.  
- Using GitHub Actions with AWS requires storing AWS credentials securely as repository secrets and using `aws-actions/configure-aws-credentials` in workflows.

---

*This document summarizes the full setup of Terraform AWS infrastructure, remote state management, and CI/CD integration with GitHub Actions.*
