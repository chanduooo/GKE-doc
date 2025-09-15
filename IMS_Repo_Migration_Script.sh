#!/bin/bash
# Repo Name: Output file Name
# Inventory Export Service : InventoryexportserviceOutput.txt
# Vehicle Image Processor : VehicleImageProcessorOutput.txt
# enrollment-core-api : EnrollmentCoreApiOutput.txt
#inventory-routing-api : InventoryRoutingApiOutput.txt
#inventory-management-services : InventoryManagementServicesOutput.txt
#dealerinspire-dashboard : DealerInspireDashboardOutput.txt
#com.dealerinspire.api.vindecoder-domain : ComDealerinspireApiVindecoderDomainOutput.txt
#com.dealerinspire.api.inventory-domain : ComDealerinspireApiInventoryDomainOutput.txt
OUTPUT_FILE="C:\Users\naveena.chidara\Documents\CarsCommerce\MigrationBashScript\Output files\nventoryManagementServicesOutput.txt"

# Display current date and time
echo "Current date and time: $(date)" >> "$OUTPUT_FILE"
# Prompt for Bitbucket and GitHub repository URLs
read -rp "Enter the Bitbucket Repository URL: " BITBUCKET_REPO_URL
echo
read -rp "Enter the GitHub Repository URL: " GITHUB_REPO_URL
echo

# Validate that Bitbucket URL is not empty
if [ -z "$BITBUCKET_REPO_URL" ]; then
    echo "Error: Bitbucket repository URL is missing!"
    exit 1
fi

# Validate that GitHub URL is not empty
if [ -z "$GITHUB_REPO_URL" ]; then
    echo "Error: GitHub repository URL is missing!"
    exit 1
fi

# Extract the repository name from Bitbucket URL
REPO_NAME=$(basename "$BITBUCKET_REPO_URL" .git)

# Check if the directory already exists and remove it if necessary

if [ -d "$REPO_NAME" ]; then
    echo "Directory $REPO_NAME already exists, removing it."
    rm -rf "$REPO_NAME"
fi

# Clone the Bitbucket repository
echo "Cloning Bitbucket repository from $BITBUCKET_REPO_URL..."
git clone --config core.protectNTFS=false "$BITBUCKET_REPO_URL"

# Check if the repository directory was created successfully
if [ ! -d "$REPO_NAME" ]; then
    echo "Error: Repository directory $REPO_NAME does not exist!"
    exit 1
fi

# Navigate into the cloned repository
cd "$REPO_NAME" || exit
echo
# List the branches and gather details for Bitbucket repository
echo ".............Listing branches and repository details for Bitbucket................" >> "$OUTPUT_FILE"
BITBUCKET_BRANCHES=$(git branch -r | grep -v '\->')

# Display the number of branches in the Bitbucket repository
BITBUCKET_BRANCH_COUNT=$(echo "$BITBUCKET_BRANCHES" | wc -l)
echo "Total number of branches in Bitbucket repository: $BITBUCKET_BRANCH_COUNT" >> "$OUTPUT_FILE"
echo
# Process each branch from Bitbucket repository
for branch in $BITBUCKET_BRANCHES; do
    branch_name=$(echo "$branch" | sed 's/origin\///')
     # Normalize line endings
    git config core.autocrlf false
    git config core.eol lf

    # Reset + forcefully discard changes (tracked files)
    git reset --hard HEAD >> "$OUTPUT_FILE" 2>&1
    git checkout -- . >> "$OUTPUT_FILE" 2>&1

    # Clean untracked and ignored files
    git clean -fdx >> "$OUTPUT_FILE" 2>&1

    # Finally, force checkout the branch
    git checkout -f "$branch_name" >> "$OUTPUT_FILE" 2>&1
    

    # Count commits, files, and tags in the current branch
    BITBUCKET_COMMIT_COUNT=$(git rev-list --count HEAD)
    BITBUCKET_FILE_COUNT=$(git ls-tree -r HEAD --name-only | wc -l)
    BITBUCKET_TAG_COUNT=$(git tag -l | wc -l)

    echo "Branch: $branch_name" >> "$OUTPUT_FILE"
    echo "  Commit Count: $BITBUCKET_COMMIT_COUNT" >> "$OUTPUT_FILE"
    echo "  File Count: $BITBUCKET_FILE_COUNT" >> "$OUTPUT_FILE"
    echo "  Tag Count: $BITBUCKET_TAG_COUNT" >> "$OUTPUT_FILE"
    echo "--------------------------------------------" >> "$OUTPUT_FILE"
done

# Add GitHub repository as a remote
echo "Adding GitHub repository as a remote..."
git remote add github "$GITHUB_REPO_URL"

# Push all branches, tags, and commit history to GitHub
echo "Pushing all branches, tags, and commit history to GitHub..."
git push --mirror github

cd ..
rm -rf "${REPO_NAME}"

# Clone the GitHub repository to verify the migration
GITHUB_REPO_NAME=$(basename "$GITHUB_REPO_URL" .git)
if [ -d "$GITHUB_REPO_NAME" ]; then
    echo "Directory $GITHUB_REPO_NAME already exists, removing it."
    rm -rf "$GITHUB_REPO_NAME"
fi

git clone --config core.protectNTFS=false "$GITHUB_REPO_URL"
cd "$GITHUB_REPO_NAME" || exit
echo
# List branches and gather details for GitHub repository
echo "..............Listing branches and repository details for GitHub................" >> "$OUTPUT_FILE"
GITHUB_BRANCHES=$(git branch -r | grep -v '\->')

# Display the number of branches in the GitHub repository
GITHUB_BRANCH_COUNT=$(echo "$GITHUB_BRANCHES" | wc -l)
echo "Total number of branches in GitHub repository: $GITHUB_BRANCH_COUNT" >> "$OUTPUT_FILE"
echo
# Process each branch from GitHub repository
for branch in $GITHUB_BRANCHES; do
    branch_name=$(echo "$branch" | sed 's/origin\///')
     # Normalize line endings
    git config core.autocrlf false
    git config core.eol lf

    # Reset + forcefully discard changes (tracked files)
    git reset --hard HEAD >> "$OUTPUT_FILE" 2>&1
    git checkout -- . >> "$OUTPUT_FILE" 2>&1

    # Clean untracked and ignored files
    git clean -fdx >> "$OUTPUT_FILE" 2>&1

    # Finally, force checkout the branch
    git checkout -f "$branch_name" >> "$OUTPUT_FILE" 2>&1


    # Count commits, files, and tags in the current branch
    GITHUB_COMMIT_COUNT=$(git rev-list --count HEAD)
    GITHUB_FILE_COUNT=$(git ls-tree -r HEAD --name-only | wc -l)
    GITHUB_TAG_COUNT=$(git tag -l | wc -l)

    echo "Branch: $branch_name"  >> "$OUTPUT_FILE"
    echo "  Commit Count: $GITHUB_COMMIT_COUNT" >> "$OUTPUT_FILE"
    echo "  File Count: $GITHUB_FILE_COUNT" >> "$OUTPUT_FILE"
    echo "  Tag Count: $GITHUB_TAG_COUNT" >> "$OUTPUT_FILE"
    echo "--------------------------------------------" >> "$OUTPUT_FILE"
done

# Migration complete message
echo "Migration complete! All branches, tags, and commit history have been transferred to GitHub." >> "$OUTPUT_FILE"

# Clean up: Remove the local repositories
cd ..
rm -rf "${GITHUB_REPO_NAME}"