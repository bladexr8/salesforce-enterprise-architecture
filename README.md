# Salesforce DX Project: Next Steps

Now that you’ve created a Salesforce DX project, what’s next? Here are some documentation resources to get you started.

## How Do You Plan to Deploy Your Changes?

Do you want to deploy a set of changes, or create a self-contained application? Choose a [development model](https://developer.salesforce.com/tools/vscode/en/user-guide/development-models).

## Configure Your Salesforce DX Project

The `sfdx-project.json` file contains useful configuration information for your project. See [Salesforce DX Project Configuration](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm) in the _Salesforce DX Developer Guide_ for details about this file.

## Read All About It

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)

## Project Commands
Create a scratch org valid for 30 days
```
sf org create scratch --definition-file config/project-scratch-def.json --alias F1AppScratchOrg --set-default --target-dev-hub myDevHub --duration-days 30
```

Open Scratch Org
```
sf org open --target-org F1AppScratchOrg
```

Preview Remote Changes in Scratch Org
```
sf project retrieve preview --target-org F1AppScratchOrg
```

Retrieve Remote Changes from Scratch Org
```
sf project retrieve start --target-org F1AppScratchOrg
```

Preview Remote Deployment to Scratch Org
```
sf project deploy preview --target-org F1AppScratchOrg
```

Deploy to Remote Scratch Org
```
sf project deploy start --target-org F1AppScratchOrg
```

Validate against a Salesforce Org (run from project home directory, only deploy fflib libraries once to org)
```
sf project deploy validate --source-dir source/fflib-apex-mocks --target-org <org-alias>
sf project deploy validate --source-dir source/fflib-apex-common --target-org <org-alias>
sf project deploy validate --source-dir source/formulaforce --target-org <org-alias>
```

Deploy to a Salesforce Org (run from project home directory, only deploy fflib libraries once to org)
```
sf project deploy start --source-dir source/fflib-apex-mocks --target-org <org-alias>
sf project deploy start --source-dir source/fflib-apex-common --target-org <org-alias>
```


Assign Race Management Permission Set
```
sf org assign permset --name FormulaForceRaceManagement --target-org F1AppScratchOrg
```

Load 2023 Season Test Data (run from Project Home Folder)
```
sf apex run --file ./scripts/apex/loadSeasonData.apex
```

Load Race Overview LWC Test Data (run from Project Home Folder)
```
sf apex run --file ./scripts/apex/loadRaceOverviewData.apex
```


