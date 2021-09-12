
# Manage multiple Azure subscriptions

# Get a list of all subscriptions in your account.
Get-AzSubscription

# Step 2,
Select-AzSubscription -Subscription "hslin - Microsoft Azure Internal Consumption"
Select-AzSubscription -Subscription "Microsoft Azure Internal Consumption"


# Step 3, Verify the change by running
Get-AzContext
